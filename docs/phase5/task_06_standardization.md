# Task 5.06 — Standardization sweeps

**Phase:** 5 · **Status:** 🟢 Completed (2026-05-31) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Final pass on cross-cutting concerns missed in Phase 4: consolidate date/time helpers, ensure analytics events are constants only, kill any remaining asset string literals, consolidate regex.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.E

## Files in scope (7)
- `lib/core/utils/validators.dart` — **new** canonical regex + helpers.
- `lib/features/auth/presentation/providers/signup_notifier.dart`
- `lib/features/auth/presentation/providers/login_notifier.dart`
- `lib/features/auth/presentation/providers/forgot_password_notifier.dart`
- `lib/features/auth/presentation/screens/signup1_screen.dart`
- `lib/features/profile/presentation/providers/change_password_providers.dart`
- `lib/service/google_config.dart`

## Steps
- [x] `rg "DateFormat\(|toIso8601|DateTime\.parse\("` — every `DateFormat` lives in `DateTimeUtils`. Remaining `DateTime.parse` / `toIso8601String` outside it are JSON decoders (`upcoming_shoots_model`, `create_dashboard_details_model`), prefs persistence (`prefs_session_store`), and one API-map-key parse in `home_notifier` — these are not formatter literals and stay in place.
- [x] `rg "FirebaseAnalytics\|logEvent\("` — only consumer of raw `logEvent` is `AnalyticsService` itself; `AnalyticsEvents` registry already exists and has no out-of-bounds callers.
- [x] `rg "'assets/"` — every literal lives in `lib/app/assets.dart`; no other call sites.
- [x] `rg "RegExp\("` — 4 duplicate email patterns + 2 duplicate plus-code patterns consolidated into `lib/core/utils/validators.dart` (`kEmailPattern`, `kPlusCodePattern`, `isValidEmail`, `isPlusCode`). Trivial `RegExp(r'\s+')` and the one-shot `"message":"(.*?)"` parser stay in place.

## Acceptance
- [x] No inline date formatter literal outside `DateTimeUtils`.
- [x] No raw analytics event name string outside `AnalyticsEvents` (no consumers yet — registry is correctly the sole owner).
- [x] No `'assets/...'` literal outside `AppAssets`.
- [x] `flutter analyze --fatal-infos` clean (0 issues).

## Notes
- `change_password_providers.dart` previously had a subtly different email pattern (`[a-zA-Z]+$` instead of `{2,}$`) — now unified on the stricter `{2,}` TLD rule via the shared `isValidEmail`.
- `GoogleConfig.plusCodeRegex` had no external consumers; deleted rather than re-pointed.
- `signup1_screen.dart` `_isPlusCode` wrapper deleted — direct `isPlusCode(value)` call.
- Date/time consolidation: no work needed — `DateTimeUtils` is already the single formatter source.
- Analytics: nothing to consolidate yet (registry exists, no event call sites in the app).
