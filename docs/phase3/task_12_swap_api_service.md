# Task 3.12 — Swap `api_service.dart` internals to `DioClient`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 4h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/api-service-dio` |

## Goal
Keep the 68 `ApiService()` call sites working but rewire the implementation to use `DioClient` internally. Removes the `http` + `dio` dual stack risk while preserving the legacy facade until Phase 4 migrates callers feature-by-feature.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #12; §7 Phase 3.B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §5.2 (never use raw `http`)

## Files in scope
- `lib/service/api_service.dart`

## Steps
- [x] Replaced all `http.{get,post,put,delete}` + raw `Dio()` usage with calls to a shared `DioClient.dio.*` (`_ensureClient()` lazily builds + caches the `DioClient` instance with the canonical interceptor chain).
- [x] Public signatures preserved — `fetchData`, `postData`, `putData`, `deleteData`, `postDataraw`, `postMultipart`, `postMultipartData`, `postMultipartDataMultiple`, `postMultipartStep3`, `getImageURL`, `baseUrl` all unchanged.
- [x] Token injection moved to `AuthInterceptor` (`tokenReader: () async => PrefsService.token`). `createAuthorizationHeader()` removed.
- [x] `postMultipartStep3` now goes through the shared client — auth header applied automatically (was bypassed in legacy raw `Dio()` path).
- [x] Cleaned up the one remaining caller (`lib/profile/myprofile.dart:_uploadImage`) that still called `createAuthorizationHeader()` directly + built a raw `Dio()` for profile-photo upload. Now uses `ApiService().postMultipart('creator/profile/upload-profile-photo', {...}, File(filePath))`.
- [ ] Live smoke against backend — **not run** (no live env here). Public-signature parity gives compile-time + test-time confidence; first feature migration in Phase 4 will exercise the verbs end-to-end.

## Acceptance
- [x] `flutter analyze lib/service/api_service.dart` → No issues found.
- [x] `flutter analyze` (full) → **298 issues** (was 301 baseline — 3 fewer because the old `api_service.dart` had `Missing type annotation` lints).
- [x] `grep -rn "import 'package:http/" lib/service/` → empty.
- [x] `flutter test` → 7/7 passing (6 exception-handler + 1 widget smoke).
- [x] `http` still in `pubspec.yaml` (Phase 5.02 removes it).

## Notes
This is the largest single-file edit in Phase 3. Pair-program if available. `http` package removal is Phase 5.02 — leave it in pubspec until then for safety.
