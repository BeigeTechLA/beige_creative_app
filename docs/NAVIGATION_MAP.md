# Navigation Map — beige_creative_app

Snapshot of every screen, every route, and the wiring between them. Generated from a full sweep of `lib/`.

## 1. Source files

| Concern | File |
|---|---|
| Router config | `lib/app/router.dart` |
| Route name constants | `lib/app/route_names.dart` |
| App root + initial-route gate | `lib/main.dart` (`MyApp`, `startApp`) |
| Entrypoints | `lib/main_dev.dart`, `lib/main_prod.dart` |
| Post-login shell (bottom nav + drawer) | `lib/main_screen.dart` (`Mainscreen`) |
| Auth/session persistence | `lib/service/shared_service.dart` |
| Auth header injection | `lib/service/api_service.dart` (`createAuthorizationHeader`) |
| Disabled/scaffold root (Riverpod) | `lib/app/app.dart` (commented out, NOT live) |

## 2. State management

No Riverpod / Bloc / Provider in the live tree. `flutter_riverpod` is a dep but `ProviderScope` is never mounted. Navigation is plain `go_router` + local `StatefulWidget` state. Auth state lives in `SharedPreferences` (keys: `token`, `isLoggedIn`, `id`, `name`, `email`, `role`, `user_type`, `profile_image_url`).

## 3. Screen inventory

