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
### Sticky header proposal — 2026-11-13

- [x] Prepared [phase-wise change plan](../feature/SHOOT_DETAILS_STICKY_HEADER_PLAN.md) for a collapsing photo and pinned toolbar, including navigation and visual QA.
- [x] User approved; implemented collapsing photo/pinned toolbar in CP Shoot Details. This supersedes the previous non-sticky preference. Host tests 23/23; iOS simulator navigation 29/29; scoped analysis and whitespace checks pass. Synthetic white-image renders reviewed at three scroll positions.
- [ ] Physical-device, native Android, landscape and authenticated live-photo/error-state smoke remain pending; see plan execution report.

### Header/navigation review — 2026-11-13

- [x] Figma `7343:62991` shows a creator profile with Back/Share/Favourite; no exact screen found in this CP repository. Auth ViewDetails is a different profile-preview layout.
- [x] Related Shoot Details contrast issue: gradient ends at safe-area inset + 32; the 44-point back target starts at inset + 8. Recommend maintaining darkness through the entire toolbar before fading, retaining the scrolling/plain-arrow preference.
- [x] Back callback pops or falls back to named Shoots; route uses SDK MaterialPage. Focused route/page/details tests pass 13/13, including production shoot-route iOS edge swipe and shared Android system back.
- Review only; no UI changes. Arrow tap/fallback inspected in source, no fresh device interaction. Exact Figma screen events remain unverified because that screen was not found here.

### Android navigation QA — 2026-11-12

- [x] Wedding #4596 loads, scrolls and returns using Android Back on dev API 36 emulator.
- [ ] Resolve Brand & Product #3052 detail HTTP 400 (`Invalid v4 shoot_type.`) and literal `null` values after failure. Route/Back work; contract/data and error-state follow-up remain open.
- Full host suite: 756 passed. See [navigation report](../upgrade/ANDROID_NAVIGATION_QA_2026-11-12.md).

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

**Back-button visibility follow-up (2026-11-04):**
- [x] Keep the back control outside scrolling content, below the status bar, with a dark circular background and white icon (44-point tap target).
- [x] Pop to the caller when available; otherwise navigate to the named Shoots route.
- [x] Scoped analysis clean; existing details widget tests 5/5 pass; hot reload and simulator screenshot confirm visibility over the bright header photo.
- Manual scroll/back interaction remains to be checked; no broader migration status change.

**Back-button preference correction (2026-11-04):** Supersedes the fixed/circular treatment above. Per user reference and scrolling feedback, the white arrow has no background and lives inside the image header so it scrolls away without covering content. The 44-point tap target, tooltip, and named-route fallback remain. Scoped analysis passes; hot reload applied.
