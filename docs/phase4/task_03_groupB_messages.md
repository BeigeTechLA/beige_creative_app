# Task 4.03 — Group B · Unit 3 · `MessagesScreen`

**Phase:** 4 · **Group:** B · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupB-messages` |

## Goal
Migrate the 30-LOC placeholder messages tab. **Blocking decision before starting:** Stream (websocket/SSE) vs polling vs static placeholder. Confirm with backend lead.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group B "Decide before Unit 3"

## Files in scope (max 5)
- `lib/features/messages/data/datasources/messages_remote_datasource.dart`
- `lib/features/messages/data/repositories/messages_repository_impl.dart`
- `lib/features/messages/domain/repositories/messages_repository.dart`
- `lib/features/messages/presentation/providers/messages_notifier.dart` (Stream or AsyncNotifier per decision)
- `lib/features/messages/presentation/screens/messages_screen.dart`

## Steps
- [ ] Confirm transport with backend
- [ ] If real-time: `StreamProvider<List<Message>>`; if polling: `AsyncNotifierProvider` + `Timer.periodic` (with `ref.onDispose` cancel); if placeholder: keep static, mark `// TODO(messaging)` and ship
- [ ] Document choice in [`MIGRATION_LOG.md`](../../MIGRATION_LOG.md)
- [ ] Widget test

## Acceptance
- [ ] Decision logged in `MIGRATION_LOG.md`
- [ ] Screen renders without error
- [ ] `flutter analyze` clean

## Notes
This unit smoke-tests the network stack on the smallest possible surface before the heavier Group B units land.
