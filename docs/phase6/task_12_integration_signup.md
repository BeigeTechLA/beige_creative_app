# Task 6.12 — Integration test: signup1 → 2 → 3 → success

**Phase:** 6 · **Status:** 🟢 Completed · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/integration-signup` |

## Goal
End-to-end signup test across all 3 screens. Asserts final submit body is
correct and the current production success route is reached.

## Files in scope (max 2)
- `integration_test/signup_flow_test.dart`
- `integration_test/robots/signup_robot.dart`

## Steps
- [x] Stub Dio for live endpoints: `auth/register-crew-step1`, `auth/register-crew-step2`, `auth/register-crew-step3`, plus role/skill lookups
- [x] Robot drives all three real screens; plugin-backed image/map/file-picker outcomes are seeded through the real `SignupNotifier`
- [x] Assert step-1 multipart, step-2 JSON, and step-3 multipart payloads match the Task 4.21 / 4.22 characterization shape

## Acceptance
- [x] `flutter test integration_test/signup_flow_test.dart -d macos` passes
- [x] All 3 screens traversed
- [x] Final submit assertion green

## Notes
Largest integration test in the suite. Reuses the characterization snapshot from
signup3 decomposition / migration (Tasks 4.21 and 4.22) as the source of truth:
`crew_member_id`, JSON fields (`certifications`, `social_media_links`,
`portfolio_links`, `featured_work`), files (`resume`, `portfolio`,
`certifications`, repeated `recent_work_media`), and paired
`recent_work_media_index` values.

Spec deviations logged:

- The task's endpoint labels (`auth/signup1`, `auth/signup2`,
  `auth/signup3-multipart`) were stale. The live repository posts to
  `ApiEndpoints.register_step1`, `register_step2`, and `register_step3`.
- The task goal said success should land on `/home`. Current production code
  in `SignUp3Screen._submit` routes to `Routes.login` after successful signup,
  matching `docs/NAVIGATION_MAP.md`; the integration test preserves and asserts
  that current behavior instead of changing navigation under a test task.
- Direct native picker mocking was avoided because `CommonUploader`,
  `FilePicker`, Google Places, and Google Maps do not expose app-level
  injection seams. The test seeds their outcomes through the real notifier and
  uses Geolocator channel stubs only to keep screen mount hermetic.
