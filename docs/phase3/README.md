# Phase 3 — Foundations

**Overall status:** 🟢 Completed · 20 / 20 tasks resolved (18 ✅ done · 2 ⛔ obsolete) · **Est:** 8.75 effort-days
**Closed:** 2026-05-28. Tasks 3.04 and 3.05 marked obsolete on audit — `AppImages` + `ColorCode` were already deleted by Phase 1/2 cleanup, leaving nothing to migrate or shim.

| Field | Value |
|---|---|
| Goal | Stand up every cross-cutting primitive — design tokens, Dio + interceptors, sealed exceptions, SessionStore, ProviderScope, GoRouter auth redirect, Firebase wrappers — so Phase 4 features can migrate against stable infra. |
| Branch | All Phase 3 work delivered on `improvments-phase1` (per project directive); per-task migration branches not used. |
| References | [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 3; [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §3–§7; [`../../MIGRATION_LOG.md`](../../MIGRATION_LOG.md) 2026-05-28 entries |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⛔ Obsolete

---

## Task list

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [3.01](task_01_target_deps.md) | Add target packages to `pubspec.yaml` | 🟢 | 1 | 1h |
| [3.02](task_02_design_tokens_colors_text.md) | Consume `ColorCode` + inline `TextStyle` into `AppColors` + `AppTextStyles` | 🟢 | 5 | 4h |
| [3.03](task_03_design_tokens_spacing_radii.md) | Consume magic numbers into `AppSpacing` + `AppRadii` + `AppShadows` + `AppDurations` | 🟢 | 5 | 4h |
| [3.04](task_04_design_tokens_assets.md) | Consume `AppImages` into `AppAssets` | ⛔ | — | 3h |
| [3.05](task_05_design_tokens_shims.md) | Re-export shims for `ColorCode`/`AppImages` legacy callers | ⛔ | — | 2h |
| [3.06](task_06_api_endpoints_move.md) | Move `ApiEndpoints` to `lib/core/network/` + fix `add_availability` leading-slash | 🟢 | 2 | 2h |
| [3.07](task_07_app_exception.md) | Sealed `AppException` hierarchy + `ExceptionHandler.guardAsync()` | 🟢 | 6 | 4h |
| [3.08](task_08_api_response.md) | `ApiResponse<T>` wrapper | 🟢 | 1 | 1h |
| [3.09](task_09_dio_client.md) | `DioClient` singleton with `BaseOptions` + timeouts | 🟢 | 1 | 3h |
| [3.10](task_10_interceptors.md) | Auth (Queued) + Retry + Error + Logging interceptors | 🟢 | 4 | 5h |
| [3.11](task_11_core_providers.md) | `core_providers.dart` (Dio + prefs + connectivity) | 🟢 | 2 | 2h |
| [3.12](task_12_swap_api_service.md) | Swap `api_service.dart` internals to `DioClient` (keep facade) | 🟢 | 2 | 4h |
| [3.13](task_13_session_store.md) | `SessionStore` interface + `SecureSessionStore` + `PrefsSessionStore` | 🟢 | 4 | 4h |
| [3.14](task_14_session_migration_shim.md) | Token migration prefs → keychain + `SharedService` shim + scoped `logout()` | 🟢 | 3 | 3h |
| [3.15](task_15_app_provider_scope.md) | Resurrect `lib/app/app.dart` with `ProviderScope` + drop `isLoggedIn` plumbing from `MyApp` | 🟢 | 3 | 3h |
| [3.16](task_16_pump_provider_app.md) | Minimal `pumpProviderApp` test helper | 🟢 | 2 | 1h |
| [3.17](task_17_router_redirect.md) | GoRouter auth `redirect:` + `AppAnalyticsObserver` | 🟢 | 5 | 3h |
| [3.18](task_18_analytics_crashlytics.md) | `AnalyticsService` + `AnalyticsEvents` + `CrashlyticsService` + `CrashlyticsKeys` | 🟢 | 5 | 3h |
| [3.19](task_19_firebase_init.md) | `FirebaseService.initialize` stub (no-op if config absent) | 🟢 | 2 | 2h |
| [3.20](task_20_shared_widgets.md) | Shared design-system widgets (`AppButton`/`AppCard`/`AppTextField`/`AppAvatar`/`AppLoading`/`AppEmptyState`) | 🟢 | 12 | 6h |

---

## Acceptance (whole phase)

- [x] `ProviderScope` wraps `MaterialApp.router`. App boots from `lib/app/app.dart`. *(Task 3.15)*
- [x] All API calls flow through `DioClient` (legacy `ApiService` still callable as a thin facade pointing at Dio). *(Task 3.12)*
- [x] Repository-grade error handling exists via `ExceptionHandler.guardAsync()`. *(Task 3.07)*
- [x] `SessionStore` is the single source of truth for token. Prefs cleared scope-aware on logout. *(Tasks 3.13, 3.14)*
- [x] GoRouter has `redirect:` driven by `authStateProvider`. *(Task 3.17)*
- [x] Design tokens (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppDurations`, `AppAssets`) are the single source for styling. *(Tasks 3.02–3.04 — final state already met by prior Phase 1/2 work; audited 2026-05-28.)*
- [x] Shared widgets (`AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState`) exist in `lib/shared/widgets/` and consume only tokens. *(Task 3.20)*
- [x] Firebase wrappers exist (stubs OK if native config not yet generated). *(Tasks 3.18, 3.19)*
- [x] `pumpProviderApp` helper works for the Phase 4 pilot widget tests. *(Task 3.16)*
- [x] §1.3 shippable check passes — `flutter analyze` 301 issues (baseline + 2 expected deprecation infos on `SharedService` call sites); `flutter test` 25/25 passing.

## Dependencies

- **In:** Phase 2 fully done (Linux CI green, secrets out of source, folder skeleton present). ✅
- **Out:** Phase 4 cannot start until Phase 3 fully done. **Now unblocked.**

## Outstanding items deliberately deferred to later phases

- **Manual device smoke** for cold-boot logged-in/out auth gating + Firebase Crashlytics dashboard verification — no device/sim available in this environment.
- **Native config files** (`google-services.json`, `GoogleService-Info.plist`) + native auto-tracking disable flags in `AndroidManifest.xml` / `Info.plist` — separate pre-prod ticket per spec.
- **`runZonedGuarded` wrap** of `startApp` — left to Phase 4 if Crashlytics shows gaps; framework + platform handlers cover dominant cases.
- **Per-feature replacement of inline `TextStyle(...)` / `EdgeInsets` literals** in widget call sites (~97 sites) — explicit Phase 4 scope.
- **Migration of 2 `SharedService.*` call sites** (auth/login + profile/myprofile) — Phase 4 feature migration knocks them out (radar via `deprecated_member_use_from_same_package` info lints).
