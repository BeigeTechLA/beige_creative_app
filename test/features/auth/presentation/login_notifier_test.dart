import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';
import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/login_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/login_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepo implements AuthRepository {
  String? capturedEmail;
  String? capturedPassword;
  LoginResult? result;
  Object? throwError;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    capturedEmail = email;
    capturedPassword = password;
    final err = throwError;
    if (err != null) throw err;
    return result ??
        const LoginResult(token: 'tok-123', user: null);
  }

  @override
  Future<void> requestPasswordReset(String email) async {}
  @override
  Future<void> verifyResetOtp({required String email, required String otp}) async {}
  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {}
  @override
  Future<int> registerStep1(Step1Payload payload) async => 0;
  @override
  Future<void> registerStep2(Step2Payload payload) async {}
  @override
  Future<void> registerStep3(Step3Payload payload) async {}
  @override
  Future<List<LookupOption>> fetchRoles() async => const [];
  @override
  Future<List<LookupOption>> fetchSkills() async => const [];
  @override
  Future<List<LookupOption>> searchEquipments(String query) async => const [];
}

class _FakeSession implements SessionStore {
  String? writtenToken;
  UserSnapshot? writtenUser;
  DateTime? writtenLoginAt;

  @override
  Future<void> writeToken(String token) async {
    writtenToken = token;
  }

  @override
  Future<void> writeUser(UserSnapshot user) async {
    writtenUser = user;
  }

  @override
  Future<void> writeLastLoginAt(DateTime when) async {
    writtenLoginAt = when;
  }

  // Unused — throw-style not needed since notifier never touches these.
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> clearToken() async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clearRefreshToken() async {}
  @override
  Future<UserSnapshot?> readUser() async => null;
  @override
  Future<void> clearUser() async {}
  @override
  Future<DateTime?> readLastLoginAt() async => null;
  @override
  Future<bool> readOnboardingSeen() async => false;
  @override
  Future<void> writeOnboardingSeen(bool seen) async {}
  @override
  Future<bool> isLoggedIn() async => writtenToken != null;
  @override
  Future<void> clearSession() async {}
}

class _FakeTelemetry implements TelemetryClient {
  int setIdentityCalls = 0;
  int clearIdentityCalls = 0;
  bool lastEmitLogoutEvent = false;
  String? lastUserId;
  String? lastUserRole;
  String? lastLoginMethod;
  final List<({String name, Map<String, Object>? parameters})> events =
      <({String name, Map<String, Object>? parameters})>[];
  final List<Object> recordedErrors = <Object>[];

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {
    setIdentityCalls++;
    lastUserId = userId;
    lastUserRole = userRole;
    lastLoginMethod = loginMethod;
  }

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {
    clearIdentityCalls++;
    lastEmitLogoutEvent = emitLogoutEvent;
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    recordedErrors.add(error);
  }
}

