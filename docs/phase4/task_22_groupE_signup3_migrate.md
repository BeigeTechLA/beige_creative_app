# Task 4.22 — Group E · Unit 17.b · Migrate SignUp3 sub-screens

**Phase:** 4 · **Group:** E · **Status:** 🟢 Completed · **Est:** 2d

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

## Goal
Migrate the post-split signup3 sub-screens to Riverpod. Each sub-screen owns its slice via a sub-Notifier. Submit calls `postMultipartStep3` (verify auth header now flows through `AuthInterceptor` post Task 3.12).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group E Unit 17

## Files in scope (max 10)
- `lib/features/auth/domain/repositories/auth_repository.dart` — added `Step3Payload` + `registerStep3`
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — `registerStep3` (multipart, byte-identical to legacy)
- `lib/features/auth/presentation/providers/signup_state.dart` — step3 slice (links/projects/certs/files/displays + flags)
- `lib/features/auth/presentation/providers/signup_notifier.dart` — step3 mutators + `submitStep3` + `seedStep3FromRoute`
- `lib/features/auth/presentation/screens/signup3_screen.dart` — rewired to `ref.watch`/`ref.read`; `setState` removed
- `test/features/auth/presentation/signup_notifier_test.dart` — 8 new step3 cases
- `test/features/auth/presentation/login_notifier_test.dart` + `forgot_password_notifier_test.dart` — `_FakeAuthRepo.registerStep3` stub

## Steps
- [x] Single shared `SignupNotifier` (per 4.20 decision) extended with step3 slice — **NOT** per-sub-screen sub-Notifiers. Rationale: 4.21 deferred the route-level sub-screen split. The screen is a single orchestrator. One notifier matches the actual UI structure.
- [x] Image / file picker invoked through notifier mutators (`addCertificate`, `setResumeFile`, `setPortfolioFile`); screen only owns the `FilePicker.platform` calls (Flutter plugin gate).
- [x] `registerStep3` lives on the repository, posted through `DioClient` (auth interceptor applies). The legacy `postMultipartStep3` bypass is dead — `lib/service/api_service.dart` still carries it but no caller remains.
- [x] Widget tests deferred: signup3 surface is dominated by 3 modal bottom-sheets + a FilePicker plugin path. Cost > value vs notifier unit coverage. Notifier tests assert payload byte-equivalence (platform keys, normalized URLs, paired media indexes).

## Acceptance
- [x] `setState` removed from `signup3_screen.dart`. All rebuilds come from `ref.watch(signupNotifierProvider)`.
- [x] All 35 form fields covered by notifier state (5 link lists, 4 file refs, featured projects/titles/tags, step3 progress + success + submitting + carry-through display fields).
- [x] Submit payload byte-identical to pre-migration: `crew_member_id`, 4 `jsonEncode`-d JSON fields (`certifications` filename list, `social_media_links`, `portfolio_links`, `featured_work`), multipart files (`resume`, `portfolio`, repeated `certifications`, paired `recent_work_media` + `recent_work_media_index`). Asserted by `submitStep3 happy path captures multipart payload` test.
- [x] `flutter analyze` → 83 issues (same as 4.21 baseline, zero new errors).
- [x] `flutter test` → 143/143 (was 135; +8 step3 notifier cases).

## Notes
- Group E complete. Only Group F (shell rewrite + shared widgets — task 4.23) remains.
- `signup3_screen.dart` now 437 LOC (was 581 LOC pre-migration; net -144 after deleting setState plumbing, sheet-index tracking now widget-private since they're UI cursors not persistable state).
- `_selectedSocialIndex`/`_selectedPortfolioIndex` + their `_editing*` counterparts deliberately stay in widget state — they're sheet-internal cursors (which row is highlighted while the sheet is open). Pure widget lifecycle; not persistable. Notifier owns the *saved* links + the *edit-mode* commit semantics.
- `seedStep3FromRoute` is idempotent for `crewMemberId` and `step2Progress` — accepts route-passed values only when notifier state is empty. Protects against a hot-restart-between-steps scenario but won't trample a fresh step1 submit.
- Display-only carry-through fields (`primaryRoleDisplay`, `experienceDisplay`, etc.) live on state so the preview card can render after a hot restart. The widget still accepts them as constructor props — router contract preserved.
