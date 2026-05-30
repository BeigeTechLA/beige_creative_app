# Task 4.09 — Group C · Unit 7.b · Migrate FeaturedWorkList + Resume + Certificates

**Phase:** 4 · **Group:** C · **Status:** 🟢 Completed · **Est:** 3d · **Actual:** ~1.5h (cold session)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupC-featured-work` |

## Goal
Migrate the post-split FeaturedWorkList (+ FeaturedWorkDetails 177 LOC), Resume (546), Certificates (528) to Riverpod. All share the profile repository and image-upload pipeline.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group C Unit 7
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §14

## Files in scope (max 10)
- `lib/features/profile/presentation/providers/featured_work_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/providers/resume_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/providers/certificates_notifier.dart` + `_state.dart`
- `lib/features/profile/presentation/screens/featured_work_list_screen.dart`
- `lib/features/profile/presentation/screens/featuredwork_details_screen.dart`
- `lib/features/profile/presentation/screens/resume_screen.dart`
- `lib/features/profile/presentation/screens/certificates_screen.dart`

## Steps
- [x] Notifiers fetch + paginate + upload
- [x] Image upload uses `postMultipart` (still via `ApiService` shim for now)
- [ ] `CancelToken` + `ref.onDispose` on each search/list provider — deferred; profileFiles endpoints are single short POSTs, no search/pagination yet
- [x] Widget tests for upload happy path

## Acceptance
- [x] All 4 screens migrated
- [x] Upload works (resume PDF, certificates, featured work media) — verified via notifier tests
- [x] No `TextEditingController` leaks — only FeaturedWorkList retains controller, disposed in `dispose()`
- [x] `flutter analyze` clean — no new errors/warnings; deprecation infos parity with sibling screens

## Notes
Image / file upload is shared with signup3 (Group E Unit 17). Keep the upload helper generic so it can be reused there.
