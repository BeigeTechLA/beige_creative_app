# Task 3.20 — Shared design-system widgets (`AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState`)

**Phase:** 3 · **Status:** 🔴 Not Started · **Est:** 6h

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
- [ ] Implement each widget per guide §6 templates; rewire to project token classes (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`)
- [ ] Use `Theme.of(context)` for surface/text colors (dark-mode safe per guide §7.2)
- [ ] One widget per file; widgets are `StatelessWidget` unless internal state required
- [ ] No callers migrated yet — Phase 4 features adopt incrementally
- [ ] Smoke widget tests (one per file) under `test/shared/widgets/` — render + tap callback

## Acceptance
- [ ] All six files compile and analyze clean
- [ ] Each smoke test passes
- [ ] No raw `Color(0xFF…)`, inline `TextStyle()`, or magic numbers anywhere in the files
- [ ] App still boots and renders pixel-identically (widgets exist but no caller yet)

## Notes
Build only the six listed. `AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog` from guide §6.7 are deferred — add incrementally as Phase 4 features need them. Do NOT pre-build the full checklist.

Token references must match Task 3.02–3.05 output. If a token is missing, add it to the relevant token file in the same PR — do not introduce a magic number to unblock.
