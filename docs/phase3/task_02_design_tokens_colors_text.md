# Task 3.02 — Design tokens: colors + text styles

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 4h
**Note:** `AppTheme.dark()` already wired at `lib/main.dart:45` (2026-05-27). This task fills the underlying `AppColors` + `AppTextStyles` scaffolds it depends on.

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/tokens-colors-text` |

## Goal
Translate every entry from `lib/utility/colorcode.dart` and every inline `TextStyle()` exemplar into `lib/app/colors.dart` + `lib/app/text_styles.dart`. Keep the scaffolds (which already exist as 463 + 573 LOC) and audit-correct them against actual usage.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations rows 1–2
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §4 Design Token Migration
- [`../audit/AUDIT_QUALITY.md`](../audit/AUDIT_QUALITY.md)

## Files in scope (max 5)
- `lib/app/colors.dart` — verify every `ColorCode.*` value has a semantic `AppColors.*` mapping
- `lib/app/text_styles.dart` — define `displayLarge..caption` per `MIGRATION_RULES.md` §4.4
- `lib/utility/colorcode.dart` — leave intact (Task 3.05 wraps as shim)
- `lib/main.dart` — verify `AppTheme.dark()` references the consolidated tokens

## Steps
- [ ] Diff `ColorCode.*` vs `AppColors.*` — fill gaps
- [ ] Scan top 10 god widgets for inline `TextStyle(...)` — categorize into `display/title/body/label/caption`
- [ ] Update `AppTextStyles` so every inline style maps cleanly
- [ ] Verify `AppTheme.dark()` consumes both without inline overrides

## Acceptance
- [ ] Every `ColorCode.X` has a corresponding `AppColors.Y` (with the **same** `Color(0xFF…)` value)
- [ ] `lib/app/text_styles.dart` has at least the 13 semantic styles from §4.4
- [ ] App renders pixel-identical to current — screenshot diff against `main`
- [ ] `flutter analyze` clean

## Notes
Zero visual drift is non-negotiable per `MIGRATION_RULES.md`. If a `ColorCode` value doesn't fit any semantic name, add it as `AppColors.<contextSpecific>` rather than mapping incorrectly.