| # | Screen widget | File | Route name | Path | Extra (Map keys) | Pushed from |
|---|---|---|---|---|---|---|
| 1 | `SplashScreen` | `splash/splash_screen.dart` | `splash` | `/splash` | — | initial route |
| 2 | `OnboardingScreen` | `onboding/onboding_screen.dart` | `onboarding` | `/onboarding` | — | Splash (logged out) |
| 3 | `Login` | `auth/login/login.dart` | `login` | `/login` | — | Onboarding, Signup1/2/3, MyProfile logout, Reset success, Delete success |
| 4 | `SignUp1Screen` | `auth/sign_up/signup1_screen.dart` | `signup-step-1` | `/signup-step-1` | — | Onboarding, Login |
| 5 | `SignUp2Screen` | `auth/sign_up/signup2_screen.dart` | `signup-step-2` | `/signup-step-2` | `crewMemberId, profileImage, email, firstName, lastName, location, workingDistance, step1Progress` | Signup1 (after API success) |
| 6 | `SignUp3Screen` | `auth/sign_up/signup3_screen.dart` | `signup-step-3` | `/signup-step-3` | `crewMemberId, profileImage, email, firstName, lastName, location, workingDistance, primaryRole, experience, hourlyRate, bio, skills, equipments, step2Progress` | Signup2 (after API success) |
| 7 | `ViewDetailsScreen` | `auth/view_details_screen .dart` (note trailing space in filename) | `view-details` | `/view-details` | `firstName, lastName, email, location, profileImage, workingDistance, primaryRole, experience, hourlyRate, bio, skills, equipments, featuredImages (List<File>)` | Signup1 (preview), Signup2 (preview) |
| 8 | `ForgotPasswordScreen` | `auth/forgotpassword/forgot_password_screen.dart` | `forgot-password` | `/forgot-password` | — | Login |
| 9 | `ForgotPasswordOtpScreen` | `auth/forgotpassword/forgot_password_otp_screen.dart` | `forgot-otp` | `/forgot-otp` | `email` | ForgotPassword (via raw `Navigator.push`, not named) |
| 10 | `ResetPasswordScreen` | `auth/resetpassword/reset_password_screen.dart` | `reset-password` | `/reset-password` | `email, otp` | ForgotOtp (via raw `Navigator.push`) |
| 11 | `MyprofileYoureAllSetScreen` | `Profile/myprofile_youre_all_set_screen.dart` | `profile-password-success` | `/profile-password-success` | — | ResetPassword (raw), NewPassword button |
| 12 | `Mainscreen` (shell) | `main_screen.dart` | `home` | `/home` | — | Splash (logged in), Login success, Shoot lottie screens |
| 13 | `HomeScreen` (tab 0) | `home/home_screen.dart` | (no route — nested in shell) | — | — | Mainscreen `_pages[0]` |
| 14 | `ShootsScreen` (tab 1) | `shoots/shoots_screen.dart` | (no route — nested) | — | — | Mainscreen `_pages[1]` |
| 15 | `FileManagerScreen` (tab 2) | `file_manager/file_manager_screen.dart` | (no route — nested) | — | — | Mainscreen `_pages[2]` |
| 16 | `MessagesScreen` (tab 3) | `messages/messages_screen.dart` | (no route — nested) | — | — | Mainscreen `_pages[3]` |
| 17 | `ManageAvailabilityScreen` (tab 4 / drawer) | `manageavailability/manage_availability_screen.dart` | (no route — nested) | — | — | Mainscreen `_pages[4]` (drawer entry only) |
| 18 | `UpcomingShootViewDetils` | `upcomingshootviewdetils/upcoming_shoot_view_detils.dart` | `upcoming-shoot-details` | `/upcoming-shoot-details` | `projectId` (REQUIRED, cast `as Map<String, dynamic>` — non-null) | Home (2x), Shoots, ManageAvailability |
| 19 | `CancelScreen` | `shoots/shoot_cancelled_screen.dart` | `cancel-shoot` | `/cancel-shoot` | `projectId` | Home, Shoots (via `shoot-cancel`), Shoots (via `cancel-shoot`) |
| 19b | `CancelScreen` (dup route, no extra) | same widget | `shoot-cancel` | `/shoot-Cancel` | — (`const CancelScreen()`) | Shoots screen list |
| 20 | `ShootCancelledLottiesScreen` | `shoots/shoot_cancelled_lotties_screen.dart` | `shoot-cancellooties` (slug typo) | `/shoot-cancelotties` | — | CancelScreen (after cancel API) |
| 21 | `ShootRequestAccepted` | `shoots/shoot_request_accepted.dart` | (no GoRoute) | — | — | UpcomingShootViewDetils (raw `Navigator.push`) |
| 22 | `AddAvailabilityScreen` | `manageavailability/add_availability_screen.dart` | `add-availability` | `/add-availability` | — | Home, ManageAvailability |
| 23 | `Myprofile` | `Profile/myprofile.dart` | `my-profile` | `/my-profile` | — | Drawer (Mainscreen), Home avatar |
| 24 | `ProfileDetils1screen` | `Profile/profiledetils/profile_detils_1screen.dart` | `profile-details` | `/profile-details` | — | Myprofile |
| 25 | `EditPersonalDetailsScreen` | `Profile/profiledetils/edit_personal_details_screen.dart` | `edit-personal-details` | `/edit-personal-details` | — | ProfileDetils1screen (tab 0, via `pushNamed`); also raw `Navigator.push` from same screen |
| 26 | `EnterProfileDetailsScreen` | `Profile/profiledetils/enter_profile_details_screen.dart` | `enter-professional-details` | `/enter-professional-details` | — | ProfileDetils1screen (tab 1) |
| 27 | `FeaturedWorkList` | `Profile/featured_work_list.dart` | `featured-works` | `/featured-works` | — | Myprofile |
| 28 | `FeaturedWorkDetailsScreen` | `Profile/featuredwork_details_screen.dart` | `featured-work-details` | `/featured-work-details` | `title, images` (REQUIRED — non-null cast) | FeaturedWorkList (2x) |
| 29 | `Certificates` | `Profile/certificates.dart` | `certificates` | `/certificates` | — | Myprofile |
| 30 | `Resume` | `Profile/resume_screen.dart` | `resume` | `/resume` | — | Myprofile |
| 31 | `AppPreferences` | `Profile/app_preferences.dart` | `app-preferences` | `/app-preferences` | — | Myprofile |
| 32 | `ChangePasswordScreen` | `Profile/change_password_screen.dart` | `change-password` | `/change-password` | `extra: String` (email — positional, NOT a map) | EditPersonalDetailsScreen |
| 33 | `ProfileOtpScreen` | `Profile/profile_otp_screen.dart` | `profile-otp` | `/profile-otp` | `email` | ChangePasswordScreen |
| 34 | `MyprofileNewPasswrodScreen` | `Profile/profile_new_passwrod_screen.dart` | `new-password` | `/new-password` | `email, otp` | ProfileOtpScreen |
| 35 | `DeleteAccount` | `Profile/deleteaccount/delete_account.dart` | `delete-account` | `/delete-account` | — | AppPreferences |
| 36 | `DeleteAccountOtpScreen` | `Profile/deleteaccount/delete_account_otp_screen.dart` | `delete-account-otp` | `/delete-account-otp` | `reason` (passed but screen does not unpack in router) | DeleteAccount |
| 37 | `DeleteAccountLottieScreen` | `Profile/deleteaccount/delete_account_lottieScreen.dart` | `delete-account-success` | `/delete-account-success` | — | DeleteAccountOtp (success), auto-routes to Login |
| 38 | `PostProductionScreen` | `file_manager/post_production_screen.dart` | `post-production` | `/post-production` | — | FileManager tab (pushNamed) + raw push |
| 39 | `PreProductionScreen` | `file_manager/pre_production_screen.dart` | `pre-production` | `/pre-production` | — | PostProduction |
| 40 | `ViewDetailsScreen` (file_manager) | `file_manager/view_details_screen.dart` | (no GoRoute) | — | — | PreProduction (raw `Navigator.push`) |

