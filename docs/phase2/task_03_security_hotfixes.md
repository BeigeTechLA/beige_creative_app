# Task 2.03 — Security hotfixes

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 3h · **Priority:** 🔥 Critical

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/security-hotfix` |

## Goal
Close three production-grade security holes immediately: plaintext password persisted to `SharedPreferences`, Bearer token logged to console on every API call, cleartext HTTP allowed on Android. Independent of all later phases — land in week 1.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risks #3, #4; §5 Hard Blocker #5
- [`../audit/AUDIT_SEC.md`](../audit/AUDIT_SEC.md)
- [`../audit/AUDIT_REPORT.md`](../audit/AUDIT_REPORT.md) Top-10

## Files in scope (max 10)
- `lib/auth/login/login.dart` (line 111 — remove plaintext password persist)
- `lib/service/api_service.dart` (line 346 — strip token `print`)
- `lib/profile/myprofile.dart` (line 601 — strip token `print`)
- `android/app/src/main/AndroidManifest.xml` — set `android:usesCleartextTraffic="false"`
- `ios/Runner/Info.plist` — verify no `NSAllowsArbitraryLoads` true

## Steps
- [ ] Delete the `prefs.setString('password', ...)` line from login flow
- [ ] Replace `print('Bearer ...')` with nothing (or `debugPrint` of a non-secret diagnostic)
- [ ] Audit `grep -rn "token\|Bearer\|password" lib/ | grep -iE "print|log"` to catch other leak sites
- [ ] Set `usesCleartextTraffic="false"` in Android manifest
- [ ] Verify iOS ATS in `Info.plist` has no opt-out
- [ ] Manual smoke: login still works, no token in `adb logcat`

## Acceptance
- [ ] `grep -rn "password" lib/auth/login/login.dart | grep -i prefs` returns nothing
- [ ] `grep -rn "Bearer" lib/service/api_service.dart lib/profile/myprofile.dart | grep -i print` returns nothing
- [ ] `flutter run --flavor dev` shows no token in console during a login
- [ ] App still authenticates successfully

## Notes
Rotation of leaked credentials (Maps key, Stripe pk_test) is in [Task 2.05](task_05_secrets_dart_define.md). This task fixes only the in-source bugs; the rotation is out-of-repo work at vendor consoles.
