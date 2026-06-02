# Task A1 — User identity on login/logout

**Phase:** A · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `telemetry/a1-user-identity` |

## Goal
Propagate the authenticated user into Firebase Analytics (`setUserId`) and Crashlytics (`setUserIdentifier` + `user_role` custom key) on login success. Clear both on logout. Without this, every crash report is anonymous and every event lacks user-scoped funnels.

## References
- `lib/core/firebase/analytics_service.dart:90` — `setUserId`
- `lib/core/firebase/crashlytics_service.dart:55` — `setUserIdentifier`
- `lib/core/firebase/crashlytics_keys.dart:11` — `userId`, `userRole`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/core/session/session_store.dart`

## Files in scope (3)
- `lib/features/auth/presentation/providers/login_notifier.dart` (or auth notifier wherever login-success branch lives) — emit identity wiring + `logLogin` + `loginSuccess` event.
- `lib/core/session/session_store.dart` (or logout call site) — clear identity in the same place tokens are cleared.
- `test/features/auth/login_notifier_test.dart` (new or existing) — assert identity wiring fired.

## Steps
- [x] On login success: call `AnalyticsService.setUserId(user.id)`, `CrashlyticsService.setUserIdentifier(user.id)`, `CrashlyticsService.setCustomKey(CrashlyticsKeys.userRole, user.role)`, `AnalyticsService.logLogin(method: 'password')`.
- [x] On logout (incl. 401-triggered): call `AnalyticsService.setUserId(null)`, `CrashlyticsService.setUserIdentifier('')`, `AnalyticsService.logEvent(AnalyticsEvents.logout)`.
- [x] Verify `AuthInterceptor.onUnauthorized` path also hits the same clear step (don't leave a stale identity after token expiry).
- [x] Unit test stubs `AnalyticsService` / `CrashlyticsService` via a thin seam (see Notes).

## Acceptance
- [x] `flutter analyze` clean.
- [x] New test asserts `setUserId` + `setUserIdentifier` called exactly once on login, exactly once with null/empty on logout.
- [ ] Manual: log in on dev flavor → user id appears under Crashlytics "User identifier" within minutes. *(deferred to QA smoke)*

## Outcome
Shipped on `improvments-phase1`.

- **New file:** `lib/core/firebase/telemetry_client.dart` — `TelemetryClient` interface + `FirebaseTelemetryClient` default + `telemetryClientProvider`. Single seam over `AnalyticsService` / `CrashlyticsService` for the notifiers that need to be unit-tested. Surface: `setUserIdentity`, `clearUserIdentity`, `logEvent`, `recordError` (Phase B+ will extend).
- **Login success path** (`lib/features/auth/presentation/providers/login_notifier.dart`): after `markLoggedIn`, calls `telemetryClientProvider.setUserIdentity(userId: user.id, userRole: user.role)` (which internally fires `setUserId` + `setUserIdentifier` + `user_id`/`user_role` custom keys + `logLogin('password')`). Wrapped in try/catch so a telemetry hiccup never fails login.
- **Explicit logout** (`lib/core/providers/auth_state_provider.dart`): `AuthStateNotifier.logout()` now calls `clearUserIdentity(emitLogoutEvent: true)` after session/restoration/draft clears.
- **401 / token-expiry path** (`lib/core/providers/core_providers.dart`): `AuthInterceptor.onUnauthorized` callback now also clears telemetry identity (with `emitLogoutEvent: false` — the user didn't choose this).
- **Tests** (`test/features/auth/presentation/login_notifier_test.dart`): added `_FakeTelemetry` + 4 new cases covering identity-set on success with role, no-op when user payload missing, no-op on login failure, logout-clears-identity-with-event.

**Verification:** `flutter analyze --fatal-infos` clean. `flutter test` → 209 passing (4 new).

**Deviation:** No `loginSuccess` event emitted in the registry yet — that lives in B1 per the task plan. A1 only wires `logLogin` (the Firebase-builtin auth event).

## Notes
- Both services are currently static singletons with no test seam. Either (a) introduce a `TelemetryClient` interface + provider that the notifier depends on, or (b) test via integration smoke and skip the unit test. (a) preferred — adds 1 file, unlocks B1/B2/B5 testing too.
- Do NOT log the user's email or PII as the user id. Use the backend user id.
- Cross-link: [[task_b1_event_emission_auth]] picks up `login_failure`, `signup_*`, `password_reset_requested`.
