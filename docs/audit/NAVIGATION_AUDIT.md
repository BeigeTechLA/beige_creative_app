# NAVIGATION AUDIT — beige_creative_app

**Date:** 2026-05-21
**Branch:** improvments-phase1
**Scope:** Full deep audit. Findings-only (no fix recommendations). Includes Flutter routing + native deep-link layer.

---

## 0. Executive summary

| Area | Status |
|------|--------|
| Router library | `go_router 14.8.1`, single `appRouter` in `lib/app/router.dart` |
| Route table size | 30 declared `GoRoute`s; 1 commented-out; 2 dead constants in `RouteNames` |
| Navigation styles in use | `context.pushNamed` (32), `context.goNamed` (14), `context.pop` (44), `Navigator.push` (26), `Navigator.pop` (55), `Navigator.pushReplacement` (5), `Navigator.pushAndRemoveUntil` (1), `Navigator.of` (1), `MaterialPageRoute` (31) |
| Mixed-paradigm risk | High — raw `Navigator` + `MaterialPageRoute` used in 19 files alongside go_router |
| Deep-link config | **None** on Android, iOS, macOS, web. No `redirect:` in router. No `uni_links`/`app_links`/`firebase_dynamic_links` deps. |
| Back-handling | No `PopScope`/`WillPopScope`/`SystemNavigator.pop`/`onWillPop` anywhere in the tree |
| Tab shell | `_pages[_selectedIndex]` swap (no `IndexedStack`) → tab state lost on switch |
| Login gate | `isLoggedIn` read in `startApp` but unused by router; splash re-reads prefs and routes |
| Orphan screens | 2 fully unreferenced; 1 reachable only via raw `Navigator.push` |

---

## 1. Route table (declared in `lib/app/router.dart`)

| Path | Name constant | Builder | Args (via `state.extra`) |
|------|---------------|---------|--------------------------|
| `/splash` | `splash` | `SplashScreen` | — |
| `/onboarding` | `onboarding` | `OnboardingScreen` | — |
| `/login` | `login` | `Login` | — |
| `/signup-step-1` | `signupStep1` | `SignUp1Screen` | — |
| `/signup-step-2` | `signupStep2` | `SignUp2Screen` | 8 keys (crewMemberId, profileImage, email, firstName, lastName, location, workingDistance, step1Progress) |
| `/signup-step-3` | `signupStep3` | `SignUp3Screen` | 14 keys |
| `/forgot-password` | `forgotPassword` | `ForgotPasswordScreen` | — |
| `/forgot-otp` | `forgotOtp` | `ForgotPasswordOtpScreen` | email |
| `/reset-password` | `resetPassword` | `ResetPasswordScreen` | email, otp |
| `/home` | `home` | `Mainscreen` (shell) | — |
| `/upcoming-shoot-details` | `upcomingShootDetails` | `UpcomingShootViewDetils` | projectId |
| `/cancel-shoot` | `cancelShoot` | `CancelScreen(projectId)` | projectId |
| `/add-availability` | `addAvailability` | `AddAvailabilityScreen` | — |
| `/delete-account` | `deleteAccount` | `DeleteAccount` | — |
| `/delete-account-otp` | `deleteAccountOtp` | `DeleteAccountOtpScreen` | — |
| `/delete-account-success` | `deleteAccountSuccess` | `DeleteAccountLottieScreen` | — |
| `/view-details` | `viewDetails` | `ViewDetailsScreen` | 13 keys |
| `/my-profile` | `myProfile` | `Myprofile` | — |
| `/shoot-cancelotties` | `shootCancelotties` (value=`"shoot-cancellooties"`) | `ShootCancelledLottiesScreen` | — |
| *(commented out)* | `changePassword` | — | — |
| `/edit-personal-details` | `editPersonalDetails` | `EditPersonalDetailsScreen` | — |
| `/enter-professional-details` | `enterProfessionalDetails` | `EnterProfileDetailsScreen` | — |
| `/profile-details` | `profileDetails` | `ProfileDetils1screen` | — |
| `/featured-works` | `featuredWorks` | `FeaturedWorkList` | — |
| `/certificates` | `certificates` | `Certificates` | — |
| `/resume` | `resume` | `Resume` | — |
| `/app-preferences` | `appPreferences` | `AppPreferences` | — |
| `/profile-password-success` | `profilePasswordSuccess` | `MyprofileYoureAllSetScreen` | — |
| `/shoot-Cancel` | `shootCancel` | `const CancelScreen()` (no projectId) | — |
| `/post-production` | `postProduction` | `PostProductionScreen` | — |
| `/pre-production` | `preProduction` | `PreProductionScreen` | — |

