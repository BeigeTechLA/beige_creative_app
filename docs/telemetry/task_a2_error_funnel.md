# Task A2 — Non-fatal error funnel through ExceptionHandler

**Phase:** A · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `telemetry/a2-error-funnel` |

## Goal
Forward non-fatal exceptions caught by `ExceptionHandler.guardAsync` to `CrashlyticsService.recordError(..., fatal: false)` so server failures, validation breaks, and unknown-shape errors land in Crashlytics. Today every repo error is silently mapped to `Either.Left(AppException)` and forgotten.

## References
- `lib/core/network/exceptions/exception_handler.dart:30-57`
- `lib/core/firebase/crashlytics_service.dart:65` — `recordError`
- `lib/core/network/exceptions/app_exception.dart`

## Files in scope (2)
- `lib/core/network/exceptions/exception_handler.dart` — add `recordError` calls in the right catch branches.
- `test/core/network/exception_handler_test.dart` (new) — assert forwarded vs skipped.

## Steps
- [x] In `guardAsync`:
  - `DioException` → forward only when mapped to `ServerException` (5xx + unknown) or `ValidationException` (422). Skip `NoInternet`, `Timeout`, `RequestCancelled`, `Unauthorized` (401), `Forbidden` (403), `NotFound` (404), `TooManyRequests` (429), `ServiceUnavailable` (503 — already user-visible).
  - `SocketException` → skip (noise).
  - `TimeoutException` → skip (noise).
  - `AppException` rethrown by feature code → skip (caller already classified).
  - Unknown `catch (e, st)` → always forward as `fatal: false` with `reason: 'guard.unexpected'`.
- [x] Mirror the same rules in `ErrorInterceptor` if it duplicates classification (check `lib/core/network/interceptors/`). *(N/A — `ErrorInterceptor` only wraps the typed error, it does not classify-and-forward; adding forwarding there would double-report when `guardAsync` is used downstream.)*
- [x] Tests: feed each branch via mocked Dio; verify `CrashlyticsService.recordError` mock was called or not called per the matrix above.

## Acceptance
- [x] Test matrix covers every branch (8 cases minimum — landed 14 forwarding-matrix cases + 6 preserved mapping cases).
- [x] `flutter analyze` clean.
- [ ] Manual: trigger a 500 on dev flavor; entry appears in Crashlytics Non-fatals tab tagged with the route key. *(deferred to QA smoke)*

## Outcome
Shipped on `improvments-phase1`.

- **`lib/core/network/exceptions/exception_handler.dart`:** added `crashRecorder` test-seam (defaults to `CrashlyticsService.recordError`). `guardAsync` now uses pattern matching on the mapped `AppException` to forward only `ServerException` (`reason: 'dio.5xx'`) and `ValidationException` (`reason: 'dio.422'`); the noise branches (`NoInternet`, `Timeout`, `RequestCancelled`, `Unauthorized`, `Forbidden`, `NotFound`, `TooManyRequests`, `ServiceUnavailable`) explicitly fall through with no forward. Unknown `catch (e, st)` always forwards with `reason: 'guard.unexpected'`. All forward calls are `unawaited` so the error path isn't slowed.
- **`test/core/network/exception_handler_test.dart`:** test count 6 → 20. New cases stub `crashRecorder` and assert it's called or not called per the matrix, plus the existing mapping cases unchanged.

**Verification:** `flutter analyze --fatal-infos` clean. `flutter test` → 223 passing (14 new).

**Deviation:** Used `@visibleForTesting` field assignment for the seam instead of full dependency injection of `CrashlyticsService`. Keeping it simple — repositories still call `ExceptionHandler.guardAsync` statically and don't need a provider.

## Notes
- `CrashlyticsService.recordError` is fire-and-forget (returns `Future<void>`) but it's `await`-able. Inside `guardAsync` use unawaited so it doesn't slow the error path: `unawaited(CrashlyticsService.recordError(...))`.
- Pass `reason: 'dio.5xx'` / `reason: 'dio.422'` / `reason: 'guard.unexpected'` so Crashlytics groups sanely.
- Depends on [[task_a1_user_identity]] for user_id breadcrumb; not blocking but improves report quality.
