# Migration Log — Beige Creative App (Crew)

> Decisions, judgment calls, and deviations from `MIGRATION_PLAN.md` / `MIGRATION_RULES.md` are logged here during migration.
> Format: date (ISO), section header. Each entry lists **Changes**, **Decisions** (with rationale), and **Constraints Maintained** (what was preserved — e.g., zero visual drift, `flutter analyze` zero errors).
>
> See also: [`MIGRATION_PLAN.md`](MIGRATION_PLAN.md) · [`MIGRATION_RULES.md`](MIGRATION_RULES.md) · [`docs/migration/`](docs/migration/) (phase plans).

---

### 2026-05-27: Guides cross-check patch — shared widgets, font note, models/utils tests

- **Changes**:
  - Cross-checked `MIGRATION_PLAN.md` + per-phase tasks against `docs/guides/FLUTTER_BASE_GUIDELINES.md`, `FLUTTER_DESIGN_SYSTEM.md`, `FLUTTER_TESTING_GUIDELINES.md`.
  - **New Phase 3 Task 3.20** — `docs/phase3/task_20_shared_widgets.md`: build `AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState` in `lib/shared/widgets/`. 6h estimate. Phase 3 total 19 → 20 tasks, 8 → 8.75 effort-days.
  - **New Phase 6 Task 6.14** — `docs/phase6/task_14_models_utils_tests.md`: unit tests for freezed DTOs, validators, formatters, extensions. 1d estimate. Phase 6 total 13 → 14 tasks, 16 → 17 effort-days.
  - **Task 3.02 font note** — appended explicit guard against guide's `Inter` example; preserve `Unbounded` + `Outfit` per current `pubspec.yaml`.
  - `MIGRATION_PLAN.md` Phase 3 + Phase 6 budget rows updated; TOTAL 93.5 → 95.25 effort-days.

- **Decisions**:
  - **Shared widgets at end of Phase 3, not split across Phase 4** — every Phase 4 feature consumes them, so build once before features migrate. Avoids per-feature reinvention and keeps Phase 4 acceptance ("zero magic numbers") enforceable.
  - **Limited to 6 widgets, not full §6.7 checklist** — `AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog` deferred until a Phase 4 feature needs them. Guide explicitly recommends incremental construction.
  - **Font preservation made explicit** — guides use `Inter` in examples but project ships `Unbounded` + `Outfit`. Without the note, Task 3.02 could silently re-introduce `Inter` and break visual parity. Zero visual drift is non-negotiable per `MIGRATION_RULES.md`.
  - **Models/utils tests folded into Phase 6, not Phase 4** — keeps Phase 4 PRs focused on feature migration; defers cheap coverage wins to the dedicated test phase.
  - **Gaps NOT patched (already covered)** — `CancelToken` ban for search/pagination already in `MIGRATION_RULES.md` §5.2 line 535 and in Task 4.14 step list. Connectivity pre-check ban already in `MIGRATION_RULES.md` §5.2 line 533. Verified before adding.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - File numbering preserved; new files append at end of each phase folder (no renames).

---

### 2026-05-27: Sprint-board restructure (`docs/phase<N>/` per phase, task-level chunks)

- **Changes**:
  - Created `docs/phase1/` … `docs/phase6/` — one folder per phase.
  - Each phase has a `README.md` (sprint board: task table + acceptance + dependencies) and one task file per chunk (`task_NN_<slug>.md`).
  - Total chunks: 73 task files across 6 phases + 6 phase READMEs = 79 new files.
    - Phase 1: 0 task files (read-only post-audit) — README only.
    - Phase 2: 9 tasks (folder renames, security hotfixes, secrets, CI, scaffold).
    - Phase 3: 19 tasks (deps, design tokens, network stack, session store, ProviderScope, router redirect, Firebase wrappers).
    - Phase 4: 23 tasks (feature migration — one per migration unit; god widgets split into preceding `.a` decomposition tasks).
    - Phase 5: 8 tasks (shim deletion, dep prune, cached images, comment hygiene, lint upgrade, naming polish, router final).
    - Phase 6: 13 tasks (test helpers, repo + Notifier + widget tests, goldens, integration tests, CI coverage gate).
  - Deleted single-file phase plans: `docs/migration/phase1_audit.md` … `phase6_testing.md` (702 LOC total). Replaced by chunked task files.
  - Kept under `docs/migration/`: `README.md` (legacy index), `flavor_bundle_id_plan.md` (companion). Both retain root link to `MIGRATION_PLAN.md`.
  - Appendix in `MIGRATION_PLAN.md` updated to point at new sprint boards.
  - Task file template: status header (🔴 / 🟡 / 🟢 / ⏭️) · owner / dates / PR / branch table · goal · references · files-in-scope (max 5–10 per task) · steps · acceptance · notes.

