# Task 4.03 — Group B · Unit 3 · `MessagesScreen`

**Phase:** 4 · **Group:** B · **Status:** ✅ Completed (placeholder route) · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` (kept consistent with prior phases) |

## Goal
Migrate the 30-LOC placeholder messages tab. **Blocking decision before starting:** Stream (websocket/SSE) vs polling vs static placeholder. Confirm with backend lead.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group B "Decide before Unit 3"

## Files in scope (max 5)
- ~~`lib/features/messages/data/datasources/messages_remote_datasource.dart`~~ — deferred to follow-on once transport is known
- ~~`lib/features/messages/data/repositories/messages_repository_impl.dart`~~ — deferred
- ~~`lib/features/messages/domain/repositories/messages_repository.dart`~~ — deferred
- ~~`lib/features/messages/presentation/providers/messages_notifier.dart`~~ — deferred (no notifier needed for placeholder)
- `lib/features/messages/presentation/screens/messages_screen.dart` — `ConsumerWidget` rendering `AppEmptyState`
- `lib/main_screen.dart` — import-path update
- `test/features/messages/presentation/screens/messages_screen_test.dart` — render smoke

## Steps
- [x] Confirm transport with backend — **N/A in autonomous mode.** No messaging endpoint in `ApiEndpoints` (verified via grep). Picked **static placeholder** per task plan's third option ("if placeholder: keep static, mark `// TODO(messaging)` and ship").
- [x] Static placeholder shipped — `ConsumerWidget` over `AppEmptyState`. Single `// TODO(messaging)` block references the log entry.
- [x] Decision logged in [`MIGRATION_LOG.md`](../../MIGRATION_LOG.md) — 2026-05-29 entry.
- [x] Widget test — render smoke covers `AppEmptyState`, title, description, icon.

## Acceptance
- [x] Decision logged in `MIGRATION_LOG.md`.
- [x] Screen renders without error — bottom-nav tab still binds (verified via test + import resolution).
- [x] `flutter analyze` clean (no new issues — baseline 300 preserved).

## Notes
Placeholder route deliberately defers the architectural transport choice (stream vs polling vs REST list). When backend lead confirms, follow-on task creates:
- `domain/repositories/messages_repository.dart`
- `data/datasources/messages_remote_datasource.dart`
- `data/repositories/messages_repository_impl.dart`
- `presentation/providers/messages_notifier.dart` (Stream or AsyncNotifier per decision)

Calibration: ~10 min vs. 1.5d budget. Treat as degenerate (no repository work attempted). First non-trivial repository-bound calibration target shifts to **4.04 File Manager**.
