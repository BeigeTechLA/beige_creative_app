import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_store.dart';

/// Secrets backend — token + refresh token in Keychain (iOS) /
/// EncryptedSharedPreferences-backed Keystore (Android).
///
/// Narrow contract — only token operations. `CompositeSessionStore` wires it
/// alongside `PrefsSessionStore` to satisfy the full `SessionStore` interface.
class SecureSessionStore implements SecureSessionBackend {
  static const String _kToken = 'auth_token';
  static const String _kRefreshToken = 'auth_refresh_token';

  final FlutterSecureStorage _storage;

  SecureSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<String?> readToken() => _storage.read(key: _kToken);
  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _kToken, value: token);
  @override
  Future<void> clearToken() => _storage.delete(key: _kToken);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);
  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);
  @override
  Future<void> clearRefreshToken() => _storage.delete(key: _kRefreshToken);
}
