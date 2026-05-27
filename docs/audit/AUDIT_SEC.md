# AUDIT_SEC.md — Security Audit (#6)

**Auditor role:** Senior Flutter Security Engineer (mobile threat modelling).
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** every `.dart` under `lib/`, `pubspec.yaml`, `AndroidManifest.xml`, `build.gradle.kts`, `ios/Runner/Info.plist`, `ios/Podfile`, all `.env`/config files.
**Output convention:** all docs live in `docs/` per project rule.

---

## Threat model summary

| Concept | Detail |
|---------|--------|
| **Sensitive data handled** | Auth bearer tokens (`shared_service.dart:27`), **user passwords stored plaintext locally** (`login.dart:111`), PII (name, email, profile photo URLs), precise location (`ACCESS_FINE_LOCATION`), payment tokens via Stripe SDK during checkout, file uploads (resume, portfolio, certifications, recent work — `signup3_screen.dart`, `myprofile.dart`), Google Maps API key. |
| **Trust boundaries** | (1) Network → backend (`mobile.beige.app` / `mobile.prod.beige.app`); (2) Local disk → `SharedPreferences` XML; (3) Stripe SDK → Stripe TLS endpoint; (4) Google Maps SDK ← key restriction (assumed); (5) Filesystem → image cache + multipart picker tmpdirs. |
| **Adversaries** | (a) Network attacker — Wi-Fi MITM, hostile proxy, NSA-level not relevant. (b) Device attacker — rooted/jailbroken user, malware with WRITE_EXTERNAL_STORAGE, USB-debug-enabled lab capture. (c) App-store mirror — anyone who can `apktool`/`Hopper` the APK. (d) Insider — anyone with git access to this repo. |
| **Worst case if compromised** | **Account takeover and credential stuffing.** An attacker who extracts a single SharedPreferences XML (e.g., via `adb backup` on a `minSdk 21` device that defaults `allowBackup=true`, or via rooted-device dump) obtains *both* the bearer token *and* the plaintext password. The token unlocks the user's profile, projects, files, and payment flows immediately; the password unlocks every other service that user reuses passwords on. |

---

## Security risk level: **CRITICAL**

> One-sentence worst case: *an attacker who obtains the device's `SharedPreferences` XML — through `adb backup`, rooted-device extraction, or a malicious "free Wi-Fi" cleartext-traffic MITM (currently allowed by manifest) — gets a never-expiring bearer token **and** the user's plaintext password, enabling full account takeover and cross-service credential stuffing.*

---

## Hardcoded secrets section (top — most critical)

### S1. 🔴 CRITICAL — Plaintext Google Maps API key committed twice

