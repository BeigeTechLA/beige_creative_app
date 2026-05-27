# Task 3.09 — `DioClient` singleton

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 3h

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
- [ ] Class `DioClient` with private `Dio _dio` + getter
- [ ] `BaseOptions(baseUrl: Env.apiUrl, connectTimeout: 15s, receiveTimeout: 15s, sendTimeout: 15s, headers: {Accept: 'application/json'})`
- [ ] Constructor takes dependencies for future interceptors (e.g. `SessionStore`)
- [ ] No global state — instantiated by `dioClientProvider` in Task 3.11

## Acceptance
- [ ] `flutter analyze` clean
- [ ] Manual: a probe call (`/healthz` or any GET) returns 2xx + parses

## Notes
Timeouts are non-negotiable per Risk #20 — slow-loris path closed here.
