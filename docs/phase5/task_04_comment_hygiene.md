# Task 5.04 — Comment hygiene

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/comment-hygiene` |

## Goal
Strip ~60 block comments of dead code + 104 single-line dead lines + resolved `// TODO(migration)` markers (per `AUDIT_QUALITY.md`). After this task, `MIGRATION_RULES.md` §10 "no commented-out code" can be enforced via lint.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.C
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §10

## Files in scope (batched)
- All files with `// TODO(migration)` once the underlying TODO is resolved
- All multi-line `/* ... */` blocks containing dead code
- All single-line `//` lines that are commented-out code (not docs)

## Steps
- [ ] List candidates: `grep -rn "// TODO\|/\*" lib/ | sort | uniq -c | sort -rn`
- [ ] Per file: review + delete dead blocks; keep genuine docs (those explaining WHY)
- [ ] Batch commits ≤5 files per commit
- [ ] `flutter analyze` clean

## Acceptance
- [ ] No `/* … */` dead-code blocks remain
- [ ] All `// TODO(migration)` markers resolved or converted to `// TODO(<owner>): …`
- [ ] `flutter analyze` clean

## Notes
Keep comments that explain non-obvious WHY (per `MIGRATION_RULES.md` §10). Delete comments that re-state the code. Per CLAUDE.md "default to writing no comments."
