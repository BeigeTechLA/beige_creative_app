import 'package:beige_creative_app/core/network/dio_client.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

/// Shared `mocktail` mocks for Phase 6 tests.
///
/// Keep this file narrow — only mocks for the cross-cutting dependencies
/// every test bumps into (Dio, session). Feature-specific repo mocks belong
/// in the test file that needs them so the surface stays grep-able. Add a
/// mock here only when ≥3 tests already declared the same `_FakeFoo` inline.

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

class MockSessionStore extends Mock implements SessionStore {}

/// Lightweight in-memory session backend pair for use with the real
/// [CompositeSessionStore]. Prefer this over [MockSessionStore] when the
/// test wants to exercise the composite's read/write semantics rather than
/// stub individual calls.
class FakeSecureSessionBackend implements SecureSessionBackend {
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

class FakePrefsSessionBackend implements PrefsSessionBackend {
  UserSnapshot? _user;
  DateTime? _lastLoginAt;
  bool _onboardingSeen = false;

  @override
  Future<UserSnapshot?> readUser() async => _user;
  @override
  Future<void> writeUser(UserSnapshot user) async => _user = user;
  @override
  Future<void> clearUser() async => _user = null;

  @override
  Future<DateTime?> readLastLoginAt() async => _lastLoginAt;
  @override
  Future<void> writeLastLoginAt(DateTime when) async => _lastLoginAt = when;
  @override
  Future<void> clearLastLoginAt() async => _lastLoginAt = null;

  @override
  Future<bool> readOnboardingSeen() async => _onboardingSeen;
  @override
  Future<void> writeOnboardingSeen(bool seen) async => _onboardingSeen = seen;

  String? _fcmToken;

  @override
  Future<String?> readFcmToken() async => _fcmToken;
  @override
  Future<void> writeFcmToken(String fcmToken) async => _fcmToken = fcmToken;
  @override
  Future<void> clearFcmToken() async => _fcmToken = null;
}

/// Sets up the default `registerFallbackValue` calls required by every mock
/// that takes complex arg types. Call once from `setUpAll` in the test that
/// stubs `MockDio.get` / `.post` / etc.
void registerHelperFallbacks() {
  registerFallbackValue(Options());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(Uri());
}
