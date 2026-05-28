import 'package:beige_creative_app/core/session/prefs_session_store.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
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
        name: 'Bob',
        email: 'bob@example.com',
        role: 'photographer',
        profileImageUrl: 'https://cdn/x.png',
      );
      await session.writeUser(snapshot);
      final read = await session.readUser();
      expect(read, equals(snapshot));
      await session.clearUser();
      expect(await session.readUser(), isNull);
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
      expect(await session.isLoggedIn(), isFalse,
          reason: 'empty token treated as logged-out');
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
  });
}
