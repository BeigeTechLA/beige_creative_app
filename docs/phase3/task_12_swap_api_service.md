# Task 3.12 — Swap `api_service.dart` internals to `DioClient`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 4h

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
- [ ] Replace all `http.get/post/put/delete` and direct `Dio()` usage with calls to `DioClient.dio.*`
- [ ] Keep public signatures unchanged (fetchData / postData / putData / deleteData / postMultipart*)
- [ ] Token injection moves to `AuthInterceptor` — drop `createAuthorizationHeader()`
- [ ] `postMultipartStep3` no longer bypasses auth — same interceptor chain applies
- [ ] Smoke each of the 4 verbs against a real endpoint

## Acceptance
- [ ] `flutter analyze` clean
- [ ] `grep -rn "import 'package:http/" lib/service/` returns nothing
- [ ] Login + profile read + booking list — all work
- [ ] `http` still in `pubspec.yaml` (removed in Phase 5)

## Notes
This is the largest single-file edit in Phase 3. Pair-program if available. `http` package removal is Phase 5.02 — leave it in pubspec until then for safety.
