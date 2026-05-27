# Task 4.22 — Group E · Unit 17.b · Migrate SignUp3 sub-screens

**Phase:** 4 · **Group:** E · **Status:** 🔴 Not Started · **Est:** 2d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupE-signup3` |

## Goal
Migrate the post-split signup3 sub-screens to Riverpod. Each sub-screen owns its slice via a sub-Notifier. Submit calls `postMultipartStep3` (verify auth header now flows through `AuthInterceptor` post Task 3.12).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group E Unit 17

## Files in scope (max 10)
- `lib/features/auth/presentation/providers/signup3_*_notifier.dart` (one per sub-screen)
- Sub-screens from 4.21 — wire `ref.watch`/`ref.read`
- `lib/features/auth/data/repositories/auth_repository_impl.dart` (`submitStep3` method)
- Widget tests for each sub-screen happy path

## Steps
- [ ] Slice Notifiers + a root `Signup3Notifier` that aggregates at submit
- [ ] Image / file picker invoked via Notifier method, not widget
- [ ] `postMultipartStep3` migrated to the new DioClient (no longer bypasses interceptors)
- [ ] Widget tests per sub-screen + an integration smoke for full submit

## Acceptance
- [ ] `setState` removed
- [ ] All 35 form fields covered across the 4 slices
- [ ] Submit produces a byte-identical multipart request body vs pre-migration (assert via characterization)
- [ ] `flutter analyze` clean

## Notes
Group E completion = ~70% of feature migration done. After this, only Group F (shell) remains.
