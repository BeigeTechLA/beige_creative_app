# Migration Readiness Report — Beige Creative App (Crew)

> Generated: 2026-05-21 · Refreshed: 2026-05-27 (LOC + status sync; plan moved from `docs/migration/` to repo root)
> Based on: `docs/audit/AUDIT_REPORT.md` + 12 area audits + `docs/audit/NAVIGATION_AUDIT.md`, `MIGRATION_RULES.md`, `docs/guides/FLUTTER_BASE_GUIDELINES.md`, and phase plans `docs/migration/phase1_audit.md` … `phase6_testing.md`.
>
> **Calibration:** solo dev, part-time (~4 hrs/day). Effort-days below are 4-hour units; calendar = ~2× effort-days. Riverpod = manual `Notifier`/`AsyncNotifier` (no codegen). Token storage = `flutter_secure_storage` (token + refresh); `SharedPreferences` retained for non-secret prefs. Pilot = splash + onboarding. `freezed` models adopted per-feature inside each Phase 4 row.
>
> **Refresh delta (2026-05-21 → 2026-05-27, branch `improvments-phase1`):**
> - Folder casing: 3 of 6 done — `Home→home`, `Profile→profile`, `Shoots→shoots` ✅. Still pending: `onboding`, `manageavailability`, `upcomingshootviewdetils`.
> - `AppTheme.dark()` now wired at `lib/main.dart:45` (no longer inline in `MyApp.build`) → Foundations row 7 flips ⚠️ → ✅.
> - `flutter_secure_storage ^9.2.2` already declared in `pubspec.yaml` → Phase 2.B.5 partly done.
> - Drift in the wrong direction: `ApiService()` instantiations 58 → **68**; `setState` 266 → **291**; `print/debugPrint` 242 → **283**; `StatefulWidget` 41 → **44**. Migration urgency unchanged.
> - 3 new profile screens added since 2026-05-21: `change_password_screen.dart` (274 LOC), `profile_otp_screen.dart` (343 LOC), `featuredwork_details_screen.dart` (177 LOC). Folded into Group C below.
> - Several god widgets churned: `signup3` 3,465 → **3,569**, `signup1` 1,959 → **1,836**, `upcoming_shoot_view_detils` 1,396 → **1,184**, `login` 464 → **382**, `reset_password` 428 → **332**, `edit_personal_details` 589 → **666**, `file_manager_screen` 661 → **604**, `pre_production` 502 → **434**, `delete_account_otp` 271 → **334**. Tables below reflect current numbers.

---

## 1. EXECUTIVE SUMMARY

**Overall project health: 2 / 10** (per `docs/audit/AUDIT_REPORT.md`). 77 findings logged across 10 audited areas (38 🔴 / 28 🟠 / 11 🟡). One root cause — **44** `StatefulWidget`s talking to a concrete `ApiService()` instantiated **68** times (drift since 2026-05-21: +3 widgets, +10 instantiations), no domain layer, no DI, no tests, no CI — drives the rest.

**What's in place (preserve):** `go_router 14.8.1` wired at `lib/app/router.dart` (30 routes, **50** `pushNamed`/`goNamed` sites); a centralized endpoint registry at `lib/service/api_endpoints.dart` (minus 4 hardcoded bypass sites); design-token palettes at `lib/utility/colorcode.dart` (`ColorCode`) and `lib/utility/imges_icons.dart` (`AppImages`); **`AppTheme.dark()` now wired at `lib/main.dart:45`** (since 2026-05-27); compile-time env split via `lib/main_dev.dart` / `lib/main_prod.dart` → `lib/config/env.dart`; modern widget-API discipline (0 `WillPopScope`, 0 `RaisedButton`, **1,992** `const` constructors).

**What's not (build):** `ProviderScope` is commented out in `lib/app/app.dart` — `flutter_riverpod 2.6.1` is paid for but unused; the live app root is a plain `MyApp` `StatelessWidget` at `lib/main.dart`. No `core/network/DioClient`, no `AppException` hierarchy, no `SessionStore` (`lib/service/shared_service.dart` is static + calls `prefs.clear()` on logout). No Firebase wiring (`firebase_core` / `_analytics` / `_crashlytics` not in `pubspec.yaml`). No `lib/core/`, `lib/features/`, `lib/shared/` directories. No CI. The design-token scaffolds at `lib/app/{colors,text_styles,spacing,radii,shadows,durations,assets}.dart` (except `theme.dart`, now wired) exist as files but remain **unused** — widgets reference `ColorCode` / `AppImages` from `lib/utility/`. Casing is **partially** normalized as of 2026-05-27: `Home→home`, `Profile→profile`, `Shoots→shoots` done; `onboding/`, `manageavailability/`, `upcomingshootviewdetils/`, and the file with a literal space (`lib/auth/view_details_screen .dart`) still pending. Mixed casing continues to break case-sensitive filesystems.

**Verdict.** Foundations are absent but the primitives are correctly chosen. The codebase is **not production-ready**: plaintext password in `SharedPreferences` (`lib/auth/login/login.dart:111`), token alongside (`lib/service/shared_service.dart:27`), token logged to console (`lib/service/api_service.dart:346`, `lib/Profile/myprofile.dart:601`), Google Maps + Stripe keys committed in source. Migration sequencing is set by `docs/migration/README.md`: Phase 2 unblocks (casing + security hotfixes + secrets + CI), Phase 3 stands up shared infra, Phase 4 migrates features one at a time, Phase 5 sweeps, Phase 6 tests. Total estimate **~75 effort-days** (~30 calendar weeks solo part-time).

---

## 2. FOUNDATIONS CHECKLIST

Everything below must be in place before any feature screen is migrated. "Scaffold present, not wired" counts as ❌ — the feature migration needs the wiring, not the file.

### Design Tokens

| # | Item | Path | Exists? |
|---|---|---|---|
| 1 | `AppColors` | `lib/app/colors.dart` | ⚠️ Scaffold exists (250 LOC) but **unused**; live palette is `ColorCode` at `lib/utility/colorcode.dart`. Phase 3 batch 3.A.1 wires it. |
| 2 | `AppTextStyles` | `lib/app/text_styles.dart` | ⚠️ Scaffold exists (188 LOC) but unused (2 refs). Phase 3 batch 3.A.2. |
| 3 | `AppSpacing` | `lib/app/spacing.dart` | ⚠️ Scaffold exists (157 LOC) but unused. Phase 3 batch 3.A.3. |
| 4 | `AppRadii` | `lib/app/radii.dart` | ⚠️ Scaffold exists (139 LOC), 1 ref. Phase 3 batch 3.A.3. |
| 5 | `AppShadows` | `lib/app/shadows.dart` | ⚠️ Scaffold exists (79 LOC), 0 refs. Phase 3 batch 3.A.3. |
| 6 | `AppDurations` | `lib/app/durations.dart` | ⚠️ Scaffold exists (31 LOC), 0 refs. Phase 3 batch 3.A.3. |
| 7 | `AppTheme.light()` + `AppTheme.dark()` | `lib/app/theme.dart` | ✅ Wired at `lib/main.dart:45` (2026-05-27). Pre-refresh: inline in `MyApp.build`. Phase 3 batch 3.A.5 reduced to a verify-only step. |
| 8 | `AppAssets` | `lib/app/assets.dart` | ⚠️ Scaffold exists (235 LOC); the live registry is `AppImages` at `lib/utility/imges_icons.dart` (used by 21+ files). Phase 3 batch 3.A.4 consolidates. |

