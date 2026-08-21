# Signup Flow — Token Management & "Go to Dashboard" Fix

Status: **planned** (not yet implemented)
Date: 2026-08-18
Branch: `improvments-phase1`

## Problem

On `SignUpSuccessScreen` (profile completion), the **Go to Dashboard**
button calls `signupNotifier.reset()` + `context.go(login)` — it dumps the
user back on the Login screen instead of taking them into the app.

Wanted:
1. **Go to Dashboard** takes the user *into* the app (`/home`), establishes a
   session token, calls get-profile, and shows the approved / under-review
   status from the returned flags.
2. **Token hygiene during signup**: if the user backs out to Login, or kills
   the app mid-flow (e.g. from Step 2), the in-progress token must be removed.

## Findings (current behaviour)

Two ways to reach `SignUpSuccessScreen`:

- **Fresh path** — brand-new signup Step1→2→3. `authState == false`, temp
  session empty. `registerStep1` returns only `crew_member_id`;
  `registerStep2` / `registerStep3` return no token. **No token anywhere.**
  (Confirmed at runtime via the `DEBUG(token-probe)` logs — step1 response
  carries no token.)
- **Resume path** — user logged in with an incomplete account
  (`is_registration_complete == 0`). Login placed a token in the **in-memory
  temp session** (`temporaryAuthSessionProvider`), `authState == true`.
  Finished Step2/3 → success screen. **Token already present.**

Token model already in place:

- **Temp session** (`temporaryAuthSessionProvider`) = process-only, in-memory.
  Dies on app kill. Never persisted.
- **Persistent store** (`SessionStore` → `SecureSessionStore`, Keychain /
  Keystore) = approved CPs, or under-review accounts on relaunch.
- **Promotion temp→persistent already auto-happens** in `home_notifier` and
  `profile_details_providers`: when get-profile returns
  `is_crew_verified == 1`, they write token + user + lastLoginAt to the
  persistent store and clear the temp session.

Router (`appRedirect` in `lib/app/router.dart`):

- `regComplete == 0` → forces back to Step2/3 (Case 1).
- `regComplete == 1 && crewVerified ∈ {0, 2}` → `/home` allowed, with a
  non-dismissible under-review / rejected status dialog (Case 2).
- `regComplete == 1 && crewVerified == 1` → full app (Case 3).

Why the current button dead-ends: even if it pointed at `/home`, the stale
`UserSnapshot` still has `regComplete == 0`, so the router bounces the user to
Step2. Flags must be refreshed first. And the fresh path has no token to enter
with.

Saved-login credential storage (already correct — no change needed):

- **Password** → `SecureStorageService` (Keychain / Keystore). Secure.
- **Email** → SharedPreferences (`PrefsKeys.savedLoginEmail`). Acceptable.
- **Token** → `SecureSessionStore`. Secure.

## Decision

Fresh signup has **no token**, so after Step 3 we **call the login API** with
the Step 1 email + password to obtain one. Reuse the existing login machinery
(`login_notifier`) so persistence stays consistent. No new credential storage
is introduced — password already lives in secure storage via the existing
remember-me path; email stays in shared prefs.

## Implementation plan

### Part A — "Go to Dashboard" enters the app

`signup_success_screen.dart` → convert to `ConsumerStatefulWidget`. Branch on
`authStateProvider`:

- **Fresh path** (`authState == false`):
  1. Hold the Step 1 password transiently so it survives to Step 3.
     - `signup_state.dart`: add `String password` (default `''`).
     - `signup_notifier.submitStep1`: store `password: password.trim()` in the
       success `copyWith` (already a method param). In-memory only; wiped by
       `reset()`. Mirrors the temp-session model — nothing new hits disk.
  2. On **Go to Dashboard**, call
     `ref.read(loginNotifierProvider.notifier).login(email, password)` with the
     stored creds. Existing login flow then persists token + user, calls
     `markLoggedIn()`, exits guest mode, and invalidates
     `currentSessionUserProvider`. Backend now reports
     `regComplete == 1, crewVerified == 0` → login's under-review-persist
     branch fires and the session survives relaunch.

