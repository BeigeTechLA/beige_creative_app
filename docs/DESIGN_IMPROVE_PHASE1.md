
# Design Token Centralization — Phase 1 Plan

> **Goal:** Activate existing design-token scaffolding and route the live theme through it without touching widget code or changing the visual output.
>
> **Reference:** `docs/guides/FLUTTER_DESIGN_SYSTEM.md`
> **Scope:** Phase 1 = tokens + theme wiring only. Widget migration is Phase 2+.

---

## 1. Current State

### What exists
| File | State | Notes |
|------|-------|-------|
| `lib/app/colors.dart` (`AppColors`) | ✅ Present, comprehensive (~250 lines) | Only ~4 import sites |
| `lib/app/text_styles.dart` (`AppTextStyles`) | ✅ Present, Unbounded + Outfit configured | Largely unused |
| `lib/app/spacing.dart` (`AppSpacing`) | ✅ Present, full scale + component tokens | Largely unused |
| `lib/app/radii.dart` (`AppRadii`) | ✅ Present, full scale | Largely unused |
| `lib/app/shadows.dart` (`AppShadows`) | ✅ Present | Largely unused |
| `lib/app/theme.dart` (`AppTheme`) | ❌ **Entire file commented out** (`/* ... */`) | Not wired |
| `lib/app/app.dart` | ❌ Commented out | Riverpod scaffolding, not live |
| `lib/utility/colorcode.dart` (`ColorCode`) | ✅ Active, 1367 references across 48 files | De facto palette |
| `lib/app/assets.dart` (`AppAssets`/`AppImages`) | ✅ Active, 42 imports | Already centralised |

### Violation counts (from audit)
| Metric | Total | Top offenders |
|--------|-------|---------------|
| Inline `TextStyle()` | 571 | home_screen (70), signup3 (59), myprofile (48) |
| Magic colors (`Color(0xFF…)` / `Colors.<name>`) | 344 | add_availability (48), manage_availability (36), home_screen (21) |
| Magic `EdgeInsets` | 417 | signup3 (53), myprofile (48), home_screen (42) |
| Magic `BorderRadius.circular(N)` | 350 | signup3 (57), myprofile (43), home_screen (39) |
| Inline `fontFamily` strings | 343 | home_screen (35), myprofile (33), upcoming_shoot (31) |
| Inline `BoxShadow` | 14 | signup3 (3), file_manager (2) |
| `Theme.of(context)` reads | 2 | Effectively unused |

### Root cause
`lib/main.dart` defines `ThemeData` inline (lines 46–101) using `ColorCode.*` directly. The well-built token files in `lib/app/` are dead code. There is no bridge from `ColorCode` to `AppColors`, so the two systems coexist without convergence.

---

## 2. Decisions (Confirmed)

| Topic | Decision |
|-------|----------|
| Naming | Keep `ColorCode` symbols; bridge them to `AppColors`. Set up `AppTextStyles` for typography. |
| Fonts | Match current — `Unbounded` (display/title) + `Outfit` (body/label). |
| Theme | Build `AppTheme.dark()` to pixel-match current inline theme. Wire `main.dart` to use it. |
| Phase 1 scope | Tokens + theme wiring only. **Zero widget edits.** |

---

## 3. Plan

### Step 1 — Extend `AppColors` (additive only)

**Action:** Scan all `lib/` widgets for unique `Color(0xFF…)` literals that do not already exist in `AppColors` or `ColorCode`. Add them to `lib/app/colors.dart` with semantic names.

**Risk:** None. Adds constants; no behavioural change.

**Output:** Updated `lib/app/colors.dart` with full coverage of every distinct hex used in the codebase.

---

### Step 2 — Bridge `ColorCode` → `AppColors`

**Action:** Convert `ColorCode` field definitions from raw `Color(0xFF…)` to references to `AppColors.*`.

```dart
// Before
static const Color primary = Color(0xFFE8D1AB);

// After
static const Color primary = AppColors.primary;
```

- Where `ColorCode` has duplicates (e.g. `kButtonColor`, `kChampagneGold`, `primary` all `0xFFE8D1AB`), all alias `AppColors.primary`.
- Verify hex equivalence before bridging — compile-time check via `static const`.
- All 1367 existing `ColorCode.*` call sites continue to work unchanged.

**Risk:** Zero if hex values match. Mistakes are visible as colour shifts during smoke test.

**Output:** `ColorCode` becomes a thin alias layer over `AppColors`. New code uses `AppColors` directly.

---

### Step 3 — Restore `AppTheme.dark()`

**Action:** Uncomment `lib/app/theme.dart`. Fix stale references:

| Stale name | Correct name |
|-----------|-------------|
| `AppColors.backgroundColor` | `AppColors.background` |
| `AppColors.red` | `AppColors.error` |

**Scope match:** Current `main.dart` sets only ~6 theme fields (`scaffoldBackgroundColor`, `appBarTheme`, `colorScheme`, splash overrides, button splash overrides). The full `AppTheme.dark()` in the commented file sets ~20 fields (chip, dialog, snackbar, bottom sheet, switch, checkbox, radio, text theme, etc.).

**Decision for Phase 1:** Enable only the fields currently in `main.dart`. Comment-fence the rest for Phase 2. This guarantees pixel match.

