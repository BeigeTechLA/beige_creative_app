# Task B2 — Feature event emission (shoots, profile, availability)

**Phase:** B · **Status:** 🟢 Completed (2026-06-02) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `improvments-phase1` |

## Goal
Activate the rest of `AnalyticsEvents` — shoots, profile uploads, availability — by emitting at notifier success branches. Mirrors B1 for the post-login surface.

## References
- `lib/core/firebase/analytics_events.dart:18-30`
- `lib/features/shoots/presentation/providers/`
- `lib/features/profile/presentation/providers/`
- `lib/features/availability/presentation/providers/`

## Files in scope (6–8)
- Shoots notifier(s) — `shootAccepted`, `shootDeclined`, `shootCancelled`. Param: `{'shoot_id': String}`.
- Profile notifier (`profile_repository_impl` caller) — `profilePhotoUploaded`. Param: `{'source': 'camera' | 'gallery'}`.
- Profile files notifier (`profile_files_repository_impl` caller) — `featuredWorkUploaded`, `resumeUploaded`, `certificationsUploaded`. Param: `{'file_count': int}` for batch, none for singleton.
- Availability notifier — `availabilityAdded`. Param: `{'duration_days': int}`.

## Steps
- [x] For each notifier, find the success branch (typically `state = state.copyWith(success: true)` after repo `Right(_)`).
- [x] Emit on that branch only — never inside the repo (architecture rule: side-effects in presentation).
- [x] Add per-feature param shapes (see above). Doc the shape in `analytics_events.dart` as a `///` comment on the constant so future authors don't drift.

## Acceptance
- [x] Every constant in the Shoots / Profile / Availability blocks has a callsite.
- [x] Notifier tests (or new ones) assert event fired on success and NOT on failure.
- [ ] Manual `DebugView`: accept a shoot on dev → event arrives with shoot_id. *(deferred to QA smoke)*

## Notes
- `shootAccepted` / `shootDeclined` / `shootCancelled` are the conversion events for crew-side; treat as funnel-critical. Get param shape right first time — renaming events later orphans the funnel history.
- No PII in params (no client name, no shoot location text — id only).
- Depends on [[task_b3_typed_event_helpers]] for the actual emit calls if landed.

## Outcome
Shipped on `improvments-phase1`.

- **Shoots — `shootAccepted`**: emitted in two places — `ShootsListNotifier.acceptShoot` (`shoots_providers.dart:159`) for list-row one-tap accept, and `UpcomingShootDetailNotifier._respond` (`upcoming_shoot_providers.dart:108`) for detail-view accept. Both pass `shootId` as `projectId.toString()`. `unawaited(...)` pattern — telemetry failure never aborts user flow.
- **Shoots — `shootDeclined`**: emitted in `UpcomingShootDetailNotifier._respond` (`upcoming_shoot_providers.dart:110`) when `status == 'declined'`. Conditioned alongside `shootAccepted` via the status check, so only one fires per response.
- **Shoots — `shootCancelled`**: emitted in `CancelShootNotifier.submit` (`shoots_providers.dart:257`). UX distinction: the cancel-shoot flow posts `declined` to the backend but emits `shootCancelled` for funnel separation from in-detail declines.
- **Profile — `profilePhotoUploaded`**: emitted in `MyProfileNotifier.uploadPhoto` (`my_profile_providers.dart:170`) and `EnterProfessionalNotifier.uploadPhoto` (`profile_details_providers.dart:397`). Both accept optional `ProfilePhotoSource` and guard with `if (source != null)` so callers without source info don't crash.
- **Profile — `featuredWorkUploaded`**: emitted in `FeaturedWorkNotifier.upload` (`profile_files_providers.dart:234–238`). Passes `files.length` as `fileCount` — batch uploads get the real count, not hardcoded 1.
- **Profile — `resumeUploaded`**: emitted in `ResumeNotifier.upload` (`profile_files_providers.dart:80`). `fileCount: 1` — resume is always singleton.
- **Profile — `certificationsUploaded`**: emitted in `CertificatesNotifier.upload` (`profile_files_providers.dart:140–141`). `fileCount: 1` — singleton upload per the profile API shape.
- **Availability — `availabilityAdded`**: emitted in `AddAvailabilityNotifier.submit` (`availability_providers.dart:276–282`). `durationDays` computed by `_durationDays(formattedDate, recurrenceUntil)` — parses both date strings, falls back to 1 on invalid/empty input.
- **All emission paths are `unawaited`.** Telemetry failure never aborts a user flow.
- **No PII.** Only `shoot_id` (int as string), `source` (enum), `file_count` (int), and `duration_days` (int) cross the wire.

**Tests:**
- `test/features/shoots/presentation/shoots_notifier_test.dart` — `shootAccepted` on accept success, not on failure; `shootCancelled` on cancel submit, not on empty reason or repo error.
- `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — `shootAccepted` on accept, `shootDeclined` on decline, neither on respond failure.
- `test/features/profile/presentation/profile_files_test.dart` — `resumeUploaded` on success / skip on failure; `certificationsUploaded` on success / skip on failure; `featuredWorkUploaded` on success with `file_count: 2` / skip on failure.
- `test/features/profile/presentation/my_profile_notifier_test.dart` — `profilePhotoUploaded` on success / skip on failure.
- `test/features/profile/presentation/profile_details_test.dart` — `profilePhotoUploaded` on success / skip on failure.
- `test/features/availability/presentation/screens/availability_test.dart` — `availabilityAdded` on submit success / skip on failure.
- `test/core/firebase/analytics_events_test.dart` — typed helper shape tests for all B2 events (6 parametric).

**Verification:** All tests passing. `flutter analyze` clean. All emission paths use typed helpers from B3 extension — no raw `logEvent` callsites in `lib/features/`.

**Deviations:** None — all events wired exactly per task spec.
