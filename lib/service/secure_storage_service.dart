import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around `flutter_secure_storage` for credentials and tokens.
///
/// On iOS values land in the Keychain; on Android in the EncryptedSharedPreferences
/// backed by Keystore. Reads are async — for hot paths (e.g. attaching auth
/// header to every request), the value is cached in memory after first read
/// via [primeCache].
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys (internal — not exposed alongside PrefsKeys to keep secure namespace
  // separate from preference namespace).
  static const String _kToken = 'auth_token';
  static const String _kSavedLoginPassword = 'saved_login_password';

  // In-memory cache for hot-path reads.
  static String? _cachedToken;
  static bool _tokenCachePrimed = false;

  /// Populates the in-memory token cache once at startup so subsequent
  /// [token] reads are synchronous.
  static Future<void> primeCache() async {
    _cachedToken = await _storage.read(key: _kToken);
    _tokenCachePrimed = true;
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  /// Synchronous read. Returns null until [primeCache] has run.
  static String? get token => _cachedToken;

  static bool get isTokenCachePrimed => _tokenCachePrimed;

  static Future<void> setToken(String value) async {
    await _storage.write(key: _kToken, value: value);
    _cachedToken = value;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _kToken);
    _cachedToken = null;
  }

  // ---------------------------------------------------------------------------
  // Remember-me password
  // ---------------------------------------------------------------------------

  static Future<String?> readSavedLoginPassword() =>
      _storage.read(key: _kSavedLoginPassword);

  static Future<void> writeSavedLoginPassword(String value) =>
      _storage.write(key: _kSavedLoginPassword, value: value);

  static Future<void> deleteSavedLoginPassword() =>
      _storage.delete(key: _kSavedLoginPassword);
}
