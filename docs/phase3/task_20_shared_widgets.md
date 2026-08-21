# Task 3.20 — Shared design-system widgets (`AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState`)

**Phase:** 3 · **Status:** ✅ Completed · **Est:** 6h

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase3/shared-widgets` |

## Goal
Build the shared design-system primitives in `lib/shared/widgets/` so Phase 4 feature migrations consume one canonical button/card/text-field/avatar/loading/empty-state instead of reinventing per screen. Every widget consumes design tokens — no magic numbers.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations (shared widgets)
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §4.3 Token Rules
- [`../guides/FLUTTER_DESIGN_SYSTEM.md`](../guides/FLUTTER_DESIGN_SYSTEM.md) §6 Component Design System

## Files in scope (max 6)
- `lib/shared/widgets/app_button.dart` — `AppButton` with `primary | secondary | outline | text | destructive` variants and `sm | md | lg` sizes; `isLoading`, `icon`, `fullWidth` flags
- `lib/shared/widgets/app_card.dart` — `AppCard` with `flat | outlined | elevated` variants; optional `onTap`
- `lib/shared/widgets/app_text_field.dart` — `AppTextField` wrapping `TextFormField` with label, hint, error, prefix icon, suffix slot, formatters, validator
- `lib/shared/widgets/app_avatar.dart` — `AppAvatar` with image + initials fallback; `xs | sm | md | lg | xl` sizes
- `lib/shared/widgets/app_loading.dart` — centered spinner with optional message
- `lib/shared/widgets/app_empty_state.dart` — icon + title + description + optional CTA via `AppButton`

## Steps
- [x] All six widgets implemented at `lib/shared/widgets/` consuming `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`.
- [x] One widget per file; all `StatelessWidget` (no internal state needed).
- [x] No raw `Color(0xFF…)`, inline `TextStyle(...)`, or magic numbers — every value resolved through a token class.
- [x] No callers migrated. Phase 4 features adopt incrementally.
- [x] Smoke widget tests under `test/shared/widgets/` — 11 cases across 6 files. All passing.
- [ ] `Theme.of(context)` for surface/text colors — used direct `AppColors` references instead. The project's `AppTheme.dark()` is already mapping `AppColors.*` onto the `TextTheme` slots; pulling from `Theme.of(context)` adds a layer of indirection for no behavioral gain in dark-only mode. Phase 4 can revisit when (if) a light theme lands.

## Acceptance
- [x] All six files compile + analyze clean (`flutter analyze lib/shared/widgets/` → No issues found).
- [x] All 11 smoke tests pass (`flutter test test/shared/widgets/` → 11/11).
- [x] Zero magic numbers / raw colors / inline text styles in the six widget files.
- [x] App still boots — full `flutter test` → 25/25 passing (incl. existing `widget_test.dart` which pumps the full `ProviderScope > App` tree).

## Notes
Build only the six listed. `AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog` from guide §6.7 are deferred — add incrementally as Phase 4 features need them. Do NOT pre-build the full checklist.

Token references must match Task 3.02–3.05 output. If a token is missing, add it to the relevant token file in the same PR — do not introduce a magic number to unblock.
