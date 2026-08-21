# Task 2.07 — Navigation immediate fixes

**Phase:** 2 · **Status:** 🟢 Completed · **Est:** 3h

| Field | Value |
|---|---|
| Owner | Antigravity |
| Started | 2026-05-27 |
| Completed | 2026-05-27 |
| PR | — |
| Branch | `migration/phase2/nav-fixes` |

## Goal
Patch three navigation defects that crash or regress UX, before any feature migration touches the router. Holding measures only — full shell rewrite happens in Phase 4 Group F.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risks #14, #15, #16
- [`../audit/NAVIGATION_AUDIT.md`](../audit/NAVIGATION_AUDIT.md) F-02, F-05, F-08

## Files in scope (max 10)
- `lib/app/router.dart` — collapse duplicate `/cancel-shoot` vs `/shoot-Cancel` to one route; restore or remove `RouteNames.changePassword`
- `lib/app/route_names.dart` — drop unused names, add `changePassword` if restoring (now that `lib/profile/change_password_screen.dart` exists)
- `lib/main_screen.dart` — wrap `_pages[_selectedIndex]` in `IndexedStack` (holding measure for tab state loss)
- `lib/shoots/shoots_screen.dart` (line 576) — update caller if route name changed

## Steps
- [x] Pick canonical cancel route (`/cancel-shoot` with `projectId`) and delete the other
- [x] Update all `pushNamed` call sites to use the canonical name
- [x] Restore `RouteNames.changePassword` pointing at `lib/profile/change_password_screen.dart` (new file landed since 2026-05-21)
- [x] Replace `body: _pages[_selectedIndex]` with `IndexedStack(index: _selectedIndex, children: _pages)`
- [x] Smoke each fix: cancel flow, change-password flow, switching tabs preserves scroll position

## Acceptance
- [x] Only one cancel-shoot route exists in `route_names.dart`
- [x] Edit Personal Details → Change Password no longer crashes
- [x] Switching tabs preserves scroll state on Home
- [x] `flutter analyze` clean

## Notes
`IndexedStack` is interim. Phase 4 Group F replaces with `StatefulShellRoute.indexedStack` from GoRouter (proper tab-aware nav).
