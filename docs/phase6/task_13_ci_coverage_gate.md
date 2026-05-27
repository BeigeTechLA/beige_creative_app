# Task 6.13 — CI coverage gating + emulator job

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/ci-coverage` |

## Goal
Gate every PR at 70% line coverage. Add a real-emulator job that runs integration tests on Android + iOS for `push` to `main`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 6
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.4

## Files in scope (max 2)
- `.github/workflows/ci.yml` — add coverage step (`flutter test --coverage` + `lcov` parse + threshold)
- `.github/workflows/integration.yml` — new: Android emulator + iOS simulator matrix

## Steps
- [ ] Add `flutter test --coverage` to PR workflow
- [ ] Parse `coverage/lcov.info` (e.g. `actions/lcov-action` or custom shell) — fail if < 70%
- [ ] New workflow for integration tests on `macos-latest` + Android emulator action
- [ ] Set up SDK + emulator caching

## Acceptance
- [ ] PR CI surfaces coverage in summary + fails below 70%
- [ ] Integration workflow green on `push` to `main`
- [ ] Caching keeps emulator job ≤15 minutes

## Notes
Production-readiness gate hits 16/16 after this task. Migration over. Release candidate per flavor can now be built. Update `docs/audit/AUDIT_REPORT.md` to reflect the final state.
