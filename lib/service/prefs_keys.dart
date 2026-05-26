/// Centralized SharedPreferences key registry.
///
/// Every key persisted via `PrefsService` must be declared here.
/// Adding a raw string key elsewhere in the codebase is a smell.
///
/// Note: sensitive values (token, password) live in
/// [SecureStorageService] and are not represented here.
class PrefsKeys {
  PrefsKeys._();

  /// Remember-me email (non-sensitive). Password lives in secure storage.
  static const String savedLoginEmail = 'saved_login_email';

  /// First-launch sentinel. Absent on fresh install (iOS clears
  /// SharedPreferences on uninstall, but Keychain entries survive — so
  /// without this we'd resurrect a stale token after reinstall).
  static const String firstLaunchDone = 'first_launch_done';
}