---

## 2. Findings

### F-01 — Raw `Navigator` + `MaterialPageRoute` mixed into go_router app
**Severity:** High
**Locations:** 26 `Navigator.push`, 5 `Navigator.pushReplacement`, 1 `Navigator.pushAndRemoveUntil`, 1 `Navigator.of`, 31 `MaterialPageRoute` across 19 files. Notable:
- `lib/auth/login/login.dart:115` — `Navigator.pushAndRemoveUntil` to `Mainscreen` (parallel route to `goNamed(home)` at line 120 in same file — login uses two different nav styles)
- `lib/auth/login/login.dart:437` + `:439` — raw `Navigator.push` + `MaterialPageRoute`
- `lib/auth/sign_up/signup1_screen.dart:647`, `lib/auth/sign_up/signup3_screen.dart:1135`, `lib/auth/resetpassword/reset_password_screen.dart:83` — `Navigator.pushReplacement`
- `lib/splash/splash_screen.dart:40` + `:42` — `Navigator.pushReplacement` + `MaterialPageRoute` (lives next to `goNamed` calls at lines 46/49)
- `lib/onboding/onboding_screen.dart:196` + `:198` — `Navigator.pushReplacement` + `MaterialPageRoute`
- `lib/home/home_screen.dart:625, 1065, 1515, 1522, 1681` — five raw pushes from Home
- `lib/Profile/myprofile.dart:1098, 1619` — raw push from profile
- `lib/widgets/commonFileViewer.dart:20` + `:22` — shared widget uses raw nav
- `lib/utility/app_utils.dart:121` — `Navigator.of(context)` in shared util

**Effect:** Screens reached via raw push are invisible to go_router (no name, no URL, no deep-link, no `state.extra`); back-stack is a hybrid of go_router stack and Navigator stack which can desync.

---

### F-02 — Tab content rebuilt on every switch (no `IndexedStack`)
**Severity:** High
**Location:** `lib/main_screen.dart:120` — `body: _pages[_selectedIndex]`.
`_pages` is `late final` (`lib/main_screen.dart:91-98`) holding 5 `const`/non-const screens. Each switch swaps the widget, so scroll position, controllers, fetched lists, and any local state inside `HomeScreen`/`ShootsScreen`/`FileManagerScreen`/`MessagesScreen`/`ManageAvailabilityScreen` are dropped on tab change.

---

### F-03 — Bottom-nav index 4 is unreachable from bottom nav; only drawer surfaces it
**Severity:** Medium
**Location:** `lib/main_screen.dart:136` — `currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex`. The bottom nav has 4 items (`_pages[0..3]`); `ManageAvailabilityScreen` is `_pages[4]`, reachable only from the drawer (`_drawerBottomItem("Manage Availability", ..., 4)` at `lib/main_screen.dart:346`). When `_selectedIndex == 4`, the bottom bar lies — it highlights index 0 while index 4 content is shown. No visual indication user is on a non-tab screen.

---

### F-04 — Splash re-reads `isLoggedIn`; main.dart's read is dead
**Severity:** Medium
**Locations:** `lib/main.dart` (`startApp` reads `isLoggedIn` from prefs before `runApp`) and `lib/splash/splash_screen.dart:32-55` (`_goToNextScreen` re-reads same key and routes).
Router `initialLocation: '/splash'` (`lib/app/router.dart:49`) ignores the first read. There is no `redirect:` on the router. Splash is the only auth gate.

---

