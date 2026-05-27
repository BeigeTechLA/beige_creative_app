# Task 2.09 — Folder skeleton

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 1h

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/folder-skeleton` |

## Goal
Create the empty target folder structure so Phase 3 can land foundations and Phase 4 can land features without re-thinking layout. No code moves in this task — pure scaffold.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations rows 25–27
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §2 Target Folder Structure

## Files in scope (dirs + `.gitkeep` only)
- `lib/core/network/exceptions/`, `lib/core/network/interceptors/`
- `lib/core/firebase/`
- `lib/core/providers/`
- `lib/core/utils/`, `lib/core/extensions/`
- `lib/core/session/` (for SessionStore — Phase 3)
- `lib/features/` (empty — feature subfolders land in Phase 4)
- `lib/shared/widgets/`, `lib/shared/layouts/`
- `lib/dummy/`

## Steps
- [ ] `mkdir -p` each directory
- [ ] Add `.gitkeep` to each leaf empty dir
- [ ] Verify `flutter analyze` still clean (no new files mean no analyzer change)
- [ ] Update `CLAUDE.md` "Folder layout" section to call out the new layout (existing layout doc shows legacy)

## Acceptance
- [ ] All directories above exist in the working tree
- [ ] Each empty dir contains a `.gitkeep`
- [ ] Build still succeeds (no source touched)

## Notes
Pure infra — should land in <1h. Phase 3 and Phase 4 fill these folders incrementally; nothing migrates in this task.
