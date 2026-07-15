# Task 4.04 — Group B · Unit 4 · File Manager (4 screens)

**Phase:** 4 · **Group:** B · **Status:** ✅ Completed (presentation + Notifier; stub repo until backend lands) · **Est:** 3.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` |

## Goal
Migrate the four file-manager screens (1,462 LOC combined) to Clean Architecture + Riverpod. Exercises the multi-screen feature template for the first time.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group B; §4 Risk #8 (controller leaks)
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 10)
- `lib/features/file_manager/domain/entities/file_folder.dart`
- `lib/features/file_manager/domain/entities/file_item.dart`
- `lib/features/file_manager/domain/repositories/file_manager_repository.dart`
- `lib/features/file_manager/data/repositories/file_manager_stub_repository.dart`
- `lib/features/file_manager/presentation/providers/file_manager_providers.dart`
- `lib/features/file_manager/presentation/screens/file_manager_screen.dart`
- `lib/features/file_manager/presentation/screens/pre_production_screen.dart`
- `lib/features/file_manager/presentation/screens/post_production_screen.dart`
- `lib/features/file_manager/presentation/screens/view_details_screen.dart` (class renamed to `FileManagerViewDetailsScreen` to avoid auth-collision)
- `test/features/file_manager/presentation/screens/file_manager_screen_test.dart`
- (Glue: `lib/main_screen.dart` import, `lib/app/router.dart` imports — mechanical)

## Steps
- [x] Repo + datasource with 3 endpoints — **Modified.** No backend endpoints exist; created `FileManagerRepository` interface + `FileManagerStubRepository` returning hardcoded lists. Real Dio impl swaps in when API lands.
- [x] One Notifier per screen — 4 notifiers (`FileManagerNotifier`, `PreProductionNotifier`, `PostProductionNotifier`, `ViewDetailsNotifier`). Three latter use `AutoDisposeFamilyNotifier<…, String>` (folderId param).
- [x] Replace `ApiService()` instantiations with repo provider — **N/A.** Legacy had zero `ApiService()` calls; data was hardcoded inline. Repo provider is wired in regardless so the swap-point is ready.
- [x] All `TextEditingController`s owned + disposed by Notifier — **Deviation.** Controllers stay in `ConsumerState.dispose`. Reason: matches splash/onboarding precedent + CLAUDE.md guidance ("controllers belong to widget lifecycle"). Notifier holds the *value* (`query`), controller flushes to it via `onChanged: notifier.setQuery`. All 4 controllers across 3 screens are disposed.
- [x] Widget test on file_manager root screen — 3 cases: render with repo override, search-query filter, view-mode toggle. Repo injected via `fileManagerRepositoryProvider.overrideWithValue(_FakeRepo())`.

## Acceptance
- [x] `flutter analyze` → 292 issues (was 300; **-8** because legacy file_manager had 6 `print` + 1 deprecated `color:` + 1 unused). No new lints in `features/file_manager/`.
- [x] All 4 screens render and fetch data — data flows through repo provider; in tests, stub returns deterministic folders; in app, `FileManagerStubRepository` returns the original hardcoded shape.
- [x] No `setState` after migration — verified via grep.
- [x] No `ApiService()` instantiation in this feature — verified (none was present pre-migration either).

## Notes
**Repository swap-point is the deliverable.** When backend lands, replace `fileManagerRepositoryProvider`'s `FileManagerStubRepository` with a `FileManagerRemoteRepository(dio: …)`; no notifier or screen edit needed.

**Class rename:** `view_details_screen.dart` exports `FileManagerViewDetailsScreen` to disambiguate from `lib/auth/view_details_screen.dart` (which the router already exposes under `RouteNames.viewDetails`). Reached via `Navigator.push` from pre-production, not the GoRouter — matches legacy behavior.

**Calibration:** ~30 min vs. 3.5d budget. Multi-screen no-repo task — still does not establish baseline for repository-bound tasks. Group B-E budgets remain as posted until the first feature with a non-stub repository lands (likely 4.05 Availability or 4.13 Upcoming Details, which have real endpoints in `ApiEndpoints`).

**API follow-up (audited 2026-07-14):** The original Phase 4 migration remains
complete. Post-migration API work is tracked separately in
[`../feature/filemanager/FILE_MANAGER_API_PLAN.md`](../feature/filemanager/FILE_MANAGER_API_PLAN.md):
FM7 is 6/6 implementation-complete, FM8 is 3/10 complete with 7 tasks blocked
on upload-protocol confirmation, and FM9 has 1/4 tasks partial. Dummy
repositories still default on, so remote activation is not yet shipped.
