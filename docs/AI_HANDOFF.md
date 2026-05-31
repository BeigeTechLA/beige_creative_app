# AI Handoff Context

Shared context for Claude Code and Codex. This file exists to prevent context
drift when switching tools.

Last updated: 2026-05-31.

## Read Order

Every AI session should read:

1. `docs/AI_HANDOFF.md`
2. `CLAUDE.md` or `AGENTS.md`, depending on the tool
3. `docs/phase4/README.md`
4. The active task file in `docs/phase4/`
5. Latest relevant `MIGRATION_LOG.md` entries
6. Current source files before editing

## Migration Status

- Phase 1: complete. Audit output lives in `docs/audit/`.
- Phase 2: complete. Folder casing, security hotfixes, env secrets, CI, and target folders are done.
- Phase 3: complete. Foundations are in place.
- Phase 4: **complete**. `23 / 23` tasks done.
- Phase 5: not started — first task `5.01` (`ApiService` retirement + `service/` cleanup).
- Phase 6: not started.

No active Phase 4 task. Next phase entry-point is `docs/phase5/` once that board is opened.

## Current Architecture

- App startup: `lib/main_dev.dart` / `lib/main_prod.dart` call `startApp(Environment)` in `lib/main.dart`.
- `startApp` initializes `Env`, Firebase, prefs, `SessionStore`, and mounts `ProviderScope`.
- Root widget: `lib/app/app.dart`.
- Router: `routerProvider` in `lib/app/router.dart`.
- Session: `SessionStore` via `sessionStoreProvider`; `SharedService` is a deprecated shim.
- Network: `DioClient` via `dioClientProvider`, with Auth, Retry, Error, and Logging interceptors.
- Legacy facade: `lib/service/api_service.dart` remains until Phase 5, but new migrated feature code should use repositories and `DioClient`.
- Design tokens: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`, `AppAssets`.
- Feature modules: `lib/features/<feature>/{data,domain,presentation}`.

## Established Phase 4 Coding Pattern

For migrated features:

- Create a domain repository contract under `domain/repositories/`.
- Create a data repository implementation under `data/repositories/`.
- Expose repository and notifier providers under `presentation/providers/`.
- Use immutable state classes with `copyWith`.
- Use `AutoDisposeNotifier`, `AutoDisposeFamilyNotifier`, or `AsyncNotifier`.
- Screens are `ConsumerWidget` or `ConsumerStatefulWidget`.
- Screens use `ref.watch` for state and `ref.read(provider.notifier)` for commands.
- Use `ref.listen` in widgets for user-visible side effects like snackbars, route changes, and sheet dismissal.
- Keep `BuildContext` out of repositories and notifiers.
- Keep controllers in widgets when they are only UI lifecycle state; notifiers own parsed values, status flags, and API state.

Known deviation to be aware of:

- Phase 4 docs say repositories should use `ExceptionHandler.guardAsync()`, but several migrated repositories currently throw and let notifiers catch/log. If changing this, do it deliberately and consistently for the active feature, then log the decision.

## Completed Home Migration (4.15 + 4.16)

Group D is complete. Home now uses:

- `lib/features/home/domain/repositories/home_repository.dart` (contract)
- `lib/features/home/data/repositories/home_repository_impl.dart` (Dio-backed)
- `lib/features/home/presentation/providers/home_state.dart` (combined immutable state)
- `lib/features/home/presentation/providers/home_notifier.dart` (AutoDisposeNotifier, Future.wait, partial-failure resilient)
- `lib/features/home/presentation/screens/home_screen.dart` (ConsumerStatefulWidget)
- 9 decomposed widgets under `presentation/widgets/`

## Verification Baseline

Most recent check (post-4.23, end of Phase 4):

- `flutter analyze`: 82 issues, mostly legacy warnings/infos; no compile errors observed.
- `flutter test`: 145/145 passing.

Do not assume this remains current after further edits; rerun checks after changes.

## Logging And Status Protocol

After each task:

- Update the task checklist/status in `docs/phase4/`.
- Add a `MIGRATION_LOG.md` entry with:
  - task id and title
  - changed files
  - decisions/deviations
  - verification commands and results
  - remaining risk or follow-up
- Update this file when:
  - active task changes
  - the canonical coding pattern changes
  - a discrepancy between Claude and Codex behavior is discovered
  - a deferred item becomes active

