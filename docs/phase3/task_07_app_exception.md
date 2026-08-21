# Task 3.07 — Sealed `AppException` + `ExceptionHandler`

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 4h

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
- [x] Implemented all 10 subclasses per `MIGRATION_RULES.md` §5.3 — `NoInternet`, `Timeout`, `RequestCancelled`, `Server`, `ServiceUnavailable`, `Unauthorized`, `Forbidden`, `NotFound`, `Validation` (with `fieldErrors`), `TooManyRequests` (with `retryAfter`).
- [x] `ExceptionHandler.guardAsync` catches `DioException` + `SocketException` + `dart:async TimeoutException` and maps to typed exceptions; also re-wraps any `AppException` thrown inside the body and falls back to `ServerException` for unknown errors.
- [x] Returns `Either<AppException, T>` via `dartz`.
- [x] Smoke test added at `test/core/network/exception_handler_test.dart` — happy path + 401 + 422 (with fieldErrors) + 500 + connectionTimeout + AppException passthrough. **6 tests, all passing.**

## Acceptance
- [x] `flutter analyze lib/core/network/exceptions/` → No issues found.
- [x] `flutter analyze` (full) → 301 issues = baseline; zero new lints.
- [x] Smoke test compiles + runs (`flutter test test/core/network/exception_handler_test.dart` → all 6 pass).
- [x] Hierarchy + `guardAsync` documented inline (dartdoc on sealed base + each subclass + handler + repository pattern example).

## Notes
Keep `ValidationException` with a `Map<String, List<String>> fieldErrors` shape — auth signup3 needs it.

**Implementation note (2026-05-28):** Used Dart `part` / `part of` to split the sealed hierarchy across files. Dart prohibits extending a sealed class outside its declaring library, so the four subclass files (`network_exception.dart`, `server_exception.dart`, `client_exception.dart`) are now `part of 'app_exception.dart'`. Barrel file (`exceptions.dart`) exports only the library file + handler — parts are not directly exportable. Consumers `import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';` and get the whole API.

Server message parser handles `message` / `error` / `detail` keys; field-error parser handles `errors` / `field_errors` keys with list-or-string values. Retry-After header parsed as integer seconds.
