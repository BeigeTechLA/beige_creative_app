# Task 6.13 — CI coverage gating + emulator job

**Phase:** 6 · **Status:** 🟡 In Progress · **Est:** 1d

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
- [x] Add `flutter test --coverage` to PR workflow
- [x] Parse `coverage/lcov.info` (custom shell) — fail if < 70%
- [x] New workflow for integration tests on `macos-latest` + Android emulator action
- [x] Set up SDK + emulator caching

## Acceptance
- [x] PR CI surfaces coverage in summary + fails below 70% (configured; local LCOV is `5358 / 11129 = 48.14%`, so the new gate fails as intended until coverage is raised)
- [ ] Integration workflow green on `push` to `main` (workflow added; needs the first GitHub Actions run on Android/iOS devices)
- [ ] Caching keeps emulator job ≤15 minutes (Flutter, Gradle, AVD, and CocoaPods caches configured; timing needs the first GitHub Actions run)

## Notes
- `.github/workflows/ci.yml` now runs `flutter test --coverage`, writes a coverage table to `$GITHUB_STEP_SUMMARY`, uploads `coverage/lcov.info`, and enforces `COVERAGE_MINIMUM=70`.
- `.github/workflows/integration.yml` now runs on `push` to `main` and `workflow_dispatch` with an Android/iOS matrix on `macos-latest`. The Android side uses `reactivecircus/android-emulator-runner@v2`; the iOS side creates and boots an available iPhone simulator. Both run the current integration files with `--flavor dev --dart-define-from-file=env/dev.example.json`.
- Current coverage is below the new gate: `48.14%`. Task 6.14 remains the active coverage-lift blocker before release readiness can be claimed.
- The existing integration tests still use vm-mode `TestWidgetsFlutterBinding`; if the first Android/iOS workflow run rejects that binding, promote them to `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` as already documented in the test files.
- The original production-readiness note is stale while 6.14 remains open and the LCOV gate is below 70%.
