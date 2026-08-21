# Task 3.02 — Design tokens: colors + text styles

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 4h
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
- [x] Diff `ColorCode.*` vs `AppColors.*` — moot: `ColorCode` already retired in commit `c416cb6` ("Centralize design tokens; migrate widgets to AppColors and retire ColorCode"). Zero `ColorCode.*` refs remain across `lib/`.
- [x] Scan god widgets for inline `TextStyle(...)` — categorized in Phase 2 sweeps (Batches 4–11 visible in `AppTextStyles` extended sections).
- [x] Update `AppTextStyles` so every inline style maps cleanly — file has 13 §4.4 semantic styles + ~50 harvested extended exemplars + inherit/legacy buckets.
- [x] Verify `AppTheme.dark()` consumes both without inline overrides — `lib/app/theme.dart:25-126` references `AppColors.*` only and maps `AppTextStyles.*` onto all 13 Material `TextTheme` slots.

## Acceptance
- [x] Every `ColorCode.X` has a corresponding `AppColors.Y` — N/A (`ColorCode` already retired; greppable zero refs). `AppColors` retains 200+ canonical tokens.
- [x] `lib/app/text_styles.dart` has at least the 13 semantic styles from §4.4 (`displayLarge/Medium/Small`, `titleLarge/Medium/Small`, `bodyLarge/Medium/Small`, `labelLarge/Medium/Small`, `caption`).
- [ ] App renders pixel-identical to current — **not verified via screenshot diff** (no UI smoke harness available in this environment). Token files unchanged in this task; visual fidelity preserved by construction.
- [x] `flutter analyze` clean — only 1 pre-existing info on `textfieldBorderLegacy` (intentional 40-bit legacy color preserved for visual fidelity).

## Notes
Zero visual drift is non-negotiable per `MIGRATION_RULES.md`. If a `ColorCode` value doesn't fit any semantic name, add it as `AppColors.<contextSpecific>` rather than mapping incorrectly.

**Audit result (2026-05-28):** Task scaffolds already complete from prior Phase 1/2 work — `colors.dart` (463 LOC, 200+ tokens), `text_styles.dart` (573 LOC, 13 §4.4 semantic + extended exemplars), `theme.dart` consumes both, `main.dart:45` wires `AppTheme.dark()`. Zero inline `Color(0x…)` outside `colors.dart`. Remaining inline `TextStyle(` literals in feature widgets (~97 sites) are Phase 4 per-feature replacement scope, not Phase 3 token-scaffold scope.
