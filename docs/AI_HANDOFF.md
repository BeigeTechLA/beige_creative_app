# AI Handoff Context

Shared context for Claude Code and Codex. This file exists to prevent context
drift when switching tools.

Last updated: 2026-08-12 (CP status guard hardening + non-dismissible Home review modal).

## Read Order

Every AI session should read:

1. `docs/AI_HANDOFF.md`
2. `CLAUDE.md` or `AGENTS.md`, depending on the tool
3. `docs/phase6/README.md`
4. The active task file in `docs/phase6/`
5. Latest relevant `MIGRATION_LOG.md` entries
6. Current source files before editing

## Migration Status

- Phase 1: complete. Audit output lives in `docs/audit/`.
- Phase 2: complete. Folder casing, security hotfixes, env secrets, CI, and target folders are done.
- Phase 3: complete. Foundations are in place.
- Phase 4: **complete**. `23 / 23` tasks done.
- Phase 5: **complete** — `8 / 8` tasks done. Tasks `5.01`–`5.08` closed 2026-05-31.
- Phase 6: in progress — 13 / 15 tasks done. Tasks 6.01 (test helpers) closed 2026-05-31; 6.02–6.12 closed 2026-06-03. 6.13 implementation is in place but the task remains 🟡 pending the first GitHub Actions Android/iOS run and coverage lift: `.github/workflows/ci.yml` now runs `flutter test --coverage`, uploads LCOV, writes a summary, and enforces `COVERAGE_MINIMUM=70`; `.github/workflows/integration.yml` runs Android emulator + iOS simulator integration tests on `push` to `main`. Current refreshed LCOV is `5358 / 11129 = 48.14%`, so the new gate will fail until coverage is raised. 6.11 added the login → home → logout journey; 6.12 added signup1 → signup2 → signup3. Both integration files still pass locally with `flutter test <file> -d macos`; device CI may require the documented binding swap to `IntegrationTestWidgetsFlutterBinding`. Next: `6.14` (models/utils/validators tests) and first remote CI feedback for `6.13`.
- Task 6.15 (Location service + Google Maps consolidation) is 🟢 complete. Native iOS Maps wiring is fixed and aligned with rotated keys. LocationService and LocationException are fully unit tested (all 9 test cases passing) and verified clean.
- Meetings UI Card & Create Meeting Screen redesign: complete as of 2026-06-09, matching Option 1 of the mockup specifications.
- Messages UI sidecar plan (`docs/feature/MESSAGES_UI_PLAN.md`): M1–M5 are complete as of 2026-06-09. M5 added motion polish, a11y labels/touch-target fixes, message goldens, and widget tests. M6 remains pending for real REST + socket.io integration and is outside the completed UI scope.
- Messages post-login logout fix (2026-06-16): `AuthRepositoryImpl` now persists a `UserSnapshot` from `data.crew_member` when `data.user` is absent, matching the documented real login shape. `MessagesRemoteSource` no longer turns a missing local user snapshot into `UnauthorizedException`; it uses an empty `currentUserId` only for DTO ownership/read derivation. Real REST 401s still map through Dio and can trigger the existing logout path.
- Messages socket host correction (2026-06-16): live probes showed `https://api.dev.beige.app/socket.io/?EIO=4&transport=websocket` returns Express 404 `Route not found`, while `https://api2.dev.beige.app/socket.io/?EIO=4&transport=polling` returns an Engine.IO open packet and WebSocket upgrade returns HTTP 101. `Env.socketUrl` dev default is now `https://api2.dev.beige.app`, with `CHAT_SOCKET_URL` dart-define override support; `MessagesSocketSource` sets path `/socket.io` and WebSocket-only transport.
- Messages self-healing logout & inside-bubble headers (2026-06-16): Caught `UnauthorizedException` in messages and chat thread providers to automatically invoke `authStateProvider.notifier.logout()` to resolve retry/reload bugs. Relocated sender headers inside the message and audio bubbles, styling them with bold uppercase name text and title-cased role badge pills.
- CP login/status routing (2026-08-12): login now fails closed unless `is_registration_complete` is `0/1`, `is_crew_verified` is `0/1/2`, and a crew identity is present. Incomplete users enter signup step 1; pending users land on Home behind a non-dismissible `ApplicationUnderReviewCard` dialog and can otherwise access only profile routes; approved users have full access; rejected users land on the revised support/logout screen. Profile refresh preserves or updates the persisted status flags, and offline state does not bypass these guards.

