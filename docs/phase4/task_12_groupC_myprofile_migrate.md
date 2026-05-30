# Task 4.12 — Group C · Unit 6.b · Migrate `Myprofile`

**Phase:** 4 · **Group:** C · **Status:** 🟢 Completed · **Est:** 3d · **Actual:** ~1.5h (cold session)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-myprofile` |

## Goal
Migrate the post-split profile entry screen to Riverpod. ~6 API calls, drawer integration, logout flow.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 6

## Files in scope (max 8)
- `lib/features/profile/presentation/providers/my_profile_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/screens/my_profile_screen.dart`
- All widgets created in 4.11 (consume notifier via `ref.watch`)
- `lib/main_screen.dart` — drawer navigation update
- Delete legacy `lib/profile/myprofile.dart`

## Steps
- [x] `AutoDisposeNotifier` initialization fetches profile data via `Future.microtask(refresh)`
- [x] Notifier owns refresh, photo upload, social/portfolio CRUD
- [x] Stats panel updates via `ref.watch` only — no `setState` for stats/lists
- [x] Drawer logout already routes via `RouteNames.myProfile` + `ProfileLogoutButton.SharedService.logout()` — deferred until 5.01 SessionStore swap
- [x] Widget tests for happy path — 6 notifier cases

## Acceptance
- [x] All 6 API calls flow through repo (`profileFilesRepository.fetchProfile` + `profileRepository.{updateSocialLinks, addPortfolioLinks, editPortfolioLink, uploadPhoto}` + `profileFilesRepository.deleteFile`)
- [x] No `setState` in profile screen for persisted state. Local `_profileImage` stays in widget per CLAUDE.md (file-picker → preview); controllers stay in widget
- [x] No `ApiService()` instantiations remain in `my_profile_screen` or its 9 widget files. (Repo impls still use ApiService shim for multipart per task notes.)
- [x] `flutter analyze` clean — only deprecation infos matching sibling parity

## Notes
Group C completion = ~30% of total feature migration done. Re-baseline Groups D + E using cumulative actuals.
