# SharedPreferences Centralization — Implementation Plan

> **Goal:** Replace scattered `SharedPreferences.getInstance()` calls with single typed `PrefsService` + `PrefsKeys` registry. Fix typos, dead keys, plaintext password storage.
>
> **Scope:** Service layer + call-site migration. No UX changes.
>
> **Status:** ✅ Phases 1–7 complete (code). Manual QA pending on device.

---

## Status Legend
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ⛔ Blocked
- ❌ Skipped (with reason)

---

## Current State Snapshot (post-migration)

| Item | Before | After |
|------|--------|-------|
| Direct `SharedPreferences.getInstance()` call sites | 9 | 1 (inside `PrefsService`) |
| Unique keys in use | 11 | 2 active (`isLoggedIn`, `saved_login_email`) + token & password in secure storage |
| Keys written but never read | 6 | 0 |
| Keys read but never written | 1 (`folder`) | 0 |
| Plaintext password in prefs | Yes | No (Keychain/Keystore) |
| Plaintext token in prefs | Yes | No (Keychain/Keystore, memory-cached) |
| Key constants defined | 0 | All in `PrefsKeys` |

### Affected Files
- `lib/service/prefs_keys.dart` — **new** key registry
- `lib/service/prefs_service.dart` — **new** typed cached wrapper + migrations
- `lib/service/secure_storage_service.dart` — **new** Keychain/Keystore layer
- `lib/service/shared_service.dart` — rewritten on top of `PrefsService`
- `lib/service/api_service.dart` — token reads via `PrefsService`, dead `getFolder` removed
- `lib/main.dart` — `PrefsService.init()` before `runApp`, dropped direct prefs read
- `lib/splash/splash_screen.dart` — `PrefsService.isLoggedIn`, fixed `isloggin` typo
- `lib/auth/login/login.dart` — credential save/load through `PrefsService`, dead `_loadSavedLogin` + `_checkSavedEmail` deleted

---

## Phase 1 — Foundation (no behavior change)

| # | Task | Files | Status |
|---|------|-------|--------|
| 1.1 | Create `lib/service/prefs_keys.dart` with `PrefsKeys` constants | new | ✅ |
| 1.2 | Create `lib/service/prefs_service.dart` — static `init()` caches `SharedPreferences`, typed getters/setters, `clearAuth()` | new | ✅ |
| 1.3 | Call `await PrefsService.init()` in `startApp()` before `runApp()` | `lib/main.dart` | ✅ |
| 1.4 | `flutter analyze` clean | — | ✅ |
| 1.5 | Smoke test: app boots dev + prod flavors | — | ⬜ (manual, run on device) |

---

## Phase 2 — Migrate Reads

| # | Task | Files | Status |
|---|------|-------|--------|
| 2.1 | Replace token reads with `PrefsService.token` | `lib/service/api_service.dart` (header + multipart) | ✅ |
| 2.2 | Replace `folder` read with `PrefsService.folder`; flag phantom writer for Phase 6 | `lib/service/api_service.dart` | ✅ |
| 2.3 | Replace `isLoggedIn` read with `PrefsService.isLoggedIn` | `lib/main.dart` | ✅ |
| 2.4 | Replace `isLoggedIn` read + fix `isloggin` typo | `lib/splash/splash_screen.dart` | ✅ |
| 2.5 | Auth header request path verified | — | ⬜ (manual login + authenticated GET) |

---

## Phase 3 — Migrate Writes + Logout

| # | Task | Files | Status |
|---|------|-------|--------|
| 3.1 | Rewrite `SharedService.setLoginDetails()` via `PrefsService` setters | `lib/service/shared_service.dart` | ✅ |
| 3.2 | Swap `SharedService.logout()` from `prefs.clear()` → `PrefsService.clearAuth()` | `lib/service/shared_service.dart` | ✅ |
| 3.3 | Selective logout preserves non-auth state | — | ✅ (covered by `PrefsKeys.authKeys`) |
| 3.4 | Login → home → logout → login round-trip test | — | ⬜ (manual) |

---

## Phase 4 — Login Credentials Cleanup

