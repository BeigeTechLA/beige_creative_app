# Task B4 — `feature_area` key + Crashlytics breadcrumbs

**Phase:** B · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `telemetry/b4-breadcrumbs` |

## Goal
`last_route` Crashlytics key tells you which screen crashed but not which subsystem. Add `feature_area` (e.g. `shoots.detail`, `profile.upload.featured_work`) and call `CrashlyticsService.log()` at high-risk action boundaries so crash reports come with a breadcrumb trail.

## References
- `lib/core/firebase/crashlytics_keys.dart:13` — `featureArea` constant (declared, unused)
- `lib/core/firebase/crashlytics_service.dart:83` — `log` (declared, unused)
- `lib/core/firebase/app_analytics_observer.dart:57-61` — `_recordRoute`

## Files in scope (4–6)
- `lib/features/shoots/presentation/providers/shoot_action_notifier.dart` (or wherever accept/decline/cancel live) — set area + log breadcrumb.
- `lib/features/profile/presentation/providers/profile_files_notifier.dart` — same for uploads.
- `lib/features/file_manager/presentation/providers/` — same for file ops.
- Optional: extend `AppAnalyticsObserver._recordRoute` to also set `feature_area` from `RouteSpec` if a `featureArea` field is added there (lower priority — skip if `RouteSpec` changes feel heavy).

## Steps
- [ ] Define a small convention: `feature_area` set on action entry, value `'<feature>.<action>'` snake-cased. Examples:
  - `'shoots.accept'`
  - `'shoots.decline'`
  - `'profile.upload.featured_work'`
  - `'auth.login'`
  - `'auth.signup.step2'`
- [ ] At each notifier action start:
  ```dart
  await CrashlyticsService.setCustomKey(CrashlyticsKeys.featureArea, 'shoots.accept');
  await CrashlyticsService.log('shoot.accept.start id=$shootId');
  ```
  On success / failure: `await CrashlyticsService.log('shoot.accept.success id=$shootId');` (no PII, just ids + status).
- [ ] Limit breadcrumb spam: only log start + terminal (success/failure). Not every intermediate state.

## Acceptance
- [ ] At least 6 feature actions wired (accept/decline/cancel, profile upload x3).
- [ ] Manual: force a crash mid-action; report shows `feature_area` + the start breadcrumb in the log section.
- [ ] `flutter analyze` clean.

## Notes
- Crashlytics breadcrumb log is best-effort; safe to call from anywhere. Don't `await` if it would block UX.
- Avoid logging route paths in breadcrumbs — that's already covered by `last_route` from [[task_a3_zone_guard_debug_gate]]'s observer.
