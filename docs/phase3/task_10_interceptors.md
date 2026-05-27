# Task 3.10 — Interceptors (Auth + Retry + Error + Logging)

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 5h

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
- [ ] `AuthInterceptor`: read token from `SessionStore` (injected) → `Authorization: Bearer <t>`; on 401, clear session + emit `Unauthorized` exception
- [ ] `RetryInterceptor`: max 3 attempts on 5xx, exponential backoff (250ms, 500ms, 1000ms); never retry 4xx
- [ ] `ErrorInterceptor`: map `DioException` (timeout, cancel, badResponse, connectionError) to `AppException` subtypes
- [ ] `LoggingInterceptor`: `kDebugMode` only; never log `Authorization` header value
- [ ] Register in `DioClient` in this order

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Manual smoke: 401 path redirects to login (verified after Task 3.17)
- [ ] Logging interceptor compiled out of release APK
- [ ] No `Bearer` header value present in any logger output

## Notes
401 refresh is a stub for now — current backend has no refresh-token endpoint per `AUDIT_SEC.md`. Treat 401 as "session over → redirect to login".
