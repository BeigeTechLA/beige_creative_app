import 'package:beige_creative_app/core/session/prefs_session_store.dart';
import 'package:beige_creative_app/core/network/interceptors/auth_interceptor.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/core/session/temporary_auth_session.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory secure backend — round-trips without touching real Keychain.
class _InMemorySecureBackend implements SecureSessionBackend {
  String? _token;
  String? _refresh;

  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> writeToken(String token) async => _token = token;
  @override
  Future<void> clearToken() async => _token = null;

  @override
  Future<String?> readRefreshToken() async => _refresh;
  @override
  Future<void> writeRefreshToken(String token) async => _refresh = token;
  @override
  Future<void> clearRefreshToken() async => _refresh = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => Env.init(Environment.dev));

  group('CompositeSessionStore round-trip', () {
    late CompositeSessionStore session;
    late _InMemorySecureBackend secure;
    late PrefsSessionStore prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      secure = _InMemorySecureBackend();
      prefs = PrefsSessionStore(sharedPrefs);
      session = CompositeSessionStore(secure: secure, prefs: prefs);
    });

    test('token write → read → clear', () async {
      expect(await session.readToken(), isNull);
      await session.writeToken('abc123');
      expect(await session.readToken(), 'abc123');
      await session.clearToken();
      expect(await session.readToken(), isNull);
    });

    test('refresh token write → read → clear', () async {
      await session.writeRefreshToken('refresh-xyz');
      expect(await session.readRefreshToken(), 'refresh-xyz');
      await session.clearRefreshToken();
      expect(await session.readRefreshToken(), isNull);
    });

    test('user snapshot write → read → clear (round-trip JSON)', () async {
      const snapshot = UserSnapshot(
        id: '42',
        firstName: 'Bob',
        lastName: 'Builder',
        name: 'Bob',
        email: 'bob@example.com',
        phoneNumber: '1234567890',
        location: 'Mumbai',
        workingDistance: 'Upto 25 Miles',
        role: 'photographer',
        profileImageUrl: 'https://cdn/x.png',
      );
      await session.writeUser(snapshot);
      final read = await session.readUser();
      expect(read, equals(snapshot));
      await session.clearUser();
      expect(await session.readUser(), isNull);
    });

    test('user snapshot parses numeric Step 2 completion values', () {
      expect(
        UserSnapshot.fromJson(const {'is_step_2_complete': 1}).isStep2Complete,
        isTrue,
      );
      expect(
        UserSnapshot.fromJson(const {'is_step_2_complete': 0}).isStep2Complete,
        isFalse,
      );
    });

    test('lastLoginAt write → read', () async {
      final when = DateTime.utc(2026, 5, 28, 12, 30);
      await session.writeLastLoginAt(when);
      expect(await session.readLastLoginAt(), when);
    });

    test('isLoggedIn reflects token presence', () async {
      expect(await session.isLoggedIn(), isFalse);
      await session.writeToken('t');
      expect(await session.isLoggedIn(), isTrue);
      await session.writeToken('');
      expect(
        await session.isLoggedIn(),
        isFalse,
        reason: 'empty token treated as logged-out',
      );
    });

    test('clearSession wipes everything', () async {
      await session.writeToken('t');
      await session.writeRefreshToken('r');
      await session.writeUser(const UserSnapshot(id: '1'));
      await session.writeLastLoginAt(DateTime.utc(2026, 1, 1));

      await session.clearSession();

      expect(await session.readToken(), isNull);
      expect(await session.readRefreshToken(), isNull);
      expect(await session.readUser(), isNull);
      expect(await session.readLastLoginAt(), isNull);
      expect(await session.isLoggedIn(), isFalse);
    });

    test('temporary auth is separate from persistent session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      const user = UserSnapshot(
        id: '42',
        isRegistrationComplete: 1,
        isCrewVerified: 0,
      );
      container
          .read(temporaryAuthSessionProvider.notifier)
          .begin(
            token: 'temporary-token',
            user: user,
            loginAt: DateTime.utc(2026, 8, 13),
          );

      expect(
        container.read(temporaryAuthSessionProvider).token,
        'temporary-token',
      );
      expect(container.read(temporaryAuthSessionProvider).user, user);
      expect(container.read(temporaryAuthSessionProvider).isActive, isTrue);
      expect(await session.readToken(), isNull);
      expect(await session.readUser(), isNull);
      expect(await session.isLoggedIn(), isFalse);
      expect(await secure.readToken(), isNull);
      expect(await prefs.readUser(), isNull);

      final restartedProcess = ProviderContainer();
      addTearDown(restartedProcess.dispose);
      expect(
        restartedProcess.read(temporaryAuthSessionProvider).isActive,
        isFalse,
      );
    });

    test('network auth prefers temporary token over persisted token', () async {
      await session.writeToken('persisted-token');
      final container = ProviderContainer(
        overrides: [sessionStoreProvider.overrideWithValue(session)],
      );
      addTearDown(container.dispose);
      final authInterceptor = container
          .read(dioClientProvider)
          .dio
          .interceptors
          .whereType<AuthInterceptor>()
          .single;

      expect(await authInterceptor.tokenReader(), 'persisted-token');
      container
          .read(temporaryAuthSessionProvider.notifier)
          .begin(
            token: 'temporary-token',
            user: const UserSnapshot(id: '42'),
            loginAt: DateTime.utc(2026, 8, 13),
          );
      expect(await authInterceptor.tokenReader(), 'temporary-token');
    });
  });
}
