# Migration Plan — Legacy Index

> **2026-05-27 — Active sprint boards moved.** The actionable per-phase task chunks now live at `docs/phase1/` … `docs/phase6/`. This file is retained as a high-level reference; do not edit it as the source of truth.
>
> **Active entry points:**
> - [`/MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) — overall plan (repo root)
> - [`/MIGRATION_LOG.md`](../../MIGRATION_LOG.md) — decisions log
> - [`docs/phase2/README.md`](../phase2/README.md) … [`docs/phase6/README.md`](../phase6/README.md) — sprint boards
> - [`flavor_bundle_id_plan.md`](flavor_bundle_id_plan.md) — companion native-flavor plan (still under `docs/migration/`)
>
> Master index for the migration of `beige_creative_app` from screen-centric `StatefulWidget` + ad-hoc HTTP to Clean Architecture + Riverpod, per `MIGRATION_RULES.md` and the three guides in `docs/guides/`.

---

## Sources

| Document | Role |
|---|---|
| `MIGRATION_RULES.md` (repo root) | The rulebook. Non-negotiable rules. |
| `docs/guides/FLUTTER_BASE_GUIDELINES.md` | Architecture / Network / Firebase / Navigation / CI |
| `docs/guides/FLUTTER_DESIGN_SYSTEM.md` | Typography / Colors / Spacing / Radii / Shadows / Themes |
| `docs/guides/FLUTTER_TESTING_GUIDELINES.md` | Unit / Widget / Integration / Golden tests |
| `docs/audit/AUDIT_REPORT.md` + siblings | Frozen snapshot of current state (Phase 1 output) |
| `CLAUDE.md` (repo root) | Conventions for AI-assisted work in this repo |

---

## Phase Overview (links retargeted to new sprint boards)

| # | Sprint board | Goal | Status |
|---|---|---|---|
| 1 | [`docs/phase1/README.md`](../phase1/README.md) | Document current state | 🟢 Completed |
| 2 | [`docs/phase2/README.md`](../phase2/README.md) | Folder scaffold + casing fixes + security hotfixes + CI gate + secrets (9 tasks) | 🔴 Not Started |
| 3 | [`docs/phase3/README.md`](../phase3/README.md) | Design tokens, network layer (`DioClient`), router cleanup, `ProviderScope`, `SessionStore` (19 tasks) | 🔴 Not Started |
| 4 | [`docs/phase4/README.md`](../phase4/README.md) | Per-feature Clean-Arch + Riverpod migration (23 tasks) | 🔴 Not Started |
| 5 | [`docs/phase5/README.md`](../phase5/README.md) | Dead code removal, lint upgrade, dep pruning, naming consistency (8 tasks) | 🔴 Not Started |
| 6 | [`docs/phase6/README.md`](../phase6/README.md) | Tests + CI coverage gating (13 tasks) | 🔴 Not Started |

Strict order: never start phase `N+1` until phase `N` is committed and `flutter analyze` / `flutter build apk` / `flutter run` all pass (see `MIGRATION_RULES.md` §1.2 and §1.3).

---

## Status Legend (for all task tables in phase files)

| Status | Meaning |
|---|---|
| **Not started** | No work begun. |
| **Started** | Branch cut, exploratory edits, not yet committable. |
| **In progress** | Active edits with at least one commit on a working branch; not yet on `main`. |
| **Done** | Merged to `main`; `flutter analyze` clean; app boots; verified by stated acceptance criteria. |
| **Blocked** | Cannot proceed; add a `> Blocked by: …` note in the task row. |

Update the status cell of each task as work moves. Do **not** delete completed tasks — they are the migration audit trail.

---

## Working Rules (Recap of `MIGRATION_RULES.md` §1)

1. Migrate one feature at a time. One feature = one phase-4 file row.
2. Each task must produce a standalone commit that compiles and runs.
3. If a task names more than 8–10 files, split it. The plan already enforces the 5-file-per-commit guideline in §15.2 of `MIGRATION_RULES.md`.
4. Old code and new code coexist until the new code is verified.
5. Never modify `flavors/`, `lib/main_*.dart` flavor entrypoints, or `lib/config/env.dart` *signatures* unless the relevant phase says so. Adding to them is fine; renaming is not without explicit approval.
6. Branch naming: `migration/phase<N>/<short-task-slug>`. PR title: `refactor(<scope>): <short description>` per §13.

---

## Cross-Cutting Blockers (from Phase 1 audit)

These are documented in detail in `docs/audit/AUDIT_REPORT.md`. They are sequenced across Phase 2 and Phase 3 so that per-feature work in Phase 4 can begin safely:

1. Secure storage + log sanitization → **Phase 2** (security hotfix batch).
2. Folder + file casing normalization → **Phase 2** (casing batch).
3. CI gate (GitHub Actions) → **Phase 2** (CI batch).
4. Secrets out of source (`--dart-define-from-file`) → **Phase 2** (secrets batch).
5. `core/network/ApiClient` behind Riverpod provider → **Phase 3**.
6. `ProviderScope` wired at `runApp` → **Phase 3**.
7. `SessionStore` abstraction + stack-clearing logout → **Phase 3**.

---

## How to use this plan

- **Pick a phase file.** Read its prerequisites. Confirm the prior phase is `Done`.
- **Pick a task row.** Cut a branch named per the rule above.
- **Touch only the files listed in that row.** Each row caps file count to obey §1.1 and §15.2.
- **Update the status cell** as work progresses. Add a `**Notes**` line under the table if context changes mid-task.
- **Commit with the prescribed message format** (§13).
- **Run the §1.3 shippable check** before merging.

When a task fails the shippable check, do not stack new tasks on top — fix or revert before continuing.

---

## Out of scope for this plan

- Feature additions or behavior changes. Only structural moves and pattern changes.
- Backend/API changes.
- `flavors/` directory and native build wiring beyond what Phase 2 §secrets requires.
- Visual redesign. Phase 3 design-token extraction is structural, not a redesign — colors and styles must match current output.

---

## Feature inventory (Phase 4 candidates)

User picks order at execution time. Listed alphabetically for reference, not priority:

- `auth` (login, signup1–3, otp, forgot/reset password)
- `file_manager`
- `home` (Dashboard)
- `manageavailability`
- `messages`
- `onboding` → rename to `onboarding` in Phase 2
- `profile` (myprofile + nested screens)
- `shoots`
- `splash`
- `upcomingshootviewdetils` → rename to `upcoming_shoot_view_details` in Phase 2

Each gets one row in `phase4_features.md` with the full §14 checklist.
