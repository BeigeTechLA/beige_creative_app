# Phase 6 — Testing & CI gating

**Overall status:** 🔴 Not Started · 0 / 14 tasks done · **Est:** 17 effort-days

| Field | Value |
|---|---|
| Goal | 70% overall coverage. Top 3–5 user journeys covered by integration tests. CI gates coverage delta. Production-readiness gate moves toward 16/16. |
| Branch | `migration/phase6/<task-slug>` per task |
| References | [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 6; [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9; [`../guides/FLUTTER_TESTING_GUIDELINES.md`](../guides/FLUTTER_TESTING_GUIDELINES.md) |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

---

## Task list

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [6.01](task_01_test_helpers.md) | Expand `pump_app`, `mocks.dart`, `test_data.dart` | 🔴 | 3 | 1d |
| [6.02](task_02_repo_tests_batch1.md) | Repo unit tests batch 1 (auth, profile, home) | 🔴 | 3 | 1.5d |
| [6.03](task_03_repo_tests_batch2.md) | Repo unit tests batch 2 (shoots, file_manager, availability) | 🔴 | 3 | 1.5d |
| [6.04](task_04_notifier_tests_auth_profile.md) | Notifier tests — auth + profile | 🔴 | 6–8 | 1.5d |
| [6.05](task_05_notifier_tests_home_shoots.md) | Notifier tests — home + shoots | 🔴 | 4–6 | 1.5d |
| [6.06](task_06_notifier_tests_rest.md) | Notifier tests — file_manager + availability + messages | 🔴 | 4–6 | 1d |
| [6.07](task_07_widget_tests_auth.md) | Widget tests — login + signup3 sub-screens + forgot password | 🔴 | 6 | 1.5d |
| [6.08](task_08_widget_tests_home_profile.md) | Widget tests — home + profile + shoots | 🔴 | 5 | 1d |
| [6.09](task_09_widget_tests_file_manager.md) | Widget tests — file_manager + availability | 🔴 | 4 | 0.5d |
| [6.10](task_10_golden_tests.md) | Golden tests for design-token components (light + dark) | 🔴 | 5–8 | 1d |
| [6.11](task_11_integration_login_logout.md) | Integration test — login → home → logout | 🔴 | 2 | 1d |
| [6.12](task_12_integration_signup.md) | Integration test — signup1 → 2 → 3 | 🔴 | 2 | 1d |
| [6.13](task_13_ci_coverage_gate.md) | CI coverage gating (lcov, 70% gate, emulator job) | 🔴 | 2 | 1d |
| [6.14](task_14_models_utils_tests.md) | Unit tests — models + utils + validators + extensions | 🔴 | 4–8 | 1d |

---

## Acceptance (whole phase)

- [ ] Overall line coverage ≥ 70% (lcov-reported).
- [ ] Every repository has a unit test covering happy + 401 + 5xx + cancel.
- [ ] Every Notifier has a unit test covering happy + error.
- [ ] Every freezed DTO has a `fromJson` round-trip + null-optional + missing-required test.
- [ ] Every custom validator + formatter + extension has at least three test cases (happy / edge / error).
- [ ] Critical screens (login, signup3, home, profile, shoots) have widget tests.
- [ ] Top 3 user journeys covered by integration tests.
- [ ] CI runs `flutter test --coverage`, generates lcov, fails if coverage drops below 70%.
- [ ] Real-emulator job runs on push to `main` (Android + iOS).
- [ ] §1.3 shippable check passes on each commit.

## Dependencies

- **In:** Phase 5 complete — no shims remain, lint promoted to fatal.
- **Out:** Production readiness gate reaches 16/16 — release candidate per flavor can be built.
