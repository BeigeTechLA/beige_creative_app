# Task 3.04 — Design tokens: assets

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 3h

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
- [ ] Diff `AppImages` keys vs `AppAssets` — add any missing
- [ ] `grep -rln "AppImages\." lib/ | wc -l` → split into batches of ≤5 files per commit
- [ ] Per batch: update import + identifier rename; verify image renders
- [ ] Leave `imges_icons.dart` intact for now

## Acceptance
- [ ] Every asset path appears in `AppAssets` with a semantic name
- [ ] `grep -rn "AppImages\." lib/` ≤ count of files in `lib/utility/`
- [ ] Visual smoke: home + profile + booking — all images render
- [ ] `flutter analyze` clean

## Notes
Image paths must be exact strings — typos here mean silent missing assets. Verify in debug overlay.
