# Task 5.05 — Lint upgrade (`--fatal-infos`)

**Phase:** 5 · **Status:** 🟢 Completed (2026-05-31) · **Est:** 1d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Promote `flutter analyze` to `--fatal-infos` in CI. Baseline-of-record at task start was 14 info-level lints (down from the audit-era ~190 / post-5.04 80, reduced incidentally by Phase 4 + 5.01–5.04). After this task, no new warnings/infos can land.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.D

## Files in scope
- `.github/workflows/ci.yml` — `--fatal-infos` added to analyze step.
- `analysis_options.yaml` — lint-set provenance + CI policy documented.
- 8 source files producing infos (see below).

## Steps
- [x] Baseline: `flutter analyze` → 14 issues (9 `deprecated_member_use`, 3 `avoid_print`, 2 `use_build_context_synchronously`).
- [x] Fix per-rule:
  - `avoid_print` (3) — `lib/shared/widgets/common_file_viewer.dart`: `print` → `debugPrint`.
  - `use_build_context_synchronously` (2) — `common_file_viewer.dart` + `lib/utility/location_service.dart`: guard `ScaffoldMessenger.of(context)` with `context.mounted`.
  - `deprecated_member_use` (9):
    - `lib/features/profile/presentation/screens/featuredwork_details_screen.dart`: `WillPopScope` → `PopScope` (`canPop: false` + `onPopInvokedWithResult`).
    - `lib/features/profile/presentation/screens/app_preferences_screen.dart`: `Switch.activeColor` → `activeThumbColor`.
    - `lib/features/auth/presentation/widgets/signup1_form.dart`: `controller.setMapStyle(_darkMapStyle)` → `GoogleMap.style: _darkMapStyle` (call removed); `SvgPicture.asset(... color:)` → `colorFilter: ColorFilter.mode(...)`.
    - `lib/features/availability/presentation/screens/add_availability_screen.dart`: `ThemeData.dark().copyWith(useMaterial3: true, ...)` → `ThemeData.dark(useMaterial3: true).copyWith(...)`; `dialogBackgroundColor:` (×2) → `dialogTheme: DialogThemeData(backgroundColor: ...)`.
    - `lib/shared/widgets/custom_dropdown.dart` + `lib/shared/widgets/custom_dropdown_field.dart`: `DropdownButtonFormField.value` → `initialValue` + `key: ValueKey(value)` so parent-driven value changes still trigger replacement.
- [x] Added `--fatal-infos` to `.github/workflows/ci.yml` analyze step.
- [x] Documented locked lint set in `analysis_options.yaml` (base `flutter_lints/flutter.yaml`, pinned via `flutter_lints: ^6.0.0`).

## Acceptance
- [x] `flutter analyze --fatal-infos` exits 0 (verified locally — "No issues found").
- [x] CI fails any PR that introduces a new info/warning (workflow step updated).
- [x] `analysis_options.yaml` documents the chosen lint set + CI policy.

## Notes
- `DropdownButtonFormField` migration adds `key: ValueKey(value)` because `initialValue` is no longer controlled — without the key, parent-driven value changes (e.g. recurrence reset in `add_availability_screen`) would no longer reflect in the dropdown's visible selection.
- Two `// ignore: deprecated_member_use` comments remain (`add_availability_screen.dart:457` SVG color; another pre-existing one) — these were already gated with the ignore + WHY before this task and are out of scope here.
- If a lint is genuinely a false positive, suppress per-file with a comment + reason (`MIGRATION_RULES.md` §10 — non-obvious WHY).
