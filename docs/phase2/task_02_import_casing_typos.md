# Task 2.02 — Fix import casing + typo'd filenames

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 4h

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/import-casing-typos` |

## Goal
Eliminate every remaining case-mismatched import (`Model_Class/` vs `model_class/`) and snake_case the typo'd filenames (`delete_account_lottieScreen.dart` etc.) that Linux CI will reject.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Hard Blockers #1
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §2, §10 (file naming `lowercase_snake_case.dart`)
- [`../audit/AUDIT_STRUCT.md`](../audit/AUDIT_STRUCT.md)

## Files in scope (max 10)
- All files that `import 'Model_Class/...'` or any case-mismatched path
- `lib/profile/deleteaccount/delete_account_lottieScreen.dart` → `delete_account_lottie_screen.dart`
- `lib/profile/profile_new_passwrod_screen.dart` → `profile_new_password_screen.dart` (and class `ProfileNewPasswrodScreen` → `ProfileNewPasswordScreen`)
- `lib/profile/profiledetils/` → `lib/profile/profile_details/` (`profile_detils_1screen.dart` → `profile_details_1_screen.dart`)
- `lib/widgets/Topmessgae.dart` → `top_message.dart` · `new_Textfield.dart` → `new_text_field.dart` · `commonFileViewer.dart`, `commonImagePicker.dart` → snake_case
- `lib/utility/Utils.dart` → `utils.dart`
- `lib/utility/imges_icons.dart` → `images_icons.dart` (typo)

## Steps
- [ ] `git mv` each file to snake_case
- [ ] Rename classes to remove typos (`Passwrod` → `Password`, `Detils` → `Details`)
- [ ] Update every import + every type reference (`grep -rn "Passwrod\|Detils" lib/`)
- [ ] `flutter analyze` → fix
- [ ] Verify routes that point to these screens still resolve

## Acceptance
- [ ] `flutter analyze` zero new errors
- [ ] `find lib -name "*[A-Z]*.dart"` returns nothing (snake_case enforced)
- [ ] No `Passwrod`, `Detils`, `Sekect`, `Sing` substrings anywhere under `lib/`
- [ ] `flutter build apk --flavor dev -t lib/main_dev.dart --debug` succeeds

## Notes
Split into multiple commits if >10 files per commit (per `MIGRATION_RULES.md` §1.1). Suggested split: (a) model_class imports, (b) widget files, (c) profile filenames.
