/// Dependency-injectable session contract.
///
/// **Secrets** (`token`, `refreshToken`) live in `flutter_secure_storage` via
/// `SecureSessionStore`. **Non-secrets** (`isLoggedIn`, `lastLoginAt`, user
/// snapshot) live in `SharedPreferences` via `PrefsSessionStore`. The composite
/// `CompositeSessionStore` wires both backends behind the [SessionStore]
/// interface so callers / providers / interceptors only ever see one type.
///
/// Concrete impls live in `secure_session_store.dart` and
/// `prefs_session_store.dart`. `sessionStoreProvider` in
/// `lib/core/providers/core_providers.dart` is overridden in `startApp`
/// with a `CompositeSessionStore` once Task 3.16 wires the harness.
abstract class SessionStore {
  // ━━━ Secrets (delegate → SecureSessionStore) ━━━
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();

  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clearRefreshToken();

  // ━━━ Non-secrets (delegate → PrefsSessionStore) ━━━
  Future<UserSnapshot?> readUser();
  Future<void> writeUser(UserSnapshot user);
  Future<void> clearUser();

  Future<DateTime?> readLastLoginAt();
  Future<void> writeLastLoginAt(DateTime when);

  /// True iff a non-empty token is in secure storage. Single source of truth
  /// for "logged in" — `isLoggedIn` flags in prefs are advisory only.
  Future<bool> isLoggedIn();

  /// Wipe everything — token, refresh, user, lastLoginAt. Called from
  /// `AuthInterceptor.onUnauthorized` and from explicit logout.
  Future<void> clearSession();
}

/// Persisted slice of the authenticated user. Kept narrow — full profile data
/// stays in the dedicated profile feature; this is just enough to bootstrap
/// the UI before the profile fetch resolves.
class UserSnapshot {
  final String id;
  final String? name;
  final String? email;
  final String? role;
  final String? userType;
  final String? profileImageUrl;

  const UserSnapshot({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.userType,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (userType != null) 'user_type': userType,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      };

  factory UserSnapshot.fromJson(Map<String, dynamic> json) => UserSnapshot(
        id: json['id'].toString(),
        name: json['name'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        userType: json['user_type'] as String?,
        profileImageUrl: json['profile_image_url'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is UserSnapshot &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.role == role &&
      other.userType == userType &&
      other.profileImageUrl == profileImageUrl;

  @override
  int get hashCode =>
      Object.hash(id, name, email, role, userType, profileImageUrl);
}

/// Composes the secure + prefs backends behind one [SessionStore] type.
///
/// Constructed in `startApp` (after `SharedPreferences.getInstance()` resolves)
/// and exposed via `sessionStoreProvider`. Test harnesses build an instance
/// with in-memory `SharedPreferences.setMockInitialValues({})` and a swapped
/// `FlutterSecureStorage` to round-trip without touching real Keychain.
///
/// Backends are typed dynamically via the structural contracts at the bottom
/// of this file so test fakes can implement just the surface they need.
class CompositeSessionStore implements SessionStore {
  final SecureSessionBackend _secure;
  final PrefsSessionBackend _prefs;

  CompositeSessionStore({
    required SecureSessionBackend secure,
    required PrefsSessionBackend prefs,
  })  : _secure = secure,
        _prefs = prefs;

  @override
  Future<String?> readToken() => _secure.readToken();
  @override
  Future<void> writeToken(String token) => _secure.writeToken(token);
  @override
  Future<void> clearToken() => _secure.clearToken();

  @override
  Future<String?> readRefreshToken() => _secure.readRefreshToken();
  @override
  Future<void> writeRefreshToken(String token) =>
      _secure.writeRefreshToken(token);
  @override
  Future<void> clearRefreshToken() => _secure.clearRefreshToken();

  @override
  Future<UserSnapshot?> readUser() => _prefs.readUser();
  @override
  Future<void> writeUser(UserSnapshot user) => _prefs.writeUser(user);
  @override
  Future<void> clearUser() => _prefs.clearUser();

  @override
  Future<DateTime?> readLastLoginAt() => _prefs.readLastLoginAt();
  @override
  Future<void> writeLastLoginAt(DateTime when) =>
      _prefs.writeLastLoginAt(when);

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secure.readToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearSession() async {
    await _secure.clearToken();
    await _secure.clearRefreshToken();
    await _prefs.clearUser();
    await _prefs.clearLastLoginAt();
  }
}

/// Public structural contract for the secure half. `SecureSessionStore`
/// implements this; test fakes can too. Lets `CompositeSessionStore` accept
/// any token-store without depending on concrete `flutter_secure_storage`.
abstract class SecureSessionBackend {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clearRefreshToken();
}

/// Public structural contract for the prefs half. `PrefsSessionStore`
/// implements this; test fakes can too.
abstract class PrefsSessionBackend {
  Future<UserSnapshot?> readUser();
  Future<void> writeUser(UserSnapshot user);
  Future<void> clearUser();
  Future<DateTime?> readLastLoginAt();
  Future<void> writeLastLoginAt(DateTime when);
  Future<void> clearLastLoginAt();
}