### Infrastructure

| # | Item | Path | Exists? |
|---|---|---|---|
| 9 | `ProviderScope` wrapping `MaterialApp.router` | `lib/main.dart` | ❌ Live root is plain `MyApp` `StatelessWidget`. `lib/app/app.dart` contains a commented-out `ConsumerWidget`. Phase 3 batch 3.D. |
| 10 | `GoRouter` configuration | `lib/app/router.dart` | ✅ 30 routes wired; `initialLocation: '/splash'`. Needs `redirect:` (Phase 3.E.1). |
| 11 | Route name constants | `lib/app/route_names.dart` | ✅ 81 LOC; 2 dead constants flagged by `docs/audit/NAVIGATION_AUDIT.md`. |
| 12 | `DioClient` with interceptors | `lib/core/network/dio_client.dart` | ❌ `lib/core/` does not exist. Today: hand-rolled `lib/service/api_service.dart` (399 LOC, mixes `http` + `dio`, instantiated 58×). Phase 3 batch 3.B. |
| 13 | Sealed `AppException` hierarchy | `lib/core/network/exceptions/` | ❌ Folder does not exist. Phase 3 batch 3.B.2. |
| 14 | `ExceptionHandler.guardAsync()` | `lib/core/network/exception_handler.dart` | ❌ Phase 3 batch 3.B.2. |
| 15 | `FirebaseService.initialize()` | `lib/core/firebase/firebase_service.dart` | ❌ `firebase_core` not in `pubspec.yaml`. Phase 3 batch 3.F.3 (stub if config files absent). |
| 16 | `AnalyticsService` + `AnalyticsEvents` | `lib/core/firebase/analytics_service.dart` | ❌ Phase 3 batch 3.F.1. |
| 17 | `CrashlyticsService` + `CrashlyticsKeys` | `lib/core/firebase/crashlytics_service.dart` | ❌ Phase 3 batch 3.F.2. |
| 18 | `AppAnalyticsObserver` on router | `lib/app/router.dart` | ❌ Phase 3 batch 3.E.2. |
| 19 | `SessionStore` (secure-storage backed) | `lib/core/session/session_store.dart` | ❌ Today: static `SharedService` at `lib/service/shared_service.dart`; `logout()` calls `prefs.clear()`. Phase 3 batch 3.C. |
| 20 | `AppLogger` (release no-op) | `lib/core/utils/app_logger.dart` | ❌ Today: 242 `print`/`debugPrint` sites. Phase 2 batch 2.B.4. |

### Testing

| # | Item | Path | Exists? |
|---|---|---|---|
| 21 | `pump_app.dart` with `pumpProviderApp` | `test/helpers/pump_app.dart` | ❌ `test/helpers/` does not exist. Phase 3 batch 3.D.3 (minimal); Phase 6 expands. |
| 22 | `mocks.dart` | `test/helpers/mocks.dart` | ❌ Phase 6. |
| 23 | `test_data.dart` | `test/helpers/test_data.dart` | ❌ Phase 6. |
| 24 | `test/widget_test.dart` compiles | `test/widget_test.dart` | ❌ Unmodified counter template; references non-existent `MyApp()` (current `MyApp` requires `isLoggedIn:`). Phase 2 batch 2.E.1. |

### Base Structure

| # | Item | Path | Exists? |
|---|---|---|---|
| 25 | `lib/core/` folder tree | `lib/core/` | ❌ Phase 2 batch 2.F.1. |
| 26 | `lib/features/` folder tree | `lib/features/` | ❌ Phase 2 batch 2.F.2. |
| 27 | `lib/shared/` folder tree | `lib/shared/` | ❌ Phase 2 batch 2.F.3. |
| 28 | `core_providers.dart` (Dio, prefs, connectivity) | `lib/core/providers/core_providers.dart` | ❌ Phase 3 batch 3.B.6. |
| 29 | CI gate (GitHub Actions) | `.github/workflows/ci.yml` | ❌ Phase 2 batch 2.E.2. |
| 30 | Secrets out of source (`--dart-define-from-file`) | `env/dev.json`, `env/prod.json` | ❌ Today: Maps key + Stripe key in source. Phase 2 batch 2.C. |

**Checklist score: 3 / 30 fully in place (`AppTheme.dark()`, `GoRouter`, `RouteNames` — rows 7, 10, 11).** 6 scaffolds (rows 1–6) and 1 partial (row 8, `AppImages`) exist but are not wired. Everything else is ❌. (Refresh 2026-05-27: row 7 flipped ⚠️ → ✅.)

---

## 3. FEATURE MIGRATION ORDER

Features are ordered by isolation (no deps first), risk (auth + session last), and complexity (god widgets in the last position of their group so the group can ship even if the god widget slips). User can deviate — `docs/migration/phase4_features.md` enforces only the per-feature template, not the order.

**Total: ~38 screens across 6 feature groups (22 migration units).** Source line counts inventoried 2026-05-21 via `find lib -name "*.dart" | xargs wc -l`.

---

### Feature Group A — Pilot Foundation (Units 1–2) | Est. 3 days

Smallest blast radius. No API calls. Proves the Phase 3 wiring (Riverpod + GoRouter redirect + design tokens) end-to-end before any complex screen touches it.

| Unit | Screen Class | File Path | LOC | API Calls | Complexity |
|---|---|---|---|---|---|
| 1 | `SplashScreen` | `lib/splash/splash_screen.dart` | 72 | 0 | Trivial |
| 2 | `OnboardingScreen` | `lib/onboding/onboding_screen.dart` → renames to `lib/onboarding/onboarding_screen.dart` in Phase 2.A.1 | 198 | 0 | Trivial |

**Dependencies:** none — pure UI. Splash currently re-reads `isLoggedIn` from prefs (`lib/splash/splash_screen.dart:32-55`); after migration that read moves into `authStateProvider` consumed by the router `redirect:`.

**Navigation:**
```
SplashScreen → OnboardingScreen → LoginScreen
            ↘                  ↘ (if logged in via redirect)
              MainScreen [home]
```

**Intra-group order:** 1 → 2. Both first-touch the new stack; do splash first so the boot path is provably working before onboarding lands.

---

### Feature Group B — Low-API Standalone Tabs (Units 3–5) | Est. 8 days

Three features with small or near-empty surface. Migrate together — they share nothing with each other but exercise the `DioClient` + `Repository` + `Notifier` pattern at low risk.

| Unit | Screen Class | File Path | LOC | API Calls | Complexity |
|---|---|---|---|---|---|
| 3 | `MessagesScreen` | `lib/messages/messages_screen.dart` | 30 | 0 (placeholder today) | Trivial |
| 4 | `FileManagerScreen` | `lib/file_manager/file_manager_screen.dart` | 604 | ~3 | Medium |
| 4 | `PreProductionScreen` | `lib/file_manager/pre_production_screen.dart` | 434 | ~2 | Medium |
| 4 | `PostProductionScreen` | `lib/file_manager/post_production_screen.dart` | 173 | ~1 | Low |
| 4 | `ViewDetailsScreen` (file_manager) | `lib/file_manager/view_details_screen.dart` | 251 | ~1 | Medium |
| 5 | `AddAvailabilityScreen` | `lib/manageavailability/add_availability_screen.dart` → `lib/manage_availability/…` | 891 | ~2 | Medium |
| 5 | `ManageAvailabilityScreen` | `lib/manageavailability/manage_availability_screen.dart` → `lib/manage_availability/…` | 851 | ~2 | Medium |