- **Resume path** (`authState == true`, temp token present, no stored password):
  - Call get-profile (`profileFilesRepository.fetchProfile`, the same call
    Home uses) to refresh the snapshot so `regComplete` flips `0 → 1` and
    `is_crew_verified` is read. Temp token stays; promoted later by
    `home_notifier` if the CP is approved.

- **Both paths** then `signupNotifier.reset()` + `context.go(/home)`. Router
  Case 2 lands `/home` with the under-review dialog; `home_notifier` reads
  `is_crew_verified` and shows approved vs pending. If already approved,
  promotion auto-writes the persistent token.

- Button shows a spinner while the call runs. `ref.listen` surfaces errors via
  snackbar. Navigate **only** on success — bad creds / network keeps the user
  on the success screen with the error shown.

### Part B — token removal on back-to-login / app-close

- **App-close during signup**: temp session is in-memory → already dropped on
  kill. Confirm no persistent write happens anywhere in the signup flow
  (verified: none does). No code needed.
- **Back-to-login**: add `cancelSignup()` — clear temp session
  (`temporaryAuthSessionProvider.notifier.clear()`), set `authState = false`,
  `signupNotifier.reset()`, then `go(login)`. Wire it into:
  - the "Already have an account? Login" links on signup1 / signup2 / signup3,
  - a `PopScope` on Step2 / Step3 (system back button).
  Prevents the redirect from bouncing the user back into the flow and
  guarantees the in-progress token is gone.

### Part C — Step 2 is a point of no return (no back to Step 1)

Step 1 identity fields (name / email / password) create the account
server-side (`crew_member_id`). There is **no update API**, so returning to
Step 1 and re-submitting hits `registerStep1` → duplicate account →
"email already exists". Step 1→2 uses `goNamed` (replace), so at Step 2
`canPop()` is false and the current back button falls through to
`context.goNamed(signupStep1)` — the bug.

Current wiring: `signup2_screen.dart:169` passes `showBack: !widget.isResume`
(resume already hides it; fresh path shows the buggy back).

Fix:
- `signup2_screen.dart` — set `showBack: false` unconditionally. Step 2 is
  forward-only; user exits via the "Login" link (`cancelSignup`).
- `signup2_header.dart:52-58` — delete the
  `else context.goNamed(signupStep1)` fallback branch defensively, so no path
  can navigate back to Step 1.

### Cleanup

- Remove the three `DEBUG(token-probe)` `AppLogger.d` lines in
  `auth_repository_impl.dart` once the plan lands.

## Files touched

- `lib/features/auth/presentation/providers/signup_state.dart` — add
  transient `password`.
- `lib/features/auth/presentation/providers/signup_notifier.dart` — store
  password in `submitStep1`; add `cancelSignup()`.
- `lib/features/auth/presentation/screens/signup_success_screen.dart` — enter
  app logic (fresh auto-login vs resume refresh).
- `lib/features/auth/presentation/screens/signup1_screen.dart`,
  `signup2_screen.dart`, `signup3_screen.dart` — wire `cancelSignup()` into
  Login links + `PopScope`.
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — remove
  debug logs.
- `lib/features/auth/presentation/screens/signup2_screen.dart` — `showBack:
  false` (Part C).
- `lib/features/auth/presentation/widgets/signup2_header.dart` — drop the
  step1 fallback branch (Part C).

## Risks / verify

- Fresh-path assumes the backend flips `is_registration_complete → 1` after
  Step 3, so login persists and the router permits `/home`. If it still
  returns `0`, login keeps the account ephemeral and the router bounces to
  Step2 — confirm login-response flags at runtime and adjust if needed.
- Verify: `flutter analyze` + a widget test on the success screen; manual smoke
  of both fresh and resume paths, plus back-to-login and app-kill cases.
