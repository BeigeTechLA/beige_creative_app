# AI Handoff Context

Shared context for Claude Code and Codex. This file exists to prevent context
drift when switching tools.

Last updated: 2026-05-31 (post-6.01).

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
- Phase 5: **complete** — `8 / 8` tasks done. Tasks `5.01`–`5.08` closed 2026-05-31.
- Phase 6: in progress — `1 / 14` tasks done. Task `6.01` (test helpers) closed 2026-05-31. Next: `6.02` (repo unit tests batch 1: auth, profile, home).
- Phase 6: not started.

Active Phase 5 entry-point: `docs/phase5/README.md`.

## Current Architecture

- App startup: `lib/main_dev.dart` / `lib/main_prod.dart` call `startApp(Environment)` in `lib/main.dart`.
- `startApp` initializes `Env`, Firebase, prefs, `SessionStore`, and mounts `ProviderScope`.
- Root widget: `lib/app/app.dart`.
- Router: `routerProvider` in `lib/app/router.dart`.
- Session: `SessionStore` via `sessionStoreProvider`. `SharedService` shim deleted in 5.01.
- Network: `DioClient` via `dioClientProvider`, with Auth, Retry, Error, and Logging interceptors.
- Legacy `ApiService` facade deleted in 5.01. All call sites now use `Env.imageUrl` for image URL construction and `_client.dio` directly for multipart uploads.
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

Most recent check (post-6.01):

- `flutter analyze --fatal-infos`: 0 issues. CI now enforces this on every PR.
- `flutter test`: 151/151 passing (6.01 added 6 helper smoke tests).
- `pubspec.yaml`: 4 deps dropped in 5.02 (`http`, `flutter_stripe`, `image_cropper`, `photo_view`). 9 packages removed from resolution.
- All network image sites now use `CachedNetworkImage` / `CachedNetworkImageProvider` (5.03).
- `lib/` is comment-clean: 0 `/* */` blocks; only 1 scoped `TODO(messaging)` remaining. `lib/service/config.dart` deleted (unused `AppConfig`).
- Lint set locked: `flutter_lints: ^6.0.0` base. `camel_case_types` re-enabled (default). `constant_identifier_names` permanently disabled with documented WHY (asset/API constants mirror server-side snake_case).
- Validation regex consolidated (5.06): `lib/core/utils/validators.dart` owns `kEmailPattern` / `kPlusCodePattern` + `isValidEmail` / `isPlusCode`.
- Model class names normalized (5.07): inner `Data` classes are now feature-prefixed (`DashboardCountData`, `ShootCountData`, `CreatorDashboardData`, `MyProfileData`, `ShootsData`); all model wrappers are PascalCase (`MyProfileModel`, `ShootStatusModel`, `UpcomingShootsModel`, `UpcomingShootDatum`, `UpcomingShootViewModel`); `CancelScreen` → `ShootCancelledScreen`.
- Router split (5.08): `lib/app/router.dart` is now a 165-LOC orchestrator. Feature routes live in `lib/features/<feature>/presentation/routes/<feature>_routes.dart` and are spread into the root route list. Splash + onboarding + the 5-tab `StatefulShellRoute` stay inline (global lifecycle). Deep-link/typed-param wiring deferred.
- Test helpers (6.01): `test/helpers/` now exposes `pumpProviderApp` + `pumpRouterApp`, `MockDioClient` / `MockSessionStore` / fake-session-backends (mocktail), and `test_data.dart` JSON fixture builders (`loginResponse`, `profileResponse`, `dashboardCountResponse`, `shootCountResponse`, `shootsListResponse`, `singleShootJson`, `errorResponse`).

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