**Dependencies:** auth provider (token), file_manager repository, availability repository. `add_availability` endpoint has a leading-slash inconsistency in `lib/service/api_endpoints.dart` — fix during 4.5.

**Decide before Unit 3 begins:** **messages — Stream or polling?** Today the file is a 27-line placeholder. Confirm backend capability (websocket / SSE / poll) with backend lead before this row starts. If real-time, use `StreamProvider`; if polling, `AsyncNotifierProvider` with a `Timer.periodic`.

**Navigation:**
```
MainScreen[Tab 3] → MessagesScreen
MainScreen[Tab 2] → FileManagerScreen
                     ├── PreProductionScreen
                     ├── PostProductionScreen
                     └── ViewDetailsScreen
MainScreen[drawer] → ManageAvailabilityScreen
                      └── AddAvailabilityScreen
```

**Intra-group order:** 3 (smoke-test the network stack on the smallest surface) → 4 (file_manager, 4 screens — exercises the multi-screen feature template) → 5 (availability, 2 screens with non-trivial state).

---

### Feature Group C — Profile (Units 6–10) | Est. 18 days

The largest feature group by LOC (~9k across 13 screens) and by god-widget count (`myprofile.dart` 2,834 LOC, `featured_work_list.dart` 1,703 LOC). Migrate together — every sub-screen shares the auth provider, profile repository, and image-upload pipeline.

| Unit | Screen Class | File Path | LOC | API Calls | Complexity |
|---|---|---|---|---|---|
| 6 | `Myprofile` (god widget) | `lib/profile/myprofile.dart` → `lib/profile/my_profile.dart` | 2,836 | ~6 | **Critical — decompose** |
| 7 | `FeaturedWorkList` (god widget) | `lib/profile/featured_work_list.dart` | 1,685 | ~5 | **High — decompose** |
| 7 | `FeaturedworkDetailsScreen` (added 2026-05-21→27) | `lib/profile/featuredwork_details_screen.dart` | 177 | ~1 | Low |
| 7 | `Resume` | `lib/profile/resume_screen.dart` | 546 | ~2 | Medium |
| 7 | `Certificates` | `lib/profile/certificates.dart` | 528 | ~2 | Medium |
| 8 | `EnterProfileDetailsScreen` | `lib/profile/profiledetils/enter_profile_details_screen.dart` → `lib/profile/profile_details/…` | 936 | ~3 | High |
| 8 | `ProfileDetils1screen` | `lib/profile/profiledetils/profile_detils_1screen.dart` → `lib/profile/profile_details/profile_details_1_screen.dart` | 595 | ~2 | Medium |
| 8 | `EditPersonalDetailsScreen` | `lib/profile/profiledetils/edit_personal_details_screen.dart` → `lib/profile/profile_details/edit_personal_details_screen.dart` | 666 | ~3 | High |
| 9 | `AppPreferences` | `lib/profile/app_preferences.dart` | 193 | 0 | Low |
| 9 | `ChangePasswordScreen` (added 2026-05-21→27) | `lib/profile/change_password_screen.dart` | 274 | ~1 | Medium |
| 9 | `ProfileOtpScreen` (added 2026-05-21→27) | `lib/profile/profile_otp_screen.dart` | 343 | ~2 | Medium |
| 9 | `ProfileNewPasswrodScreen` (typo) | `lib/profile/profile_new_passwrod_screen.dart` → `lib/profile/profile_new_password_screen.dart` | 319 | ~2 | Medium |
| 9 | `MyprofileYoureAllSetScreen` | `lib/profile/myprofile_youre_all_set_screen.dart` → `lib/profile/my_profile_youre_all_set_screen.dart` | 65 | 0 | Trivial |
| 10 | `DeleteAccount` | `lib/profile/deleteaccount/delete_account.dart` → `lib/profile/delete_account/delete_account_screen.dart` | 275 | ~1 | Medium |
| 10 | `DeleteAccountOtpScreen` | `lib/profile/deleteaccount/delete_account_otp_screen.dart` → `lib/profile/delete_account/delete_account_otp_screen.dart` | 334 | ~2 | Medium |
| 10 | `DeleteAccountLottieScreen` | `lib/profile/deleteaccount/delete_account_lottieScreen.dart` → `lib/profile/delete_account/delete_account_lottie_screen.dart` | 75 | 0 | Trivial |

**Dependencies:** auth provider, profile repository, image upload (`postMultipart` in `api_service.dart`), Google Maps (`enter_profile_details_screen`), Stripe (none here yet but profile is the natural landing for stored cards if added).

**Sub-task discipline:** `myprofile.dart` and `featured_work_list.dart` must be **split before Notifier migration** (per `phase4_features.md` "Split rule"). Break each into ≤600-LOC widgets in a dedicated `4.6.a` / `4.7.a` PR; the Notifier migration is `4.6.b` / `4.7.b`.

**Navigation:**
```
Mainscreen[drawer] → Myprofile
                      ├── EditPersonalDetailsScreen
                      ├── EnterProfileDetailsScreen
                      ├── ProfileDetils1screen
                      ├── FeaturedWorkList
                      ├── Resume
                      ├── Certificates
                      ├── AppPreferences
                      │     └── ProfileNewPasswrodScreen
                      ├── DeleteAccount
                      │     └── DeleteAccountOtpScreen
                      │           └── DeleteAccountLottieScreen → /login
                      └── MyprofileYoureAllSetScreen → /login
```