ProviderContainer _container({
  required _FakeAuthRepo repo,
  required _FakeSession session,
  _FakeTelemetry? telemetry,
}) {
  final c = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      sessionStoreProvider.overrideWithValue(session),
      telemetryClientProvider.overrideWithValue(telemetry ?? _FakeTelemetry()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('LoginNotifier.login validation', () {
    test('rejects empty email', () async {
      final c = _container(repo: _FakeAuthRepo(), session: _FakeSession());
      await c
          .read(loginNotifierProvider.notifier)
          .login(email: '   ', password: 'pw');
      expect(
        c.read(loginNotifierProvider).errorMessage,
        'Please enter your email address',
      );
    });

    test('rejects malformed email', () async {
      final c = _container(repo: _FakeAuthRepo(), session: _FakeSession());
      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'not-an-email', password: 'pw');
      expect(
        c.read(loginNotifierProvider).errorMessage,
        'Please enter a valid email address',
      );
    });

    test('rejects empty password', () async {
      final c = _container(repo: _FakeAuthRepo(), session: _FakeSession());
      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: '  ');
      expect(
        c.read(loginNotifierProvider).errorMessage,
        'Please enter your password',
      );
    });
  });

  group('LoginNotifier.login happy path', () {
    test('persists token + flips auth state on success', () async {
      final repo = _FakeAuthRepo()
        ..result = const LoginResult(
          token: 'tok-xyz',
          user: UserSnapshot(id: '42', email: 'user@example.com'),
        );
      final session = _FakeSession();
      final c = _container(repo: repo, session: session);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(repo.capturedEmail, 'user@example.com');
      expect(repo.capturedPassword, 'secret');
      expect(session.writtenToken, 'tok-xyz');
      expect(session.writtenUser?.id, '42');
      expect(session.writtenLoginAt, isNotNull);
      expect(c.read(authStateProvider), isTrue);
      final LoginState s = c.read(loginNotifierProvider);
      expect(s.loginSuccess, isTrue);
      expect(s.isLoggingIn, isFalse);
      expect(s.errorMessage, isNull);
    });

    test('repo error surfaces message and keeps auth off', () async {
      final repo = _FakeAuthRepo()
        ..throwError = Exception('Invalid email or password');
      final session = _FakeSession();
      final c = _container(repo: repo, session: session);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(session.writtenToken, isNull);
      expect(c.read(authStateProvider), isFalse);
      final s = c.read(loginNotifierProvider);
      expect(s.errorMessage, 'Invalid email or password');
      expect(s.loginSuccess, isFalse);
      expect(s.isLoggingIn, isFalse);
    });
  });

  group('LoginNotifier telemetry wiring', () {
    test('login success sets identity with backend user id + role', () async {
      final repo = _FakeAuthRepo()
        ..result = const LoginResult(
          token: 'tok-xyz',
          user: UserSnapshot(
            id: '42',
            email: 'user@example.com',
            role: 'photographer',
          ),
        );
      final session = _FakeSession();
      final telemetry = _FakeTelemetry();
      final c = _container(repo: repo, session: session, telemetry: telemetry);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(telemetry.setIdentityCalls, 1);
      expect(telemetry.clearIdentityCalls, 0);
      expect(telemetry.lastUserId, '42');
      expect(telemetry.lastUserRole, 'photographer');
      expect(telemetry.lastLoginMethod, 'password');
    });

    test('login success without user payload skips telemetry identity',
        () async {
      final repo = _FakeAuthRepo()
        ..result = const LoginResult(token: 'tok-only', user: null);
      final session = _FakeSession();
      final telemetry = _FakeTelemetry();
      final c = _container(repo: repo, session: session, telemetry: telemetry);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(telemetry.setIdentityCalls, 0);
      expect(c.read(loginNotifierProvider).loginSuccess, isTrue);
    });

    test('login failure does not touch telemetry', () async {
      final repo = _FakeAuthRepo()..throwError = Exception('nope');
      final session = _FakeSession();
      final telemetry = _FakeTelemetry();
      final c = _container(repo: repo, session: session, telemetry: telemetry);

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'user@example.com', password: 'secret');

      expect(telemetry.setIdentityCalls, 0);
      expect(telemetry.clearIdentityCalls, 0);
    });
  });

  group('LoginNotifier event emission (B1)', () {
    test('emits login_success exactly once on success', () async {
      final repo = _FakeAuthRepo()
        ..result = const LoginResult(
          token: 'tok',
          user: UserSnapshot(id: '7', email: 'u@example.com'),
        );
      final telemetry = _FakeTelemetry();
      final c = _container(
        repo: repo,
        session: _FakeSession(),
        telemetry: telemetry,
      );

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'u@example.com', password: 'pw');

      final names = telemetry.events.map((e) => e.name).toList();
      expect(names.where((n) => n == AnalyticsEvents.loginSuccess), hasLength(1));
      expect(
        names.where((n) => n == AnalyticsEvents.loginFailure),
        isEmpty,
      );
    });

    test('login_success not emitted on failure', () async {
      final repo = _FakeAuthRepo()..throwError = Exception('nope');
      final telemetry = _FakeTelemetry();
      final c = _container(
        repo: repo,
        session: _FakeSession(),
        telemetry: telemetry,
      );

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'u@example.com', password: 'pw');

      expect(
        telemetry.events.where((e) => e.name == AnalyticsEvents.loginSuccess),
        isEmpty,
      );
    });

    test('login_failure tags 401 as invalid_credentials', () async {
      final repo = _FakeAuthRepo()
        ..throwError = DioException(
          requestOptions: RequestOptions(path: '/login'),
          error: const UnauthorizedException(),
        );
      final telemetry = _FakeTelemetry();
      final c = _container(
        repo: repo,
        session: _FakeSession(),
        telemetry: telemetry,
      );

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'u@example.com', password: 'pw');

      final failures = telemetry.events
          .where((e) => e.name == AnalyticsEvents.loginFailure)
          .toList();
      expect(failures, hasLength(1));
      expect(failures.single.parameters, {'reason': 'invalid_credentials'});
    });

    test('login_failure tags NoInternetException as network', () async {
      final repo = _FakeAuthRepo()
        ..throwError = const NoInternetException();
      final telemetry = _FakeTelemetry();
      final c = _container(
        repo: repo,
        session: _FakeSession(),
        telemetry: telemetry,
      );

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'u@example.com', password: 'pw');

      final failures = telemetry.events
          .where((e) => e.name == AnalyticsEvents.loginFailure)
          .toList();
      expect(failures, hasLength(1));
      expect(failures.single.parameters, {'reason': 'network'});
    });

    test('login_failure tags ServerException as server', () async {
      final repo = _FakeAuthRepo()
        ..throwError = const ServerException(message: 'oops');
      final telemetry = _FakeTelemetry();
      final c = _container(
        repo: repo,
        session: _FakeSession(),
        telemetry: telemetry,
      );

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'u@example.com', password: 'pw');

      final failures = telemetry.events
          .where((e) => e.name == AnalyticsEvents.loginFailure)
          .toList();
      expect(failures, hasLength(1));
      expect(failures.single.parameters, {'reason': 'server'});
    });

    test('login_failure tags raw Exception (repo error:true branch) as server',
        () async {
      final repo = _FakeAuthRepo()..throwError = Exception('Login failed');
      final telemetry = _FakeTelemetry();
      final c = _container(
        repo: repo,
        session: _FakeSession(),
        telemetry: telemetry,
      );

      await c
          .read(loginNotifierProvider.notifier)
          .login(email: 'u@example.com', password: 'pw');

      final failures = telemetry.events
          .where((e) => e.name == AnalyticsEvents.loginFailure)
          .toList();
      expect(failures, hasLength(1));
      expect(failures.single.parameters, {'reason': 'server'});
    });
  });

  group('AuthStateNotifier.logout telemetry wiring', () {
    test('logout clears identity and emits logout event', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final telemetry = _FakeTelemetry();
      final c = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          sessionStoreProvider.overrideWithValue(_FakeSession()),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(c.dispose);

      // Seed authed state, then log out.
      c.read(authStateProvider.notifier).markLoggedIn();
      await c.read(authStateProvider.notifier).logout();

      expect(telemetry.clearIdentityCalls, 1);
      expect(telemetry.lastEmitLogoutEvent, isTrue);
      expect(c.read(authStateProvider), isFalse);
    });
  });
}
