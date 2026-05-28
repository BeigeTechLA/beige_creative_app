# Task 3.16 — `pumpProviderApp` test helper

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 1h

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
- [x] Extension on `WidgetTester` at `test/helpers/pump_app.dart` — `pumpProviderApp(Widget, {List<Override> overrides, ThemeData? theme})`.
- [x] Wraps in `ProviderScope(overrides: ...) > MaterialApp(home: Directionality(...))`. `Directionality` belt-and-suspenders for leaf widgets that read `Directionality.of(context)`.
- [x] Smoke test at `test/helpers/pump_app_test.dart` — overrides `dioClientProvider` with `DioClient.withDio(Dio(BaseOptions(baseUrl: 'https://override.example/')))` and asserts the consumer reads the overridden baseUrl. Passing.

## Acceptance
- [x] `flutter test test/helpers/pump_app_test.dart` → 1/1 passing.
- [x] `flutter test` (full suite) → 14/14 passing.
- [x] Importable from any future test via `import 'package:.../test/helpers/pump_app.dart';` — extension method visible after import.

## Notes
Full `mocks.dart` + `test_data.dart` are Phase 6.01 — this task lands only the minimum needed to widget-test the splash + onboarding pilot.