> Filename note: `auth/view_details_screen .dart` has a literal space before `.dart`. It is imported as `auth/view_details_screen .dart` in `router.dart`. Don't "fix" the rename without touching the import.

## 4. Navigation diagram (Mermaid)

```mermaid
flowchart TD
  Splash["/splash<br/>SplashScreen"]
  Onb["/onboarding<br/>OnboardingScreen"]
  Login["/login<br/>Login"]
  Su1["/signup-step-1<br/>SignUp1Screen"]
  Su2["/signup-step-2<br/>SignUp2Screen"]
  Su3["/signup-step-3<br/>SignUp3Screen"]
  VD["/view-details<br/>ViewDetailsScreen (preview)"]
  Fp["/forgot-password"]
  FpOtp["/forgot-otp"]
  Rp["/reset-password"]
  AllSet["/profile-password-success<br/>MyprofileYoureAllSetScreen"]

  Home["/home<br/>Mainscreen (shell)"]
  HomeTab[HomeScreen tab 0]
  ShootsTab[ShootsScreen tab 1]
  FilesTab[FileManagerScreen tab 2]
  MsgTab[MessagesScreen tab 3]
  AvailTab[ManageAvailabilityScreen tab 4 / drawer]

  Up["/upcoming-shoot-details<br/>UpcomingShootViewDetils"]
  Cancel["/cancel-shoot<br/>CancelScreen"]
  CancelDup["/shoot-Cancel<br/>CancelScreen (dup)"]
  CancelLot["/shoot-cancelotties<br/>ShootCancelledLottiesScreen"]
  Accepted[ShootRequestAccepted (no route)]

  Add["/add-availability<br/>AddAvailabilityScreen"]

  Prof["/my-profile<br/>Myprofile"]
  PDetails["/profile-details"]
  EditPers["/edit-personal-details"]
  EntProf["/enter-professional-details"]
  FW["/featured-works"]
  FWD["/featured-work-details"]
  Cert["/certificates"]
  Res["/resume"]
  AppPref["/app-preferences"]

  ChPwd["/change-password"]
  PrOtp["/profile-otp"]
  NewPwd["/new-password"]

  Del["/delete-account"]
  DelOtp["/delete-account-otp"]
  DelDone["/delete-account-success"]

  Post["/post-production"]
  Pre["/pre-production"]
  FmView[file_manager ViewDetailsScreen (no route)]

  Splash -->|isLoggedIn=true goNamed| Home
  Splash -->|isLoggedIn=false goNamed| Onb
  Onb --> Login
  Onb --> Su1
  Login -->|success goNamed| Home
  Login --> Fp
  Login --> Su1
  Su1 --> Su2
  Su1 --> VD
  Su1 -->|Login link| Login
  Su2 --> Su3
  Su2 --> VD
  Su2 -->|Login link| Login
  Su3 -->|submit success goNamed| Login
  Su3 -->|Login link| Login

  Fp -->|Navigator.push| FpOtp
  FpOtp -->|Navigator.push| Rp
  Rp -->|Navigator.pushReplacement| AllSet
  AllSet -->|delayed goNamed| Login

  Home --> HomeTab
  Home --> ShootsTab
  Home --> FilesTab
  Home --> MsgTab
  Home --> AvailTab
  Home -.->|drawer pushNamed| Prof

  HomeTab --> Up
  HomeTab --> Cancel
  HomeTab --> Add
  HomeTab --> Prof
  ShootsTab --> Up
  ShootsTab --> CancelDup
  AvailTab --> Add
  AvailTab --> Up
  Up -->|Navigator.push| Accepted
  Accepted -->|delayed goNamed| Home

  Cancel -->|after API goNamed| CancelLot
  CancelLot -->|delayed goNamed| Home

  Prof --> PDetails
  Prof --> FW
  Prof --> Cert
  Prof --> Res
  Prof --> AppPref
  Prof -->|logout goNamed| Login
  PDetails --> EditPers
  PDetails --> EntProf
  EditPers --> ChPwd
  ChPwd --> PrOtp
  PrOtp --> NewPwd
  NewPwd --> AllSet
  FW --> FWD

  AppPref --> Del
  Del --> DelOtp
  DelOtp -->|goNamed| DelDone
  DelDone -->|delayed goNamed| Login

  FilesTab --> Post
  Post --> Pre
  Pre -->|Navigator.push| FmView
```

