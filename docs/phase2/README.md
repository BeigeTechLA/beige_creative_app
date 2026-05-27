# Phase 2 — Folder Scaffold + Unblock

**Overall status:** 🔴 Not Started · 0 / 9 tasks done · **Est:** 4.5 effort-days

| Field | Value |
|---|---|
| Goal | Codebase compiles on case-sensitive FS · zero plaintext credentials · CI green on every PR · target folder skeleton exists. No feature migration in this phase. |
| Branch | `migration/phase2/<task-slug>` per task |
| References | [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Blockers, §7 Phase 2; [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §1.3 Shippable Rule |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

---

## Task list (sprint board)

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [2.01](task_01_folder_renames.md) | Finish folder renames (3 dirs + literal-space file) | 🔴 Not Started | ~10 | 4h |
| [2.02](task_02_import_casing_typos.md) | Fix `Model_Class` import casing + typo'd filenames | 🔴 Not Started | ~10 | 4h |
| [2.03](task_03_security_hotfixes.md) | Strip plaintext password persist + token prints + manifest hardening | 🔴 Not Started | 5 | 3h |
| [2.04](task_04_app_logger.md) | Introduce `AppLogger` (release no-op) | 🔴 Not Started | 1 + replacements | 2h |
| [2.05](task_05_secrets_dart_define.md) | Move Maps + Stripe keys to `--dart-define-from-file` | 🔴 Not Started | 6 | 4h |
| [2.06](task_06_drop_flutter_dotenv.md) | Drop `flutter_dotenv` dependency (0 imports) | 🔴 Not Started | 2 | 1h |
| [2.07](task_07_nav_immediate_fixes.md) | Collapse duplicate `CancelScreen`, restore `changePassword` route, add `IndexedStack` | 🔴 Not Started | 4 | 3h |
| [2.08](task_08_ci_gate.md) | Compile `test/widget_test.dart` + GitHub Actions workflow | 🔴 Not Started | 2 | 3h |
| [2.09](task_09_folder_skeleton.md) | Create `lib/core/`, `lib/features/`, `lib/shared/`, `lib/dummy/` skeleton | 🔴 Not Started | dirs only | 1h |

---

## Acceptance (whole phase)

- [ ] All folders + files under `lib/` are `lowercase_snake_case`. No imports rely on case-insensitive matching.
- [ ] No plaintext password anywhere in `SharedPreferences`.
- [ ] No `Bearer` token logged from `api_service.dart` or `myprofile.dart` (or anywhere else).
- [ ] Google Maps + Stripe keys live in `env/<flavor>.json` consumed via `--dart-define-from-file`. Old keys rotated at vendor consoles.
- [ ] GitHub Actions CI runs `flutter analyze --fatal-infos` + `flutter test` + `flutter build apk --debug` per PR on `ubuntu-latest`. Green.
- [ ] `test/widget_test.dart` compiles (smoke only — full plan in Phase 6).
- [ ] `lib/core/`, `lib/features/`, `lib/shared/`, `lib/dummy/` exist (empty or with `.gitkeep`).
- [ ] §1.3 shippable check passes on each commit.

## Dependencies

- **In:** Phase 1 ✅
- **Out:** Phase 3 (foundations) cannot start until Phase 2 fully done.
