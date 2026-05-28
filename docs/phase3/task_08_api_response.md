# Task 3.08 — `ApiResponse<T>` wrapper

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 1h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/api-response` |

## Goal
Generic envelope to normalize the Beige API shape (`{error: bool, message: String?, data: T}`) before mapping to entities.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 3.B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §5

## Files in scope
- `lib/core/network/api_response.dart`

## Steps
- [x] Defined `ApiResponse<T>` with `bool error`, `String? message`, `T? data` (all final, const constructor).
- [x] Added `factory ApiResponse.fromJson(Map<String, dynamic>, T Function(dynamic))` that defensively parses `error` (defaults to false if non-bool) and skips `dataParser` when `data` is null.
- [x] Added `assertNoError()` (public — repositories call it directly after parsing) that throws `ServerException(message: …)`; thrown exception is caught by `ExceptionHandler.guardAsync` and converted to `Either.Left`.

## Acceptance
- [x] Compiles — `flutter analyze lib/core/network/api_response.dart` → No issues found.
- [x] Documented — class-level dartdoc has a 5-line usage example (`fromJson` + `assertNoError` + return `data!`).

## Notes
Trivial primitive. Lives in front of `ExceptionHandler.guardAsync` — repositories call `_assertNoError(json)` after the Dio call.
