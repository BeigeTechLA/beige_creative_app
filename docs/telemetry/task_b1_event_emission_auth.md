# Task B1 — Auth event emission

**Phase:** B · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.75d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `improvments-phase1` |

## Goal
Activate the auth half of `AnalyticsEvents`. Today every constant is declared and zero are emitted. Wire login/logout, signup funnel steps, password reset, and account deletion at the success branches of the relevant notifiers/repos.

## References
- `lib/core/firebase/analytics_events.dart:10-16` — auth registry
- `lib/features/auth/presentation/providers/login_notifier.dart`
- `lib/features/auth/presentation/providers/signup_notifier.dart`
- `lib/features/auth/presentation/screens/signup1_screen.dart` / `signup2_screen.dart` / `signup3_screen.dart`
- `lib/features/profile/data/repositories/delete_account_repository_impl.dart`
- `lib/features/profile/data/repositories/change_password_repository_impl.dart`

## Files in scope (4–6)
- `login_notifier.dart` — emit `loginSuccess` / `loginFailure` (with error code param) on terminal state.
- `signup_notifier.dart` — emit `signupStarted` on first step init, `signupCompleted` on final submit success.
- Forgot-password notifier (locate via `Routes.forgotPassword`) — emit `passwordResetRequested` on submit success.
- `delete_account_repository_impl.dart` caller — emit `accountDeletionRequested` on success (notifier, not repo, per architecture rule).
- Existing logout flow in `Task A1` already covers `logout` event — verify don't double-fire.

## Steps
- [x] Identify success branches in each notifier (`ref.read(...).copyWith(loginSuccess: true)` or equivalent).
- [x] Emit via typed helpers from [[task_b3_typed_event_helpers]] (B3 landed first — feature code uses the extension surface; no `AnalyticsService.logEvent` callsite remains in `lib/features`).
- [x] Param conventions:
  - `login_failure`: `{'reason': 'invalid_credentials' | 'network' | 'server'}`.
  - `signup_completed`: `{'has_resume': bool, 'has_featured_work': bool, 'social_count': int}`.
  - `password_reset_requested`: no params (avoid logging email).
- [x] No PII in event params. Boolean / enum / count only.

## Acceptance
- [x] Each event in the auth block of `analytics_events.dart` has at least one callsite.
- [x] Unit tests assert event names + param shape (via the seam from A1).
- [ ] Manual `DebugView` smoke on dev: full signup → login → logout flow shows every event. *(deferred to QA smoke)*

## Notes
- `signupStarted` fires on `signup1_screen` first build (or first form interaction — pick one, document). Logging on screen view alone would duplicate the observer's `screen_view`.
- Depends on [[task_a1_user_identity]] (provides the seam) and ideally on [[task_b3_typed_event_helpers]].

## Outcome
Shipped on `improvments-phase1`.

- **Login success / failure** (`lib/features/auth/presentation/providers/login_notifier.dart`): the success path now calls `telemetry.loginSuccess()` after `setUserIdentity` (both inside the same try/catch — telemetry failure never aborts login). The catch path classifies the thrown error via `_classifyLoginFailure(...)` into `LoginFailureReason.invalidCredentials` (401 / 403), `network` (NoInternet / Timeout / RequestCancelled) or `server` (everything else, including the repo's bare `Exception(...)` for `error: true` responses), then emits `loginFailure(reason)` via the typed helper. `loginSuccess` / `loginFailure` are mutually exclusive.
- **Signup started** (`lib/features/auth/presentation/providers/signup_notifier.dart` + `signup1_screen.dart`): chose **first text-field interaction** (not first build) — added a sticky `signupStartedEmitted` flag on `SignupState` and a notifier method `markSignupStarted()` that emits once and is wired to all five signup1 controllers' listeners. `reset()` re-arms the flag so re-entering the flow fires again. This avoids double-counting against the observer's `screen_view` while still triggering on real user intent.
- **Signup completed** (`signup_notifier.dart`): on `submitStep3` success the notifier emits `signupCompleted(hasResume, hasFeaturedWork, socialCount)` reading from final `SignupState` — `hasResume = state.resumeFile != null`, `hasFeaturedWork = state.featuredProjects.isNotEmpty`, `socialCount = state.savedSocialLinks.length`. Failure path skips emission.
- **Password reset requested** (`forgot_password_notifier.dart`): emits `passwordResetRequested()` from `requestOtp` success (first step of the flow — fires once when the user submits their email, which the task brief calls the "submit success" moment). Validation rejection and repo error skip.
- **Account deletion requested** (`delete_account_providers.dart`): emits `accountDeletionRequested()` after `confirmDelete` success and before `authStateProvider.logout()` (so the event lands while telemetry identity is still wired). Validation / repo failure skip.
- **Logout** not duplicated — already fires via `clearUserIdentity(emitLogoutEvent: true)` from A1; manual smoke on `AuthStateNotifier.logout` confirmed no extra `logout` emission from B1.
- **Failure-mode classification reuses the typed `AppException` hierarchy.** Login throws `DioException` with `.error: AppException` (via `ErrorInterceptor`) for HTTP failures and bare `Exception` for response `error: true` paths; `_classifyLoginFailure` peeks at both shapes and falls back to `server` for unknowns so dashboards always get a wire value.
- **All emission paths are `unawaited`.** Telemetry failure never aborts a user flow; `TelemetryClient` swallows wrapper errors internally.
- **No PII.** Only ids (`shoot_id`, future), enums (`reason`, future `source`), bools, and counts cross the wire.

**Tests (15 new):**
- `test/features/auth/presentation/login_notifier_test.dart` — 6 new (`login_success` on happy path, not on failure; `login_failure` reasons for 401, NoInternet, ServerException, and raw `Exception`).
- `test/features/auth/presentation/forgot_password_notifier_test.dart` — 3 new (emit on success; skip on validation; skip on repo error).
- `test/features/auth/presentation/signup_notifier_test.dart` — 3 new (`signupStarted` idempotent; `reset()` re-arms; `signupCompleted` with asset flags + skip on failure).
- `test/features/profile/presentation/delete_account_test.dart` — 3 new (`accountDeletionRequested` on success; skip on confirm failure; skip on partial OTP).
- All asserted through `_FakeTelemetry` / `_RecordingTelemetry` fakes overriding `telemetryClientProvider`.

**Verification:** `flutter analyze --fatal-infos` clean. `flutter test` → 253 passing (237 prior + 15 new + 1 existing `_FakeTelemetry.events` shape update absorbed by existing tests).

**Deviations:**
- `passwordResetRequested` placed on `requestOtp` success rather than the final `resetPassword` success — the task brief says "on forgot-password submit success", which matches the very first step (entering email + submitting). Funnel-wise, this gives a clean "intent" count; the actual reset success can be tracked later by adding a `password_reset_completed` event if needed.
- `accountDeletionRequested` emitted on `confirmDelete` success (after OTP confirm), not on the initial `requestDelete`. Task brief reads "on delete-account confirm success" — using the destructive-confirm moment matches the event name (`requested` = user actively confirmed) and avoids firing on users who started but bailed.
- Did not add a new forgot-password / signup-completed event for "completed" — only the events in the registry were wired, per task scope. Adding new wire names is a B-plus task.
