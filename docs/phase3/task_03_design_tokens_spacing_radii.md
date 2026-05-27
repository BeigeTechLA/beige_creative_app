# Task 3.03 — Design tokens: spacing + radii + shadows + durations

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 4h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/tokens-spacing` |

## Goal
Fill `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations` scaffolds with values extracted from current `EdgeInsets.all/symmetric/only`, `BorderRadius.circular`, `BoxShadow`, and animation `Duration` literals.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations rows 3–6
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §4 Design Token Migration; §4.3 Token Rules

## Files in scope (max 5)
- `lib/app/spacing.dart` — 4-px base grid; common screen-padding constants
- `lib/app/radii.dart` — `xs..full` plus `BorderRadius` getters
- `lib/app/shadows.dart` — `sm/md/lg/xl` elevation
- `lib/app/durations.dart` — `fast/normal/slow/pageTransition`

## Steps
- [ ] `grep -rn "EdgeInsets\|BorderRadius\|BoxShadow" lib/` — bucket values
- [ ] Pin most-frequent values as named constants; keep non-grid values that match current UI (4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32...)
- [ ] Avoid renaming any value if it would force a visual change
- [ ] Update `AppTheme.dark()` to use the new tokens for component themes

## Acceptance
- [ ] All four token files compile + are referenced from `AppTheme.dark()`
- [ ] Screenshot diff against `main` — zero visual drift
- [ ] `flutter analyze` clean

## Notes
Use semantic names — no `space14` / `radius8`. Per `MIGRATION_RULES.md` §4.3 the size-suffix style is banned.
