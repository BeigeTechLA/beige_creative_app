# Task 5.07 — Naming polish

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/naming-polish` |

## Goal
Rename 5 colliding `Data` classes (`AUDIT_QUALITY.md` flagged) to feature-specific names. Audit `_screen.dart` suffix consistency (some Profile screens lack the suffix).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.F

## Files in scope (≤10)
- Files containing `class Data` (run `grep -rn "class Data" lib/` to enumerate)
- Files where the class is e.g. `Myprofile` but file is `my_profile_screen.dart` → add `Screen` suffix

## Steps
- [ ] List `Data` classes, propose feature-specific names per usage
- [ ] Rename + all references in one PR per class (≤5 files each)
- [ ] Add `_screen.dart` to any presentation screen class missing it
- [ ] `flutter analyze` clean

## Acceptance
- [ ] `grep -rn "class Data" lib/` returns 0
- [ ] Every file under `presentation/screens/` ends with `_screen.dart`
- [ ] Every class in those files ends with `Screen`
- [ ] App boots

## Notes
Class renames cascade — keep each rename in its own commit with ≤5 files. Use `git mv` if filename changes.
