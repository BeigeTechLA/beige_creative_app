# Task 3.08 — `ApiResponse<T>` wrapper

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 1h

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
- [ ] Define `ApiResponse<T>` with `bool error`, `String? message`, `T? data`
- [ ] Add `factory ApiResponse.fromJson(Map<String, dynamic>, T Function(dynamic))`
- [ ] Add `_assertNoError()` helper for repositories to check the `error: true` pattern

## Acceptance
- [ ] Compiles, exports cleanly
- [ ] Documented with one-line usage example

## Notes
Trivial primitive. Lives in front of `ExceptionHandler.guardAsync` — repositories call `_assertNoError(json)` after the Dio call.
