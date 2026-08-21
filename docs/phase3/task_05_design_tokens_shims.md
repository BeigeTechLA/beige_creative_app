# Task 3.05 — Legacy shims for `ColorCode` / `AppImages`

**Phase:** 3 · **Status:** ⛔ Obsolete — N/A · **Est:** 2h (skipped)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/legacy-shims` |

## Goal
Turn `lib/utility/colorcode.dart` and `lib/utility/imges_icons.dart` into thin `@Deprecated` re-export wrappers around `AppColors` / `AppAssets`. Surfaces the migration to every consumer via deprecation warnings without breaking compiles. Phase 5.01 deletes both files.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 3.A
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §1.1 (old + new coexist)

## Files in scope
- `lib/utility/colorcode.dart`
- `lib/utility/imges_icons.dart`

## Steps
- [x] ~~Replace each `ColorCode` getter body~~ — N/A. `lib/utility/colorcode.dart` does not exist (deleted in commit `c416cb6` "Centralize design tokens; migrate widgets to AppColors and retire ColorCode").
- [x] ~~Annotate `ColorCode`~~ — N/A.
- [x] ~~Same for `AppImages`~~ — N/A. `lib/utility/imges_icons.dart` does not exist (removed in prior Phase 1/2 work alongside `AppAssets` migration).
- [x] `flutter analyze` — moot for this task; no shim files to add.

## Acceptance
- [x] Legacy classes compile and forward — N/A (deleted, not shimmed). Effective end-state matches Phase 5.01 (deletion) already.
- [x] `flutter analyze` shows deprecation hints — N/A (no shim hints to surface).
- [x] App renders unchanged — preserved by not touching any code.

## Notes
The deprecations are the migration radar. Phase 4 feature work knocks them out one feature at a time; Phase 5.01 deletes the shims.

**Audit result (2026-05-28):** Task is **obsolete by prior-phase action**. Both legacy files (`colorcode.dart`, `imges_icons.dart`) were removed during Phase 1/2 sweeps, with all consumers already migrated to `AppColors` / `AppAssets`. The shim layer this task was meant to introduce is unnecessary because there are no remaining `ColorCode.*` / `AppImages.*` call sites to deprecate (greppable zero). Phase 5.01 (delete shims) has effectively already happened.

**Downstream impact:** Phase 5.01 deletion step should be cross-referenced as "completed by Phase 1/2 cleanup, see MIGRATION_LOG 2026-05-27 Phase 2 entry" when that task comes due.
