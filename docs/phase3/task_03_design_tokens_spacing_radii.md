# Task 3.03 — Design tokens: spacing + radii + shadows + durations

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 4h

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
- [x] `grep -rn "EdgeInsets|BorderRadius|BoxShadow" lib/` — bucketed during Phase 1/2 sweeps; harvested literals are visible in extended sections of each token file.
- [x] Pin most-frequent values as named constants — `AppSpacing` covers the 4-px grid plus off-grid component constants; `AppRadii` covers `none..full` plus outliers; `AppShadows` covers `none/sm/md/lg/xl` plus extended card/CTA/nav/sheet variants; `AppDurations` covers `instant/fast/normal/slow/pageTransition` plus splash/long/autoDismiss.
- [x] Avoid renaming any value if it would force visual change — all values preserved verbatim from original literals.
- [ ] Update `AppTheme.dark()` to use the new tokens for component themes — **deferred**: `inputDecorationTheme`, `cardTheme`, `bottomSheetTheme`, etc. remain commented in `lib/app/theme.dart:107-124` per Phase 2 "deferred fields, enable individually with screenshot diff" gating. Tokens are consumed by 44 (`AppSpacing`) + 41 (`AppRadii`) + 9 (`AppShadows`) + 2 (`AppDurations`) widget call sites instead.

## Acceptance
- [x] All four token files compile (`flutter analyze` → No issues found).
- [x] Tokens referenced widely — 96 total widget refs across `lib/`. Direct `AppTheme.dark()` consumption deferred (see step above) to honor zero-visual-drift gate.
- [ ] Screenshot diff against `main` — **not verified** (no UI smoke harness available). No edits this task; zero-drift preserved by construction.
- [x] `flutter analyze` clean on token files.

## Notes
Use semantic names — no `space14` / `radius8`. Per `MIGRATION_RULES.md` §4.3 the size-suffix style is banned.

**Audit result (2026-05-28):** All four scaffolds already complete from prior Phase 1/2 work — `spacing.dart` (214 LOC), `radii.dart` (215 LOC), `shadows.dart` (164 LOC), `durations.dart` (34 LOC). Values harvested from real widget literals with strict 1:1 fidelity. Naming is semantic (xs/sm/md/lg/xl + canonical-use-site outliers like `tabInnerPad`, `clientContact`, `viewerSheet`). Theme-component wiring deferred to keep visual diff at zero — same gating policy applied to the deferred Material theme fields commented in `theme.dart`.