```dart
// lib/service/google_config.dart:3
"AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc";
```
```xml
<!-- android/app/src/main/AndroidManifest.xml:22-24 -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc"/>
```
**Same key, two places**, both committed to VCS. The same key is shared between `dev` and `prod` flavors (`docs/AUDIT_MAP.md` §  Pre-audit flag #9). Anyone who clones the repo or unpacks the APK has the key. If the key is unrestricted, anyone can run up the project's Google Maps quota until billing is exhausted. **Reverse-engineering APKs to extract Google API keys is a standard tactic and is automated by tools like `apk-tool` + `grep`.**

#### Fix

1. **Rotate the key now.** It is leaked; treat as compromised.
2. Restrict the new keys at the GCP console: Android package name + SHA-1 fingerprint, **separate keys per flavor**.
3. Move the new dev/prod keys into `--dart-define=GOOGLE_MAPS_KEY=...` (passed through CI secret) and read via `String.fromEnvironment('GOOGLE_MAPS_KEY')`. On Android, inject via `manifestPlaceholders` from `build.gradle.kts`.
4. Delete `lib/service/google_config.dart` (one-line file containing only the literal) and use the env constant.

```kotlin
// android/app/build.gradle.kts — after fix
android {
    defaultConfig {
        manifestPlaceholders["MAPS_API_KEY"] = (project.findProperty("MAPS_API_KEY_DEV") ?: "") as String
    }
    productFlavors {
        create("dev") { manifestPlaceholders["MAPS_API_KEY"] = mapsKeyDev }
        create("prod") { manifestPlaceholders["MAPS_API_KEY"] = mapsKeyProd }
    }
}
```
```xml
<!-- AndroidManifest.xml — after fix -->
<meta-data android:name="com.google.android.geo.API_KEY" android:value="${MAPS_API_KEY}"/>
```

### S2. 🔴 CRITICAL — Stripe publishable key hard-coded in source

```dart
// lib/config/env.dart:15-20
case Environment.dev:
  ...
  stripePublishableKey =
      'pk_test_51S5czd54hnPNgHXUq7sunp8uvTDW4ln6aw8Y3bP249JZmx4xuvoIED4mZTuNIkAFcOoCApICfgv9dM4VbbleJo7L00GqNEkj3I';
case Environment.prod:
  ...
  stripePublishableKey = 'PLACE_HOLDER_LIVE_STRIPE_KEY';
```

The dev key is a real `pk_test_...` value committed to the repo. **Publishable keys are technically safe to ship in clients** (Stripe documents this) — but a *test* key still allows pre-auth charges against the dev account and enables a known-customer attack surface. The prod key is a literal placeholder string; **invoking Stripe in production will throw**, but if a future commit replaces the placeholder with a real `pk_live_...` it will end up in VCS the same way.

#### Fix

1. Move both keys to `--dart-define=STRIPE_PK=...` per flavor.
2. Add `STRIPE_PK` to `.gitignore`-only env files; rotate the test key.
3. Add a startup assertion that fails fast if `stripePublishableKey.startsWith('PLACE_HOLDER')`.

### S3. 🔴 CRITICAL — User password persisted in plain SharedPreferences

```dart
// lib/auth/login/login.dart:109-112
if (savePassword) {
  await prefs.setString("email", email);
  await prefs.setString("password", password);
}
```
- `SharedPreferences` on Android = `/data/data/com.beige_creative_app[.dev]/shared_prefs/FlutterSharedPreferences.xml` — readable on rooted devices, by `adb backup` (default-on for `minSdk<31`), and by anyone who acquires the device unlock screen.
- iOS `NSUserDefaults` backing store = `~/Library/Preferences/<bundle>.plist` — readable by macOS desktop apps with proper entitlements when the device is paired.
- `flutter_secure_storage` is **not** in `pubspec.yaml` (`grep -n flutter_secure_storage pubspec.*` → 0 — confirmed).
- Same file also holds `token` (`shared_service.dart:27`) → both credentials live next to each other.

**Worst case:** a single `adb pull /data/data/com.beige_creative_app.dev/shared_prefs/FlutterSharedPreferences.xml` yields email, password, bearer token, and user ID.

#### Fix

1. Add `flutter_secure_storage: ^9.x` (uses iOS Keychain + Android EncryptedSharedPreferences with Keystore-backed keys).
2. **Stop persisting the password.** Persist only the email (for the "remember me" UX) and the auth token via secure storage. To replay a session, refresh the token via the existing refresh endpoint or prompt the user.
3. If absolutely necessary for "Save Password" UX, store only via secure storage AND clearly opt-in.

```dart
// AFTER
final _secure = const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

await _secure.write(key: 'auth_token', value: token);
await _secure.write(key: 'remembered_email', value: email); // ← email only
// no password persistence at all
```

### S4. 🔴 HIGH — Bearer token written to logs

```dart
// lib/service/api_service.dart:340-346
dio.options.headers = {
  "Accept": "application/json",
  "Authorization": "Bearer $token",
};
debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
debugPrint("🌍 FULL URL => $fullUrl");
debugPrint("🧾 HEADERS => ${dio.options.headers}");
```
```dart
// lib/Profile/myprofile.dart:600-601
debugPrint("🌐 API URL: $url");
debugPrint("🔑 Headers: $headers");
```
Both sites print the full headers map — which contains the live bearer token — to `logcat` (Android) and Console.app (iOS). On Android these logs are world-readable via `adb logcat` and accessible to any pre-Android-12 app holding `READ_LOGS` (rare on modern OS but still surfaces in crash-reporting pipelines like Crashlytics).

**Additionally, `print()`/`debugPrint()` calls remain in `release` builds** — Flutter does not strip them, and the codebase has 242 such calls in `lib/` (map § Pre-audit flag #19).

#### Fix

1. Remove every `debugPrint(... Headers ...)` and `debugPrint(... Authorization ...)` site.
2. Replace ad-hoc `debugPrint` with a single `AppLogger` that:
   - is a `no-op` in release builds (`if (kReleaseMode) return;`),
   - sanitises `Authorization`/`token`/`password`/`Cookie` keys when logging maps.

### S5. 🟠 MEDIUM — Legacy `AppConfig` cleartext URL artifact

```dart
// lib/service/config.dart:12 (file content — commented but committed)
// apiUrl = 'http://localhost:3004/api/';
```
Cleartext `http://` URL persisted in source as a comment. Not active, but indicates a development history that allowed `http://`. Combined with `usesCleartextTraffic="true"` (S6 below), cleartext traffic could be reintroduced in one keystroke.

### S6. 🟠 MEDIUM — Cleartext placeholder URL in user-visible UI

```dart
// lib/file_manager/view_details_screen.dart:230
_buildDetailRow("Folder Link", "http://fijejpfkmdjfief", isLink: true),
```
A placeholder `http://` link shipped in the file manager detail row. If `isLink` triggers a `url_launcher` or `WebView` open (not directly verified), this would surface as a cleartext request from inside the app — which `usesCleartextTraffic="true"` allows.

---

## Findings (severity order — Critical first)

### F1. 🔴 CRITICAL — `usesCleartextTraffic="true"` set globally

```xml
<!-- android/app/src/main/AndroidManifest.xml:10-14 -->
<application
    android:label="BEIGECP"
    android:name="${applicationName}"
    android:icon="@mipmap/cp_app_icon"
    android:usesCleartextTraffic="true">
```

Applies to **both** flavors (no flavor-specific manifest override — map § Pre-audit flag #5). Combined with the absence of `android:networkSecurityConfig`, **the app will accept any plaintext `http://` connection at runtime**. A malicious "Free Wi-Fi" hotspot can MITM image URLs, redirect to phishing forms, or downgrade Stripe initialisation.

**Production builds should set `false`.** If the API genuinely requires cleartext (none of `Env.apiUrl` / `Env.imageUrl` does — both are `https://`), restrict to specific domains via a `network_security_config.xml`:

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <base-config cleartextTrafficPermitted="false"/>
  <!-- no exceptions -->
</network-security-config>
```
```xml
<!-- AndroidManifest.xml -->
<application
    ...
    android:networkSecurityConfig="@xml/network_security_config">
```

### F2. 🔴 CRITICAL — Release builds use the debug keystore

`android/key.properties` is **not present on disk** (map § Pre-audit flag #8). `android/app/build.gradle.kts:66-70` falls back:

```kotlin
release {
    signingConfig = if (keystorePropertiesFile.exists()) {
        signingConfigs.getByName("release")
    } else {
        signingConfigs.getByName("debug")
    }
    ...
}
```

A release-signed-with-debug-key APK is **trivially side-loadable by anyone with the same debug key** (the Android SDK ships one), allowing app spoofing and ad-tracker impersonation. Play Store also rejects debug-signed uploads with `INSTALL_PARSE_FAILED_INCONSISTENT_CERTIFICATES` on update.

#### Fix

1. Generate a release keystore (`keytool -genkeypair ...`) per build environment.
2. Add `android/key.properties` to local + CI (gitignored).
3. Document the recovery procedure for lost keystores (rotation requires Play Console upload key escrow).

### F3. 🔴 HIGH — No code obfuscation / minification for release

`android/app/build.gradle.kts` references ProGuard but does **not** enable minification:

```kotlin
// build.gradle.kts:71-74
proguardFiles(
    getDefaultProguardFile("proguard-android-optimize.txt"),
    "proguard-rules.pro"
)
```

But: `grep -n "minifyEnabled\|shrinkResources\|isMinifyEnabled\|isShrinkResources" android/app/build.gradle.kts` returns **0**. Flutter's Gradle plugin defaults to `isMinifyEnabled = false`. The `proguard-rules.pro` file referenced **does not exist** on disk (verified). Release APKs ship with full Dart symbols and Kotlin/Java symbol names — making static reverse-engineering trivial.

#### Fix

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        ...
    }
}
```
Plus run `flutter build apk --obfuscate --split-debug-info=build/symbols/<version>/` for Dart symbol obfuscation. Stash the split-debug-info per release for crash decoding.

### F4. 🔴 HIGH — No Dio / HTTP client timeouts

`grep -rn "connectTimeout\|receiveTimeout\|sendTimeout" lib` → **0**. Both `ApiService` and the bare `Dio()` instances at `lib/Profile/myprofile.dart:594` and `lib/auth/sign_up/signup3_screen.dart` use default timeouts (Dio: no timeout; `package:http`: no timeout).

**Failure mode under attack:** an attacker controlling the upstream network (Wi-Fi pineapple, slow-loris-style proxy) can hold a TCP socket open indefinitely. The Flutter UI shows a spinner forever; the user retries; sockets accumulate; battery and data costs spike.

#### Fix

```dart
// AFTER — Dio default for the whole app
final dio = Dio(BaseOptions(
  baseUrl: Env.apiUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 20),
  sendTimeout:    const Duration(seconds: 30),
));
```

### F5. 🔴 HIGH — No certificate pinning

`grep -rn "SecurityContext\|badCertificateCallback\|onBadCertificate\|sslPinning\|TLS\|pinned" lib` → 0.

No pinning means any device-trusted root (corporate proxies, user-installed CAs) can MITM the `mobile.beige.app` and `mobile.prod.beige.app` traffic. On Android 7+ user-installed CAs require a `networkSecurityConfig` to be trusted, which is not present (F1). On rooted devices and on iOS with a configuration profile, the issue is fully exploitable.

#### Fix

Pin the API certificate (SHA-256 SPKI) via a Dio interceptor or a `HttpClient` `SecurityContext`. Rotate pins on certificate renewal; deploy double-pinning (current + next) before swapping certs.

### F6. 🟠 MEDIUM — `SharedService.logout()` wipes all SharedPreferences

```dart
// lib/service/shared_service.dart:44-49
static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print("🗑️ User data cleared from SharedPreferences");
}
```
Cross-ref `docs/AUDIT_ARCH.md` §D4 / `docs/AUDIT_STATE.md` §D4. **Security read of the same finding:** `prefs.clear()` is *permissive* in the wrong direction — it wipes session and the "remembered email" too. From a security perspective the bigger concern is the **inverse**: the function deletes everything *except* what it should keep encrypted (it never moves to secure storage). The right fix is the migration to `flutter_secure_storage` in S3; once secure storage holds the token, `logout()` removes only the `auth_token` key, leaving non-credential prefs intact.

### F7. 🟠 MEDIUM — `image_cropper`, `image_picker`, `file_picker` permissions but no runtime usage rationale strings on iOS

`ios/Runner/Info.plist` (full content read at audit time) contains **no** `NS*UsageDescription` keys:

| Required key | Reason | Status |
|--------------|--------|--------|
| `NSPhotoLibraryUsageDescription` | image_picker / image_cropper | **missing** |
| `NSCameraUsageDescription` | image_picker (camera source) | **missing** |
| `NSLocationWhenInUseUsageDescription` | geolocator | **missing** |
| `NSAppTransportSecurity` (denied arbitrary loads) | TLS-only | **missing** (defaults to ATS enforced — OK, but document explicitly) |

iOS will **crash on first call to picker/geolocator** and the App Store will **reject** the binary at upload. This is a security gate (ATS) and a UX gate combined.

#### Fix

```xml
<!-- ios/Runner/Info.plist (snippets to add) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>BEIGE needs access to your photo library to upload portfolio media and your profile picture.</string>
<key>NSCameraUsageDescription</key>
<string>BEIGE uses the camera to capture portfolio photos and your profile picture.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>BEIGE uses your location to suggest nearby shoots and confirm on-site arrival.</string>
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <false/>
</dict>
```

### F8. 🟠 MEDIUM — Android over-broad legacy storage permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml:6-8 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
```
Correct use of `maxSdkVersion` to scope legacy permissions. **OK** — kept for the audit checklist completeness. Two concerns remain:

1. `WRITE_EXTERNAL_STORAGE` (capped to `maxSdkVersion="29"`) is no longer used by any modern image picker. Verify with `image_picker` and `image_cropper` docs at 10.0/1.2 — both use scoped storage / SAF. **Likely removable.**
2. `READ_EXTERNAL_STORAGE` (`maxSdkVersion="32"`) is necessary only for Android 12 and below to read user-picked media. Confirm `image_picker` 1.2 behaviour — current best practice is `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO` only.

### F9. 🟠 MEDIUM — `ACCESS_COARSE_LOCATION` redundant with `ACCESS_FINE_LOCATION`

```xml
<!-- AndroidManifest.xml:4-5 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
Granting `FINE` implies `COARSE`. On Android 12+ the user may grant either; the app accepts whichever is available via `geolocator`. **Keep both** for backward compatibility but ensure the runtime UI explains why fine is needed. Not a CVE; raised because the principle of least privilege says request the lowest tier first.

### F10. 🟡 LOW — Deep link surface minimal

```xml
<!-- AndroidManifest.xml:38-41 -->
<intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
</intent-filter>
```
Only the standard launcher intent filter. No `VIEW` action with custom scheme/host. No `uniLinks` / `app_links` import in `lib/`. **No deep-link attack surface today.** When deep links are added, validate every path/query parameter before navigation and treat as untrusted input.

### F11. 🟡 LOW — WebView absent

`grep -rn "WebView\|InAppWebView\|flutter_inappwebview" lib pubspec.yaml` → 0. **No WebView attack surface.** Keep it that way; if introduced, set `javaScriptMode: JavaScriptMode.disabled` for untrusted origins.

### F12. 🟡 LOW — Stack traces / debug surfaces

The codebase relies on `debugPrint(e)` and `debugPrint(stackTrace)` patterns inside `catch` blocks (`docs/AUDIT_QUALITY.md` §D11). In release builds, `debugPrint` still writes to platform logs but is throttled by Flutter. **No on-screen stack trace dialog observed.** Users see opaque error snackbars (`docs/AUDIT_STATE.md` §C9). Acceptable for security; bad for UX. Not a fix-for-security item.

### F13. 🟡 LOW — `allowBackup` not explicitly set

`grep -n "allowBackup" android/app/src/main/AndroidManifest.xml` → 0. On `minSdkVersion=21` (Flutter default), Android defaults `android:allowBackup="true"`. **An attacker with `adb` access can `adb backup -f mybackup.ab com.beige_creative_app.dev` and pull the SharedPreferences XML containing the token + password.**

#### Fix

```xml
<!-- AndroidManifest.xml -->
<application
    ...
    android:allowBackup="false"
    android:fullBackupContent="false"
    tools:replace="android:allowBackup">
```
With `xmlns:tools="http://schemas.android.com/tools"` declared on `<manifest>` if not already.

### F14. 🟡 LOW — `debuggable` follows build type (default OK)

`grep -n "android:debuggable" android/app/src` → 0. Flutter's Gradle plugin auto-injects `debuggable=true` for debug and removes for release; **default is correct**. No action.

---

## Security hardening checklist

| # | Item | Status |
|---|------|--------|
| 1 | TLS-only network (no cleartext) | ❌ — `usesCleartextTraffic="true"` (F1) |
| 2 | Certificate pinning on API endpoints | ❌ (F5) |
| 3 | HTTP client timeouts (`connect`/`receive`/`send`) | ❌ (F4) |
| 4 | Tokens stored in OS keystore (`flutter_secure_storage`) | ❌ — plain SharedPreferences (S3) |
| 5 | Passwords never persisted | ❌ — `login.dart:111` (S3) |
| 6 | Logs sanitised in release; no token/header leakage | ❌ — `api_service.dart:346`, `myprofile.dart:601` (S4) |
| 7 | API keys injected from `--dart-define` / build env, not source | ❌ — `google_config.dart:3`, `env.dart:16` (S1, S2) |
| 8 | Per-flavor API keys + key restrictions in vendor console | ❌ — same key for dev + prod (S1) |
| 9 | Release builds signed with release keystore | ❌ — falls back to debug keystore (F2) |
| 10 | Release builds minified + obfuscated (R8 / `--obfuscate`) | ❌ (F3) |
| 11 | iOS `NSAppTransportSecurity` set; usage description strings present | ❌ — `Info.plist` missing required keys (F7) |
| 12 | Android `allowBackup="false"` | ❌ (F13) |
| 13 | Android permissions minimal + scoped to SDK ranges | ⚠️ — legacy WRITE_EXTERNAL_STORAGE could go (F8) |
| 14 | Deep link inputs validated | ✅ — no deep links yet (F10) |
| 15 | WebView absent or javascript disabled for untrusted origins | ✅ — no WebView (F11) |
| 16 | Stack traces never shown to end-user | ✅ — opaque snackbars (F12) |
| 17 | CI: secrets injected from environment (`--dart-define-from-file`) | ❌ — secrets are in source |
| 18 | Logout removes all credential prefs from secure storage | ⚠️ — `prefs.clear()` over-clears (F6) |

**4 ✅ · 2 ⚠️ · 13 ❌.**

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Stop persisting the password; move the auth token to `flutter_secure_storage`.** *Effort: ~half a dev-day to add the dep, write a `SessionStore`, and replace 6 prefs sites.* *Impact:* eliminates the catastrophic credential exposure on the device (S3). Highest single security win in the audit.

2. 🔴 **Rotate and constrain the Google Maps key. Move both keys (Maps + Stripe) into `--dart-define`/`manifestPlaceholders`; delete `google_config.dart` and the hard-coded `pk_test_…` literal.** *Effort: 1 dev-day including CI secret wiring + key rotation in GCP/Stripe.* *Impact:* closes the cleartext-secret leak (S1, S2). Mandatory before any APK ships publicly.

3. 🔴 **Remove the two `debugPrint(…HEADERS…)` sites (`api_service.dart:346`, `myprofile.dart:601`) and gate every other `debugPrint` behind an `AppLogger` that no-ops in release.** *Effort: 1 dev-day mechanical pass over the 242 print/debugPrint sites.* *Impact:* stops bearer-token leakage to `logcat` (S4) and removes the broader leak vector that the dependency injection refactor (`docs/AUDIT_ARCH.md`) will not address by itself.

4. 🔴 **Harden the Android manifest: set `usesCleartextTraffic="false"`, add `android:networkSecurityConfig`, set `allowBackup="false"`.** *Effort: 1 dev-hour.* *Impact:* removes the Wi-Fi MITM downgrade path (F1) and the `adb backup` extraction path (F13). Two of the three "device attacker" paths closed.

5. 🟠 **Restore a real release keystore + enable minification + obfuscation; add Dio timeouts; add certificate pinning interceptor.** *Effort: 1 dev-day combined.* *Impact:* signing makes Play uploads possible (F2); obfuscation slows reverse-engineering (F3); timeouts close slow-loris (F4); pinning closes MITM in environments with hostile root CAs (F5). Pre-launch baseline.

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20) and the audit set `docs/AUDIT_ARCH.md` / `docs/AUDIT_STATE.md` / `docs/AUDIT_STRUCT.md` / `docs/AUDIT_QUALITY.md` / `docs/AUDIT_PERF.md`. All `.md` artefacts under `docs/` per project rule.*
