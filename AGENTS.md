# AGENTS.md

This is the Codex/agent entrypoint for the repo. It intentionally mirrors the
Claude Code entrypoint so both tools start from the same context.

## Read First

1. `docs/AI_HANDOFF.md`
2. `CLAUDE.md`
3. `docs/phase4/README.md`
4. The current `docs/phase4/task_*.md` file for the requested work
5. Latest relevant entries in `MIGRATION_LOG.md`
6. Current source files before editing

If any older doc conflicts with `docs/AI_HANDOFF.md`, the active phase task,
or current code, use the newer/current source and log the discrepancy when it
affects implementation.

## Current Defaults

- Active migration phase: Phase 4 feature migration.
- Phases 1-3 are closed.
- Use Riverpod/Clean Architecture for new migrated work.
- Do not introduce new screen-level `ApiService()` calls.
- Keep feature code under `lib/features/<feature>/`.
- Use named GoRouter routes and `state.extra` maps.
- Use app design tokens, not raw colors/assets/styles.
- Preserve existing working behavior unless the active task explicitly changes it.

## Handoff Discipline

At the end of any meaningful task:

- Update the relevant phase task status/checklist.
- Add a concise `MIGRATION_LOG.md` entry for decisions, deviations, files moved,
  verification, and remaining risks.
- Update `docs/AI_HANDOFF.md` if the active task, next task, architecture
  pattern, or cross-tool instruction changed.

