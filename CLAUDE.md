# CLAUDE.md

This file is the Claude Code entrypoint for this repo. Keep it short and
delegate current migration context to the shared handoff file used by all AI
tools.

## Mandatory Startup

Before planning or editing, read these in order:

1. `docs/AI_HANDOFF.md` — current shared context for Claude Code + Codex.
2. `docs/phase6/README.md` — active sprint board.
3. The current task file under `docs/phase6/`.
4. The latest relevant entries in `MIGRATION_LOG.md`.
5. The files you are about to edit.

Treat `docs/audit/` and older sections of `MIGRATION_PLAN.md` as historical
unless the active task file points to them. Current code and phase task files
win over stale audit text.

## Current Project State

Flutter app `beige_creative_app` (BEIGE), crew-side mobile client.

Current migration state:

- Phase 1 complete.
- Phase 2 complete.
- Phase 3 complete.
- Phase 4 complete; `23 / 23` tasks done.
- Phase 5 complete; `8 / 8` tasks done.
- Phase 6 in progress; `12 / 14` tasks done. Task `6.01` (test helpers) closed 2026-05-31; `6.02`–`6.12` closed 2026-06-03 (all 6 repos + every Notifier + widget tests for every entry-point screen + golden baselines for the 4 shared design-token components + login/logout and signup integration tests). Next: `6.13` (CI coverage gate).

Riverpod is wired. Do not follow older notes that say ProviderScope/Riverpod is
unused. `startApp` mounts `ProviderScope`, overrides shared dependencies, and
boots `App`.

## Commands

A Makefile at the repository root handles common run, build, clean, and verification tasks:
- `make run-dev` / `make run-prod` — Run app on device/simulator
- `make build-dev` / `make build-prod` — Full release build (iOS IPA + Android APK + AAB)
- `make build-dev-ios` / `make build-prod-ios` — iOS IPA only
- `make build-dev-android` / `make build-prod-android` — Android APK only
- `make build-dev-aab` / `make build-prod-aab` — Android AAB only
- `make pub` — Run flutter pub get
- `make clean` — Clean builds
- `make analyze` — Run flutter analyze
- `make test` — Run unit/widget tests

Or run manual commands:

```bash
flutter pub get
flutter analyze
flutter test

# Integration tests live under integration_test/ and are not part of the
# default flutter test run.
flutter test integration_test/login_logout_test.dart -d macos
flutter test integration_test/signup_flow_test.dart -d macos

# Regenerate golden PNGs after deliberate design-token changes (6.10).
# Goldens live in test/golden/goldens/. Re-run on the same Flutter SDK
# version that produced them — cross-SDK pixel diffs are noise.
flutter test --update-goldens test/golden/

flutter run --flavor dev  --dart-define-from-file=env/dev.json  -t lib/main_dev.dart
flutter run --flavor prod --dart-define-from-file=env/prod.json -t lib/main_prod.dart

flutter build apk       --flavor dev  --dart-define-from-file=env/dev.json  -t lib/main_dev.dart  --release
flutter build appbundle --flavor dev  --dart-define-from-file=env/dev.json  -t lib/main_dev.dart  --release
flutter build ipa       --flavor dev  --dart-define-from-file=env/dev.json  -t lib/main_dev.dart  --release

flutter build apk       --flavor prod --dart-define-from-file=env/prod.json -t lib/main_prod.dart --release
flutter build appbundle --flavor prod --dart-define-from-file=env/prod.json -t lib/main_prod.dart --release
flutter build ipa       --flavor prod --dart-define-from-file=env/prod.json -t lib/main_prod.dart --release
```

## Architecture Rules

- App startup: `lib/main_dev.dart` / `lib/main_prod.dart` call `startApp(Environment)`.
- `startApp` initializes `Env`, Firebase, prefs, `SessionStore`, then mounts `ProviderScope`.
- App root: `lib/app/app.dart`.
- Router: `routerProvider` in `lib/app/router.dart`.
- Routing: use named GoRouter routes via `context.goNamed` / `context.pushNamed`.
- Route arguments: use `state.extra` as `Map<String, dynamic>` unless a task explicitly changes this.
- Network: all feature work goes through repositories and `dioClientProvider`. Image URLs use `Env.imageUrl`. Multipart uploads use `_client.dio.post(url, data: FormData...)`.
- Session: use `SessionStore` via `sessionStoreProvider`. Legacy `ApiService` + `SharedService` shims deleted in 5.01 — do not reintroduce.
- Design tokens: use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`, `AppAssets`.
- Feature code lives under `lib/features/<feature>/{data,domain,presentation}`.
- Shared reusable UI lives under `lib/shared/widgets/`; legacy `lib/widgets/` is cleaned up in Phase 4.23.

## Phase 4 Pattern

Follow the established migration pattern:

- Domain repository contract under `domain/repositories/`.
- Data implementation under `data/repositories/`.
- Provider file under `presentation/providers/`.
- Immutable state class with `copyWith`.
- `AutoDisposeNotifier`, `AutoDisposeFamilyNotifier`, or `AsyncNotifier` depending on lifecycle.
- Screen uses `ConsumerWidget` or `ConsumerStatefulWidget`.
- `ref.watch` for state, `ref.read(...notifier)` for commands.
- UI side effects (`SnackBar`, route changes, sheet pop) happen in widgets via `ref.listen`, not inside repositories.
- Controllers may stay in `ConsumerStatefulWidget` when they are purely widget lifecycle state; notifier owns parsed values and business state.

## Workflow Rules

- Read the active task file before touching code.
- Preserve existing user/tool changes; never reset or revert unrelated work.
- Keep changes scoped to the phase task.
- Update the phase task file and `MIGRATION_LOG.md` when a task status, decision, deviation, or verification changes.
- Update `docs/AI_HANDOFF.md` when the active task changes or when a new cross-tool convention is established.
- New Markdown docs belong under `docs/`, except repo-root convention files: `README.md`, `CLAUDE.md`, `AGENTS.md`, `MIGRATION_PLAN.md`, `MIGRATION_RULES.md`, `MIGRATION_LOG.md`.
- Prefer `rg` / `rg --files` for search.
- Run `flutter analyze` and focused tests for the changed area; run full `flutter test` when feasible.
