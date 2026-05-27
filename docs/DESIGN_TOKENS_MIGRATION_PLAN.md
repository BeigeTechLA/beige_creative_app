# Design Tokens — Active Migration Plan

> **Status:** In progress - PR1 complete; PR2 typography/spacing pending (reviewed 2026-05-25)
> **Strategy:** Hybrid — mechanical sweep first (PR1), then per-folder manual (PR2)
> **Fidelity:** Strict literal-match. No rounding. Unscaled literals get a new token.
> **Verification:** `flutter analyze` only. No goldens, no manual screen-by-screen.
> **Companion:** `DESIGN_TOKENS_RULES.md` · `DESIGN_TOKENS_MIGRATION.md` · `DESIGN_IMPROVE_PHASE1.md`

---

## Starting snapshot (2026-05-23)

| Violation | Count | Notes |
|---|---|---|
| `Color(0xFF…)` outside `lib/app/` | 0 | Already migrated |
| `Colors.X` outside `lib/app/` | 0 | Already migrated |
| `ColorCode.*` references | 1 | Comment inside `lib/app/colors.dart`. False positive |
| Raw `'assets/…'` strings | 1 | Commented-out line in `lib/home/home_screen.dart:357`. Delete |
| Inline `BoxShadow(` | 14 | Across 10 files |
| `BorderRadius.circular(N)` | 340 | 21 distinct N values |
| Inline `TextStyle(` | 571 | Largest body of work |
| Raw `EdgeInsets.*(N)` | 334 | Second largest |

Files-with-TextStyle-or-EdgeInsets by folder (PR2 ordering):

| # | Folder | Files |
|---|---|---|
| 1 | `Profile/` | 16 |
| 2 | `auth/` | 8 |
| 3 | `widgets/` | 7 |
| 4 | `shoots/` | 4 |
| 5 | `file_manager/` | 4 |
| 6 | `manageavailability/` | 2 |
| 7 | `upcomingshootviewdetils/` | 1 |
| 8 | `onboding/` | 1 |
| 9 | `messages/` | 1 |
| 10 | `home/` | 1 |
| 11 | `main_screen.dart` | 1 |

---

## Current implementation review (2026-05-25)

| Area | Status | Current verification |
|---|---|---|
| `Color(0x...)` outside `lib/app/` | Done | 0 matches |
| `Colors.X` outside `lib/app/` | Done | 0 matches |
| `ColorCode.*` references in `lib/` | Done | 0 matches; `lib/utility/colorcode.dart` is gone |
| `main.dart` theme wiring | Done | `MaterialApp.router(theme: AppTheme.dark())` |
| PR1 radii tokens | Done | Required strict-match tokens exist in `lib/app/radii.dart` |
| `BorderRadius.circular(N)` outside `lib/app/` | Done | 0 matches |
| Inline `BoxShadow(` outside `lib/app/shadows.dart` | Done | 0 matches |
| Raw `'assets/...'` / `"assets/..."` strings outside `lib/app/assets.dart` | Done | 0 matches |
| Inline `TextStyle(` outside `lib/app/text_styles.dart` | Pending | 524 matches |
| Raw `EdgeInsets.*(N)` outside `lib/app/spacing.dart` | Pending | 308 matches |
| `Radius.circular(N)` inside `BorderRadius.only(...)` / `BorderRadius.vertical(...)` | Future/out of scope | 50 matches |

---

## PR1 — Mechanical sweep

> **Status:** Done. Steps 1.1, 1.2, 1.3, and 1.4 are complete.

One branch off `improvments-phase1`. Single PR. Steps:

### 1.1 Extend `lib/app/radii.dart`

> **Status:** Done. `noneAll`, `mldAll`, `headerAll`, `r2/r3/r5/r15/r26`, and their `*All` helpers exist.

Add convenience `BorderRadius` for existing raw doubles that lack `*All`:

```dart
static final BorderRadius noneAll   = BorderRadius.circular(none);    // 0
static final BorderRadius mldAll    = BorderRadius.circular(mld);     // 10
static final BorderRadius headerAll = BorderRadius.circular(header);  // 28
```

Add tokens for unscaled outliers (numerical names — obvious they are exceptions for future cleanup):

```dart
static const double r2  = 2;
static const double r3  = 3;
static const double r5  = 5;
static const double r15 = 15;
static const double r26 = 26;

static final BorderRadius r2All  = BorderRadius.circular(r2);
static final BorderRadius r3All  = BorderRadius.circular(r3);
static final BorderRadius r5All  = BorderRadius.circular(r5);
static final BorderRadius r15All = BorderRadius.circular(r15);
static final BorderRadius r26All = BorderRadius.circular(r26);
```

### 1.2 Replace `BorderRadius.circular(N)` across widget tree

> **Status:** Done. Current verification returns 0 `BorderRadius.circular(N)` matches outside `lib/app/`.

| N | Replacement | Count |
|---|---|---|
| 0 | `AppRadii.noneAll` | 1 |
| 2 | `AppRadii.r2All` | 1 |
| 3 | `AppRadii.r3All` | 1 |
| 4 | `AppRadii.xsAll` | 20 |
| 5 | `AppRadii.r5All` | 1 |
| 6 | `AppRadii.smAll` | 8 |
| 8 | `AppRadii.mdAll` | 2 |
| 10 | `AppRadii.mldAll` | 7 |
| 11.5 | `AppRadii.statsInnerAll` | 1 |
| 12 | `AppRadii.lgAll` | 98 |
| 14 | `AppRadii.xlAll` | 68 |
| 15 | `AppRadii.r15All` | 2 |
| 16 | `AppRadii.xxlAll` | 37 |
| 18 | `AppRadii.xxxlAll` | 14 |
| 20 | `AppRadii.hugeAll` | 43 |
| 22 | `AppRadii.portfolioCompactAll` | 8 |
| 24 | `AppRadii.massiveAll` | 11 |
| 25 | `AppRadii.portfolioAll` | 5 |
| 26 | `AppRadii.r26All` | 1 |
| 28 | `AppRadii.headerAll` | 1 |
| 30 | `AppRadii.roundAll` | 10 |

