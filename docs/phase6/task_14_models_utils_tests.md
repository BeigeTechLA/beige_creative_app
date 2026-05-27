# Task 6.14 — Unit tests for models + utilities + validators

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/models-utils-tests` |

## Goal
Cover pure-logic surfaces that repo + Notifier + widget tests don't reach: freezed model JSON round-trips, custom validators, date/string/number formatters, extension methods. Cheap coverage wins that lift the overall 70% line.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 6
- [`../guides/FLUTTER_TESTING_GUIDELINES.md`](../guides/FLUTTER_TESTING_GUIDELINES.md) §5.1 Model Test; §5.3 Validator / Utility Test
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9

## Files in scope (max 8)
- `test/features/<feature>/data/models/<model>_test.dart` — one per non-trivial freezed DTO (LoginResponse, ProfileResponse, ShootResponse, AvailabilityResponse)
- `test/core/utils/validators_test.dart` — email, phone, password strength, required-field
- `test/core/utils/date_formatters_test.dart` — date / time / duration formatters
- `test/core/extensions/<ext>_test.dart` — `String`, `DateTime`, `BuildContext` extensions

## Steps
- [ ] One model test per DTO: `fromJson` happy + `toJson` round-trip + null optional field + missing required field (throws)
- [ ] Validators: happy + empty + invalid format + edge case per validator
- [ ] Formatters: happy + null + locale edge case per formatter
- [ ] No mocks needed — all pure functions

## Acceptance
- [ ] `flutter test test/features test/core` passes
- [ ] Coverage delta surfaces models + utils + extensions at ≥ 80% line
- [ ] AAA pattern (Arrange → Act → Assert) in every test
- [ ] Three minimum cases per function (happy / edge / error)

## Notes
Skip trivial getters and `==`/`hashCode` — freezed generates those. Focus on `fromJson` factories (where API drift will break first) and any hand-rolled `copyWith` overrides.

This task pads coverage cheaply ahead of the 70% gate in Task 6.13. Run after batches 02–09 finish; sequence relative to 6.13 doesn't matter since both gate on the same lcov output.