**Intra-group order:** 9 (settings, lowest complexity, builds momentum) → 10 (delete-account flow, linear, 3 screens) → 7 (resume + certificates, then `featured_work_list.dart` decomposition) → 8 (profile_details forms, multi-step) → 6 (`myprofile.dart` decomposition + migration, last because it's the entry point and breaks the most things if wrong).

---

### Feature Group D — Home + Shoots + Upcoming Details (Units 11–13) | Est. 12 days

`Home/home_screen.dart` is the largest god widget on the dashboard side (2,902 LOC, 7 parallel fetchers fire-and-forget in `initState` per `docs/audit/AUDIT_PERF.md`). Tab 0 + Tab 1 + a deep details push live or die together — migrate as one group.

| Unit | Screen Class | File Path | LOC | API Calls | Complexity |
|---|---|---|---|---|---|
| 11 | `HomeScreen` (god widget) | `lib/home/home_screen.dart` | 2,860 | ~7 | **Critical — decompose** |
| 12 | `ShootsScreen` | `lib/shoots/shoots_screen.dart` | 1,032 | ~4 | High |
| 12 | `ShootCancelledScreen` (`CancelScreen`) | `lib/shoots/shoot_cancelled_screen.dart` | 368 | ~1 | Medium |
| 12 | `ShootRequestAccepted` | `lib/shoots/shoot_request_accepted.dart` | 82 | 0 | Trivial |
| 12 | `ShootCancelledLottiesScreen` | `lib/shoots/shoot_cancelled_lotties_screen.dart` | 79 | 0 | Trivial |
| 13 | `UpcomingShootViewDetils` | `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` → `lib/upcoming_shoot_view_details/upcoming_shoot_view_details.dart` | 1,184 | ~4 (incl. 4 hardcoded endpoints — fix in 4.13) | High |

**Dependencies:** auth, home repository, shoots repository, location service (`lib/utility/location_service.dart`), file viewer (`lib/widgets/commonFileViewer.dart`).

**Search debounce required:** `lib/Shoots/shoots_screen.dart:247` calls `searchShoots` on every keystroke. The Notifier must wrap it in a 250ms `Timer`-based debounce per `docs/audit/AUDIT_PERF.md` D4.

**Hardcoded endpoints — must land in `ApiEndpoints`:** `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:75-84` has 4 string-literal URLs (per `docs/audit/AUDIT_REPORT.md` Architecture row).

**Navigation:**
```
Mainscreen[Tab 0] → HomeScreen
                     ↘ pushes UpcomingShootViewDetils(projectId)
                                     ├── CancelScreen(projectId)
                                     │     └── ShootCancelledLottiesScreen
                                     └── ShootRequestAccepted
Mainscreen[Tab 1] → ShootsScreen
                     ↘ pushes UpcomingShootViewDetils, CancelScreen
```

**Intra-group order:** 13 (details screen, leaf, exercises new pattern on a single 1.4k god) → 12 (shoots tab + supporting screens) → 11 (`home_screen.dart` decomposition + migration, last because it's the busiest screen and the riskiest single PR in the project).

---

### Feature Group E — Auth (Units 14–17) | Est. 14 days

Auth migrates **last** — same rationale as biegeapp: it touches token storage, navigation redirect, and the signup3 god widget (3,465 LOC, 35-field state class per `docs/audit/AUDIT_STATE.md`). Doing it last lets `SessionStore` stabilize through Phase 3 / 4.A–4.D while the legacy `SharedService` shim keeps existing logins working.

| Unit | Screen Class | File Path | LOC | API Calls | Complexity |
|---|---|---|---|---|---|
| 14 | `Login` | `lib/auth/login/login.dart` | 382 | ~2 (login + reset email-check) | High |
| 14 | `ViewDetailsScreen` (auth landing — typo'd filename) | `lib/auth/view_details_screen .dart` (literal space — Phase 2.A.3 renames) | 276 | ~1 | Medium |
| 15 | `ForgotPasswordScreen` | `lib/auth/forgotpassword/forgot_password_screen.dart` → `lib/auth/forgot_password/…` | 362 | ~1 | Medium |
| 15 | `ForgotPasswordOtpScreen` | `lib/auth/forgotpassword/forgot_password_otp_screen.dart` → `lib/auth/forgot_password/…` | 400 | ~1 | Medium |
| 15 | `ResetPasswordScreen` | `lib/auth/resetpassword/reset_password_screen.dart` → `lib/auth/reset_password/…` | 332 | ~1 | Medium |
| 16 | `SignUp1Screen` (god widget) | `lib/auth/sign_up/signup1_screen.dart` | 1,836 | ~2 | **High — decompose** |
| 16 | `SignUp2Screen` | `lib/auth/sign_up/signup2_screen.dart` | 1,331 | ~2 | High |
| 17 | `SignUp3Screen` (god widget — 35-field state) | `lib/auth/sign_up/signup3_screen.dart` | 3,569 | ~3 (incl. 1 hardcoded endpoint at `:240-241`) | **Critical — decompose into 3–4 sub-screens** |

**Dependencies:** `SessionStore` (must be Phase 3 Done), auth repository, `flutter_secure_storage`, Google Maps (signup1 / signup3 location step), file_picker + image_picker + image_cropper (signup3 portfolio), `postMultipartStep3` (which currently bypasses the auth header — verify before reuse, see `CLAUDE.md`).

**Decomposition required (per `phase4_features.md` Split rule):**
- `signup1_screen.dart` (1,959 LOC) — split into form + map step + state.
- `signup3_screen.dart` (3,465 LOC, 35 fields) — split into ~4 sub-screens: resume, portfolio, certifications, recent-work-media. Each sub-screen owns one slice of the state; aggregate at submit. This single decomposition is the biggest engineering risk in the project — track it as its own PR series.

**Navigation:**
```
LoginScreen
  ├── ViewDetailsScreen (auth landing)
  ├── ForgotPasswordScreen
  │     └── ForgotPasswordOtpScreen(email)
  │           └── ResetPasswordScreen(email, otp) → LoginScreen
  ├── SignUp1Screen
  │     └── SignUp2Screen(8 keys via extra Map)
  │           └── SignUp3Screen(14 keys via extra Map) → LoginScreen
  └── on success → Mainscreen [home]
```

**Intra-group order:** 14 (login first — smallest, lowest risk after Phase 3 sessions land) → 15 (forgot-password trio, linear, low complexity) → 16 (signup1 + signup2; decompose signup1 before migrating) → 17 (signup3 decomposition + migration, last because it is the single largest screen in the codebase).

---

### Feature Group F — Shared Infrastructure & Shell (Unit 18) | Est. 3 days

Lives outside the feature groups. Migrates whenever the underlying `core_providers` are stable (post Phase 3).

| Unit | Class | File Path | LOC | Complexity |
|---|---|---|---|---|
| 18 | `Mainscreen` (post-login shell) | `lib/main_screen.dart` | 467 | High |
| 18 | `Utils` | `lib/utility/Utils.dart` | 487 | Medium |
| 18 | `app_utils.dart` | `lib/utility/app_utils.dart` | 122 | Medium |
| 18 | `location_service.dart` | `lib/utility/location_service.dart` | 79 | Medium |
| 18 | Shared widgets (`Topmessgae`, `app_loder`, `common_calendar`, `commonFileViewer`, `commonImagePicker`, `new_Textfield`, `custom_*`) | `lib/widgets/` | ~1,200 across 13 files | Medium |

**Dependencies:** any. The shared widgets are migration "leaves" — they don't import features, features import them. Move into `lib/shared/widgets/` and rename to `snake_case` (Phase 2.A.4 already covers the file renames; the move happens here when callers are migrated).

**Shell-specific concerns (`Mainscreen`):**
- `_pages[_selectedIndex]` has no `IndexedStack` — tab state lost on switch (`docs/audit/NAVIGATION_AUDIT.md` F-02; Phase 2.D.3 patches the current shell as a holding measure, this unit replaces it with `StatefulShellRoute.indexedStack`).
- Persistent `BackdropFilter(sigmaX: 80, sigmaY: 70)` around the bottom nav at `lib/main_screen.dart:132-141` — remove during migration (`docs/audit/AUDIT_PERF.md` D1).
- Bottom nav index 4 is unreachable from the bar; only the drawer surfaces `ManageAvailabilityScreen` (`NAVIGATION_AUDIT.md` F-03).

---

### Migration Summary by Group

| Group | Feature | Screens | LOC (gross) | Est. Days | Migrate After |
|---|---|---|---|---|---|
| A | Pilot (splash + onboarding) | 2 | ~270 | 3 | Phase 3 |
| B | Low-API tabs (messages, file_manager, manage_availability) | 7 | ~3.2k | 8 | A |
| C | Profile (16 screens, 2 gods) | 16 | ~9.4k | 18 | B (needs auth + image upload) |
| D | Home + Shoots + Upcoming Details | 6 | ~5.6k | 12 | C (`/my-profile` reachable from Home drawer) |
| E | Auth (login + forgot + signup1/2/3) | 8 | ~8.5k | 14 | D (highest risk; `SessionStore` already stable) |
| F | Shell + shared widgets + utils | 1 shell + ~13 widgets | ~2.4k | 3 | Any (after Phase 3) |
| | **Total** | **~41 screens + shell + 13 shared widgets** | **~29.4k LOC** | **~58 days** | |

Phase 2 + Phase 3 (~12 days) and Phase 5 + Phase 6 (~15 days) bracket the 58 feature-days. See **Section 7. Timeline**.

---

## 4. RISK REGISTER

| # | Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|---|
| 1 | **God-widget decomposition breaks behavior** — splitting `signup3_screen.dart` (3,465 LOC, 35-field state), `home_screen.dart` (2,902), `myprofile.dart` (2,834), `featured_work_list.dart` (1,703), `signup1_screen.dart` (1,959) introduces nav/state bugs. | H | H | Decompose **before** migration in each Phase 4 row, in its own PR. Write a characterization test (golden + API-call snapshot) of the original screen before splitting; assert behavior parity after. Track each split as `4.x.a` (split) + `4.x.b` (migrate). |
| 2 | **Zero test coverage means silent regressions** — `test/widget_test.dart` is an unmodified template that doesn't even compile against `MyApp(isLoggedIn:)`. | H | H | Phase 2.E.1 lands a compiling smoke test. Phase 6 is deferred until Phase 5 stabilizes, but characterization tests for the gods land in Phase 4. |
| 3 | **Plaintext password persisted in `SharedPreferences`** — `lib/auth/login/login.dart:111`. Full account-takeover vector via `adb backup` / rooted device. | H | H | Phase 2.B.1 removes the persist (1 line). No dependency on later phases. Land in week 1. |
| 4 | **Bearer token logged to console** — `lib/service/api_service.dart:346`, `lib/profile/myprofile.dart:601`. Leak on every API call. | H | H | Phase 2.B.2 strips both. `AppLogger` (Phase 2.B.4) prevents recurrence. |
| 5 | **Maps + Stripe keys committed in source** — `lib/service/google_config.dart:3`, `android/app/src/main/AndroidManifest.xml:24`, `lib/config/env.dart:15-16`. | H | M | Phase 2.C rotates + injects via `--dart-define-from-file`. Out-of-repo task: rotate at vendor console. |
| 6 | **`logout()` calls `prefs.clear()`** — `lib/service/shared_service.dart:44-49` wipes every key. Future non-auth prefs (locale, theme, onboarding-seen) lost on every logout. | M | H | Phase 3.C.5 introduces `SessionStore.logout()` with key-scoped removal. `SharedService` becomes a shim. |
| 7 | **No 401 handling** — token expiry leaves users on broken screens. | H | M | Phase 3.B.5 `AuthInterceptor` (Queued) + `redirect:` driven by `authStateProvider` (3.E.1). |
| 8 | **50+ leaked `TextEditingController`s** — `docs/audit/AUDIT_STATE.md` C4. 41 `StatefulWidget`s, only 8 `dispose()` overrides. | H | H | Riverpod migration moves controllers into `Notifier` lifetime; the widget owns nothing. Each Phase 4 row eliminates its leaks. |
| 9 | **87% of async `setState` lack `mounted` guard** — `docs/audit/AUDIT_STATE.md`. 266 `setState`, 35 `mounted` references. | M | H | Riverpod migration removes the class entirely — `ref.read(notifier).method()` does not touch `mounted`. |
| 10 | **Linux CI breaks on first run** — case-mismatched imports (`Model_Class/` vs `model_class/`) + folder casing (3 of 6 dirs renamed as of 2026-05-27; `onboding/`, `manageavailability/`, `upcomingshootviewdetils/` still pending). | H | M | Phase 2.A finishes the remaining 3 renames **before** Phase 2.E adds CI. Order enforced in `docs/migration/phase2_structure_and_unblock.md`. |
| 11 | **`add_availability` endpoint has leading slash** — `lib/service/api_endpoints.dart` flagged by `CLAUDE.md`; base URL already ends in `api/`. Other endpoints don't have it. | L | M | Phase 3.B.1 fixes during endpoint consolidation. |
| 12 | **`http` + `dio` both in `pubspec.yaml`** — dual HTTP stacks; `http` is primary today despite Dio being the target. | L | L | Phase 3.B.7 swaps `api_service.dart` internals to Dio; Phase 5.A.1 removes `api_service.dart`; Phase 5.B.2 drops `http` from pubspec. |
| 13 | **4 hardcoded endpoint string literals bypass `ApiEndpoints`** — `lib/profile/myprofile.dart:597-598`, `:2579-2583`; `lib/auth/sign_up/signup3_screen.dart:240-241`; `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart:75-84`. | M | H | Each is fixed in its feature's Phase 4 row (Profile Unit 6 + Profile Unit 8; Auth Unit 17; Home/Shoots Unit 13). |
| 14 | **Duplicate `CancelScreen` routes with mismatched signatures** — `/cancel-shoot` (with `projectId`) vs `/shoot-Cancel` (no `projectId`). Caller in `shoots_screen.dart:576` uses the broken one. | M | H | Phase 2.D.1 collapses to one route. Unblocks Group D migration. |
| 15 | **`RouteNames.changePassword` route is commented out but call site is live** — `lib/profile/profiledetils/edit_personal_details_screen.dart:537`. Runtime crash when reached. NB: a new `lib/profile/change_password_screen.dart` (274 LOC) landed between 2026-05-21 and 2026-05-27 — verify wiring before closing. | M | H | Phase 2.D.2 restores route or removes call; align with the new screen file. |
| 16 | **Tab state lost on every switch** — `lib/main_screen.dart:120` uses `_pages[_selectedIndex]`, no `IndexedStack`. | M | H | Phase 2.D.3 wraps in `IndexedStack` as holding measure; Group F replaces with `StatefulShellRoute.indexedStack`. |
| 17 | **Persistent `BackdropFilter(sigmaX: 80, sigmaY: 70)`** — `lib/main_screen.dart:132-141`. 4–6ms/frame, always-on, on every screen. | M | H | Group F removes during shell rewrite. Holds at no-op cost until then. |
| 18 | **12 `Image.network` sites, 0 `CachedNetworkImage`** — dep is in `pubspec.yaml` (3.4.1) but unused. | M | M | Phase 5.B.3 migrates one screen per commit. |
| 19 | **No Firebase wired** — `firebase_core` not in `pubspec.yaml`. Crashes invisible. | H | M | Phase 3.F stubs the wrappers; native config (download `google-services.json`, generate via `flutterfire configure`) deferred to a separate pre-prod task. |
| 20 | **No timeouts on Dio** — slow-loris DoS path open. `docs/audit/AUDIT_SEC.md` F4. | M | M | Phase 3.B.4 sets `connectTimeout` / `receiveTimeout` / `sendTimeout` on `DioClient` `BaseOptions`. |
| 21 | **`InstrumentSans` font referenced but `pubspec.yaml` declares only `Unbounded` + `Outfit`** — silent fallback to system font. | L | M | Phase 3.A.2 picks one — either add to pubspec or replace with `Outfit` in the relevant text-style entries. |
| 22 | **76+ outdated packages** — `flutter pub outdated` baseline. | M | L | Defer until post-migration. Avoid mid-migration major upgrades. |
| 23 | **Day-estimate calibration is best-effort** — solo, part-time. Real velocity unknown until first 2 units land. | M | M | After Group A (units 1–2) re-estimate Group B–E from actuals. |

---

## 5. BLOCKERS

### Hard Blockers (must resolve before migration starts)

| # | Blocker | Why It Blocks | Resolution |
|---|---|---|---|
| 1 | **Case-mismatched folder names + 4 case-mismatched router imports** (`docs/audit/NAVIGATION_AUDIT.md` F-09; `lib/app/router.dart:5,18,19,20`) | Linux CI runner fails to build before any later phase can be gated. macOS/Windows hides the bug locally. | **Partially done (2026-05-27):** `Home→home`, `Profile→profile`, `Shoots→shoots` already renamed. Phase 2.A still needs: `onboding→onboarding`, `manageavailability→manage_availability`, `upcomingshootviewdetils→upcoming_shoot_view_details`, the file with the literal space (`lib/auth/view_details_screen .dart`), and any remaining router imports referencing old paths. Use `git mv` to preserve history. |
| 2 | **No target packages in `pubspec.yaml`** | `freezed`, `json_annotation`, `build_runner`, `mocktail`, `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `dartz`/`fpdart`, `connectivity_plus` — none declared. (`flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage` are present; `flutter_secure_storage ^9.2.2` added since 2026-05-21.) | Phase 3 batch 3.B adds `dio` consumers; the rest are added in a single foundation PR at the start of Phase 3. |
| 3 | **`lib/core/`, `lib/features/`, `lib/shared/` do not exist** | No target structure to migrate into. | Phase 2.F creates the empty skeleton. |
| 4 | **`test/widget_test.dart` does not compile** | `flutter test` exits non-zero; Phase 2.E.2 CI can't ship green. | Phase 2.E.1 lands a minimal `expect(find.byType(MaterialApp), findsOneWidget)` smoke test. |
| 5 | **Plaintext password + token in `SharedPreferences`; token logged** | Catastrophic data-exposure vector before any public release; CI history of secrets if discovered late. | Phase 2.B (security hotfix batch) runs in week 1 — independent of all later phases. |
| 6 | **Secrets in source — Maps key + Stripe pk_test** | Cannot rotate without code change; same key dev + prod; in `git log` permanently. | Phase 2.C moves to `--dart-define-from-file=env/<flavor>.json`; out-of-repo rotation. |

### Architectural Decisions (already taken — bake into Phase 2 / 3)

| # | Decision | Choice | Reason |
|---|---|---|---|
| 1 | Riverpod generation vs manual | **Manual `Notifier` / `AsyncNotifier`** | Avoids `build_runner` dependency for state; reduces tooling churn. Codegen reserved for `freezed` models only (see #4). |
| 2 | GoRouter shell type | **`StatefulShellRoute.indexedStack`** for tab preservation | Fixes the "every tab switch rebuilds" bug (`NAVIGATION_AUDIT.md` F-02). Phase 2.D.3 lands `IndexedStack` as holding measure; Group F rewrites to `StatefulShellRoute`. |
| 3 | Token storage | **`flutter_secure_storage`** for token + refresh; **`SharedPreferences`** retained for non-secret prefs (locale, theme, `isLoggedIn` boolean derived from `SessionStore`) | Closes the password-in-prefs vector (Risk #3) and gives `logout()` a scope-able boundary (Risk #6). Phase 2.B.5 adds the dep; Phase 3.C wires `SessionStore`. |
| 4 | Model generation | **`freezed` + `json_serializable`** per feature, inside each Phase 4 row (not all-at-once) | Eliminates DTO boilerplate; gives `copyWith` / `==` / `toString` for free. Migration cost amortized — only convert models that the migrating feature touches. Old hand-written `lib/model_class/*.dart` coexist until their feature is migrated. |
| 5 | Migration strategy | **Strangler fig** — feature-at-a-time | Per `MIGRATION_RULES.md` §1.1. Old + new coexist; shippable after every commit. |
| 6 | God-widget strategy | **Decompose before Notifier migration**, in its own PR | `phase4_features.md` Split rule. Track as `4.x.a` (split) + `4.x.b` (migrate). |
| 7 | Functional return type | **`Either<AppException, T>` via `dartz` (or `fpdart`)** | Per `MIGRATION_RULES.md` §5.5. Pick one in Phase 3.B.2 setup; do not mix. |
| 8 | Flavor mechanism | **Stay with `-t lib/main_<flavor>.dart`** — no Android product flavors | Per project constraint. Both flavors hit same API host today; do not introduce Android flavors mid-migration. iOS schemes deferred to a separate hardening task post-migration. |

### Package Conflicts Requiring Replacement

| Current Package | Version | Conflict | Action |
|---|---|---|---|
| `http` | `^1.4.0` | Redundant alongside Dio; primary HTTP client today. | Phase 3.B.7 swaps `api_service.dart` internals to Dio; Phase 5.B.2 removes the package. |
| `flutter_dotenv` | `^5.0.2` | 0 imports — abandoned path. | Phase 2.C.7 removes during secrets migration. |
| `flutter_stripe` | `^12.1.1` | 0 imports — never wired. | Phase 5.B.2 removes (keep only if a checkout flow is funded). |
| `image_cropper` | `^10.0.0+1` | 0 imports. | Phase 5.B.2 removes (or wires to image_picker flow in Group C / E if needed). |
| `photo_view` | `^0.15.0` | 0 imports. | Phase 5.B.2 removes. |
| `cached_network_image` | `^3.3.1` | 0 imports today but 12 `Image.network` sites should use it. | **Keep**; Phase 5.B.3 migrates the call sites. |

---

## 6. RECOMMENDED FIRST FEATURE (PILOT MIGRATION)

### Feature: **Splash + Onboarding** (Migration units 1–2, Group A)

**Why this feature:**
- **Zero API calls** — isolates the migration to infrastructure wiring only (`ProviderScope`, `GoRouter` redirect, design tokens, `AppTheme`).
- **2 screens, 270 LOC total** (72 + 198) — smallest blast radius for mistakes.
- **No dependencies** on auth state at the screen level (splash *reads* `isLoggedIn` today; after migration the read moves into `authStateProvider` consumed by the router `redirect:`).
- **Exercises every Phase 3 foundation layer:** `ProviderScope`, `GoRouter` initial route + redirect, `AppColors`, `AppTextStyles`, `AppSpacing`, `AppTheme.dark()`, `AnalyticsService` (first screen-view event). Proves the foundation works before any feature with a network call lands.
- **Self-contained navigation** — Splash → Onboarding → Login (or Home if logged in) is linear, no tab shell, no deep linking, no return-value pops, no `extra` Map.
- **Reversible** — if the approach doesn't work, these screens can revert without touching auth or any tabbed feature.
- **Already includes the `Navigator.pushReplacement` + `MaterialPageRoute` smell** (`lib/splash/splash_screen.dart`, `lib/onboding/onboding_screen.dart`) living next to `goNamed` calls — fixing this pair is a microcosm of the F-01 finding (`NAVIGATION_AUDIT.md`).

**Expected learnings (re-calibrate everything else from these):**
1. Does the `ProviderScope` → `GoRouter` (with `redirect:`) → `MaterialApp.router` wiring boot cleanly with the existing flavors (`-t lib/main_dev.dart` / `lib/main_prod.dart`)?
2. Do `AppColors` / `AppTextStyles` produce visually identical output to the current dark theme? Screenshot diff against `main`.
3. Does the splash `redirect:` flow (logged-in vs logged-out branches) work correctly, including cold-start with valid token in secure storage?
4. How long does a "trivial" 2-screen migration actually take? **This number calibrates every other group estimate.**
5. Does `pumpProviderApp` (Phase 3.D.3 minimal version) work for widget tests on these screens?
6. Are the `Notifier` patterns (manual, no codegen) ergonomic enough, or does the team want to revisit the codegen decision?

**Estimated time: 3 effort-days** (~6 calendar days solo part-time). Includes the rename of `lib/onboding/` → `lib/onboarding/` (already scoped in Phase 2.A.1, so this is just verification), writing the two `Notifier`s, swapping the inline theme for `AppTheme.dark()`, removing the raw `Navigator.pushReplacement` pairs, and a smoke widget test for each screen.

---

## 7. TIMELINE ESTIMATE

Effort-days assume the calibrated solo + part-time pace (~4 hrs/day, ~20 hr/week). Calendar weeks listed are 2× effort-days (~5 effort-days per calendar week for a part-time line).

### Phase 1 — Audit (COMPLETE)

| Task | Status | Days |
|---|---|---|
| All audits in `docs/audit/` | ✅ Done | — |
| `docs/audit/AUDIT_REPORT.md` synthesis | ✅ Done | — |
| `MIGRATION_RULES.md` published | ✅ Done | — |
| `CLAUDE.md` reflects current conventions | ✅ Done | — |
| Phase plan stubs (`docs/migration/phase1…6`) | ✅ Done | — |
| **This document** (Migration readiness report) | ✅ Now | — |

### Phase 2 — Folder Scaffold + Unblock

Source: `docs/migration/phase2_structure_and_unblock.md`. Six batches (2.A–2.F).

| Batch | Task | Est. Days |
|---|---|---|
| 2.A | Folder + file casing normalization (**`Home`, `Profile`, `Shoots` ✅ done 2026-05-27**; remaining: `onboding→onboarding`, `manageavailability→manage_availability`, `upcomingshootviewdetils→upcoming_shoot_view_details`, `Model_Class→model_class` imports, file with literal space, typo'd filenames, remaining router imports) | 1 |
| 2.B | Security hotfixes (stop password persist, strip token logs, `usesCleartextTraffic=false`, `AppLogger`; **`flutter_secure_storage ^9.2.2` already in pubspec**) | 0.75 |
| 2.C | Secrets out of source (`env/<flavor>.json`, `--dart-define-from-file`, move Maps + Stripe keys, rotate keys, drop `flutter_dotenv`) | 1 |
| 2.D | Navigation immediate fixes (duplicate `CancelScreen` routes, dead `RouteNames.changePassword`, `IndexedStack` holding measure) | 0.5 |
| 2.E | CI gate (`test/widget_test.dart` smoke, GitHub Actions: analyze + test + build dev APK, lint baseline) | 1 |
| 2.F | Folder scaffold for Phase 3/4 (`lib/core/`, `lib/features/`, `lib/shared/`, `lib/dummy/`) | 0.25 |
| | **Subtotal** | **~4.5 days** (was 5.25; refresh 2026-05-27 trimmed 2.A by 0.5 and 2.B by 0.25) |

### Phase 3 — Foundations

Source: `docs/migration/phase3_foundations.md`. Six batches (3.A–3.F).

| Batch | Task | Est. Days |
|---|---|---|
| 3.A | Design tokens (consume `ColorCode` + `AppImages` into `lib/app/{colors,text_styles,spacing,radii,shadows,durations,assets}.dart`; **`AppTheme.dark()` already wired in `MyApp` 2026-05-27**; deprecate legacy with re-export shims) | 1 |
| 3.B | Network layer (`ApiEndpoints` move, sealed `AppException`, `ApiResponse<T>`, `DioClient` with timeouts, 4 interceptors in order, `core_providers.dart`, swap `api_service.dart` internals to Dio, drop `http` from `pubspec.yaml`) | 3 |
| 3.C | `SessionStore` + auth state (interface, `SecureSessionStore`, `PrefsSessionStore` for non-secrets, one-time migration of token from prefs → keychain, `SharedService` shim, scoped `logout()`) | 1.5 |
| 3.D | App root + Riverpod (`lib/app/app.dart` resurrected, `ProviderScope` at `runApp`, drop `isLoggedIn` plumbing from `MyApp`, minimal `pumpProviderApp` helper) | 1 |
| 3.E | Navigation hardening (auth `redirect:`, `AppAnalyticsObserver` on router, document `state.extra` Map pattern, prune dead `RouteNames`) | 1 |
| 3.F | Firebase wrappers (stubs OK — `AnalyticsService`, `CrashlyticsService`, `FirebaseService.initialize` no-op if config absent) | 0.5 |
| | **Subtotal** | **~8 days** (was 8.5; refresh 2026-05-27 trimmed 3.A by 0.5) |

### Phase 4 — Feature Migration

Source: `docs/migration/phase4_features.md` (template + status table) + Section 3 above (ordering + decomposition notes).

| Group | Unit(s) | Feature | Est. Days |
|---|---|---|---|
| A | 1–2 | Splash + Onboarding (pilot) | 3 |
| B | 3 | Messages (confirm Stream vs polling first) | 1.5 |
| B | 4 | File Manager (4 screens) | 3.5 |
| B | 5 | Manage Availability (2 screens) | 3 |
| C | 9 | Profile — Settings (`AppPreferences`, `MyprofileYoureAllSetScreen`, `ProfileNewPasswrodScreen` → rename) | 2 |
| C | 10 | Profile — Delete Account flow (3 screens, linear) | 2 |
| C | 7 | Profile — Resume + Certificates + `FeaturedWorkList` (decompose 1,703 LOC first) | 5 |
| C | 8 | Profile — Profile-Details forms (3 screens incl. 950-LOC enter form) | 4 |
| C | 6 | Profile — `Myprofile` (decompose 2,834 LOC first, then migrate) | 5 |
| D | 13 | Upcoming Shoot Details (1,396 LOC; fix 4 hardcoded endpoints) | 3 |
| D | 12 | Shoots tab + supporting screens (debounce search) | 4 |
| D | 11 | Home — `HomeScreen` (decompose 2,902 LOC first; coordinate 7 fetchers into one `_load()` with `Future.wait`) | 5 |
| E | 14 | Auth — Login + `ViewDetailsScreen` (rename file with literal space) | 2 |
| E | 15 | Auth — Forgot Password trio | 3 |
| E | 16 | Auth — SignUp1 (decompose 1,959 LOC first) + SignUp2 | 5 |
| E | 17 | Auth — SignUp3 (decompose 3,465 LOC into 3–4 sub-screens; largest single risk in the project) | 4 |
| F | 18 | Shell rewrite (`StatefulShellRoute.indexedStack`, remove `BackdropFilter`) + shared widgets move + utils consolidation | 3 |
| | | **Subtotal** | **~58 days** |

### Phase 5 — Cleanup

Source: `docs/migration/phase5_cleanup.md`. Seven batches (5.A–5.G).

| Batch | Task | Est. Days |
|---|---|---|
| 5.A | Delete transitional shims (`api_service.dart`, `shared_service.dart`, deprecated re-exports, empty `lib/service/`) | 0.5 |
| 5.B | Dependency pruning (`http`, `flutter_stripe`, `image_cropper`, `photo_view`) + `Image.network` → `CachedNetworkImage` migration | 2 |
| 5.C | Comment hygiene (60+ block comments, 104 single-line dead lines, resolved `// TODO(migration)` markers) | 1 |
| 5.D | Lint upgrade (promote warnings to errors, `--fatal-infos` in CI, fix the resulting punch list) | 1 |
| 5.E | Standardization sweeps (remaining hardcoded URLs, asset string literals, analytics raw names, date/time helper consolidation, regex consolidation) | 1 |
| 5.F | Naming polish (5 colliding `Data` classes, `_screen.dart` suffix audit) | 0.5 |
| 5.G | Router final pass (split `lib/app/router.dart` per feature if >400 LOC, typed parameters in lieu of `state.extra` Map where deep-linkable, optional deep-link wiring) | 1 |
| | **Subtotal** | **~7 days** |

### Phase 6 — Testing

Source: `docs/migration/phase6_testing.md` (currently a stub; rewritten after Phase 5 stabilizes per project owner's direction).

| Task | Est. Days |
|---|---|
| Test helpers expansion (`pump_app`, `mocks`, `test_data`) | 1 |
| Unit tests for repositories (~6) | 3 |
| Unit tests for Notifiers (~15) | 4 |
| Widget tests for critical screens (login, signup3 sub-screens, home, profile, shoots, payment if added) | 3 |
| Golden tests (design-token components, light + dark) | 1 |
| Integration tests (top 3–5 user journeys: login→home→logout; login→profile→edit→save; login→shoots→cancel; signup1→2→3; forgot password) | 3 |
| CI coverage gating (lcov, 70% gate, real-emulator job on push to `main`) | 1 |
| | **Subtotal** | **~16 days** |

---

### TOTAL

| Phase | Effort Days | Status |
|---|---|---|
| Phase 1 — Audit | — | ✅ Complete |
| Phase 2 — Folder scaffold + unblock | 4.5 | Partial (3 dir renames + `flutter_secure_storage` dep done 2026-05-27) |
| Phase 3 — Foundations | 8.75 | Partial (`AppTheme.dark()` wired 2026-05-27); 2026-05-27 guides-gap patch added Task 3.20 shared widgets (+0.75d) |
| Phase 4 — Feature migration | 58 | Not started |
| Phase 5 — Cleanup | 7 | Not started |
| Phase 6 — Testing | 17 | Stub; 2026-05-27 guides-gap patch added Task 6.14 models/utils tests (+1d) |
| **TOTAL** | **~95.25 effort-days** (94.75 → 93.5 on 2026-05-27 refresh → 95.25 on 2026-05-27 guides-gap patch) | |

### Realistic calendar estimate

Calibration: **solo dev, part-time (~4 hrs/day, ~5 effort-days per calendar week)**.

- **Solo, part-time (calibrated baseline):** **~19 calendar weeks** for the optimistic case (no slippage); **~24 weeks** with a 25% buffer for god-widget surprises. **~5–6 months.**
- **Solo, full-time (~8 hrs/day, ~10 effort-days per calendar week):** **~10 calendar weeks** baseline, **~12–13 weeks** with buffer. **~3 months.**
- **Two devs, full-time:** **~6–7 weeks** baseline. One on Phase 2 + Phase 3 + auth-related foundations, the other starts Phase 4 from Group A once Phase 3.A–3.D land. Coordination overhead is real — pair on `signup3` decomposition.
- **Three devs, full-time:** **~5 weeks** baseline — but god-widget PRs serialize regardless of dev count, and Phase 3 is hard to parallelize. Not recommended unless all three are fluent in Riverpod + GoRouter.

### Recommended phased delivery (solo part-time baseline)

| Milestone | Includes | Target |
|---|---|---|
| **M1 — Unblock + CI** | Phase 2 complete (casing, security hotfixes, secrets, navigation patches, CI green on a no-op PR) | Week 3 |
| **M2 — Foundations** | Phase 3 complete (`DioClient` + interceptors live; `ProviderScope` wired; `SessionStore` swap done; design tokens consume the legacy palettes via deprecated shims; Firebase wrappers stubbed) | Week 5 |
| **M3 — Pilot landed** | Group A (splash + onboarding) on `main`; calibration numbers harvested; estimates for Groups B–E re-baselined from actuals | Week 6 |
| **M4 — Tabs cleared** | Group B (messages + file_manager + manage_availability) complete | Week 8 |
| **M5 — Profile** | Group C (13 profile screens, 2 god-widget decompositions) complete | Week 12 |
| **M6 — Home + Shoots** | Group D (home god + shoots + upcoming details) complete | Week 15 |
| **M7 — Auth** | Group E complete (login + forgot + signup decompositions — signup3 split lands as its own multi-PR sub-milestone) | Week 18 |
| **M8 — Shell + sweeps** | Group F (shell + shared widgets); Phase 5 cleanup complete; lint upgraded; `--fatal-infos` enforced in CI | Week 20 |
| **M9 — Testing** | Phase 6 complete; 70% coverage gate live; top 3–5 user journeys covered by integration tests | Week 24 |
| **M10 — Production-readiness gate** | All 16 items in `docs/audit/AUDIT_REPORT.md` Production Readiness Gate satisfied; release candidate APK + IPA built per flavor | Week 25 |

---

## Appendix — Quick links

> All paths relative to repo root (this file lives at repo root since 2026-05-27).

- [`MIGRATION_RULES.md`](MIGRATION_RULES.md) — the rulebook. Non-negotiable.
- [`MIGRATION_LOG.md`](MIGRATION_LOG.md) — decisions, judgment calls, deviations logged as migration proceeds.

### Sprint boards (phase index + task chunks; 2026-05-27 restructure)

- [`docs/phase1/README.md`](docs/phase1/README.md) — Phase 1 Audit (🟢 Completed)
- [`docs/phase2/README.md`](docs/phase2/README.md) — Phase 2 Folder Scaffold + Unblock (9 tasks)
- [`docs/phase3/README.md`](docs/phase3/README.md) — Phase 3 Foundations (19 tasks)
- [`docs/phase4/README.md`](docs/phase4/README.md) — Phase 4 Feature Migration (23 tasks)
- [`docs/phase5/README.md`](docs/phase5/README.md) — Phase 5 Cleanup (8 tasks)
- [`docs/phase6/README.md`](docs/phase6/README.md) — Phase 6 Testing & CI (13 tasks)
- [`docs/migration/flavor_bundle_id_plan.md`](docs/migration/flavor_bundle_id_plan.md) — native flavor / bundle id companion plan.

### Audits + guides

- [`docs/audit/AUDIT_REPORT.md`](docs/audit/AUDIT_REPORT.md) — consolidated audit, Top-10 priority list, production-readiness gate (0/16 today).
- [`docs/audit/NAVIGATION_AUDIT.md`](docs/audit/NAVIGATION_AUDIT.md) — route table + findings F-01 through F-09.
- [`docs/guides/FLUTTER_BASE_GUIDELINES.md`](docs/guides/FLUTTER_BASE_GUIDELINES.md) — target architecture, network, Firebase, navigation, CI.
- [`docs/guides/FLUTTER_DESIGN_SYSTEM.md`](docs/guides/FLUTTER_DESIGN_SYSTEM.md) — design tokens.
- [`docs/guides/FLUTTER_TESTING_GUIDELINES.md`](docs/guides/FLUTTER_TESTING_GUIDELINES.md) — testing patterns.
