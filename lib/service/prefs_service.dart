import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_keys.dart';
import 'secure_storage_service.dart';

/// Typed, cached wrapper around [SharedPreferences] + [SecureStorageService].
///
/// Call [init] once during app startup (before `runApp`) so subsequent
/// reads are synchronous and avoid the per-call `getInstance()` round-trip.
/// Sensitive values (`token`, `savedLoginPassword`) live in Keychain
/// (iOS) / EncryptedSharedPreferences (Android); the token is mirrored
/// into an in-memory cache so the auth-header hot path stays sync.
///
/// All non-secure keys must be declared in [PrefsKeys].
class PrefsService {
  PrefsService._();

  static SharedPreferences? _prefs;

  /// Must be awaited before any other [PrefsService] member is touched.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _wipeSecureStorageOnFreshInstall();
    await SecureStorageService.primeCache();
  }

  /// iOS Keychain entries survive app uninstall, but SharedPreferences
  /// does not. If our sentinel is missing we treat this as a fresh
  /// install and clear any leftover secure-storage state so the user
  /// doesn't land on the dashboard with a stale token.
  static Future<void> _wipeSecureStorageOnFreshInstall() async {
    final prefs = _p;
    if (prefs.getBool(PrefsKeys.firstLaunchDone) == true) return;

    await SecureStorageService.deleteToken();
    await SecureStorageService.deleteSavedLoginPassword();
    await prefs.setBool(PrefsKeys.firstLaunchDone, true);
  }

  static SharedPreferences get _p {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('PrefsService.init() must be awaited before use.');
    }
    return prefs;
  }

  // ---------------------------------------------------------------------------
  // Auth — token is the single source of truth for "logged in".
  // ---------------------------------------------------------------------------

  static bool get isLoggedIn => SecureStorageService.token != null;

  static String? get token => SecureStorageService.token;
  static Future<void> setToken(String value) =>
      SecureStorageService.setToken(value);

  static Future<void> clearAuth() => SecureStorageService.deleteToken();

  // ---------------------------------------------------------------------------
  // Remember-me credentials
  // ---------------------------------------------------------------------------

  static String? get savedLoginEmail => _p.getString(PrefsKeys.savedLoginEmail);
  static Future<bool> setSavedLoginEmail(String value) =>
      _p.setString(PrefsKeys.savedLoginEmail, value);

  /// Password is sensitive — async because it hits Keychain/Keystore directly.
  static Future<String?> getSavedLoginPassword() =>
      SecureStorageService.readSavedLoginPassword();
  static Future<void> setSavedLoginPassword(String value) =>
      SecureStorageService.writeSavedLoginPassword(value);

  static Future<void> clearSavedLogin() async {
    await _p.remove(PrefsKeys.savedLoginEmail);
    await SecureStorageService.deleteSavedLoginPassword();
  }
}
