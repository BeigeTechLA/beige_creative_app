# Task 5.05 — Lint upgrade (`--fatal-infos`)

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/lint-fatal-infos` |

## Goal
Promote `flutter analyze` to `--fatal-infos` in CI. Currently ~190 info-level lints. After this task, no new warnings/infos can land.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.D

## Files in scope
- `.github/workflows/ci.yml` — add `--fatal-infos`
- `analysis_options.yaml` — pin lint set
- Any source files producing infos/warnings

## Steps
- [ ] Baseline count: `flutter analyze 2>&1 | tail -5`
- [ ] Bucket lints by rule; fix the high-frequency ones first (typically `prefer_const_constructors`, `use_super_parameters`, `avoid_print`)
- [ ] Once at 0 infos, add `--fatal-infos` to CI workflow
- [ ] Lock the lint set in `analysis_options.yaml`

## Acceptance
- [ ] `flutter analyze --fatal-infos` exits 0
- [ ] CI fails any PR that introduces a new info/warning
- [ ] `analysis_options.yaml` documents the chosen lint set

## Notes
If a lint is genuinely a false positive, suppress per-file with a comment + reason (`MIGRATION_RULES.md` §10 — non-obvious WHY).
