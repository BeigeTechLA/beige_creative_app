# Task 4.14 — Group D · Unit 12 · Shoots tab + supporting screens

**Phase:** 4 · **Group:** D · **Status:** 🟢 Completed · **Est:** 4d

| Field | Value |
|---|---|
| Owner | Claude (assist) |
| Branch | `improvments-phase1` |

## Goal
Migrate `ShootsScreen` (1,032 LOC, Tab 1 root) + `ShootCancelledScreen` (331) + `ShootRequestAccepted` (73) + `ShootCancelledLottiesScreen` (71). **Debounce required:** `searchShoots` previously fired on every keystroke.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group D Unit 12; §4 Risk #8 (state leaks)
- [`../audit/AUDIT_PERF.md`](../audit/AUDIT_PERF.md) D4 (debounce)

## Files in scope (max 8)
- `lib/features/shoots/presentation/providers/shoots_providers.dart` — `ShootsListNotifier` + `CancelShootNotifier` + state classes + debounce timer
- `lib/features/shoots/presentation/screens/shoots_screen.dart` — `ConsumerStatefulWidget` (Tab 1 root)
- `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart` — `ConsumerStatefulWidget` (decline bottom sheet)
- `lib/features/shoots/presentation/screens/shoot_request_accepted_screen.dart` — `ConsumerStatefulWidget`
- `lib/features/shoots/presentation/screens/shoot_cancelled_lotties_screen.dart` — `ConsumerStatefulWidget`
- `lib/features/shoots/domain/repositories/shoots_repository.dart` — extended with `fetchShoots()` + `fetchShootCount()`
- `lib/features/shoots/data/repositories/shoots_repository_impl.dart` — Dio impls for the two new methods

## Steps
- [x] `AutoDisposeNotifier<ShootsListState>` exposes search + accept; counts hydrate alongside the list
- [x] 250ms debounce on search (`Timer` cancellation in Notifier; cancelled in `ref.onDispose`)
- [x] Cancel-shoot flow uses repo method from 4.13 (`respondToProject(status: 'declined', reason, comment)`)
- [x] Widget/notifier tests for search debounce + cancel happy path (10 cases)
- [x] Pagination dedupe — N/A (list is non-paginated; full dashboard payload arrives in one call). Documented in Decisions.

## Acceptance
- [x] Typing in search fires at most 1 filter pass per 250ms; zero new API calls (filter is client-side over the cached `allShoots` list)
- [x] No duplicate items — list is replaced wholesale on refresh; search returns a filtered copy
- [x] `flutter analyze` clean (159 issues — one fewer than 160 baseline)
- [x] No `setState` in `ShootsScreen` build path (only in `CancelScreen` for the local `_isOtherSelected` toggle, gated by the AnimatedSwitcher pattern)

## Notes
- Search debounce lives in the Notifier (state-machine pattern per `MIGRATION_RULES.md` §3.11). Filter is purely client-side — the backend has no paginated search endpoint for this list, so the debounce avoids repeated client-side filter passes while the user is typing.
- `CountCard` data is non-fatal: if `fetchShootCount` fails, the list still hydrates with `counts: null` (safe-defaults render `00`). This matches legacy behavior where the count-fetch try/catch swallowed errors.
- `fetchacceptdecline` legacy path used `crew_accept: int` (1=accept, 2=decline). New flow standardizes on `status: accepted|declined` per the 4.13 shape, with the backend supporting both forms; verify on staging before flipping the deprecation flag on `crew_accept`.
- `ShootRequestAccepted` had no live callers in legacy (commented-out post-accept routing). Migration preserves the class for forward use; route entry deferred until a caller is wired.
- 4 hardcoded endpoint strings all flowed through `ApiEndpoints` already (`acceptdeclineproject`, `myshootcount`, `creatordashboarddetails`); zero net new endpoint constants required.
