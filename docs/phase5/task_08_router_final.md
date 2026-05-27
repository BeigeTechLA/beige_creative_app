# Task 5.08 — Router final pass

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/router-final` |

## Goal
If `lib/app/router.dart` is >400 LOC, split per feature. Replace `state.extra` Map with typed parameters on routes that should be deep-linkable. Optionally wire deep links for top-level routes.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.G
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §6.3

## Files in scope (≤8)
- `lib/app/router.dart` — orchestrator (≤400 LOC after split)
- `lib/features/<name>/presentation/routes/<name>_routes.dart` — per-feature route fragments composed into the orchestrator
- `lib/app/route_names.dart` — update
- Any screen that should be deep-linkable — replace `extra` Map with path/query params

## Steps
- [ ] Measure: `wc -l lib/app/router.dart` — if >400, split per feature into `*_routes.dart` files
- [ ] Identify deep-linkable routes: shoot detail, creative profile, password reset OTP entry
- [ ] Replace their `state.extra` reads with `state.pathParameters` / `state.uri.queryParameters`
- [ ] Add manifest intent filter (Android) + URL types (iOS) for the deep-link host
- [ ] Smoke: each deep link opens the right screen

## Acceptance
- [ ] `lib/app/router.dart` ≤400 LOC
- [ ] Deep-linkable routes accept typed params
- [ ] App boots both flavors
- [ ] `flutter analyze` clean

## Notes
Deep-link wiring is the only optional item — defer if not on roadmap. Otherwise this task lands the structural split.
