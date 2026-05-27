# Task 2.05 — Secrets out of source via `--dart-define-from-file`

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 4h · **Priority:** 🔥 Critical

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/secrets` |

## Goal
Move Google Maps and Stripe publishable keys out of source files into `env/<flavor>.json` consumed via `--dart-define-from-file`. Rotate leaked keys at vendor consoles. Same key currently in dev + prod.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #5, §5 Hard Blocker #6
- [`../audit/AUDIT_SEC.md`](../audit/AUDIT_SEC.md)
- [`docs/migration/flavor_bundle_id_plan.md`](../migration/flavor_bundle_id_plan.md) (companion)

## Files in scope (max 10)
- `env/dev.json` — new (gitignored)
- `env/prod.json` — new (gitignored)
- `env/dev.example.json` — committed template
- `env/prod.example.json` — committed template
- `.gitignore` — add `env/dev.json`, `env/prod.json`
- `lib/config/env.dart` — read from `String.fromEnvironment`
- `lib/service/google_config.dart` — read from `Env.googleMapsKey`
- `android/app/src/main/AndroidManifest.xml` — switch hardcoded Maps key to `manifestPlaceholders`
- `android/app/build.gradle.kts` — wire `manifestPlaceholders` from `--dart-define`
- `ios/Runner/AppDelegate.swift` or `Info.plist` — consume from build settings

## Steps
- [ ] Rotate keys at vendor consoles (Maps console; Stripe dashboard) — **out-of-repo**
- [ ] Create `env/*.example.json` with empty strings + comments
- [ ] Create `env/dev.json` + `env/prod.json` locally; add to `.gitignore`
- [ ] Update `Env.init()` in `lib/config/env.dart` to use `const String.fromEnvironment('GOOGLE_MAPS_KEY')` etc.
- [ ] Wire Android `manifestPlaceholders` in `build.gradle.kts`
- [ ] Update CLAUDE.md Commands section: `flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart`
- [ ] `git log -p` confirms old keys never re-introduced; old key history scrubbed if release-relevant

## Acceptance
- [ ] `grep -rn "AIza\|pk_test\|pk_live" lib/ android/ ios/` returns nothing
- [ ] `env/dev.json` and `env/prod.json` ignored by git
- [ ] `flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart` boots and Maps screen renders
- [ ] Stripe test charge still completes (or stays at placeholder if prod key not funded)

## Notes
History scrub is out of scope. If the leaked Maps key was production-billable, treat the rotation as a security incident response rather than a code change. `flutter_dotenv` removal handled in [Task 2.06](task_06_drop_flutter_dotenv.md).
