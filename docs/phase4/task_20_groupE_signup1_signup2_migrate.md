# Task 4.20 — Group E · Unit 16.b · Migrate SignUp1 + SignUp2

**Phase:** 4 · **Group:** E · **Status:** 🔴 Not Started · **Est:** 3d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupE-signup1-signup2` |

## Goal
Migrate the post-split signup1 + the 1,331-LOC signup2 to Riverpod. signup2 carries 8 keys from signup1 via `state.extra` Map.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group E Unit 16

## Files in scope (max 8)
- `lib/features/auth/presentation/providers/signup_notifier.dart` + `_state.dart` (covers 1+2)
- `lib/features/auth/presentation/screens/signup1_screen.dart`
- `lib/features/auth/presentation/screens/signup2_screen.dart`
- All widgets from 4.19

## Steps
- [ ] Single Notifier accumulates form data across steps
- [ ] `state.extra` Map carries the in-progress submission
- [ ] Validation per step in Notifier
- [ ] Widget tests for happy path step1 → step2

## Acceptance
- [ ] `setState` removed
- [ ] No `TextEditingController` leaks
- [ ] Step 2 receives step-1 data and persists changes
- [ ] `flutter analyze` clean

## Notes
The shared Notifier strategy survives signup3 — Task 4.22 extends it rather than introducing a new one.