Active Phase 6 entry-point: `docs/phase6/README.md`.

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

Most recent check (post Messages socket reflection fix):

- `flutter analyze --fatal-infos`: 0 issues. CI enforces fatal infos on every PR.
- `flutter test`: 519 / 521 passing (2 pre-existing shoots_repository_impl_test.dart failures persist).
- `flutter test test/features/messages/presentation/screens/messages_screen_test.dart`: 3 / 3 passing.
- `flutter test test/golden/messages_test.dart`: 3 / 3 passing.
- `flutter test integration_test/login_logout_test.dart -d macos`: 1 / 1 passing.
- `flutter test integration_test/signup_flow_test.dart -d macos`: 1 / 1 passing.
- `pubspec.yaml`: 4 deps dropped in 5.02 (`http`, `flutter_stripe`, `image_cropper`, `photo_view`). 9 packages removed from resolution.
- All network image sites now use `CachedNetworkImage` / `CachedNetworkImageProvider` (5.03).
- `lib/` is comment-clean: 0 `/* */` blocks; only 1 scoped `TODO(messaging)` remaining. `lib/service/config.dart` deleted (unused `AppConfig`).
- Lint set locked: `flutter_lints: ^6.0.0` base. `camel_case_types` re-enabled (default). `constant_identifier_names` permanently disabled with documented WHY (asset/API constants mirror server-side snake_case).
- Validation regex consolidated (5.06): `lib/core/utils/validators.dart` owns `kEmailPattern` / `kPlusCodePattern` + `isValidEmail` / `isPlusCode`.
- Model class names normalized (5.07): inner `Data` classes are now feature-prefixed (`DashboardCountData`, `ShootCountData`, `CreatorDashboardData`, `MyProfileData`, `ShootsData`); all model wrappers are PascalCase (`MyProfileModel`, `ShootStatusModel`, `UpcomingShootsModel`, `UpcomingShootDatum`, `UpcomingShootViewModel`); `CancelScreen` → `ShootCancelledScreen`.
- Router split (5.08): `lib/app/router.dart` is now a 165-LOC orchestrator. Feature routes live in `lib/features/<feature>/presentation/routes/<feature>_routes.dart` and are spread into the root route list. Splash + onboarding + the 5-tab `StatefulShellRoute` stay inline (global lifecycle). Deep-link/typed-param wiring deferred.
- Test helpers (6.01): `test/helpers/` now exposes `pumpProviderApp` + `pumpRouterApp`, `MockDioClient` / `MockSessionStore` / fake-session-backends (mocktail), and `test_data.dart` JSON fixture builders (`loginResponse`, `profileResponse`, `dashboardCountResponse`, `shootCountResponse`, `shootsListResponse`, `singleShootJson`, `errorResponse`).
- Repo unit tests (6.02 + 6.03): pattern is to mock `DioClient` and stub `.dio` to return a `MockDio`, then `verify(...).captured` the path/body each repo method sends. Live repos throw `Exception` (not `Either`), so tests assert `throwsA(...)` for envelope-error branches and `throwsA(isA<DioException>())` for 401 / 5xx / cancel. Cancel-path simulates `DioException(type: DioExceptionType.cancel)`; no `CancelToken` is plumbed through the repo layer today. **Exceptions to the throws pattern**, pinned by tests: `AvailabilityRepositoryImpl.fetchMonth` returns `{}` on envelope-error / non-Map payload (does NOT throw), and `AvailabilityRepositoryImpl.createAvailability` is fire-and-forget (never inspects `response.data`). `FileManagerStubRepository` is the live impl for file_manager (no backend yet) — tests pin the hardcoded stub shape.
- Integration tests (6.11 + 6.12): use vm-mode `TestWidgetsFlutterBinding.ensureInitialized()` so they run under `flutter test ... -d macos`. They mount minimal route harnesses instead of the full production router when the journey only needs a small route set. Dio is mocked; UI, Riverpod Notifiers, repositories, and route extras are real. For signup, native picker outcomes are seeded through `SignupNotifier` because `CommonUploader`, `FilePicker`, Google Places, and Google Maps do not expose injection seams; Geolocator channels are stubbed only to keep `SignUp1Screen` mount hermetic.

Do not assume this remains current after further edits; rerun checks after changes.

## Logging And Status Protocol

After each task:

- Update the task checklist/status in the active `docs/phase6/` task file and board.
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