- **Decisions**:
  - **Sprint-planning granularity** — each task ≤10 files = ≤1 PR. Mirrors `MIGRATION_RULES.md` §1.1 ("if a step touches more than 8–10 files, break it into smaller steps").
  - **God-widget split-then-migrate as separate tasks** — `.a` (decompose, zero behavior change) + `.b` (migrate). Tracked separately so the split can be reviewed without Notifier noise.
  - **Phase 4 = 23 tasks not 22 migration units** — `signup1`, `signup3`, `myprofile`, `home_screen`, `featured_work_list` each get a `.a` decomposition predecessor.
  - **Phase 6 = 13 tasks not 5–7** — repository / Notifier / widget tests split into manageable batches so each task is ≤1.5 effort-days.
  - **Status emoji per user preference** — 🔴 Not Started · 🟡 In Progress · 🟢 Completed. Same legend on every README + task file.
  - **Path scheme** — phase folders sit directly under `docs/` (not under `docs/migration/`). Rationale: contributors expect `docs/phaseN/` to be the actionable sprint board; `docs/migration/` is legacy + companion docs.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - Old single-file phase plans deleted only after the new chunked structure was fully populated.

---

### 2026-05-27: Plan refresh + relocation to repo root

- **Changes**:
  - Moved `docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` (repo root) to match the sibling `biegeapp` layout (`MIGRATION_PLAN.md` + `MIGRATION_RULES.md` + `MIGRATION_LOG.md` co-located at root).
  - Created this file (`MIGRATION_LOG.md`) at the root.
  - Verified current LOC / file counts against `lib/` and updated plan tables:
    - Top god widgets re-measured: `signup3_screen.dart` 3,465 → 3,569; `home_screen.dart` 2,902 → 2,860; `myprofile.dart` 2,834 → 2,836; `featured_work_list.dart` 1,703 → 1,685; `signup1_screen.dart` 1,959 → 1,836; `signup2_screen.dart` 1,328 → 1,331; `upcoming_shoot_view_detils.dart` 1,396 → 1,184.
    - Several screens shrank: `login.dart` 464 → 382; `reset_password_screen.dart` 428 → 332; `forgot_password_screen.dart` 401 → 362; `file_manager_screen.dart` 661 → 604; `pre_production_screen.dart` 502 → 434.
    - One screen grew: `edit_personal_details_screen.dart` 589 → 666.
    - Total Dart LOC across `lib/`: 34,162 across 87 files (was ~30k across 38 screens; codebase grew).
  - 3 new profile screens folded into Group C: `change_password_screen.dart` (274 LOC), `profile_otp_screen.dart` (343 LOC), `featuredwork_details_screen.dart` (177 LOC).
  - Foundations checklist row 7 (`AppTheme.dark()`) flipped ⚠️ → ✅ — wired at `lib/main.dart:45`.
  - Foundations checklist note: `flutter_secure_storage ^9.2.2` already declared in `pubspec.yaml`.
  - Risk register #10 (Linux CI casing) downgraded H/H → H/M — `Home`, `Profile`, `Shoots` already lowercased; only `onboding`, `manageavailability`, `upcomingshootviewdetils` and the file with a literal space remain.
  - Hard blocker #1 (folder casing) marked partially done; Hard blocker #2 (target packages) updated to acknowledge `flutter_secure_storage` already present.
  - Phase 2.A budget trimmed 1.5 → 1 day; Phase 2.B trimmed 1 → 0.75 day; Phase 3.A trimmed 1.5 → 1 day. Total ~94.75 → ~93.5 effort-days.
  - Appendix paths fixed (file now sits at root; relative links retargeted).
  - Back-references in `docs/migration/flavor_bundle_id_plan.md` updated (`docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` at repo root).

- **Decisions**:
  - **Plan at repo root, not under `docs/`** — matches `biegeapp` layout for cross-project muscle memory. CLAUDE.md states "all new .md files belong under `docs/`" with exceptions for `CLAUDE.md` and `README.md`. Adding `MIGRATION_PLAN.md` + `MIGRATION_LOG.md` to that exception set as the canonical migration-control docs, given they sit alongside `MIGRATION_RULES.md` (already at root). Reason: discoverability — a contributor opening the repo sees plan, rules, log together; the alternative buries plan two levels deep while rules sit at root.
  - **Refresh vs rewrite** — kept the 2026-05-21 analysis verbatim and applied targeted edits. The audit-driven judgment calls (pilot choice, group order, decomposition strategy) are still correct; only the underlying numbers moved.
  - **Drift in the wrong direction** (`ApiService()` 58 → 68, `setState` 266 → 291, `print/debugPrint` 242 → 283, `StatefulWidget` 41 → 44) noted but not treated as a blocker — the migration roadmap absorbs new screens via the same per-feature template; new screens just lengthen Group C by 0.5 day and Phase 5 cleanup by a few `print()` strips.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged (no lib/ touches).
  - No commits made; user controls when to stage and commit.

---
