# Task 4.13 — Group D · Unit 13 · `UpcomingShootViewDetils`

**Phase:** 4 · **Group:** D · **Status:** 🟢 Completed · **Est:** 3d

| Field | Value |
|---|---|
| Owner | Claude (assist) |
| Branch | `improvments-phase1` |

## Goal
Migrate the 1,184-LOC shoot details screen. Fix hardcoded endpoint string literals by moving them into `ApiEndpoints`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group D Unit 13; §4 Risk #13

## Files in scope
- `lib/features/shoots/domain/repositories/shoots_repository.dart`
- `lib/features/shoots/data/repositories/shoots_repository_impl.dart`
- `lib/features/shoots/presentation/providers/upcoming_shoot_providers.dart`
- `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`
- `lib/core/network/api_endpoints.dart` — `projectDetails(id)` helper
- `lib/app/router.dart` — retarget import

## Steps
- [x] Move hardcoded URL into `ApiEndpoints.projectDetails(id)` helper
- [x] `AutoDisposeFamilyNotifier<UpcomingShootDetailState, int>` loads detail + handles accept/decline
- [x] Accept + Decline actions emit `respondedSignal` bump consumed via `ref.listen`
- [x] Screen rewritten as `ConsumerWidget` consuming `upcomingShootDetailProvider(projectid)`
- [x] Dead legacy code stripped (~400 LOC of unreachable methods)
- [x] Notifier tests — 5 cases (refresh hydrate, refresh error, accept signal, decline payload, respond failure)
- [x] Router import retargeted; legacy `lib/upcoming_shoot_view_details/` deleted

## Acceptance
- [x] `grep -rn "https://\|http://" lib/features/shoots/` returns nothing
- [x] `flutter analyze` clean of new regressions (160 issues — unchanged baseline)
- [x] All API calls flow through repo
- [x] Accept + Decline flow wired

## Notes
- Re: "4 hardcoded endpoints" claim in original plan: actual count was **1 live hardcoded URL** (`creator/project-details/<id>`). The decline/cancel/accept buttons in legacy were commented-out / dead code, so their endpoints never made it to runtime. Migration preserved the live accept-project flow (which already used `ApiEndpoints.acceptdeclineproject`) and added the project-details helper.
- First use of `AutoDisposeFamilyNotifier<State, int>` + `AutoDisposeNotifierProviderFamily<Notifier, State, int>` in the codebase — keyed by `projectId`.
- Legacy file size reduction: 1,184 LOC → 386 LOC orchestrator (~67% drop) — bulk savings came from stripping unreachable methods, not just decomposing into Riverpod state.
- Calibration vs 3d budget: ~1.5h actual.

**Post-completion Time & Budget icon update (2026-08-05):** The Event Budget
and Total Time Duration items now use `assets/svg/shoots/ic_doller.svg` and
`assets/svg/shoots/ic_clock_circle.svg` through `AppAssets` instead of Material
icons. The event information row also uses `ic_shoot_date.svg`,
`ic_shoot_location.svg`, and a white-tinted reuse of `ic_clock_circle.svg`.

**Post-completion type-chip update (2026-08-05):** Shoot Type and Booking Type
chips are borderless and use the shared `AppColors.surfaceChip` (`#323131`)
background.
