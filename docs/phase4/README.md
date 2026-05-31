# Phase 4 — Feature Migration

**Overall status:** 🟢 Completed · 23 / 23 tasks done · **Est:** 58 effort-days
**Calibration:** re-baseline Groups B–E after Group A (pilot) ships and yields actuals.

| Field | Value |
|---|---|
| Goal | Migrate every screen to Riverpod + Clean Architecture per feature group, one feature unit per task. Decompose god widgets in their own preceding "a" task before the migration "b" task. |
| Branch | `migration/phase4/<group>-<unit>` per task |
| References | [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Feature Migration Order; [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §3, §14 Per-Feature Checklist |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

---

## Group A — Pilot (3 days)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [4.01](task_01_groupA_splash.md) | Unit 1 — `SplashScreen` migration | 🟢 | 4 | 1d |
| [4.02](task_02_groupA_onboarding.md) | Unit 2 — `OnboardingScreen` migration | 🟢 | 4 | 1d |

## Group B — Low-API tabs (8 days)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [4.03](task_03_groupB_messages.md) | Unit 3 — `MessagesScreen` (placeholder; transport deferred) | 🟢 | 4 | 1.5d |
| [4.04](task_04_groupB_file_manager.md) | Unit 4 — `FileManagerScreen` + 3 sub-screens | 🟢 | 10 | 3.5d |
| [4.05](task_05_groupB_availability.md) | Unit 5 — `ManageAvailability` + `AddAvailability` | 🟢 | 7 | 3d |

## Group C — Profile (18 days)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [4.06](task_06_groupC_settings.md) | Unit 9 — Profile settings (`AppPreferences`, password chain, You're-all-set) | 🟢 | 10 | 2d |
| [4.07](task_07_groupC_delete_account.md) | Unit 10 — Delete account flow (3 screens) | 🟢 | 7 | 2d |
| [4.08](task_08_groupC_featured_work_decompose.md) | Unit 7.a — Decompose `FeaturedWorkList` (1,685 LOC) | 🟢 | 6 | 2d |
| [4.09](task_09_groupC_featured_work_migrate.md) | Unit 7.b — Migrate `FeaturedWorkList` + `Resume` + `Certificates` | 🟢 | 8 | 3d |
| [4.10](task_10_groupC_profile_details.md) | Unit 8 — Profile-details forms (3 screens) | 🟢 | 7 | 4d |
| [4.11](task_11_groupC_myprofile_decompose.md) | Unit 6.a — Decompose `Myprofile` (2,836 LOC) | 🟢 | 6–10 | 2d |
| [4.12](task_12_groupC_myprofile_migrate.md) | Unit 6.b — Migrate `Myprofile` | 🟢 | 8 | 3d |

## Group D — Home + Shoots + Upcoming Details (12 days)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [4.13](task_13_groupD_upcoming_details.md) | Unit 13 — `UpcomingShootViewDetils` + fix 4 hardcoded endpoints | 🟢 | 6 | 3d |
| [4.14](task_14_groupD_shoots.md) | Unit 12 — `ShootsScreen` + 3 supporting screens (debounce search) | 🟢 | 8 | 4d |
| [4.15](task_15_groupD_home_decompose.md) | Unit 11.a — Decompose `HomeScreen` (2,860 LOC) | 🟢 | 6–10 | 2d |
| [4.16](task_16_groupD_home_migrate.md) | Unit 11.b — Migrate `HomeScreen` (coordinate 7 fetchers via `Future.wait`) | 🟢 | 8 | 3d |

## Group E — Auth (14 days)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [4.17](task_17_groupE_login.md) | Unit 14 — `Login` + auth `ViewDetailsScreen` | 🟢 | 5 | 2d |
| [4.18](task_18_groupE_forgot_password.md) | Unit 15 — Forgot Password trio | 🟢 | 6 | 3d |
| [4.19](task_19_groupE_signup1_decompose.md) | Unit 16.a — Decompose `SignUp1` (1,836 LOC) | 🟢 | 6 | 2d |
| [4.20](task_20_groupE_signup1_signup2_migrate.md) | Unit 16.b — Migrate `SignUp1` + `SignUp2` | 🟢 | 8 | 3d |
| [4.21](task_21_groupE_signup3_decompose.md) | Unit 17.a — Decompose `SignUp3` (3,569 LOC, 35-field state) into widget files | 🟢 | 9 | 2d |
| [4.22](task_22_groupE_signup3_migrate.md) | Unit 17.b — Migrate `SignUp3` sub-screens (largest single risk in project) | 🟢 | 7 | 2d |

## Group F — Shell + shared widgets (3 days)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [4.23](task_23_groupF_shell_shared.md) | Unit 18 — Shell rewrite (`StatefulShellRoute.indexedStack`) + move shared widgets + drop `BackdropFilter` | 🟢 | 8 | 3d |

---

## Acceptance (whole phase)

- [ ] Every screen extends `ConsumerWidget` or `ConsumerStatefulWidget`.
- [ ] No screen calls `ApiService()` directly — all go through a Repository.
- [ ] All repositories use `ExceptionHandler.guardAsync()`.
- [ ] All `setState` removed (or reduced to local widget state — animation controllers etc.).
- [ ] All `TextEditingController`s owned by Notifiers, disposed correctly.
- [ ] All navigation via `context.goNamed/pushNamed` — zero `Navigator.push` raw calls.
- [ ] §1.3 shippable check passes on each commit.

## Decomposition discipline

God widgets are split in their own preceding `.a` task with zero behavioral change (just file splits + state lifted to a parent). The `.b` task migrates the split widgets to Notifier. Track both as separate PRs.

## Dependencies

- **In:** Phase 3 fully done.
- **Out:** Phase 5 cleanup gates on this phase finishing.