Add `import 'package:beige_creative_app/app/radii.dart';` to each touched file.

### 1.3 Replace 14 inline `BoxShadow`

> **Status:** Done. Current verification returns 0 inline `BoxShadow(` matches outside `lib/app/shadows.dart`.

Touched files:

- `lib/main_screen.dart`
- `lib/home/home_screen.dart`
- `lib/auth/resetpassword/reset_password_screen.dart`
- `lib/auth/sign_up/signup3_screen.dart`
- `lib/auth/sign_up/signup2_screen.dart`
- `lib/auth/sign_up/signup1_screen.dart`
- `lib/shoots/shoots_screen.dart`
- `lib/Profile/myprofile.dart`
- `lib/file_manager/view_details_screen.dart`
- `lib/file_manager/file_manager_screen.dart`

Per file: read existing `color`/`blurRadius`/`offset`/`spreadRadius`. Map to `AppShadows.sm | md | lg | xl`. If no existing token matches, add a new named entry to `lib/app/shadows.dart` (e.g. `bottomNav`, `goldGlow`).

### 1.4 Trivia

> **Status:** Done. Current verification returns 0 raw asset-string matches outside `lib/app/assets.dart`.

- Delete commented-out asset line `lib/home/home_screen.dart:357`.

### 1.5 Verify

```bash
flutter analyze
grep -rnE "BorderRadius\.circular\([0-9]" lib --include="*.dart" | grep -v "lib/app/" | wc -l   # expect 0
grep -rnE "BoxShadow\(" lib --include="*.dart" | grep -v "lib/app/" | wc -l                     # expect 0
grep -rnE "'assets/" lib --include="*.dart" | grep -v "lib/app/assets.dart" | wc -l             # expect 0
```

Commit message: `chore(tokens): mechanical sweep — radii, shadows, dead-asset cleanup`.

---

## PR2 — Per-folder manual (TextStyle + EdgeInsets)

> **Status:** Pending. Current verification still finds 524 `TextStyle(` matches and 308 raw `EdgeInsets.*(N)` matches outside token files.

Folder-by-folder, in the order listed above. Per folder:

1. Grep violations:
   ```bash
   grep -nE "TextStyle\(|EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]" lib/<folder>/**/*.dart
   ```
2. **TextStyle replacement.** Read each match's `fontFamily`/`fontSize`/`fontWeight`. Map to nearest `AppTextStyles.<name>`. If one-off color/decoration only → `AppTextStyles.bodyMedium.copyWith(...)`. If no existing style matches by fontSize+weight+family → **add a new token** to `lib/app/text_styles.dart` (no rounding).
3. **EdgeInsets replacement.** Map raw numbers to `AppSpacing.<token>`. Prefer prebuilt insets (`screenPadding`, `cardInsets`, `buttonPadding`, `authCardPadding`, `insetsHBase`, `insetsHXl`). If a raw value is missing from `AppSpacing` → **add token** to `lib/app/spacing.dart` (numerical name e.g. `s7 = 7` for outliers).
4. Add imports for `text_styles.dart` / `spacing.dart` per file as needed.
5. `flutter analyze` — must pass.
6. Commit per folder: `chore(tokens): migrate <folder>/ to AppTextStyles + AppSpacing`.

After all folders done, push branch + open PR2.

Final verify:
```bash
grep -rnE "TextStyle\(" lib --include="*.dart" | grep -v "lib/app/text_styles.dart" | wc -l                                       # 0
grep -rnE "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]" lib --include="*.dart" | grep -v "lib/app/spacing.dart" | wc -l # 0
```

---

## Out of scope (future tickets)

- `Radius.circular(N)` inside `BorderRadius.only(...)` — not in current grep.
- Inline `Duration(...)` — `AppDurations` exists; not yet in `DESIGN_TOKENS_RULES.md`.
- Wiring `MyApp.build` to `AppTheme.dark()` — done in the current implementation; `lib/main.dart` now uses `AppTheme.dark()`.
- Collapsing strict-match outlier tokens (`r2`, `r3`, `r5`, `r15`, `r26`, future `s7` etc.) onto the canonical scale once visual diff is reviewed.

---

## Risks / known gotchas

- Strict-match means token bloat. Outlier tokens are named numerically so they stand out for later cleanup.
- `flutter analyze` won't catch pixel drift from a mis-mapped `TextStyle`. Mitigation: pick tokens that exactly match `fontFamily`+`fontSize`+`fontWeight`; add new token rather than approximate.
- Each file likely needs new imports. Verify no unused-import warnings after.
- Some `BorderRadius.circular(N)` calls may live inside `BoxShadow`/`Radius.only` constructions that the regex catches by accident — verify per match.

---

## Changelog

| Date | Step | Notes |
|---|---|---|
| 2026-05-23 | Plan written | Hybrid strategy, strict-match, 2 PRs, `flutter analyze` only |
| 2026-05-25 | Implementation reviewed | Marked colors/theme/radii/shadows done; raw assets, typography, spacing remain pending |
| 2026-05-25 | Batches 0-3 executed | Raw assets, shared widgets, and auth core migrated; PR1 now complete |
