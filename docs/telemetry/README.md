# Telemetry — Firebase Crashlytics & Analytics

**Overall status:** 🟡 In Progress · 4 / 12 tasks done · **Est:** 6.5 effort-days

| Field | Value |
|---|---|
| Goal | Move from "wrappers exist" to "wrappers fully exercised." User identity propagated, non-fatal errors funneled to Crashlytics, `AnalyticsEvents` registry actually emitted, consent + release-symbol pipeline closed. |
| Branch | `telemetry/<task-slug>` per task |
| References | `lib/core/firebase/`, `lib/main.dart`, `lib/core/network/exceptions/exception_handler.dart`, `docs/AI_HANDOFF.md` |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

---

## Current state (2026-06-02 audit)

What works:
- `FirebaseService.initialize` runs in `startApp` before any Firebase-touching code, tolerant of missing native config.
- `CrashlyticsService` registers `FlutterError.onError` + `PlatformDispatcher.onError` as fatal sinks.
- `AppAnalyticsObserver` emits `screen_view` via `FirebaseAnalyticsObserver` delegate; honors `RouteSpec.trackScreenView` opt-outs.
- `AppShell._goBranch` emits `logScreenView` for `StatefulShellRoute` branch switches (which don't push root nav).
- `flavor` + `last_route` Crashlytics custom keys set.

What's dead or missing:
- `AnalyticsEvents` registry has zero callsites. All event names declared, none emitted.
- `setUserId`, `setUserIdentifier`, `logLogin` defined and never called.
- `CrashlyticsKeys.userId`, `userRole`, `featureArea` constants exist, never set.
- `ExceptionHandler.guardAsync` swallows + maps exceptions but never forwards to `CrashlyticsService.recordError`. Non-fatal pipeline is silent.
- `runApp` not wrapped in `runZonedGuarded`. Async errors outside `PlatformDispatcher` slip through.
- No explicit `setCrashlyticsCollectionEnabled` / `setAnalyticsCollectionEnabled` debug gate.
- No consent / iOS ATT gating.
- Release symbol upload (iOS dSYM + Android mapping) not verified post-flavor wiring.

---

## Phase breakdown

### Phase A — Foundation (identity + error sink)
Cannot ship telemetry without these. ~2 days.

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [A1](task_a1_user_identity.md) | Wire `setUserId` + `setUserIdentifier` + role key on login/logout | 🟢 | 3 | 0.5d |
| [A2](task_a2_error_funnel.md) | Forward non-fatal errors from `ExceptionHandler` to Crashlytics | 🟢 | 2 | 0.5d |
| [A3](task_a3_zone_guard_debug_gate.md) | `runZonedGuarded` wrap + `setCrashlyticsCollectionEnabled(!kDebugMode)` | 🟢 | 2 | 0.5d |

### Phase B — Event wiring (use the registry)
Convert `AnalyticsEvents` from dead constants into live funnel. ~2.5 days.

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [B1](task_b1_event_emission_auth.md) | Emit auth events (`login_success/failure`, `logout`, signup steps, password reset, account deletion) | 🔴 | 4–6 | 0.75d |
| [B2](task_b2_event_emission_features.md) | Emit shoots / profile / availability events from feature notifiers | 🔴 | 6–8 | 1d |
| [B3](task_b3_typed_event_helpers.md) | Typed event helpers — enforce param shape, kill duplicates | 🟢 | 1 | 0.25d |
| [B4](task_b4_breadcrumbs.md) | `feature_area` Crashlytics key + `CrashlyticsService.log` breadcrumbs at high-risk actions | 🔴 | 4–6 | 0.5d |
| [B5](task_b5_logger_bridge.md) | Bridge `AppLogger.e` → `CrashlyticsService.recordError` (non-fatal) | 🔴 | 1 | 0.25d |

### Phase C — Compliance & release pipeline
Gates required before store submission. ~1.5 days.

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [C1](task_c1_consent_ios_att.md) | iOS ATT prompt + consent-gated analytics/crashlytics toggle | 🔴 | 4 | 1d |
| [C2](task_c2_release_symbol_upload.md) | iOS dSYM upload phase + Android R8 mapping auto-upload, per-flavor | 🔴 | 2 | 0.5d |

### Phase D — Optional polish
Defer until A+B+C closed. ~0.5d.

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [D1](task_d1_perf_optional.md) | Add `firebase_performance` for HTTP traces (bundle-cost review first) | 🔴 | 2 | 0.5d |

---

## Event parameter contracts (B3)

Typed helpers live on `TelemetryClient` via `extension TelemetryEventHelpers`
in `lib/core/firebase/analytics_events.dart`. Always use the helpers — do
not call `logEvent` with raw names + maps from feature code.

| Helper | Wire name | Parameters |
|---|---|---|
| `loginSuccess()` | `login_success` | _none_ |
| `loginFailure(LoginFailureReason)` | `login_failure` | `{'reason': 'invalid_credentials' \| 'network' \| 'server'}` |
| `signupStarted()` | `signup_started` | _none_ |
| `signupCompleted(...)` | `signup_completed` | `{'has_resume': bool, 'has_featured_work': bool, 'social_count': int}` |
| `passwordResetRequested()` | `password_reset_requested` | _none_ |
| `logout()` | `logout` | _none_ |
| `accountDeletionRequested()` | `account_deletion_requested` | _none_ |
| `shootAccepted(String)` | `shoot_accepted` | `{'shoot_id': String}` |
| `shootDeclined(String)` | `shoot_declined` | `{'shoot_id': String}` |
| `shootCancelled(String)` | `shoot_cancelled` | `{'shoot_id': String}` |
| `profilePhotoUploaded(ProfilePhotoSource)` | `profile_photo_uploaded` | `{'source': 'camera' \| 'gallery'}` |
| `featuredWorkUploaded({fileCount})` | `featured_work_uploaded` | `{'file_count': int}` (singleton = 1) |
| `resumeUploaded({fileCount})` | `resume_uploaded` | `{'file_count': int}` (singleton = 1) |
| `certificationsUploaded({fileCount})` | `certifications_uploaded` | `{'file_count': int}` (singleton = 1) |
| `availabilityAdded({durationDays})` | `availability_added` | `{'duration_days': int}` |

`login` (Firebase-builtin) is emitted by `TelemetryClient.setUserIdentity`
during A1's identity-wiring path — do not emit it from feature code.

---

## Acceptance for the whole plan

- `flutter analyze --fatal-infos` clean.
- `flutter test` green; helper tests cover identity wiring + error forwarding stubs.
- Manual smoke on dev flavor: logged-in user appears in Crashlytics user lookup; thrown `ServerException` shows up as non-fatal with `last_route` + `feature_area` + `user_role` keys.
- Manual smoke on dev flavor: at least one event per registry entry visible in Firebase DebugView.
- Release build of `prod` flavor uploads iOS dSYMs and Android mapping.txt; verified by deliberately-symbolicated crash.
