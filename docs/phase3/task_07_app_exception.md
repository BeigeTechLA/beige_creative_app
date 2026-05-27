# Task 3.07 — Sealed `AppException` + `ExceptionHandler`

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 4h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/app-exception` |

## Goal
Land the sealed `AppException` hierarchy and `ExceptionHandler.guardAsync()` so repositories can return `Either<AppException, T>` instead of throwing.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations rows 13–14; §7 Phase 3.B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §5.3 Exception Hierarchy

## Files in scope (max 6)
- `lib/core/network/exceptions/app_exception.dart` — `sealed class AppException`
- `lib/core/network/exceptions/network_exception.dart` — `NoInternet`, `Timeout`, `RequestCancelled`
- `lib/core/network/exceptions/server_exception.dart` — `Server`, `ServiceUnavailable`
- `lib/core/network/exceptions/client_exception.dart` — `Unauthorized` (401), `Forbidden` (403), `NotFound` (404), `Validation` (422 with fieldErrors), `TooManyRequests` (429)
- `lib/core/network/exceptions/exception_handler.dart` — `guardAsync<T>(Future<T> Function())` → `Either<AppException, T>`
- `lib/core/network/exceptions/exceptions.dart` — barrel file

## Steps
- [ ] Implement all subclasses per `MIGRATION_RULES.md` §5.3
- [ ] `ExceptionHandler.guardAsync` catches `DioException` + `SocketException` + `TimeoutException` and maps to typed exceptions
- [ ] Return `Either` via `dartz` (chosen in Task 3.01)
- [ ] Unit test happy + 401 + 5xx paths (smoke only — full tests in Phase 6)

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Smoke test compiles + runs
- [ ] Hierarchy + `guardAsync` documented inline

## Notes
Keep `ValidationException` with a `Map<String, List<String>> fieldErrors` shape — auth signup3 needs it.
