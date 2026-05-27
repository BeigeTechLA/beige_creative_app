# Task 4.14 — Group D · Unit 12 · Shoots tab + supporting screens

**Phase:** 4 · **Group:** D · **Status:** 🔴 Not Started · **Est:** 4d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupD-shoots` |

## Goal
Migrate `ShootsScreen` (1,032 LOC, Tab 1 root) + `ShootCancelledScreen` (368) + `ShootRequestAccepted` (82) + `ShootCancelledLottiesScreen` (79). **Debounce required:** `searchShoots` currently fires on every keystroke.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group D Unit 12; §4 Risk #8 (state leaks)
- [`../audit/AUDIT_PERF.md`](../audit/AUDIT_PERF.md) D4 (debounce)

## Files in scope (max 8)
- `lib/features/shoots/presentation/providers/shoots_notifier.dart` + `_state.dart`
- `lib/features/shoots/presentation/providers/shoot_cancel_notifier.dart` + `_state.dart`
- `lib/features/shoots/presentation/screens/shoots_screen.dart`
- `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart`
- `lib/features/shoots/presentation/screens/shoot_request_accepted_screen.dart`
- `lib/features/shoots/presentation/screens/shoot_cancelled_lotties_screen.dart`

## Steps
- [ ] AsyncNotifier with `search`, `filter`, `loadMore`
- [ ] 250ms debounce on search (`Timer` cancellation in Notifier)
- [ ] `CancelToken` + `ref.onDispose` on the list provider
- [ ] Cancel-shoot flow uses repo method from 4.13
- [ ] Widget tests for search debounce + cancel happy path

## Acceptance
- [ ] Typing in search fires at most 1 API call per 250ms
- [ ] Pagination works without duplicate items
- [ ] `flutter analyze` clean
- [ ] No `setState`

## Notes
Search debounce belongs in the Notifier (state-machine pattern), not the widget. Reference: `MIGRATION_RULES.md` §3.11 CancelToken example.
