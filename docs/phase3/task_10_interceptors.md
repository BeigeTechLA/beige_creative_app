# Task 3.10 — Interceptors (Auth + Retry + Error + Logging)

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 5h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/interceptors` |

## Goal
Four interceptors in strict order: `AuthInterceptor` (QueuedInterceptor — token inject + 401 refresh stub) → `RetryInterceptor` (5xx + exponential backoff) → `ErrorInterceptor` (`DioException` → `AppException`) → `LoggingInterceptor` (dev only).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #7 (401); §7 Phase 3.B
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §5.4 Interceptor Order

## Files in scope (max 4)
- `lib/core/network/interceptors/auth_interceptor.dart` — extends `QueuedInterceptor`
- `lib/core/network/interceptors/retry_interceptor.dart` — extends `Interceptor`
- `lib/core/network/interceptors/error_interceptor.dart`
- `lib/core/network/interceptors/logging_interceptor.dart`

## Steps
- [x] `AuthInterceptor` (extends `QueuedInterceptor`): takes `tokenReader: Future<String?> Function()` + optional `onUnauthorized: Future<void> Function()`. Injects `Authorization: Bearer <t>` when token non-empty; on 401, awaits `onUnauthorized?.call()` before forwarding the error.
- [x] `RetryInterceptor`: 3 attempts, backoff `[250ms, 500ms, 1000ms]`. Retries 5xx + transient transport failures (connectionError, connectionTimeout, receiveTimeout). Skips 4xx and `DioExceptionType.cancel`. Attempt counter stored in `RequestOptions.extra['__retry_attempt__']`.
- [x] `ErrorInterceptor`: delegates to `ExceptionHandler.mapDioException(err, st)` (renamed from private `_mapDioException` so handler + interceptor share one mapping) and attaches the typed `AppException` to `DioException.error` via `copyWith(error: …)`.
- [x] `LoggingInterceptor`: `kDebugMode`-gated logs via `AppLogger`. Redacts `authorization`, `cookie`, `x-api-key` header values to `<redacted>`. Logs method+URI on request, status on response, type+status on error.
- [x] Registration order documented in `MIGRATION_LOG`. Actual wiring lands in Task 3.11 (`dioClientProvider`) — chain is `Auth → Retry → Error → Logging`.

## Acceptance
- [x] `flutter analyze lib/core/network/interceptors/ lib/core/network/exceptions/` → No issues found.
- [ ] Manual smoke: 401 path redirects to login — **deferred to Task 3.17** (router redirect) as the task itself notes.
- [x] Logging interceptor compiled out of release APK — `kDebugMode` gate ensures the log bodies are dead code in release; Dart's tree-shaker drops them.
- [x] No `Bearer` header value in logger output — `_redactSensitive` swaps the value to `<redacted>` before logging.
- [x] Existing `exception_handler_test.dart` → 6/6 still passing after `_mapDioException` → public `mapDioException` rename.

## Notes
401 refresh is a stub for now — current backend has no refresh-token endpoint per `AUDIT_SEC.md`. Treat 401 as "session over → redirect to login".