```dart
// theme.dart — Phase 1 active block
static ThemeData dark() {
  return ThemeData(
    useMaterial3: true,                                  // verify current
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      iconTheme: IconThemeData(color: AppColors.white),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.transparent,
    ),
    colorScheme: const ColorScheme.dark(
      surface: AppColors.background,
      primary: AppColors.white,
    ),
    splashFactory: NoSplash.splashFactory,
    splashColor: AppColors.transparent,
    highlightColor: AppColors.transparent,
    hoverColor: AppColors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(splashFactory: NoSplash.splashFactory),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(splashFactory: NoSplash.splashFactory),
    ),
  );

  // PHASE 2: inputDecorationTheme, cardTheme, bottomNavigationBarTheme,
  // dialogTheme, bottomSheetTheme, dividerTheme, snackBarTheme,
  // chipTheme, switchTheme, checkboxTheme, radioTheme, textTheme
}
```

> ⚠️ Verify whether current inline `ThemeData` actually sets `useMaterial3: true`. Current `main.dart` does **not** set it explicitly — Flutter defaults to M3 in newer versions, but matching exactly avoids surprises.

**Risk:** Low. Single visual smoke test required after wiring.

---

### Step 4 — Switch `main.dart` to `AppTheme.dark()`

**Action:** Replace inline `theme: ThemeData(...)` block in `lib/main.dart` (lines 46–101) with:

```dart
theme: AppTheme.dark(),
```

Remove the now-unused `import '../utility/colorcode.dart';` if no other reference remains in `main.dart`.

**Verification:**
1. `flutter analyze` — zero new warnings.
2. `flutter run --flavor dev -t lib/main_dev.dart` — boot to splash → login → home.
3. Smoke-test top routes: splash, sign-in, dashboard, drawer, profile, file manager, messages, manage availability.
4. Side-by-side screenshot diff vs `improvments-phase1` baseline on the same screens.

**Risk:** Low. Single-file change. Trivially revertible.

---

### Step 5 — Lint guardrail (block new violations)

**Goal:** Prevent regression from new code while the existing 1,000+ violations are migrated incrementally in Phase 2.

**Options:**
- Add `analysis_options.yaml` rules where possible.
- Add `custom_lint` package + bespoke rules banning `TextStyle(`, `Color(0xFF`, `EdgeInsets.all(<literal>)`, `BorderRadius.circular(<literal>)` outside `lib/app/`.
- Cheaper alternative: PR-template checklist + `docs/DESIGN_TOKENS_RULES.md` enforcing convention manually.

**Recommended:** Start with the checklist; add `custom_lint` if violations creep back in.

**Risk:** None.

---

### Step 6 — Migration log

**Create:** `docs/DESIGN_TOKENS_MIGRATION.md` containing:
- `ColorCode` → `AppColors` mapping table.
- Raw-pixel → `AppSpacing` mapping.
- Raw-radius → `AppRadii` mapping.
- Inline `TextStyle` patterns → `AppTextStyles` choices.
- Hotspot file list for Phase 2 in priority order.

**Risk:** None.

---

## 4. What Stays Untouched in Phase 1

- Every widget file under `lib/Home/`, `lib/Shoots/`, `lib/Profile/`, `lib/auth/`, `lib/file_manager/`, `lib/messages/`, `lib/manageavailability/`, `lib/UpcomingShootViewdetils/`, `lib/widgets/`, `lib/onboding/`, `lib/splash/`, `lib/main_screen.dart`.
- `ColorCode` symbol names — only the right-hand side of each `static const` is changed.
- `AppAssets` registry (already correct).
- Behaviour. Theme output. Visuals.

---

## 5. Phase 2 Preview (After Phase 1 Lands)

1. Migrate hotspot trio (`signup3_screen`, `myprofile`, `home_screen`) — ~30 % of all violations.
2. Migrate remaining 45 violation files in priority order.
3. Enable the deferred `AppTheme.dark()` fields (chip, dialog, bottom sheet, snackbar, input decoration, text theme).
4. Remove `ColorCode` aliases as call sites migrate; eventually delete the file.
5. Phase 3+: dark/light mode toggle, tablet breakpoints, scale clamping.

---

## 6. Verification Gates

| Gate | Check |
|------|-------|
| Before each commit | `flutter analyze` — zero new warnings |
| After Step 2 | App still compiles. Boot to splash. |
| After Step 4 | Manual smoke test of 7 top routes. Screenshot diff. |
| Before merging Phase 1 | `flutter test` (where coverage exists) + side-by-side screenshot review |

---

## 7. Effort Estimate

| Step | Effort |
|------|--------|
| Step 1 — extend AppColors | 30 min |
| Step 2 — bridge ColorCode | 30 min |
| Step 3 — restore theme.dart | 45 min |
| Step 4 — wire main.dart | 15 min + smoke test |
| Step 5 — lint guardrail | 15 min |
| Step 6 — migration doc | 15 min |
| **Total Phase 1** | **~2.5 hrs** |

---

## 8. Open Questions

- `useMaterial3: true` in current theme — confirm Flutter default vs explicit.
- `custom_lint` vs PR checklist for guardrail — pick before Step 5.
- Should `lib/app/app.dart` (Riverpod root) be deleted or left commented for future use?

---

## Changelog

| Version | Date | Notes |
|---------|------|-------|
| 1.0 | 2026-05-23 | Initial Phase 1 plan |
