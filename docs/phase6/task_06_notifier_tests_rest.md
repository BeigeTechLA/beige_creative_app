# Task 6.06 — Notifier tests: file_manager + availability + messages

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/notifier-rest` |

## Goal
Unit tests for remaining Notifiers in Groups B + the messaging stream/polling notifier.

## Files in scope (max 6)
- `test/features/file_manager/presentation/providers/file_manager_notifier_test.dart` (+ sub-screen notifiers)
- `test/features/availability/presentation/providers/availability_notifier_test.dart`
- `test/features/messages/presentation/providers/messages_notifier_test.dart`

## Steps
- [ ] Mirror prior Notifier-test patterns
- [ ] Messages: if Stream-based, use `StreamController` mock
- [ ] AAA + ≥3 cases per method

## Acceptance
- [ ] All test files pass
- [ ] Notifier coverage ≥ 80% on these features
- [ ] No real API calls

## Notes
By task end: every Notifier in the codebase has tests. Widget tests follow.
