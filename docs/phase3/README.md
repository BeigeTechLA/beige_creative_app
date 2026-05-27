# Phase 3 — Foundations

**Overall status:** 🔴 Not Started · 0 / 20 tasks done · **Est:** 8.75 effort-days
**Partial pre-work done 2026-05-27:** `AppTheme.dark()` wired in `MyApp` (covered in Task 3.02); `flutter_secure_storage ^9.2.2` dep already added.

| Field | Value |
|---|---|
| Goal | Stand up every cross-cutting primitive — design tokens, Dio + interceptors, sealed exceptions, SessionStore, ProviderScope, GoRouter auth redirect, Firebase wrappers — so Phase 4 features can migrate against stable infra. |
| Branch | `migration/phase3/<task-slug>` per task |
| References | [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 3; [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §3–§7 |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

---

## Task list

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [3.01](task_01_target_deps.md) | Add target packages to `pubspec.yaml` | 🔴 | 1 | 1h |
| [3.02](task_02_design_tokens_colors_text.md) | Consume `ColorCode` + inline `TextStyle` into `AppColors` + `AppTextStyles` | 🔴 | 5 | 4h |
| [3.03](task_03_design_tokens_spacing_radii.md) | Consume magic numbers into `AppSpacing` + `AppRadii` + `AppShadows` + `AppDurations` | 🔴 | 5 | 4h |
| [3.04](task_04_design_tokens_assets.md) | Consume `AppImages` into `AppAssets` | 🔴 | 5 | 3h |
| [3.05](task_05_design_tokens_shims.md) | Re-export shims for `ColorCode`/`AppImages` legacy callers | 🔴 | 2 | 2h |
| [3.06](task_06_api_endpoints_move.md) | Move `ApiEndpoints` to `lib/core/network/` + fix `add_availability` leading-slash | 🔴 | 3 | 2h |
| [3.07](task_07_app_exception.md) | Sealed `AppException` hierarchy + `ExceptionHandler.guardAsync()` | 🔴 | 6 | 4h |
| [3.08](task_08_api_response.md) | `ApiResponse<T>` wrapper | 🔴 | 1 | 1h |
| [3.09](task_09_dio_client.md) | `DioClient` singleton with `BaseOptions` + timeouts | 🔴 | 1 | 3h |
| [3.10](task_10_interceptors.md) | Auth (Queued) + Retry + Error + Logging interceptors | 🔴 | 4 | 5h |
| [3.11](task_11_core_providers.md) | `core_providers.dart` (Dio + prefs + connectivity) | 🔴 | 1 | 2h |
| [3.12](task_12_swap_api_service.md) | Swap `api_service.dart` internals to `DioClient` (keep facade) | 🔴 | 1 | 4h |
| [3.13](task_13_session_store.md) | `SessionStore` interface + `SecureSessionStore` + `PrefsSessionStore` | 🔴 | 3 | 4h |
| [3.14](task_14_session_migration_shim.md) | Token migration prefs → keychain + `SharedService` shim + scoped `logout()` | 🔴 | 3 | 3h |
| [3.15](task_15_app_provider_scope.md) | Resurrect `lib/app/app.dart` with `ProviderScope` + drop `isLoggedIn` plumbing from `MyApp` | 🔴 | 3 | 3h |
| [3.16](task_16_pump_provider_app.md) | Minimal `pumpProviderApp` test helper | 🔴 | 1 | 1h |
| [3.17](task_17_router_redirect.md) | GoRouter auth `redirect:` + `AppAnalyticsObserver` | 🔴 | 2 | 3h |
| [3.18](task_18_analytics_crashlytics.md) | `AnalyticsService` + `AnalyticsEvents` + `CrashlyticsService` + `CrashlyticsKeys` | 🔴 | 4 | 3h |
| [3.19](task_19_firebase_init.md) | `FirebaseService.initialize` stub (no-op if config absent) | 🔴 | 2 | 2h |
| [3.20](task_20_shared_widgets.md) | Shared design-system widgets (`AppButton`/`AppCard`/`AppTextField`/`AppAvatar`/`AppLoading`/`AppEmptyState`) | 🔴 | 6 | 6h |

---

## Acceptance (whole phase)

- [ ] `ProviderScope` wraps `MaterialApp.router`. App boots from `lib/app/app.dart`.
- [ ] All API calls flow through `DioClient` (legacy `ApiService` still callable as a thin facade pointing at Dio).
- [ ] Repository-grade error handling exists via `ExceptionHandler.guardAsync()`.
- [ ] `SessionStore` is the single source of truth for token. Prefs cleared scope-aware on logout.
- [ ] GoRouter has `redirect:` driven by `authStateProvider`.
- [ ] Design tokens (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`, `AppAssets`) are the single source for styling.
- [ ] Shared widgets (`AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState`) exist in `lib/shared/widgets/` and consume only tokens.
- [ ] Firebase wrappers exist (stubs OK if native config not yet generated).
- [ ] `pumpProviderApp` helper works for the Phase 4 pilot widget tests.
- [ ] §1.3 shippable check passes on each commit.

## Dependencies

- **In:** Phase 2 fully done (Linux CI green, secrets out of source, folder skeleton present).
- **Out:** Phase 4 cannot start until Phase 3 fully done.
