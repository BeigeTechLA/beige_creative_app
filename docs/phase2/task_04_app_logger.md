# Task 2.04 — Introduce AppLogger

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 2h

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/app-logger` |

## Goal
Land a single `AppLogger` wrapper that is a no-op in release. All future `debugPrint` migrates to it. Prevents future token-style leaks and standardizes log output.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 20
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §10 (never `print()`)
- [`../audit/AUDIT_QUALITY.md`](../audit/AUDIT_QUALITY.md) — 283 print/debugPrint sites currently

## Files in scope (max 10)
- `lib/core/utils/app_logger.dart` — new
- Optional: convert 3-5 highest-noise sites as exemplar (do **not** do all 283 — that's Phase 5 cleanup)

## Steps
- [ ] Create `lib/core/utils/` (if Task 2.09 already ran) or place under `lib/utility/` temporarily
- [ ] Write `AppLogger` with `d/i/w/e` methods; release no-op via `kReleaseMode` guard
- [ ] Migrate 3-5 highest-noise call sites as demonstration
- [ ] Document usage in CLAUDE.md "Conventions" section

## Acceptance
- [ ] `lib/core/utils/app_logger.dart` exists with `kReleaseMode` guard
- [ ] `flutter analyze` clean
- [ ] Release APK contains no `print` of sensitive data (manual check via `strings` on the `.apk`)
- [ ] Logger is referenced from at least 3 files as proof-of-life

## Notes
Full 283-site migration is Phase 5.04. This task only lands the primitive + a couple of exemplar uses.
