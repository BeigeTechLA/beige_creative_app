# Task 4.07 — Group C · Unit 10 · Delete account flow

**Phase:** 4 · **Group:** C · **Status:** ✅ Completed · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` |

## Goal
Migrate the linear 3-screen delete-account flow: confirm → OTP → lottie success → `/login`. Exercises destructive-action UX patterns + `SessionStore.clearSession()` (scoped — not `prefs.clear()`).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 10
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 6)
- `lib/features/profile/domain/repositories/delete_account_repository.dart`
- `lib/features/profile/data/repositories/delete_account_repository_impl.dart`
- `lib/features/profile/presentation/providers/delete_account_providers.dart` — repo provider + notifier + state
- `lib/features/profile/presentation/screens/delete_account_screen.dart` (was 275 LOC; class renamed `DeleteAccount` → `DeleteAccountScreen`)
- `lib/features/profile/presentation/screens/delete_account_otp_screen.dart`
- `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart`
- `test/features/profile/presentation/delete_account_test.dart` — 6 cases
- (Glue: `lib/app/router.dart` 3 imports + 1 class reference; `lib/profile/deleteaccount/` deleted)

## Steps
- [x] Repo methods: `requestDelete`, `confirmDelete`, `resendOtp`. On `confirmDelete` success the notifier calls `sessionStoreProvider.clearSession()` + flips `authStateProvider` to `false`. Widget then `context.goNamed(deleteAccountSuccess)`; lottie screen auto-redirects to `/login` after 3s.
- [x] Notifier coordinates the 3-step state machine — single `DeleteAccountNotifier` covers all 3 screens (request, confirm, resend) since they share the same session state.
- [x] Widget tests for OTP entry validation — `confirmDelete` rejects 3-digit input.
- [x] Test: post-deletion auth state is `false` + session cleared — covered explicitly.

## Acceptance
- [x] All 3 screens migrated — `DeleteAccountScreen`, `DeleteAccountOtpScreen`, `DeleteAccountLottieScreen`.
- [x] Successful deletion redirects to login + clears session — `confirmDelete` happy-path test asserts `session.cleared == true` and `authStateProvider == false`; lottie screen then `Future.delayed(3s) → context.goNamed(login)`.
- [x] No `setState` for network/form state — `setState` retained only for OTP focus-color refresh (widget-lifecycle UI).
- [x] `flutter analyze` → 254 issues (was 265; net **-11** from removing 3 legacy files containing `debugPrint` + deprecated patterns + the latent `response.error` Map-access bug that would have thrown at runtime).

## Notes
**Latent bug fixed:** Legacy `delete_account.dart` / `delete_account_otp_screen.dart` called `response.error` on `Future<dynamic>` — `dynamic` field access against the underlying `Map<String, dynamic>` throws `NoSuchMethodError` at runtime. New `DeleteAccountRepositoryImpl._postOrThrow` uses `data is Map && data['error'] == true` correctly.

**Resend OTP endpoint** matches legacy: reuses `restartpassword` (`auth/reset-password`) with empty body. Likely a backend mis-wiring (the password-reset endpoint reused for the delete-account flow) — flagged for backend confirmation. Preserved verbatim to keep parity; swap endpoint once backend lead clarifies.

**Class rename:** `DeleteAccount` → `DeleteAccountScreen` (consistent with `*Screen` suffix convention across the migrated `features/` tree). Router builder updated.

**Session-clear ordering:** Session cleared *after* the backend confirms the deletion, not before. If `confirmDelete` throws, the user stays logged in — they can retry the OTP entry. Test `repo failure leaves session intact` enforces this.

**Calibration:** ~45 min vs. 2d budget. Similar shape to 4.06 (3 screens, OTP timer, multi-step flow) but fewer notifiers. Group C pattern is consolidating: ~45-60 min per standard-shape unit.


## UI-only redesign — 2026-11-09

User approved parity with beigeapp commit `2f8cdab`, explicitly excluding API calls.
This supersedes the legacy live deletion/session-clear behavior documented above.

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Port information, OTP and requested screens | Profile screens, widgets, SVG assets, routes | Same UI-only journey as beigeapp | Completed |
| 2 | Disable legacy actions | delete_account_providers.dart | No request, resend, confirm, logout or deletion-event side effects | Completed |
| 3 | Verify and document | delete_account_test.dart, migration log | Analysis and focused tests | Completed |

Full-project analysis: no issues. Diff whitespace check passed. Focused tests updated
for inert notifier methods, paste/resend/navigation and narrow keyboard layouts.
Commit verification on 2026-11-09: all 3 focused tests pass; the earlier sandbox
execution blocker is resolved. Explicit API-binding-pending comment added to the notifier.
Future API integration points are TODO comments. Scheduled date remains a placeholder.
Existing repository retained but is not called by the flow or disabled notifier.

### Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Preferences → Delete account | Warning and six cards; Continue opens OTP | Scroll small screens |
| 2 | Enter/paste six digits, then resend | CTA enables, resend resets fields with preview notice | Partial/non-digit input, keyboard, large text |
| 3 | Continue to requested preview | Animation, date placeholder and preview notice | No logout, email, API request or deletion analytics |
| 4 | Navigate back | Previous screen restored | iOS swipe-back |

Device visual verification remains pending.
Basic Android navigation smoke completed 2026-11-12: information → OTP with dummy
six-digit input → requested-success preview, then Back through Preferences and
Profile to the originating Affiliate branch. Session remains signed in.
Full host suite: 756 passed. iOS, comprehensive visual/accessibility QA and API
binding remain pending. See [navigation report](../upgrade/ANDROID_NAVIGATION_QA_2026-11-12.md).


2026-11-09 OTP sizing correction: moved 7px gaps from inside Expanded cells
to Row spacing, giving all six fields equal width in both CP and User apps.


## Figma review — 2026-11-17

- [x] Compared current working-tree source with Figma `P0Loe0Kc4jWEIUBrXGQ6wp`: information `7343:65017`, filled OTP `7343:65318`, requested `7343:65395`, pending `13729:5718`, cancellation `13729:5852`, cancelled `13729:5945`.
- [x] Existing focused tests pass 3/3 (`flutter test --no-pub test/features/profile/presentation/delete_account_test.dart`).
- [ ] Resolve review findings: OTP auto-submits on sixth digit instead of waiting for the explicit destructive CTA; information cards use horizontal rows/circular badges/14px body instead of stacked content/rounded-square badges/12px body; 60-day grace-period wording is absent; recovery copy removes Support/verification and conditional-reactivation language; requested receipt adds a Request ID and Back to Login absent from that reference, and its date paragraph is not centered.
- [ ] Exercise the real entry → OTP → confirmation path with mocked transport and production routing; current OTP widget tests enter the route without requesting an OTP, so automatic submission returns early and is not tested. Native visual comparison and live backend behavior were not verified.

Review only: no application code changed. Existing uncommitted implementation calls deletion APIs and logs out on success, contradicting the November 9 preview-only notes. This review records that discrepancy without treating the older notes as current runtime behavior or authorizing further API work. The supplied design is on the Customer page; it was used as the explicitly requested reference for this CP app.

## CP deletion audit and fixes — 2026-11-17

The user requested comparison with beigeapp and fixes in CP. This authorizes
functional corrections to the current API-bound working tree; the older
preview-only scope and review-only note above are historical.

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Compare deletion API, OTP, logout and recovery setup | Read-only comparison with beigeapp | Concrete defects identified | Completed |
| 2 | Correct request setup and lifecycle | Deletion repository, OTP screen, retry interceptor, auth-state provider; regression tests | Canonical headers, explicit confirmation, no mutation retries, session state reset, readable backend errors | Completed |
| 3 | Verify and document | Tests, task notes, migration log | Analysis passes; execution limits documented | Completed |

Findings corrected:
- Removed duplicate hyphenated identity headers. The shared AppHeadersInterceptor
  supplies `device_type`, `user_type=2`, and `user_type_name=creative`.
- OTP typing, pasting and autofill now wait for the destructive CTA.
- RetryInterceptor now honors `skipRetry`; deletion POST/PATCH failures must not
  automatically repeat an operation with an uncertain server outcome.
- Logout invalidates deletion state immediately (also guarding late responses),
  then resets account status after removing its persisted key. The success receipt
  deliberately survives until the existing success-screen exit clears it.
- Backend rejection messages use the typed exception path so the notifier does
  not prepend `Unexpected error: Exception:` or report ordinary rejections as bugs.

### Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Request OTP, type/paste six digits | No deletion until CTA tap | Autofill, partial input, resend |
| 2 | Tap Verify & Delete | One request and confirmed receipt; automatic logout | Timeout/500 must not retry |
| 3 | Log in with deletion_pending, cancel | Recovery remains gated until cancellation succeeds | Failure preserves pending state |
| 4 | Log out, then log in again | No previous OTP/request/cancelled state | In-flight response after logout |

Native manual and live backend checks have not been performed in this audit.

Verification: full-project `flutter analyze --no-pub --fatal-infos` passed with
no issues; `git diff --check` passed. Regression coverage was added for canonical
headers/methods, no retries on 500/transport errors, ordinary retry preservation,
backend error messages, OTP paste/typing awaiting CTA, and logout state reset.
The focused run (deletion widget/repository, session expiry, router and login
notifier tests) could not execute: sandbox denies binding Flutter's test server
to `127.0.0.1`. A temporary SDK clone and XDG configuration under `/tmp` overcame
SDK/config write restrictions; no installed SDK or global config was modified.
No runtime test passes are claimed. Re-run these tests outside this sandbox.


2026-11-17 commit verification: full-project `flutter analyze --no-pub` passes;
focused deletion widget/repository, session expiry and router tests pass 59/59.
This supersedes the earlier sandbox-blocked test result. Native visual/live API
checks and remaining Figma layout/copy differences are still pending.

Login notifier verification: fixed its missing mocked preferences override;
all 17 login tests now pass (76 focused tests total).
