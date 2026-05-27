# Task 3.05 — Legacy shims for `ColorCode` / `AppImages`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 2h

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
- [ ] Replace each `ColorCode` getter body with `=> AppColors.xxx`
- [ ] Annotate the class + each getter with `@Deprecated('Use AppColors.xxx — to be removed in Phase 5')`
- [ ] Same for `AppImages` → `AppAssets`
- [ ] `flutter analyze` — accept deprecation warnings (do not promote to errors yet)

## Acceptance
- [ ] Legacy classes compile and forward to the new tokens
- [ ] `flutter analyze` shows deprecation hints but no errors
- [ ] App renders unchanged

## Notes
The deprecations are the migration radar. Phase 4 feature work knocks them out one feature at a time; Phase 5.01 deletes the shims.