### F-05 — Logout doesn't clear the navigation stack
**Severity:** High
**Location:** `lib/Profile/myprofile.dart:2801-2803`:
```
await SharedService.logout(); // prefs.clear()
context.goNamed(RouteNames.login);
```
`SharedService.logout` (`lib/service/shared_service.dart:45-49`) wipes prefs entirely. `goNamed` does not necessarily clear the underlying stack of go_router pages — depending on stack state at logout time, a back-gesture from `/login` may resurrect the previously authenticated screen tree (which then makes API calls with a null token).
Same pattern in:
- `lib/Profile/deleteaccount/delete_account_lottieScreen.dart:30` (`goNamed(login)` after delete-account)
- `lib/Profile/myprofile_youre_all_set_screen.dart:30` (`goNamed(login)`)
- `lib/auth/sign_up/signup3_screen.dart:259` (`goNamed(login)`)

---

### F-06 — Duplicate route to `CancelScreen` with mismatched signatures
**Severity:** Medium
**Locations:** `lib/app/router.dart:188-198` (`/cancel-shoot`, passes `projectId`) and `lib/app/router.dart:347-351` (`/shoot-Cancel`, builds `const CancelScreen()` with no `projectId`).
`CancelScreen` constructor (`lib/Shoots/shoot_cancelled_screen.dart:12`) accepts optional `projectId`. Any code calling `pushNamed(RouteNames.shootCancel)` lands on a screen with `projectId == null`, which will break cancel-API calls. The actual caller is `lib/shoots/shoots_screen.dart:576` using `RouteNames.shootCancel` — no projectId is forwarded.

---

### F-07 — Dead / unused name constants
**Severity:** Low
**Location:** `lib/app/route_names.dart`. Declared but never registered as a `GoRoute`:
- `signup` (line 9)
- `viewShootDetails` (lines 80-81)
- `changePassword` (lines 43-44) — its route is commented out (`lib/app/router.dart:282-289`) with an invalid empty builder `const ()`. A reference exists: `lib/Profile/profiledetils/edit_personal_details_screen.dart:537` does `pushNamed(RouteNames.changePassword)` — this call will throw at runtime (`GoError: no routes for name`).

---

### F-08 — Typo bomb: `shootCancelotties` constant value contains a misspelling
**Severity:** Low
**Location:** `lib/app/route_names.dart:68-69` → value `"shoot-cancellooties"` (extra `o`, double `l`). The router path is `/shoot-cancelotties` (`lib/app/router.dart:275`). Name lookup is still consistent (the constant is the same string both sides), but the constant name and value have diverged from the path. Any developer typing the value verbatim will get it wrong.

---

### F-09 — Import case mismatches that will break Linux/case-sensitive CI
**Severity:** High (latent — passes on macOS/HFS+/APFS default, fails on Linux CI / strict Docker)
**Locations:** `lib/app/router.dart`:
- Line 5: `'../ManageAvailability/add_availability_screen.dart'` — actual folder is `lib/manageavailability/`
- Line 18: `'../Shoots/shoot_cancelled_lotties_screen.dart'` — actual folder is `lib/shoots/`
- Line 19: `'../Shoots/shoot_cancelled_screen.dart'` — actual folder is `lib/shoots/`
- Line 20: `'../UpcomingShootViewdetils/upcoming_shoot_view_detils.dart'` — actual folder is `lib/upcomingshootviewdetils/`

The `lib/` top-level inventory confirms folders: `Profile`, `auth`, `config`, `file_manager`, `home`, `manageavailability`, `messages`, `model_class`, `onboding`, `service`, `shoots`, `splash`, `upcomingshootviewdetils`, `utility`, `widgets`. Only `Profile` is capitalized.

---

### F-10 — Orphan screens
**Severity:** Low
- `lib/file_manager/view_details_screen.dart` (`ViewDetailsScreen`) — defined, never imported, never routed. Name collides with `lib/auth/view_details_screen .dart` (note trailing space in filename).
- `lib/Profile/profile_new_passwrod_screen.dart` (`MyprofileNewPasswrodScreen`) — defined, never imported. References to `RouteNames.changePassword` exist but its route is commented out (F-07).
- `lib/auth/view_details_screen .dart` — **filename has a literal space** before `.dart`. The router imports `'../auth/view_details_screen .dart'` (`lib/app/router.dart:42`) including the space. Works but is fragile on any tool that trims whitespace.

---

