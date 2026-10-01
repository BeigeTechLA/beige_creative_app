import 'dart:typed_data';
import 'dart:convert';

import 'package:beige_creative_app/app/router.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_status.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/restoration/draft_store.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/core/session/temporary_auth_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mocks.dart';

class _Telemetry extends Mock implements TelemetryClient {}

class _Adapter implements HttpClientAdapter {
  int status = 401;
  dynamic body = {
    'error': true,
    'code': 'SESSION_EXPIRED',
    'message': 'Your session has expired. Please log in again.',
  };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late CompositeSessionStore session;
  late SharedPreferences prefs;
  late _Telemetry telemetry;
  late Dio dio;
  late _Adapter adapter;
  const user = UserSnapshot(
    id: '42',
    isRegistrationComplete: 1,
    isCrewVerified: 1,
  );

  setUp(() async {
    Env.init(Environment.dev);
    SharedPreferences.setMockInitialValues({DraftKeys.signUp: '{}'});
    prefs = await SharedPreferences.getInstance();
    session = CompositeSessionStore(
      secure: FakeSecureSessionBackend(),
      prefs: FakePrefsSessionBackend(),
    );
    await session.writeToken('expired-token');
    await session.writeRefreshToken('refresh-token');
    await session.writeUser(user);
    telemetry = _Telemetry();
    when(
      () => telemetry.clearUserIdentity(
        emitLogoutEvent: any(named: 'emitLogoutEvent'),
      ),
    ).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(session),
        prefsProvider.overrideWithValue(prefs),
        telemetryClientProvider.overrideWithValue(telemetry),
        authStateProvider.overrideWith(() => AuthStateNotifier(initial: true)),
      ],
    );
    dio = container.read(dioClientProvider).dio;
    adapter = _Adapter();
    dio.httpClientAdapter = adapter;
  });

  tearDown(() {
    dio.close();
    container.dispose();
  });

  test(
    '401 clears persisted and temporary sessions and redirects to Login',
    () async {
      expect(container.read(currentSessionUserProvider), user);
      container
          .read(temporaryAuthSessionProvider.notifier)
          .begin(token: 'temporary-token', user: user, loginAt: DateTime.now());
      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      expect(container.read(authStateProvider), isFalse);
      expect(await session.readToken(), isNull);
      expect(await session.readRefreshToken(), isNull);
      expect(await session.readUser(), isNull);
      expect(container.read(currentSessionUserProvider), isNull);
      expect(container.read(temporaryAuthSessionProvider).isActive, isFalse);
      expect(prefs.containsKey(DraftKeys.signUp), isFalse);
      expect(
        appRedirect(
          isAuth: container.read(authStateProvider),
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: '/home',
        ),
        '/login',
      );
      verify(() => telemetry.clearUserIdentity()).called(1);
    },
  );

  test('multiple 401s clean up once; a later login can expire again', () async {
    await Future.wait(
      List.generate(
        3,
        (_) => expectLater(
          dio.get<dynamic>('/protected'),
          throwsA(isA<DioException>()),
        ),
      ),
    );
    verify(() => telemetry.clearUserIdentity()).called(1);
    await session.writeToken('new-token');
    container.read(authStateProvider.notifier).markLoggedIn();
    await expectLater(
      dio.get<dynamic>('/protected'),
      throwsA(isA<DioException>()),
    );
    expect(await session.readToken(), isNull);
    expect(container.read(authStateProvider), isFalse);
    verify(() => telemetry.clearUserIdentity()).called(1);
  });

  for (final status in [200, 401, 403]) {
    for (final code in [
      'SESSION_EXPIRED',
      'session_expired',
      'Token_Invalid',
      'TOKEN_INVALID',
      'TOKEN_MISSING',
      'UNKNOWN',
      null,
    ]) {
      test(
        'HTTP $status with code $code follows the expiry allowlist',
        () async {
          adapter.status = status;
          adapter.body = {
            'error': true,
            'code': code,
            'message': 'Your session has expired. Please log in again.',
          };
          if (status == 200) {
            await dio.get<dynamic>('/protected');
          } else {
            await expectLater(
              dio.get<dynamic>('/protected'),
              throwsA(isA<DioException>()),
            );
          }
          final upper = code?.toUpperCase();
          final expires =
              upper == 'SESSION_EXPIRED' || upper == 'TOKEN_INVALID';
          expect(container.read(authStateProvider), !expires);
          expect(await session.readToken(), expires ? isNull : 'expired-token');
          if (expires) {
            verify(() => telemetry.clearUserIdentity()).called(1);
          } else {
            verifyNever(() => telemetry.clearUserIdentity());
          }
        },
      );
    }
  }

  test(
    'storage failure still revokes auth and lets the 401 request finish',
    () async {
      final brokenSession = MockSessionStore();
      when(() => brokenSession.readToken()).thenAnswer((_) async => 'expired');
      when(
        () => brokenSession.clearSession(),
      ).thenThrow(StateError('storage unavailable'));
      container.updateOverrides([
        sessionStoreProvider.overrideWithValue(brokenSession),
        prefsProvider.overrideWithValue(prefs),
        telemetryClientProvider.overrideWithValue(telemetry),
        authStateProvider.overrideWith(() => AuthStateNotifier(initial: true)),
      ]);
      dio = container.read(dioClientProvider).dio;
      dio.httpClientAdapter = adapter;
      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      expect(container.read(authStateProvider), isFalse);
      expect(prefs.containsKey(DraftKeys.signUp), isFalse);
      verify(() => telemetry.clearUserIdentity()).called(1);
    },
  );

  test('explicit logout retains the user-initiated telemetry event', () async {
    await container.read(authStateProvider.notifier).logout();
    expect(container.read(authStateProvider), isFalse);
    expect(await session.readToken(), isNull);
    verify(() => telemetry.clearUserIdentity(emitLogoutEvent: true)).called(1);
  });

  test(
    'tokenless request with an expiry code never ends the session',
    () async {
      final tokenlessSession = CompositeSessionStore(
        secure: FakeSecureSessionBackend(),
        prefs: FakePrefsSessionBackend(),
      );
      await tokenlessSession.writeUser(user);
      container.updateOverrides([
        sessionStoreProvider.overrideWithValue(tokenlessSession),
        prefsProvider.overrideWithValue(prefs),
        telemetryClientProvider.overrideWithValue(telemetry),
        authStateProvider.overrideWith(() => AuthStateNotifier(initial: true)),
      ]);
      dio = container.read(dioClientProvider).dio;
      dio.httpClientAdapter = adapter;

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );

      // No token on the request → the expiry code must be ignored.
      expect(container.read(authStateProvider), isTrue);
      expect(await tokenlessSession.readUser(), user);
      verifyNever(() => telemetry.clearUserIdentity());
    },
  );
}
