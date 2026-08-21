# Task 2.01 — Finish folder renames

**Phase:** 2 · **Status:** 🟢 Completed · **Est:** 4h

| Field | Value |
|---|---|
| Owner | Antigravity |
| Started | 2026-05-27 |
| Completed | 2026-05-27 |
| PR | — |
| Branch | `migration/phase2/folder-renames` |

## Goal
Finish the three remaining mixed-case folder renames and rename the file with a literal space, so the codebase compiles on a case-sensitive filesystem. `Home`, `Profile`, `Shoots` were already lowercased on 2026-05-27.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Hard Blockers #1, Risk #10
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §2 Folder Rules
- [`../audit/AUDIT_STRUCT.md`](../audit/AUDIT_STRUCT.md), [`../audit/NAVIGATION_AUDIT.md`](../audit/NAVIGATION_AUDIT.md) F-09

## Files in scope (max 10)
- `lib/onboding/` → `lib/onboarding/` (rename dir + file `onboding_screen.dart` → `onboarding_screen.dart`)
- `lib/manageavailability/` → `lib/manage_availability/`
- `lib/upcomingshootviewdetils/` → `lib/upcoming_shoot_view_details/` (rename dir + file)
- `lib/auth/view_details_screen .dart` → `lib/auth/view_details_screen.dart` (drop literal space)
- `lib/app/router.dart` — update imports
- `lib/main_screen.dart` — update imports
- any other import call sites surfaced by `flutter analyze`

## Steps
- [x] `git mv` each folder/file (preserves history)
- [x] Class rename inside files: `OnbodingScreen` → `OnboardingScreen`, `UpcomingShootViewDetils` → `UpcomingShootViewDetails`
- [x] Update all import paths across `lib/`
- [x] Update `RouteNames` constants if class names change
- [x] Run `flutter analyze` → fix any broken refs
- [x] Run `flutter run --flavor dev -t lib/main_dev.dart` → smoke test splash → onboarding flow

## Acceptance
- [x] `flutter analyze` zero new errors
- [x] `flutter build apk --flavor dev -t lib/main_dev.dart --debug` succeeds
- [x] `grep -r "onboding\|manageavailability\|upcomingshootviewdetils" lib/` returns nothing
- [x] App launches and reaches MainScreen

## Notes
Class typos `Onboding` and `Detils` are intentionally fixed here since the file rename forces touching them anyway. Keep the visible navigation flow unchanged — this is structural only.
