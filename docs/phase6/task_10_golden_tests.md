# Task 6.10 — Golden tests for design tokens

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/golden-tokens` |

## Goal
Goldens of design-system primitives (buttons, inputs, cards, app bar, bottom nav) in light + dark mode. Catches accidental token drift in later edits.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.1 (golden tests live in `test/golden/`)

## Files in scope (max 8)
- `test/golden/buttons_test.dart`
- `test/golden/inputs_test.dart`
- `test/golden/cards_test.dart`
- `test/golden/app_bar_test.dart`
- `test/golden/bottom_nav_test.dart`
- `test/golden/colors_swatch_test.dart`

## Steps
- [ ] Render each component in light + dark; emit `*.png` under `test/golden/`
- [ ] Commit goldens (verify file size budget)
- [ ] Document the regeneration command in `CLAUDE.md` (`flutter test --update-goldens`)

## Acceptance
- [ ] Goldens land in repo
- [ ] CI fails if a token change drifts a golden by >0.1% pixel diff
- [ ] Light + dark covered

## Notes
Run on a fixed Flutter SDK version — golden diffs across SDK versions are noise. Pin in `analysis_options.yaml` or `.fvmrc`.
