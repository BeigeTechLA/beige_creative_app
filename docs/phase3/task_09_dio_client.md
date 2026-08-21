# Task 3.09 — `DioClient` singleton

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/dio-client` |

## Goal
Single Dio instance with `BaseOptions` (baseUrl from `Env.apiUrl`, connect/receive/send timeouts, default headers). Interceptors land in [Task 3.10](task_10_interceptors.md).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 12; §4 Risk #20
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §5.4

## Files in scope
- `lib/core/network/dio_client.dart`

## Steps
- [x] Class `DioClient` with private `Dio _dio` + public `dio` getter.
- [x] `BaseOptions(baseUrl: Env.apiUrl, connectTimeout: 15s, receiveTimeout: 15s, sendTimeout: 15s, headers: {Accept: 'application/json'}, responseType: json)`.
- [x] Constructor stays argument-less; `DioClient.withDio(Dio)` test seam added for mock injection. Dependencies (e.g. `SessionStore`) flow in via interceptors, not the constructor — keeps `DioClient` thin.
- [x] No global state — `dioClientProvider` in Task 3.11 owns the lifecycle.
- [x] `attachInterceptors(List<Interceptor>)` extension point added so Task 3.10 can wire `AuthInterceptor`, `RetryInterceptor`, `ErrorInterceptor`, `LoggingInterceptor` without re-touching this class.

## Acceptance
- [x] `flutter analyze lib/core/network/dio_client.dart` → No issues found.
- [ ] Probe call returns 2xx + parses — **not verified** (no live network in this env). DioClient is wired up by provider in Task 3.11; first real call happens when a feature data source is migrated in Phase 4.

## Notes
Timeouts are non-negotiable per Risk #20 — slow-loris path closed here.