## 5. Major user journeys

### A. Cold boot
1. `main_dev.dart` / `main_prod.dart` → `startApp(env)` → `Env.init()` → reads `isLoggedIn` from `SharedPreferences` (read but only used to decide *what `MyApp` is given* — see note).
2. `MyApp` mounts `MaterialApp.router(routerConfig: appRouter)`.
3. Router `initialLocation: '/splash'` always — **`isLoggedIn` is NOT used to gate the initial route at the router level**. The Splash screen re-reads `isLoggedIn` and `goNamed`s either `home` or `onboarding` after Lottie completes.

### B. First-time user → onboarding → signup
`Splash` → `Onboarding` → tap **Sign Up** → `SignUp1Screen` → on API success `goNamed(signupStep2)` with step-1 payload → `SignUp2Screen` → on API success `pushNamed(signupStep3)` with merged payload → `SignUp3Screen` → multipart submit → `goNamed(login)`. Each step also has a "Preview" entry into `view-details` and a "Login" link back to `/login`.

### C. Returning user → login → home
`Splash` → if `isLoggedIn` → `goNamed(home)` → `Mainscreen` mounts, calls `fetchprofiledata()` in `initState`. Or: `Login` form → `ApiService` POST → `SharedService.setLoginDetails(...)` sets prefs → `goNamed(home)`. **No router redirect/guard exists** — anyone who lands on `/home` with no token will hit a 401 on first API call.

### D. Forgot password (legacy stack)
`Login` → `pushNamed(forgotPassword)` → enter email → **`Navigator.push`** (not named) → `ForgotPasswordOtpScreen(email)` → OTP verify → **`Navigator.push`** → `ResetPasswordScreen(email, otp)` → reset API → **`Navigator.pushReplacement`** → `MyprofileYoureAllSetScreen` → after 3 s → `goNamed(login)`. The three named routes `forgot-otp` / `reset-password` exist but are not used from this flow — the in-flow pushes construct widgets directly.

### E. Change password (from profile)
`Myprofile` → `app-preferences`? No — actually `Profile Details` → `Edit Personal Details` → tap edit icon → `pushNamed(changePassword, extra: email)` (extra is a **bare `String`**, not a map) → enter email → `pushNamed(profileOtp, extra: {email})` → OTP → `pushNamed(newPassword, extra: {email, otp})` → button at l.272 → `pushNamed(profilePasswordSuccess)` → delayed `goNamed(login)`. The success-path inside `_resetPassword()` at l.103 (`context.pushNamed(RouteNames.);`) is sitting inside a commented block and is also a compile-blocking fragment in isolation — see "Unknowns".

### F. Project lifecycle (crew side)
Home / Shoots / ManageAvailability list cards → `pushNamed(upcomingShootDetails, extra: {projectId})` → `UpcomingShootViewDetils` shows details → user can `Navigator.push(ShootRequestAccepted)` → delayed `goNamed(home)`; or cancel → `pushNamed(cancelShoot, extra: {projectId})` → `CancelScreen` submits → `goNamed(shoot-cancellooties)` → `ShootCancelledLottiesScreen` → delayed `goNamed(home)`.

### G. Account deletion
`Myprofile` → `App Preferences` → tap delete card → `pushNamed(deleteAccount)` → select reason → `pushNamed(deleteAccountOtp, extra: {reason})` → OTP → `goNamed(deleteAccountSuccess)` → `DeleteAccountLottieScreen` → after Lottie → `goNamed(login)`. **Note:** `SharedService.logout()` is NOT called anywhere in this path; only `prefs.clear()`-equivalent should run to actually drop the token. Verify before relying on this flow to log the user out.

### H. File manager
`Mainscreen` tab 2 → `FileManagerScreen` → tap card → `pushNamed(postProduction)` → `PostProductionScreen` → `pushNamed(preProduction)` → `PreProductionScreen` → tap → raw `Navigator.push(ViewDetailsScreen())` (the `file_manager/view_details_screen.dart` one, not the auth one).

## 6. Deep links / guarded routes

- **Deep links:** none configured. `go_router` is name-based, all args pass via `state.extra` (in-memory `Map`/`Object`), so URLs are not parseable on cold-start. No `redirect` callback on the `GoRouter`, no `Uri`/intent handling in native or Dart.
- **Route guards:** none. `appRouter` has no `redirect`. There is no `ShellRoute`, no `refreshListenable`, no auth-aware router. The only "gate" is the Splash screen reading `SharedPreferences.isLoggedIn`.
- **Auth-required surfaces:** every screen that calls `ApiService` relies on `Authorization: Bearer <token>` from `SharedPreferences` (`api_service.dart::createAuthorizationHeader`). A missing token surfaces as a 401 / `Exception('Failed to ...')` at call time, never as a route bounce.