### F-11 — Screen reachable only via raw `Navigator.push` (bypasses go_router)
**Severity:** Medium
**Location:** `lib/shoots/shoot_request_accepted.dart:11` — `ShootRequestAccepted`. Reached only from `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:691, 693` via `Navigator.push(MaterialPageRoute(...))`. No name, no path, not deep-linkable.

---

### F-12 — `app/app.dart` is dead but still in the tree
**Severity:** Low (cleanliness)
**Location:** `lib/app/app.dart` — entire file commented out. References Riverpod (`ConsumerWidget`, `routerProvider`) and `AppTheme.dark()` which aren't wired. CLAUDE.md already flags this. Confirmed live root is `MyApp` in `lib/main.dart`.

---

### F-13 — No back-press handling anywhere
**Severity:** Medium
**Searched:** `WillPopScope`, `PopScope`, `onWillPop`, `SystemNavigator.pop` — **0 hits** across the entire `lib/` tree.
Effect: Android hardware-back from any screen always pops (or exits when stack is empty). No "press back again to exit" on Mainscreen, no "discard form?" guard on signup flow, no protection on in-progress availability/booking flows.

---

### F-14 — Argument typing is implicit and lossy
**Severity:** Medium
**Location:** Router builders. Every screen with args uses `state.extra as Map<String, dynamic>? ?? {}` (e.g. `lib/app/router.dart:87, 108, 142, 156, 239`) and unpacks individual keys with `?? ""`/`?? 0`/`?? []`. Two routes use `state.extra as Map<String, dynamic>` (non-nullable, no `?? {}`) — `lib/app/router.dart:179, 192` — and will throw if called without `extra`. Specifically:
- `/upcoming-shoot-details` (line 179)
- `/cancel-shoot` (line 192)
No compile-time guard exists; a caller forgetting `extra: {...}` only fails at navigation time.

---

### F-15 — Drawer mixes `Navigator.pop` (close drawer) with go_router navigation
**Severity:** Low
**Location:** `lib/main_screen.dart:389` — `Navigator.pop(context)` closes the drawer (legitimate — drawer is a Navigator overlay). `lib/main_screen.dart:225` uses `context.pop()` for the same close action elsewhere. Inconsistent.

---

### F-16 — Shared widgets/utilities reach for `Navigator` directly
**Severity:** Medium
**Locations:**
- `lib/widgets/commonFileViewer.dart:20, 22, 28` — opens a viewer via raw `Navigator.push(MaterialPageRoute(...))` and pops via `Navigator.pop`.
- `lib/utility/app_utils.dart:76, 87, 95, 111, 121` — modal/dialog helpers use `Navigator.of(context).pop()` and raw `showDialog`/`showModalBottomSheet`.
These helpers are called from many feature screens; standardizing them would clean up the largest share of raw-Navigator calls.

---

### F-17 — Profile-image upload screen launches a route then expects a return value via `.then`
**Severity:** Low
**Location:** `lib/main_screen.dart:243-248`:
```
context.pushNamed(RouteNames.myProfile).then((value) { fetchprofiledata(); });
```
`pushNamed` returns a `Future<T?>` that completes when the route is popped, but `fetchprofiledata` runs on any pop regardless of why the user navigated back. This is fine, but worth noting because the same pattern is duplicated and the result `value` is never read.

---

