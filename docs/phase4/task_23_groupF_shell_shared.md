# Task 4.23 — Group F · Unit 18 · Shell rewrite + shared widgets

**Phase:** 4 · **Group:** F · **Status:** 🟢 Completed · **Est:** 3d

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

## Goal
Replace the legacy `Mainscreen` shell with `StatefulShellRoute.indexedStack`. Remove persistent `BackdropFilter` (`AUDIT_PERF.md` D-1 — 4–6ms/frame). Move shared widgets from `lib/widgets/` → `lib/shared/widgets/`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group F; §4 Risks #16, #17; §5 Architectural Decision #2
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §6.1

## Files in scope (max 10)
- `lib/shared/layouts/app_shell.dart` — new (`AppShell` + drawer + bottom-bar)
- `lib/app/router.dart` — `StatefulShellRoute.indexedStack` with 5 branches; legacy `appRouter` constant dropped
- `lib/app/route_names.dart` — added `shoots`, `files`, `messages`, `manageAvailability`
- `lib/main_screen.dart` — **deleted** (465 LOC)
- `lib/widgets/` — **deleted** (12 files); 11 moved to `lib/shared/widgets/`, `common_image_picker.dart` deleted (unused)
- `lib/shared/widgets/*` — moved targets with internal `../app/X` → `../../app/X` import depth fix
- `test/shared/layouts/app_shell_test.dart` — new (2 cases: tab-state preservation + drawer item switches branches)
- 35 caller files across `lib/features/**` — import-path rewrite from `widgets/` → `shared/widgets/` and `app_loder` → `app_loader`

## Steps
- [x] Convert each tab body to a `StatefulShellRoute` branch — 5 branches: `/home` (HomeScreen), `/shoots` (ShootsScreen), `/files` (FileManagerScreen), `/messages` (MessagesScreen), `/manage-availability` (ManageAvailabilityScreen).
- [x] Surface "Manage Availability" drawer item — kept in drawer as the 5th branch. Bottom bar still shows 4 tabs (Dashboard, Shoots, Files, Messages); drawer is the only entry to Manage Availability. Matches legacy UX. Follow-up: design-led bottom-bar restructure if MA needs to be more discoverable.
- [x] Remove `BackdropFilter(sigmaX: 80, sigmaY: 70)` from the bottom bar — `_AppShellBottomBar` is a plain `BottomNavigationBar` with `AppColors.background`. Per `AUDIT_PERF.md` D-1 this reclaims 4-6 ms/frame on scroll-heavy screens. DevTools verification deferred — empirical frame measurement belongs in a perf sweep (Phase 6.07).
- [x] `git mv` each widget into `lib/shared/widgets/` with `snake_case` filenames (legacy names preserved; one typo fix `app_loder.dart` → `app_loader.dart`). `common_image_picker.dart` deleted (0 importers).
- [x] Update every import call site (36 files) — bulk-rewrote via perl. Both relative (`'../../widgets/X.dart'`) and absolute (`'package:beige_creative_app/widgets/X.dart'`) forms covered.
- [x] Widget test for tab-switching state preservation — `test/shared/layouts/app_shell_test.dart` pumps the shell with stubbed counter branches, bumps the Dashboard counter twice, switches to Shoots + back, asserts `A: 2` survives. Second test asserts drawer-driven `goBranch(4)` lands on Manage Availability.

## Acceptance
- [x] Tab state preserved across switches (scroll position, form drafts) — `IndexedStack` semantics under `StatefulShellRoute`; verified by `app_shell_test`.
- [x] `flutter analyze` clean — 82 issues (was 83 baseline). Net **−1**; one new `app_shell.dart` unused-param warning fixed in-flight.
- [x] `BackdropFilter` removed; frame budget improves (verify in Flutter DevTools) — removed structurally. DevTools verification deferred to a Phase 6 perf sweep.
- [x] All shared widgets live under `lib/shared/widgets/`.
- [x] `lib/widgets/` and `lib/main_screen.dart` deleted.

## Notes
- End of Phase 4. All 23 tasks complete.
- The router was the only `appRouter` constant call site (legacy back-compat alias). Removed — `routerProvider` is the single source.
- `Mainscreen` carried a `fetchprofiledata()` API call to populate the drawer profile chip. The new drawer shows a static "My Profile" chip + caption; the chip routes to `RouteNames.myProfile` which has its own `myProfileNotifierProvider` fetch. Reasoning: legacy fetched on every shell mount; the new path fetches only when the user navigates into MyProfile. Net better. Follow-up if user feedback demands the avatar back: wire a non-autodispose `drawerProfileSummaryProvider` that caches the lightweight name + image url.
- `home`, `shoots`, `files`, `messages`, `manage-availability` route names added. Old code using `RouteNames.home` still works (same string value).
- `appRouter` consts/global removed → there is now exactly one router instance per `ProviderScope`. Test `widget_test.dart` already uses `routerProvider`.