| # | Task | Files | Status |
|---|------|-------|--------|
| 4.1 | Rename keys `email`/`password` → `savedLoginEmail`/`savedLoginPassword` | `lib/auth/login/login.dart` | ✅ |
| 4.2 | Dedupe `_loadSavedLogin()` vs `_loadSavedCredentials()` — kept the live one, deleted dead `_loadSavedLogin` and unused `_checkSavedEmail` | `lib/auth/login/login.dart` | ✅ |
| 4.3 | Route all credential call sites through `PrefsService` | `lib/auth/login/login.dart` | ✅ |
| 4.4 | Migration shim: on first boot copy OLD keys → NEW keys, delete OLD | `lib/service/prefs_service.dart::migrateLegacyRememberMe()` | ✅ |
| 4.5 | Unchecking "save password" now clears stored credentials | `lib/auth/login/login.dart` | ✅ (added `clearSavedLogin` branch) |

---

## Phase 5 — Security: Secure Credential Storage

| # | Task | Files | Status |
|---|------|-------|--------|
| 5.1 | Add `flutter_secure_storage ^9.2.2` to `pubspec.yaml` | `pubspec.yaml` | ✅ |
| 5.2 | Create `SecureStorageService` wrapping Keychain/Keystore (`encryptedSharedPreferences: true` on Android, `first_unlock` accessibility on iOS) | new | ✅ |
| 5.3 | Move `savedLoginPassword` to secure storage (async read) | `lib/service/prefs_service.dart` | ✅ |
| 5.4 | Move `token` to secure storage; in-memory cache primed at startup for sync header reads | `lib/service/prefs_service.dart`, `lib/service/secure_storage_service.dart` | ✅ |
| 5.5 | Migration: copy plaintext token/password from prefs → secure storage, delete plaintext | `lib/service/prefs_service.dart::_migratePlaintextSecrets()` + `migrateLegacyRememberMe()` | ✅ |
| 5.6 | iOS + Android device test (Keychain/Keystore actually used) | — | ⬜ (manual) |

---

## Phase 6 — Dead Code Pass

| # | Task | Status |
|---|------|--------|
| 6.1 | Drop dead user-identity prefs (`id`/`name`/`email`/`role`/`user_type`/`profile_image_url`) — never read | ✅ (writes removed from `SharedService`, stripped on upgrade by migration) |
| 6.2 | Resolve `folder` phantom: removed `ApiService.getFolder()` (no caller); old key wiped on upgrade | ✅ |
| 6.3 | Trim `PrefsKeys` to only live entries (+ legacy migration constants) | ✅ |

---

## Phase 7 — Verification

| # | Task | Status |
|---|------|--------|
| 7.1 | `flutter analyze` zero new warnings on touched files | ✅ (all 12 hits pre-existing) |
| 7.2 | `flutter test` passes | ❌ skipped — sole test file `test/widget_test.dart` is fully commented out (pre-existing) |
| 7.3 | Grep confirms zero `SharedPreferences.getInstance()` outside `lib/service/prefs_service.dart` | ✅ |
| 7.4 | Grep confirms zero raw key strings (`prefs.getString('…')` etc.) outside service layer | ✅ |
| 7.5 | Manual QA: fresh install + upgrade-over-old-build, login/logout, remember-me, secure storage round-trip | ⬜ (run on device) |

---

## Risks

| Risk | Mitigation | Resolution |
|------|------------|-----------|
| Existing users lose remember-me credentials on key rename | Phase 4.4 migration shim | ✅ Implemented |
| `prefs.clear()` removal breaks unknown caller assumption | Grep showed only `SharedService.logout()` calls it | ✅ Verified safe |
| Secure storage adds async overhead to token reads | Cache token in memory after `primeCache()` at startup | ✅ Implemented |
| iOS Keychain persists across app uninstall | Documented; not an issue for this app (login flow handles stale token via 401) | ✅ Documented |
| Migration runs every boot | `_migratePlaintextSecrets` and `migrateLegacyRememberMe` are idempotent + cheap | ✅ Verified |

---

## Followups (out of plan, candidates)

- Remove the legacy migration shim after one full release cycle has shipped to users
- Add unit tests for `PrefsService` migration paths (currently no test infra)
- Consider moving `SharedService.setLoginDetails` JSON parsing into the API response model layer
- Audit other features for prefs needs that should land here instead of new raw-key usage
