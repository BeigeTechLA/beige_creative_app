import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/mocks.dart';
import 'robots/auth_robot.dart';

/// First Phase 6 integration test.
///
/// Drives the **real** LoginScreen + LoginNotifier + session store + Riverpod
/// auth state + GoRouter across a login → home → logout → login loop. The Dio
/// layer is stubbed (canned `auth/login` response); SharedPreferences is the
/// `setMockInitialValues({})` in-memory backing. Everything else is real —
/// `AuthState` flips, `CompositeSessionStore` round-trip, `TelemetryClient`
/// stub, GoRouter `refreshListenable` redirect.
///
/// Run locally with:
///   `flutter test integration_test/login_logout_test.dart -d macos`
///
/// On-device promotion: swap the binding to
/// `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` and run with
/// a device id (`flutter test -d <id> integration_test/login_logout_test.dart`).

class _StubTelemetry implements TelemetryClient {
  int clearIdentityCalls = 0;
  bool lastEmitLogoutEvent = false;

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {}

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {
    clearIdentityCalls++;
    lastEmitLogoutEvent = emitLogoutEvent;
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

/// Minimal harness app: a real `GoRouter` with two routes (`/login`, `/home`)
/// + auth-driven redirect mirroring production. `refreshListenable` flips on
/// every `authStateProvider` mutation so the router re-evaluates.
class _HarnessApp extends ConsumerStatefulWidget {
  const _HarnessApp();

  @override
  ConsumerState<_HarnessApp> createState() => _HarnessAppState();
}

class _HarnessAppState extends ConsumerState<_HarnessApp> {
  late final _AuthRefreshNotifier _refresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _refresh = _AuthRefreshNotifier(ref);
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _refresh,
      redirect: (context, state) {
        final isAuth = ref.read(authStateProvider);
        final loc = state.matchedLocation;
        if (!isAuth && loc != '/login') return '/login';
        if (isAuth && loc == '/login') return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: Routes.login.name,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          name: Routes.home.name,
          builder: (_, _) => const _HomeStub(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _sub = _ref.listenManual<bool>(
      authStateProvider,
      (_, _) => notifyListeners(),
    );
  }
  final WidgetRef _ref;
  late final ProviderSubscription<bool> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

class _HomeStub extends ConsumerWidget {
  const _HomeStub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('home-stub'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(authStateProvider.notifier).logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  // Vm-mode binding. Swap to `IntegrationTestWidgetsFlutterBinding` for
  // on-device promotion.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Env.init(Environment.dev);
    registerHelperFallbacks();
    CrashlyticsBreadcrumbs.setCustomKey = (_, _) async {};
    CrashlyticsBreadcrumbs.log = (_) async {};
  });

  tearDownAll(CrashlyticsBreadcrumbs.resetForTesting);

  testWidgets(
    'login → home → logout returns to login (real Notifier + router + session)',
    (tester) async {
      // ── Arrange ──
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final dio = MockDio();
      final dioClient = MockDioClient();
      when(() => dioClient.dio).thenReturn(dio);
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/login'),
          data: {
            'error': false,
            'message': 'ok',
            'data': {
              'token': 'integration-jwt',
              'crew_member': {
                'id': 7,
                'email': 'crew@example.com',
                'first_name': 'Crew',
                'last_name': 'Member',
              },
              'user': {
                'id': 7,
                'email': 'crew@example.com',
                'name': 'Crew Member',
              },
            },
          },
          statusCode: 200,
        ),
      );

      final session = CompositeSessionStore(
        secure: FakeSecureSessionBackend(),
        prefs: FakePrefsSessionBackend(),
      );
      final telemetry = _StubTelemetry();

      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          dioClientProvider.overrideWithValue(dioClient),
          sessionStoreProvider.overrideWithValue(session),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _HarnessApp(),
        ),
      );
      tester.takeException();
      await tester.pump();

      // ── Act + Assert: login flow ──
      final robot = AuthRobot(tester);
      await robot.expectOnLoginScreen();
      await robot.enterEmail('crew@example.com');
      await robot.enterPassword('hunter2');
      await robot.tapLogin();

      // Session round-trip via real CompositeSessionStore.
      expect(await session.readToken(), 'integration-jwt');
      expect(await session.isLoggedIn(), isTrue);
      expect(container.read(authStateProvider), isTrue);
      await robot.expectOnHome();

      // Verify Dio captured the right path + body.
      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, 'auth/login');
      expect(captured.last, {
        'email': 'crew@example.com',
        'password': 'hunter2',
      });

      // ── Act + Assert: logout flow ──
      await robot.tapLogout();

      expect(container.read(authStateProvider), isFalse);
      expect(await session.readToken(), isNull);
      expect(await session.isLoggedIn(), isFalse);
      expect(telemetry.clearIdentityCalls, 1);
      expect(telemetry.lastEmitLogoutEvent, isTrue);
      await robot.expectOnLoginScreen();
    },
  );
}
