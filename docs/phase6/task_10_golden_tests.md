# Task 6.10 — Golden tests for design tokens

**Phase:** 6 · **Status:** 🟢 Completed (2026-06-03) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Goldens of design-system primitives (buttons, inputs, cards, app bar, bottom nav) in light + dark mode. Catches accidental token drift in later edits.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.1 (golden tests live in `test/golden/`)

## Files in scope (3)
- `test/golden/buttons_test.dart` — **new** — 5 golden tests covering `AppButton` variants (primary / secondary / outline / text / destructive), sizes (sm / md / lg), states (disabled / loading), `fullWidth + icon`, and a light-surface render.
- `test/golden/cards_test.dart` — **new** — 4 golden tests covering `AppCard` variants (flat / outlined / elevated) on dark + light surfaces, and `AppAvatar` initials across all 5 sizes plus single-name / empty / null / multi-word fallback paths.
- `test/golden/inputs_test.dart` — **new** — 4 golden tests covering `AppTextField` empty (label + hint + obscured), filled (initial value + prefix icon + suffix), error + disabled, and light-surface variants.

**`app_bar_test.dart`, `bottom_nav_test.dart`, `colors_swatch_test.dart` — NOT created.** See Notes.

## Steps
- [x] Rendered each component on dark + light surfaces; emitted `*.png` files under `test/golden/goldens/`.
- [x] Committed goldens (13 PNG files, 368 KB total).
- [x] Documented the regeneration command in `CLAUDE.md` (`flutter test --update-goldens test/golden/`).

## Acceptance
- [x] Goldens land in repo (13 PNGs).
- [x] CI fails on any pixel diff — Flutter's `matchesGoldenFile` requires byte-exact match by default.
- [x] Light + dark covered for `AppButton`, `AppCard`, `AppTextField`. `AppAvatar` is theme-agnostic.
- [x] `flutter analyze --fatal-infos` clean.
- [x] Full `flutter test` green (451 events).

## Notes
- **`AppColors` are static, not theme-driven.** Light/dark goldens differ only in the scaffold background colour. Catches contrast regressions but not Material 3 colour-scheme drift (we don't use M3 colour-scheme yet).
- **Skipped `app_bar_test.dart` / `bottom_nav_test.dart`.** No shared `AppBar` / `BottomNav` widget — each screen rolls its own header inline. Goldens there would be screen-level, not token-level — already covered by 6.07–6.09 widget tests.
- **Skipped `colors_swatch_test.dart`.** A coloured-rectangle-per-token golden doesn't catch the failure mode that matters — a token rename would silently change the swatch position without flagging misuse. The variant goldens already catch real drift on consumed components.
- **Regenerate after deliberate design changes** with `flutter test --update-goldens test/golden/`. Pinned in `CLAUDE.md`. Baseline was generated on Flutter `3.38.9` / Dart `3.10.8`. Cross-SDK drift is noise; if CI runs on a different SDK, the baseline will need a one-time regenerate.
- **Excluded screen-level goldens** — they would lock in layouts still being iterated. Phase 6 only owes token-level goldens.
