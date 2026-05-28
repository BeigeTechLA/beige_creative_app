# Task 3.04 — Design tokens: assets

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/tokens-assets` |

## Goal
Consolidate `AppImages` (in `lib/utility/imges_icons.dart`) into `lib/app/assets.dart` as `AppAssets`. 21+ files reference `AppImages.*` today — convert imports + identifiers, keep paths byte-identical.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 8
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §4.1

## Files in scope (max 5 per commit; split if more)
- `lib/app/assets.dart` — verify completeness vs `AppImages`
- All callers of `AppImages.*` — convert to `AppAssets.*`
- `lib/utility/imges_icons.dart` — keep, gets shimmed in [Task 3.05](task_05_design_tokens_shims.md)

## Steps
- [x] Diff `AppImages` keys vs `AppAssets` — moot: `lib/utility/imges_icons.dart` already deleted. `AppAssets` (189 LOC) holds the canonical set.
- [x] Convert callers — zero `AppImages.*` references remain in `lib/` (43 `AppAssets.*` call sites).
- [x] Per batch verification — n/a (already migrated in prior commits).
- [x] `imges_icons.dart` — already removed (not just shimmed). Task 3.05 shim is obsolete for this token.

## Acceptance
- [x] Every asset path appears in `AppAssets` — confirmed via grep; zero hardcoded `'assets/` strings in widgets outside `lib/app/assets.dart`.
- [x] `grep -rn "AppImages\." lib/` → **0** references.
- [ ] Visual smoke: home + profile + booking — **not verified** (no UI smoke harness available). Asset string set unchanged in this task.
- [x] `flutter analyze lib/app/assets.dart` — 26 pre-existing info-level `constant_identifier_names` lints (legacy snake_case names like `group_logo`, `clock_icon`); zero errors.

## Notes
Image paths must be exact strings — typos here mean silent missing assets. Verify in debug overlay.

**Audit result (2026-05-28):** Migration already done. `AppAssets` at `lib/app/assets.dart` (189 LOC) is the single source; `imges_icons.dart` removed; zero remaining `AppImages.` refs; zero hardcoded `'assets/` literals in widgets. Pre-existing snake_case constant names retained to avoid widespread cascading renames — flagged as Phase 4 cleanup opportunity if desired.