### F-18 — Login route uses both go_router and raw Navigator in the same flow
**Severity:** Medium
**Location:** `lib/auth/login/login.dart`:
- Line 115: `Navigator.pushAndRemoveUntil` → `Mainscreen()` directly (bypasses go_router; `/home` is not entered, so the URL/stack don't reflect the live screen)
- Line 120: `context.goNamed(RouteNames.home)` (correct path)
- Line 352: `pushNamed(forgotPassword)` (correct)
- Line 437/439: `Navigator.push` + `MaterialPageRoute` (raw)
- Line 443: `pushNamed(signupStep1)` (correct)

Suggests refactor-in-progress; two code paths to the same destination.

---

### F-19 — Tab navigation discards transient state with no warning
**Severity:** Medium
**Location:** `lib/main_screen.dart`. Combined with F-02, when a user is in the middle of editing in one tab and taps a different tab, all transient widget state (text fields, scroll, expand/collapse, fetched lists) is dropped silently.

---

## 3. Deep-link / native audit

### F-20 — Zero deep-link configuration on any platform
**Severity:** Medium (depends on product intent — flagged because the app has share-relevant content like shoot details and shoot cancellation that would benefit from linkability)

**Android (`android/app/src/main/AndroidManifest.xml`):**
- Single `<intent-filter>` with `MAIN` + `LAUNCHER` only (lines 38-41)
- No `<data android:scheme="...">` (no custom URL scheme)
- No `<data android:host="...">` + `autoVerify` (no App Links)
- No `FlutterDeepLinkingEnabled` meta-data
- `MainActivity` is `singleTop` + `exported=true`
- No `assetlinks.json` for App Links verification
- Debug/profile manifests carry no intent-filters

**iOS (`ios/Runner/Info.plist`):**
- No `CFBundleURLTypes` / `CFBundleURLSchemes` — no custom scheme registered
- No `FlutterDeepLinkingEnabled`
- No `LSApplicationQueriesSchemes`
- No `Runner.entitlements` file at all → no `com.apple.developer.associated-domains` → no Universal Links

**macOS (`macos/Runner/Info.plist` + `DebugProfile.entitlements` + `Release.entitlements`):**
- No `CFBundleURLTypes`
- No `com.apple.developer.associated-domains`
- Only sandbox/network entitlements present

**Web (`web/manifest.json`, `web/index.html`):**
- `start_url: "."`, no `share_target`, no `protocol_handlers`

**Dart side:**
- No `uni_links` / `app_links` / `firebase_dynamic_links` / `flutter_branch_sdk` / `flutter_appsflyer_sdk` in `pubspec.yaml`
- `GoRouter` has **no `redirect:` callback** — auth/login state cannot affect deep-link resolution
- `initialLocation: '/splash'` (`lib/app/router.dart:49`) hard-coded; any incoming deep link would be overwritten by splash anyway

**Net:** The app cannot be opened by URL on any platform today.

---

### F-21 — Routes pass arguments via `state.extra` (non-serializable map)
**Severity:** Medium (precondition for deep-linking even if F-20 were fixed)
**Effect:** Even if Universal Links / App Links were added, the routes for `/upcoming-shoot-details`, `/cancel-shoot`, `/signup-step-2`, `/signup-step-3`, `/forgot-otp`, `/reset-password`, `/view-details` cannot be entered from a URL — they all rely on `state.extra` (a runtime-only `Map<String, dynamic>`) instead of path/query params. CLAUDE.md documents this as the convention. Listed here so deep-link planning accounts for it.

---

### F-22 — `singleTop` launch mode without intent handling
**Severity:** Low
**Location:** `android/app/src/main/AndroidManifest.xml:26-42`. `launchMode="singleTop"` is configured (appropriate for future deep-link reuse of activity), but no `onNewIntent` Dart hook is wired (no `uni_links`/`app_links` plugin). If deep links are added later, this attribute is already in the right state.

---

## 4. Raw-call inventory (cross-reference for cleanup work)

### `Navigator.push(...)` — 26 sites
`lib/Profile/deleteaccount/delete_account.dart:142`, `lib/Profile/myprofile.dart:1098`, `lib/Profile/myprofile.dart:1619`, `lib/Profile/profiledetils/profile_detils_1screen.dart:491`, `lib/Profile/profiledetils/profile_detils_1screen.dart:498`, `lib/auth/forgotpassword/forgot_password_otp_screen.dart:100`, `lib/auth/forgotpassword/forgot_password_screen.dart:68`, `lib/auth/forgotpassword/forgot_password_screen.dart:134`, `lib/auth/forgotpassword/forgot_password_screen.dart:378`, `lib/auth/login/login.dart:437`, `lib/auth/sign_up/signup1_screen.dart:1407`, `lib/auth/sign_up/signup2_screen.dart:454`, `lib/auth/sign_up/signup2_screen.dart:941`, `lib/file_manager/file_manager_screen.dart:453`, `lib/file_manager/pre_production_screen.dart:232`, `lib/home/home_screen.dart:625`, `lib/home/home_screen.dart:1065`, `lib/home/home_screen.dart:1515`, `lib/home/home_screen.dart:1522`, `lib/home/home_screen.dart:1681`, `lib/main_screen.dart:234`, `lib/manageavailability/manage_availability_screen.dart:569`, `lib/shoots/shoots_screen.dart:569`, `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:643`, `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:691`, `lib/widgets/commonFileViewer.dart:20`

### `Navigator.pushReplacement(...)` — 5 sites
`lib/auth/resetpassword/reset_password_screen.dart:83`, `lib/auth/sign_up/signup1_screen.dart:647`, `lib/auth/sign_up/signup3_screen.dart:1135`, `lib/onboding/onboding_screen.dart:196`, `lib/splash/splash_screen.dart:40`

### `Navigator.pushAndRemoveUntil(...)` — 1 site
`lib/auth/login/login.dart:115`

### `Navigator.of(context)` — 1 site
`lib/utility/app_utils.dart:121`

### `MaterialPageRoute(...)` — 31 sites
Same files as the `Navigator.push` block above plus splash/login replacements. Each raw `Navigator.push` is paired with a `MaterialPageRoute` 1-2 lines later.

### `Navigator.pop(...)` — 55 sites
Spread across 30 files. Most are legitimate (closing dialogs/bottom sheets/drawer). A subset closes screens that were entered via `pushNamed` — those should use `context.pop()` for consistency. Sample: `lib/Profile/myprofile.dart:76, 123, 187, 460, 743, 1935, 2347, 2590, 2774`; `lib/auth/sign_up/signup3_screen.dart:1468, 1558, 1647, 1931, 2003, 2130, 2207, 2537, 2737, 3037, 3118, 3277`; `lib/main_screen.dart:233, 389`; `lib/utility/app_utils.dart:87, 95`.

### `context.pushNamed(...)` — 32 sites (correct usage)
See Section 1 of the parallel agent inventory; spread across 16 files. No issues with the calls themselves except F-06 (`shootCancel` without projectId).

### `context.goNamed(...)` — 14 sites
Used for terminal/auth-state transitions (login, home, onboarding, delete-success). Generally appropriate, though F-05 flags it as insufficient for clearing the stack on logout in some cases.

### `context.pop(...)` — 44 sites
Standard back behavior. Co-exists with 55 raw `Navigator.pop`s — inconsistent style.

---

## 5. Cross-reference: routed vs orphan screens

**Routed (29 screens reachable via name):** SplashScreen, OnboardingScreen, Login, SignUp1Screen, SignUp2Screen, SignUp3Screen, ForgotPasswordScreen, ForgotPasswordOtpScreen, ResetPasswordScreen, Mainscreen, UpcomingShootViewDetils, CancelScreen (×2 routes), AddAvailabilityScreen, DeleteAccount, DeleteAccountOtpScreen, DeleteAccountLottieScreen, ViewDetailsScreen (auth/), Myprofile, ShootCancelledLottiesScreen, EditPersonalDetailsScreen, EnterProfileDetailsScreen, ProfileDetils1screen, FeaturedWorkList, Certificates, Resume, AppPreferences, MyprofileYoureAllSetScreen, PostProductionScreen, PreProductionScreen.

**Tab-only (5, not routable):** HomeScreen, ShootsScreen, FileManagerScreen, MessagesScreen, ManageAvailabilityScreen.

**Reached only via raw `Navigator.push` (1):** ShootRequestAccepted (`lib/shoots/shoot_request_accepted.dart`).

**Defined but unreachable (2):** `lib/file_manager/view_details_screen.dart` (`ViewDetailsScreen`), `lib/Profile/profile_new_passwrod_screen.dart` (`MyprofileNewPasswrodScreen`).

---

## 6. Severity tally

| Severity | Count | Items |
|----------|-------|-------|
| High | 4 | F-01, F-02, F-05, F-09 |
| Medium | 11 | F-03, F-04, F-06, F-11, F-13, F-14, F-16, F-18, F-19, F-20, F-21 |
| Low | 7 | F-07, F-08, F-10, F-12, F-15, F-17, F-22 |

---

## 7. Out of scope

- No fix recommendations included (per audit-mode request).
- No runtime instrumentation; findings are static-analysis only against the working tree on branch `improvments-phase1`.
- Test coverage of navigation flows not assessed (no nav tests exist under `test/`).
- Performance/animation behavior of route transitions not measured.
