# Task 4.05 — Group B · Unit 5 · Manage Availability

**Phase:** 4 · **Group:** B · **Status:** ✅ Completed · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` |

## Goal
Migrate the two availability screens (1,742 LOC combined). Verify `add_availability` endpoint leading-slash fix from Task 3.06 took effect.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 8)
- `lib/features/availability/domain/entities/availability_entry.dart` — `AvailabilityStatus` enum + `AvailabilityPayload` value object
- `lib/features/availability/domain/repositories/availability_repository.dart`
- `lib/features/availability/data/repositories/availability_repository_impl.dart` — Dio-backed, DTO→entity mapping inline
- `lib/features/availability/presentation/providers/availability_providers.dart` — repo provider + `ManageAvailabilityNotifier` + `AddAvailabilityNotifier`
- `lib/features/availability/presentation/screens/manage_availability_screen.dart`
- `lib/features/availability/presentation/screens/add_availability_screen.dart`
- `test/features/availability/presentation/screens/availability_test.dart` — 5 cases
- (Glue: `lib/main_screen.dart` + `lib/app/router.dart` imports retargeted; `lib/manage_availability/` deleted)

## Steps
- [x] Repo + datasource (~2 endpoints) — `creator/availability` (POST `{month, year}`) + `creator/add-availability` (POST payload). Datasource folded into `AvailabilityRepositoryImpl` (Dio call site + DTO mapping in one file) to stay inside the 8-file budget; can be extracted later if it grows.
- [x] State: selected days, ranges, recurrence — `ManageAvailabilityState{focusedDay, events: Map<DateTime, AvailabilityStatus>, eventFilter, isLoading}`; `AddAvailabilityState{type, recurrence, includeWeekends, isAllDay, selectedWeekDays, isSubmitting, submittedOk, errorMessage, validationMessage}`.
- [x] Calendar widget reusable from `lib/widgets/common_calendar.dart` — kept in place; moves to `lib/shared/widgets/` in Group F (per task plan).
- [x] Widget tests for save flow — 3 `AddAvailabilityNotifier` unit cases (rejects missing type, posts payload with all-day + weekly recurrence, surfaces error on repo throw); 2 `ManageAvailabilityNotifier` cases (loads + count getters, shiftMonth updates focused day + reloads).

## Acceptance
- [x] `flutter analyze` → 285 issues (was 292; net **-7** from legacy avoid_print + deprecated_member_use). 3 deprecated `useMaterial3` / `dialogBackgroundColor` carried forward verbatim from legacy date/time picker themes — not regressions.
- [x] Save availability returns 2xx — `createAvailability` on the real repo posts to `ApiEndpoints.add_availability` via Dio; non-2xx surfaces through Dio's exception path → `errorMessage` in state → snackbar via `ref.listen`.
- [x] Calendar selection state survives orientation change — focused day + filter live in Riverpod; orientation rebuild reads from the notifier rather than local `setState`.
- [x] No `ApiService()` direct instantiation — verified via grep on `lib/features/availability/`.

## Notes
**Controllers stay in widgets, not notifiers.** Same precedent as Tasks 4.01/4.02/4.04 — controllers belong to widget lifecycle; the notifier holds parsed values. The Add screen owns 6 controllers, all disposed in `dispose()`.

**`ref.listen` for snackbar side-effects** — `AddAvailabilityState{validationMessage, errorMessage}` drives the messenger from the widget's `ref.listen` callback. Keeps the notifier pure (no `BuildContext`).

**Test infrastructure note for AutoDispose notifiers:** `container.read(provider)` alone is insufficient — AutoDispose disposes after the synchronous read returns, killing the microtask that runs the initial `refresh()`. Pattern is `container.listen(provider, (_, _) {})` to hold the element alive, then poll `!isLoading` up to 20 microtask drains. Reusable for any Group B-E notifier test that loads in `build()`.

**Calibration:** ~50 min vs. 3d budget. **First real repository task** — Dio + endpoint integration + DTO mapping + submit flow + error surfacing. Even with the bigger surface, the per-feature template is now established: domain entities → repo interface → impl → provider + notifier(s) → screens → tests. Group B-E remaining budgets should be reduced once one more API-bound task lands (likely 4.13 Upcoming Details). Don't re-baseline yet on a single data point.

**Post-completion UI polish (2026-07-27):** The Add Availability type
dropdown now shows a semantic green status dot for `Available` and a red status
dot for `Not Available`. The Add Date field displays selected dates in
`MM/dd/yyyy` format while API payloads remain `yyyy-MM-dd`; the field starts
blank whenever the form loads. Selection behavior and submitted values are
otherwise unchanged. All form validation and submission errors use the shared
app-level `TopMessage` theme instead of raw `SnackBar` instances.

**Post-completion date icon update (2026-08-05):** The Add Date and Until Date
fields, plus the Manage Availability screen's Available Days card, now use the
shared `assets/icon/ic_add_date.svg` asset through `AppAssets.icAddDate`.
