# Task 3.16 — `pumpProviderApp` test helper

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 1h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/pump-helper` |

## Goal
Minimal helper that pumps a widget inside `ProviderScope` with override support, so Phase 4 widget tests can land starting with the pilot.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 21; §7 Phase 3.D
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.3

## Files in scope
- `test/helpers/pump_app.dart`

## Steps
- [ ] Extension on `WidgetTester` with `pumpProviderApp(Widget, {List<Override> overrides})`
- [ ] Wraps in `ProviderScope(overrides: ...) > MaterialApp(home: widget)`
- [ ] One smoke test demonstrating override of `dioClientProvider`

## Acceptance
- [ ] `flutter test test/helpers/pump_app.dart` (or the smoke test that uses it) passes
- [ ] Importable from any future test file

## Notes
Full `mocks.dart` + `test_data.dart` are Phase 6.01 — this task lands only the minimum needed to widget-test the splash + onboarding pilot.
