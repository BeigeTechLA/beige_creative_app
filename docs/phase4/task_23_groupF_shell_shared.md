# Task 4.23 — Group F · Unit 18 · Shell rewrite + shared widgets

**Phase:** 4 · **Group:** F · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupF-shell` |

## Goal
Replace the legacy `Mainscreen` shell with `StatefulShellRoute.indexedStack`. Remove persistent `BackdropFilter` (`AUDIT_PERF.md` D-1 — 4–6ms/frame). Move shared widgets from `lib/widgets/` → `lib/shared/widgets/`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group F; §4 Risks #16, #17; §5 Architectural Decision #2
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §6.1

## Files in scope (max 10)
- `lib/app/router.dart` — `StatefulShellRoute.indexedStack` for the 4 bottom tabs
- `lib/shared/layouts/app_shell.dart` — replaces `Mainscreen`
- `lib/main_screen.dart` — deleted
- `lib/shared/widgets/` — `topmessage.dart`, `app_loader.dart`, `common_calendar.dart`, `file_viewer.dart`, `image_picker.dart`, `text_field.dart`, `dropdown.dart`, `multi_select_field.dart`, `loader.dart` etc.
- `lib/widgets/` — deleted

## Steps
- [ ] Convert each tab body to a `StatefulShellRoute` branch
- [ ] Surface the drawer-only "Manage Availability" item in a discoverable way (or accept current pattern + log a follow-up)
- [ ] Remove `BackdropFilter(sigmaX: 80, sigmaY: 70)`
- [ ] `git mv` each widget into `lib/shared/widgets/` with `snake_case` filenames
- [ ] Update every import call site
- [ ] Widget test for tab-switching state preservation

## Acceptance
- [ ] Tab state preserved across switches (scroll position, form drafts)
- [ ] `flutter analyze` clean
- [ ] `BackdropFilter` removed; frame budget improves (verify in Flutter DevTools)
- [ ] All shared widgets live under `lib/shared/widgets/`
- [ ] `lib/widgets/` and `lib/main_screen.dart` deleted

## Notes
End of Phase 4. After this, Phase 5 cleanup can begin.