## 7. Bottom nav / drawer (Mainscreen)

- 4 tabs in `BottomNavigationBar` (Dashboard / Shoots / Files / Messages) — `_pages` indexed by `_selectedIndex`. **No `IndexedStack`** — each tab loses state on switch (commented-out IndexedStack lives at l.113-116).
- Drawer (`_buildDrawer`) re-exposes the 4 tabs PLUS a 5th `_pages[4]` = `ManageAvailabilityScreen`. The bottom bar clamps with `currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex` to hide the 5th from the bar.
- Drawer also has a profile chip → `context.pushNamed(myProfile).then((_) => fetchprofiledata())`. Profile changes propagate back by re-fetching, not by reactive state.

## 8. Unknowns / oddities / risk flags

| Location | Issue |
|---|---|
| `route_names.dart::shootCancelotties` | Constant value `"shoot-cancellooties"` (double-o typo) but path is `/shoot-cancelotties`. `goNamed` uses the constant — works as long as both sides agree, but the name is misleading. |
| `route_names.dart::signup`, `route_names.dart::viewShootDetails` | Defined but no `GoRoute` matches and nothing imports them. Dead constants. |
| `router.dart` `cancelShoot` vs `shootCancel` | Two routes (`/cancel-shoot`, `/shoot-Cancel`) both build `CancelScreen`. `cancelShoot` requires `extra.projectId`; `shootCancel` ignores extra. Shoots screen uses `shootCancel` for one list, `cancelShoot` for cancel action. Likely an accidental dup. |
| `manage_availability_screen.dart:767` | `pushNamed(upcomingShootDetails)` with **no `extra`** map. Router builder is `state.extra as Map<String, dynamic>` (non-nullable cast) — this will throw `TypeError` at runtime. |
| `auth/view_details_screen .dart` | Filename has a trailing space before `.dart`. Imported with the space — case-sensitive filesystems (Linux CI) may break. |
| `auth/forgotpassword/*` | Forgot-password chain still uses raw `Navigator.push` even though named routes exist (`forgot-otp`, `reset-password`). Inconsistent with the rest of the app. |
| `Profile/profile_new_passwrod_screen.dart:103` | `context.pushNamed(RouteNames.);` — token after `RouteNames.` is missing. The line *appears* to be inside a `/*...*/` block (l.97-102 opens with `/*`, l.102 has `*//*` which closes then re-opens). Worth a closer look — if the comment grouping is wrong this won't compile. |
| `Profile/deleteaccount/*` flow | Success screen `goNamed(login)` but never calls `SharedService.logout()` / `prefs.clear()` — token may persist after account deletion. |
| `lib/app/app.dart` | A `ConsumerWidget` root referencing `flutter_riverpod` exists but is commented out. Anyone reading `lib/app/` may think it is the live root — it is not. `MyApp` in `lib/main.dart` is. |
| `lib/app/theme.dart` and siblings | Per `CLAUDE.md`, treated as unused scaffolding — but `Mainscreen` and several feature screens DO import from `app/colors.dart`, `app/spacing.dart`, `app/text_styles.dart`, `app/radii.dart`, `app/shadows.dart`. The "unused" caveat in CLAUDE.md is now partially out-of-date; only `theme.dart` itself (not used by `MyApp`) and `app.dart` are dead. |
| `splash_screen.dart` | Reads `isLoggedIn` AFTER `startApp` already read it. Double read is harmless but the value computed in `startApp` is never consumed (passed to `MyApp` but `MyApp` ignores it). |
| `messages/messages_screen.dart` | No outgoing navigation found. Likely a placeholder tab. |
| `home_screen.dart` lines 1557, 1565 | Raw `Navigator.push(ShootsScreen())` — re-mounts a tab as a new full-screen route instead of switching `_selectedIndex`. Tab state diverges. |

## 9. Things worth confirming with the team

1. Is the forgot-password flow expected to use named routes? If yes, three call sites need conversion.
2. Is `shootCancel` (`/shoot-Cancel`) intentional, or should `cancelShoot` be the only route?
3. Should the router have a `redirect` to bounce unauthenticated users off `/home` and friends, or is the "first API call 401" pattern the intended UX?
4. Should `DeleteAccountLottieScreen` call `SharedService.logout()` before `goNamed(login)`?
5. The `extra` shape for `change-password` is a bare `String`. Every other screen uses `Map<String, dynamic>`. Standardize?