# Task 2.06 — Drop `flutter_dotenv`

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 1h

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/drop-dotenv` |

## Goal
Remove `flutter_dotenv ^5.0.2` — it's declared in `pubspec.yaml` but has zero imports. Dead weight after Task 2.05 wires `--dart-define-from-file`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Package Conflicts (`flutter_dotenv` row)
- [`../audit/AUDIT_DEPS.md`](../audit/AUDIT_DEPS.md)

## Files in scope (max 10)
- `pubspec.yaml`
- `pubspec.lock` (auto-regenerates)

## Steps
- [ ] Confirm `grep -rn "flutter_dotenv\|DotEnv" lib/` returns nothing
- [ ] Remove the dependency line from `pubspec.yaml`
- [ ] `flutter pub get`
- [ ] `flutter analyze` clean
- [ ] Smoke run

## Acceptance
- [ ] `flutter_dotenv` absent from `pubspec.yaml`
- [ ] App builds + boots both flavors
- [ ] No reference to `.env` files in CLAUDE.md (update if found)

## Notes
Block until [Task 2.05](task_05_secrets_dart_define.md) lands — otherwise removing the dep before alternate plumbing exists would block builds.
