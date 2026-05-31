# Task 5.08 — Router final pass

**Phase:** 5 · **Status:** 🟢 Completed (2026-05-31) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Split `lib/app/router.dart` per feature so the orchestrator stays ≤400 LOC. Typed-param + deep-link wiring scoped as optional (task notes); deferred — no deep-link product roadmap yet.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.G
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §6.3

## Files in scope (6)
- `lib/app/router.dart` — orchestrator (465 → **165** LOC).
- `lib/features/auth/presentation/routes/auth_routes.dart` — **new** (login, signup1/2/3, forgot, otp, reset, view-details).
- `lib/features/profile/presentation/routes/profile_routes.dart` — **new** (16 routes: my-profile, edit/enter, featured, certificates, resume, prefs, change/new password + otp + success, delete-account flow).
- `lib/features/shoots/presentation/routes/shoots_routes.dart` — **new** (upcoming details, cancel-shoot, shoot-cancelotties).
- `lib/features/availability/presentation/routes/availability_routes.dart` — **new** (add-availability).
- `lib/features/file_manager/presentation/routes/file_manager_routes.dart` — **new** (pre / post production).

## Steps
- [x] Measured: `wc -l lib/app/router.dart` → 465 (over 400 threshold).
- [x] Split per feature into `*_routes.dart` files each exporting `final List<RouteBase> <feature>Routes`.
- [x] Orchestrator keeps splash + onboarding + the 5-tab `StatefulShellRoute` (global app lifecycle) inline, spreads feature fragments below.
- [x] Skipped deep-link wiring + typed params (task notes mark optional; not on roadmap).
- [x] `flutter analyze --fatal-infos` clean.
- [x] `flutter test` 145/145 passing — includes app smoke test that mounts `MaterialApp.router` against this exact route tree.

## Acceptance
- [x] `lib/app/router.dart` ≤400 LOC (165 LOC).
- [ ] ~~Deep-linkable routes accept typed params~~ — deferred (optional per task notes).
- [x] App boots — smoke test passes; no runtime route-tree errors.
- [x] `flutter analyze` clean.

## Notes
- Per-feature fragments live under `presentation/routes/` — co-located with the feature's screens for discoverability when a screen route changes.
- Splash + onboarding intentionally stay in the orchestrator: they describe pre-auth global lifecycle, not a feature. Moving them into a one-route fragment file would be ceremony without payoff.
- StatefulShellRoute stays in the orchestrator too — its branches reference screens across 5 features; splitting it would create circular intent.
- Public-route set, redirect logic, and `_AuthRefreshNotifier` remain in `router.dart` — they're cross-cutting orchestration concerns.
