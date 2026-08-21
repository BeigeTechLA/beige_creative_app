# Design Tokens — Completion Plan

> **Status:** Phases A, B, D, E executed (2026-05-26). Phase C deferred by
> request. Phase F closing-out underway. See [Final state](#final-state) at
> the bottom for actual deliverables.
> **Created:** 2026-05-26
> **Companion:** `DESIGN_TOKENS_BATCH_EXECUTION_PLAN.md` (superseded),
> `DESIGN_TOKENS_MIGRATION.md`, `DESIGN_TOKENS_RULES.md`
> **Scope:** Finish the unfinished migration, add enforcement, extend coverage, clean the tokens themselves, then unlock the deferred ThemeData fields. **Light mode is explicitly out of scope** — app stays dark-only per `CLAUDE.md`.

---

## Baseline (measured 2026-05-26)

Already done — these gates stay at 0 and are protected by Phase A.1 lint rules:

| Category | Count outside `lib/app/` |
|---|---:|
| `Color(0xFF…)` literal | 0 |
| `Colors.<name>` | 0 |
| `ColorCode.*` | 0 |
| `BoxShadow(…)` inline | 0 |
| `'assets/…'` strings | 0 |
| `BorderRadius.circular(N)` literal | 0 |

Still pending — this plan drives these to 0:

| Category | Count | Hotspots |
|---|---:|---|
| Inline `TextStyle(` | 138 | `home_screen.dart` 65, `featured_work_list.dart` 17, `signup3_screen.dart` 10, `manage_availability_screen.dart` 8 |
| Raw `EdgeInsets.*(N)` | 82 | `home_screen.dart` 31, `featured_work_list.dart` 11, `manage_availability_screen.dart` 8 |
| Hardcoded `fontFamily: "Outfit"/"Unbounded"` | 63 | mirrors `TextStyle(` hotspots |
| `Radius.circular(N)` inside `BorderRadius.only/vertical` | 37 | home, upcomingshoot, signup3 |
| `withOpacity(…)` (deprecated) | 72 | home heavy |
| Raw `Duration(milliseconds: N)` | 46 | home, animations |
| Raw `SizedBox(width/height: N)` | 481 | repo-wide |
| Inline icon `size: N` literals | dozens | `SvgPicture.asset`, `Icon` |

---

## Execution principles

1. Preserve visuals. Exact-match tokens only. No rounding font sizes, weights, spacing, durations.
2. One phase ships per PR. Each phase has its own exit gate.
3. `flutter analyze` clean after every phase. `flutter test` only when phase touches behavior.
4. Each PR runs the grep gates from `DESIGN_TOKENS_RULES.md` before merge.
5. New tokens added only when an exact value is not already present.
6. Outlier tokens added to the relevant `lib/app/*.dart` file are flagged for Phase D collapse.

---

## Phase A — Stop the bleed (Week 1, ~2 days)

Cheap wins. No visual diff risk. Locks down regressions while later phases run.

### A.1 — Wire `custom_lint` enforcement

**Files:**
- `pubspec.yaml`
- `analysis_options.yaml`
- New: `lib/app/lints/` (custom lint rules) **or** a project-level `analysis_options.yaml` with strict regex matchers via existing analyzer.

**Tasks:**
- Add `custom_lint` + `dart_code_metrics` (or hand-rolled `custom_lint` plugin) as `dev_dependencies`.
- Implement (or import) lint rules that match the grep gates in `DESIGN_TOKENS_RULES.md`:
  - `no-raw-color-literal` — `Color(0x…)` outside `lib/app/`
  - `no-material-colors` — `Colors.<name>` outside `lib/app/`
  - `no-inline-text-style` — `TextStyle(...)` outside `lib/app/text_styles.dart`
  - `no-raw-edge-insets` — `EdgeInsets.*(N)` with numeric literals outside `lib/app/spacing.dart`
  - `no-raw-radius` — `BorderRadius.circular(N)` / `Radius.circular(N)` with literals outside `lib/app/radii.dart`
  - `no-inline-box-shadow`
  - `no-raw-asset-string`
  - `no-raw-font-family`
  - `no-with-opacity` — flag deprecated `withOpacity`; suggest `withValues(alpha:)` or pre-baked token.
- CI: fail PR on any lint hit.

**Exit gate:**
- `flutter analyze` exits non-zero on a synthetic violation.
- Existing repo still passes (because earlier batches already cleared the locked categories).

**Risk:** Low. Additive.

### A.2 — Delete `ColorCode` legacy shim

**Files:**
- `lib/app/colors.dart` — the `class ColorCode` declaration after `AppColors`.

**Tasks:**
- Verify `grep -rn "ColorCode" lib --include="*.dart"` returns 0 matches outside `colors.dart`. Already true at baseline — re-verify in PR.
- Delete the `ColorCode` class.
- Drop the bullet "No new constants to `ColorCode`" from `DESIGN_TOKENS_RULES.md` (rule becomes irrelevant when the class is gone).

**Exit gate:**
- `flutter analyze` clean.
- `rg "ColorCode" lib` returns 0.

**Risk:** None.

### A.3 — `withOpacity` → `withValues(alpha:)` sweep

**Scope:** 72 call sites, all currently `AppColors.X.withOpacity(N)`.

**Tasks:**
- Repo-wide replace: `withOpacity\((0\.\d+)\)` → `withValues(alpha: $1)`.
- When the same color+alpha pair appears 3+ times, promote to a named `AppColors.*` constant (e.g. `AppColors.white08`, `AppColors.black60`) and replace inline.
- After the sweep, the `no-with-opacity` lint from A.1 becomes a hard error.

**Exit gate:**
```bash
rg -n "withOpacity\(" lib -g "*.dart" -g "!lib/app/"
```
0 matches.

**Risk:** Low. `withValues(alpha:)` returns same color value as `withOpacity` for the same input.

---

## Phase B — Finish the migration (Week 1–2, ~3–4 days)

Real completion of batches that the plan claims were Done.

### B.1 — Re-tokenize `lib/home/home_screen.dart`

**Outstanding:** 65 `TextStyle(`, 31 `EdgeInsets.*(N)`, ~40 `fontFamily:` strings.

**Tasks:**
- Migrate every inline `TextStyle(` to `AppTextStyles.<name>` (use `copyWith` for one-off `color:` overrides).
- Migrate every raw `EdgeInsets.*(N)` to `AppSpacing` tokens / convenience insets.
- Migrate `Radius.circular(N)` inside `BorderRadius.only/vertical` to the partial-corner helpers added in B.3.
- Delete dead commented-out widget code while passing through. Do not refactor live layout.

**Exit gate:**
```bash
rg -n "TextStyle\(" lib/home -g "*.dart"
rg -n "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]" lib/home -g "*.dart"
rg -n "fontFamily:\s*['\"]" lib/home -g "*.dart"
```
0 matches each.

**Risk:** High. `home_screen.dart` is 2700+ lines and is the first post-login screen. Screenshot diff before/after on dev flavor required.

### B.2 — Re-tokenize remaining hotspot screens

**Files:**
- `lib/profile/featured_work_list.dart` (17 + 11)
- `lib/profile/myprofile.dart` (7 + 4)
- `lib/manageavailability/manage_availability_screen.dart` (8 + 8)
- `lib/manageavailability/add_availability_screen.dart` (4 + 4)
- `lib/auth/sign_up/signup1_screen.dart` (8)
- `lib/auth/sign_up/signup2_screen.dart` (5)
- `lib/auth/sign_up/signup3_screen.dart` (10 + 6)
- `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` (4 + 3)
- `lib/profile/resume_screen.dart` (3)
- `lib/profile/certificates.dart` (3)
- `lib/profile/profiledetils/enter_profile_details_screen.dart` (2)
- `lib/onboding/onboding_screen.dart` (1 + 2)
- `lib/file_manager/view_details_screen.dart` (3)
- `lib/file_manager/file_manager_screen.dart` (3)
- Other files with single-digit hits (per Phase A.1 lint output).

**Tasks:** Same playbook as B.1.

**Commit strategy:** One commit per feature folder (`profile/`, `manageavailability/`, `auth/sign_up/`, `file_manager/`, `upcomingshootviewdetils/`, `onboding/`) to keep PRs reviewable.

**Exit gate:**
```bash
rg -n "TextStyle\(" lib -g "*.dart" -g "!lib/app/text_styles.dart"
rg -n "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]" lib -g "*.dart" -g "!lib/app/spacing.dart"
rg -n "fontFamily:\s*['\"]" lib -g "*.dart" -g "!lib/app/"
```
0 matches each.

**Risk:** Medium. Spread of changes is large. Each PR independent.

### B.3 — Partial-corner radius helpers

**Files:** `lib/app/radii.dart` + B.1/B.2 consumers.

**Tasks:**
- Audit remaining `BorderRadius.only/vertical` sites (37 today). Group by corner profile.
- Add named helpers for the recurring combinations. Examples expected:
  - `topLg`, `topXxl`, `topMassive22`, `topMassive24`, `topRound30`
  - `bottomPillSm` already exists — extend with what audit finds.
- B.1 and B.2 consume them.

**Exit gate:**
```bash
rg -n "Radius\.circular\([0-9]" lib -g "*.dart" -g "!lib/app/"
```
0 matches.

**Risk:** Low.

---

## Phase C — Extend coverage (Week 2–3, ~3 days)

New token categories already declared but unused at scale.

### C.1 — `SizedBox` literal sweep

**Scope:** 481 sites of raw `SizedBox(width: N)` / `SizedBox(height: N)`.

**Tasks:**
- Map every height/width value to an existing `AppSpacing.vertical*` / `gapH*` convenience box. Add new ones for unmatched outlier values (note for Phase D).
- Replace inline `SizedBox(height: 16)` → `AppSpacing.verticalBase`, etc.
- Add lint `no-raw-sized-box-literal` to A.1.

**Exit gate:**
```bash
rg -n "SizedBox\(\s*(width|height):\s*[0-9]" lib -g "*.dart" -g "!lib/app/"
```
0 matches.

**Risk:** Low. Mechanical replacement.

### C.2 — `Duration` literal sweep

**Scope:** 46 sites of raw `Duration(milliseconds: N)` / `Duration(seconds: N)`.

**Tasks:**
- Map each value to an `AppDurations.<name>`. Add new tokens for outliers and note them for Phase D.
- Replace at call sites.
- Add lint `no-raw-duration` to A.1.

**Exit gate:**
```bash
rg -n "Duration\((milliseconds|seconds):\s*[0-9]" lib -g "*.dart" -g "!lib/app/"
```
0 matches.

**Risk:** Low.

### C.3 — Icon size tokens

**Files:** New `lib/app/icon_sizes.dart`.

**Tasks:**
- Create `AppIconSizes` with the standard ramp the codebase uses today (audit `SvgPicture.asset width:` and `Icon size:` literals; common values look like 16, 18, 20, 22, 24, 28).
- Replace inline `width: 22` / `size: 24` on icons across the repo.
- Add lint `no-raw-icon-size` to A.1.

**Exit gate:**
```bash
rg -n "(Icon|SvgPicture\.asset)[^;]*size:\s*[0-9]" lib -g "*.dart"
rg -n "SvgPicture\.asset[^;]*width:\s*[0-9]" lib -g "*.dart"
```
0 matches outside `lib/app/`.

**Risk:** Low.

---

## Phase D — Token quality (Week 3, ~2 days)

Tokens themselves need cleanup. Outliers were strict-match imports during Phase 1/2; now we collapse them.

### D.1 — Numeric outlier collapse

**Targets in `lib/app/spacing.dart`:**
- `s3`, `s5`, `s15`, `s22`, `s25`, `s50`, `authCardCompactTop`, `dropdownIconInset`

**Targets in `lib/app/radii.dart`:**
- `r2`, `r3`, `r5`, `r15`, `r26`

**Tasks:**
- For each token, list every call site (post-Phase B these are stable).
- Decide one of:
  - **Rename** to a semantic name (e.g. `s22` → `folderCardInsetH` — already documented inline; rename and remove the numeric alias).
  - **Snap** to the nearest canonical scale value if visual diff is acceptable (requires UX sign-off).
  - **Keep** if truly one-off but useful — rename to a semantic name regardless.
- Update consumers.

**Exit gate:**
- 0 numeric-named tokens (`s\d+`, `r\d+`) remain in `lib/app/spacing.dart` / `lib/app/radii.dart`.

**Risk:** Low if rename-only. Medium if snap.

### D.2 — Normalize `system*` text styles

**Targets in `lib/app/text_styles.dart`:**
- `systemDefault`, `system13`, `system14`, `system14Strong`, `system15Medium`, `system15Strong`, `system16Medium`, `systemSemiBold`, `system13Tight`, `system15Bold`, `system16Strong`, `system18Strong`, `system19Bold`, `system20Bold`

These were strict-match imports of `TextStyle(fontSize: N)` widget code that omitted `fontFamily`. Almost certainly intended as `Outfit`.

**Tasks:**
- For each token, find every call site.
- Compare rendered output with `Outfit` vs without on dev flavor.
- If identical-enough (most likely true on iOS; Android system font may differ subtly), set `fontFamily: fontFamilyBody` and **rename the token** to its body-scale equivalent (e.g. `system14` → folded into `body14`).
- If divergent, keep but rename to `bodyNoFamily14` etc. so the absence is intentional.

**Exit gate:**
- 0 tokens prefixed `system` remain.

**Risk:** Medium. Visual diff required on a real device.

### D.3 — `AppShadows` getter → const

**Targets:** `sm`, `md`, `lg`, `xl`, `activeNavGlow`, `ctaDark`, `heroOverlay`, `goldCta`, `card`, `cardSubtle`. All getters that alloc per call.

**Tasks:**
- Replace `withValues(alpha:)` with pre-baked `AppColors.*` opacity constants (most already exist: `black12`, `black10`, `white15`, etc.).
- Convert getters to `static const List<BoxShadow>`.
- `cardBlack12`, `cardHeavy`, `viewerSheet` already const — model the rest on these.

**Exit gate:**
- `grep "get " lib/app/shadows.dart` returns 0 matches.
- `flutter analyze` clean.

**Risk:** Low. Same visual output (opacity values pre-baked into `AppColors.*` constants).

---

## Phase E — Theme expansion (Week 3–4, ~5 days)

Move per-widget styling into `ThemeData` so individual widgets stop redeclaring the same thing. Each subphase is one PR with a screenshot diff.

### E.1 — `inputDecorationTheme`

**Files:** `lib/app/theme.dart`, every screen that builds `TextField` / `TextFormField` decorations.

**Tasks:**
- Define `inputDecorationTheme` with the actual border/radius/color/text-style values used by `lib/widgets/custom_text_field.dart` and `new_Textfield.dart`.
- Drop per-widget repetition of those properties.
- Verify shared widgets still render identically.

**Exit gate:**
- Login + signup + profile-edit screens visually identical pre/post.

**Risk:** Medium-high. Input styling is everywhere.

### E.2 — `textTheme`

**Tasks:**
- Map `AppTextStyles` to Material `TextTheme` slots (`bodyLarge` → `bodyLarge`, etc.).
- Set `Theme.of(context).textTheme` so screens can inherit without naming a token.
- Audit: don't remove explicit token references in widgets — just enable inheritance for new code.

**Exit gate:** `flutter analyze` clean. Spot-check 3 screens.

**Risk:** Low (additive).

### E.3 — `cardTheme`, `bottomSheetTheme`, `dialogTheme`, `chipTheme`, `dividerTheme`

**Tasks:** Same playbook per theme field. One PR each. Screenshot diff each.

**Exit gate per PR:** Visual diff clean on representative screen.

**Risk:** Medium. Roll forward one field at a time so a regression is bisectable to one PR.

---

## Phase F — Final sweep & docs (Week 4, ~1 day)

### F.1 — Repo-wide grep gates

All gates in `DESIGN_TOKENS_RULES.md` return 0. Lint clean.

```bash
rg -n "TextStyle\(" lib -g "*.dart" -g "!lib/app/text_styles.dart"
rg -n "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]" lib -g "*.dart" -g "!lib/app/spacing.dart"
rg -n "BorderRadius\.circular\([0-9]" lib -g "*.dart" -g "!lib/app/radii.dart"
rg -n "Radius\.circular\([0-9]" lib -g "*.dart" -g "!lib/app/"
rg -n "Color\(0x[0-9a-fA-F]{8}\)" lib -g "*.dart" -g "!lib/app/"
rg -n "fontFamily:\s*['\"]" lib -g "*.dart" -g "!lib/app/"
rg -n "BoxShadow\(" lib -g "*.dart" -g "!lib/app/shadows.dart"
rg -n "['\"]assets/" lib -g "*.dart" -g "!lib/app/assets.dart"
rg -n "withOpacity\(" lib -g "*.dart" -g "!lib/app/"
rg -n "Duration\((milliseconds|seconds):\s*[0-9]" lib -g "*.dart" -g "!lib/app/"
rg -n "SizedBox\(\s*(width|height):\s*[0-9]" lib -g "*.dart" -g "!lib/app/"
rg -n "ColorCode" lib -g "*.dart"
```

### F.2 — Documentation

- Mark `DESIGN_TOKENS_BATCH_EXECUTION_PLAN.md` as superseded.
- Update `DESIGN_TOKENS_RULES.md`:
  - Drop the `ColorCode` rule.
  - Add `SizedBox` / `Duration` / icon size / `withOpacity` rules.
  - Promote the "Future: automated enforcement" section to "Active enforcement" once A.1 lands.
- Write a one-page `DESIGN_TOKENS_COMPLETE.md` note: "All gates green as of <date>. Source of truth: `lib/app/`."

---

## Recommended commit order

| # | Phase | Subject |
|---|---|---|
| 1 | A.1 | `chore(tokens): add custom_lint rules enforcing token gates` |
| 2 | A.2 | `chore(tokens): delete ColorCode legacy shim` |
| 3 | A.3 | `chore(tokens): replace withOpacity with withValues / pre-baked tokens` |
| 4 | B.3 | `chore(tokens): add partial-corner BorderRadius helpers to AppRadii` |
| 5 | B.1 | `chore(tokens): finish home_screen.dart text/spacing/font migration` |
| 6 | B.2 | `chore(tokens): finish remaining feature screens (one commit per folder)` |
| 7 | C.1 | `chore(tokens): replace raw SizedBox(width/height) with AppSpacing gaps` |
| 8 | C.2 | `chore(tokens): replace raw Duration literals with AppDurations` |
| 9 | C.3 | `chore(tokens): add AppIconSizes + sweep raw icon size literals` |
| 10 | D.1 | `chore(tokens): collapse numeric outlier tokens (sN, rN) into semantic names` |
| 11 | D.2 | `chore(tokens): normalize systemN text styles onto fontFamilyBody` |
| 12 | D.3 | `chore(tokens): convert AppShadows getters to const using pre-baked colors` |
| 13 | E.1 | `feat(tokens): enable inputDecorationTheme; remove per-widget input styling` |
| 14 | E.2 | `feat(tokens): enable textTheme mapping AppTextStyles to Material slots` |
| 15 | E.3 | `feat(tokens): enable cardTheme / bottomSheetTheme / dialogTheme` |
| 16 | E.3 | `feat(tokens): enable chipTheme / dividerTheme` |
| 17 | F.2 | `docs(tokens): mark design-token migration complete; update rules + supersede plans` |

---

## Effort & risk summary

| Phase | Effort | Risk | Visual diff required |
|---|---:|---|---|
| A — Stop the bleed | 2 days | Low | No |
| B — Finish migration | 3–4 days | High (home), Medium (rest) | Yes — per screen |
| C — Extend coverage | 3 days | Low | No |
| D — Token quality | 2 days | Low–Medium (D.2) | Yes — D.2 only |
| E — Theme expansion | 5 days | Medium | Yes — per subphase |
| F — Final sweep | 1 day | None | No |
| **Total** | **~16 working days** | — | — |

---

## What this plan does NOT do

- **Light mode.** Out of scope per current product direction. Defer the `AppColors` semantic-role restructure until a light theme is actually required.
- **Material 3 enable** (`useMaterial3: true`). Touches every component visually; needs a separate scoped effort.
- **`flutter_riverpod` wiring.** Tokens are pure constants — no DI needed.

---

## Final state

Executed 2026-05-26 across 11 commits on `improvments-phase1`. Phase C was
explicitly deferred mid-execution at the user's request. Phase E was scoped
down to textTheme + dividerTheme.

### What shipped

| Phase | Status | Commit |
|---|---|---|
| A.2 — drop ColorCode references | shipped | `9f0f9e6` |
| A.3 — `withOpacity` → `withValues` (72 sites) | shipped | `e1ae373` |
| A.1 — `tool/check_design_tokens.sh` + plan doc | shipped | `2764fa5` |
| B.3 — partial-corner BorderRadius helpers + 35 callers | shipped | `75d623e` |
| B.1 — `home_screen.dart` full migration + dead `_meetingCard` removed | shipped | `7a7516e` |
| B.2 — remaining feature screens (10 sites across 6 files) | shipped | `0eda8e7` |
| C.1 / C.2 / C.3 — SizedBox / Duration / Icon size sweeps | **deferred** | — |
| D.1 — numeric outlier tokens renamed (13 spacing + 5 radii) | shipped | `dd28394` |
| D.2 — `system*` → `inherit*` text styles (88 sites) | shipped | `689d6ac` |
| D.3 — `AppShadows` getters → const (10 lists + 7 new AppColors alphas) | shipped | `2607106` |
| E — textTheme + dividerTheme (scoped subset) | shipped | `6731700` |
| F — gate verification + doc closeout | this commit | — |

### Final gate state

Locked categories (all 0 ✓):

| Gate | Count |
|---|---:|
| `no-raw-color-literal` | 0 |
| `no-material-colors` | 0 |
| `no-colorcode` | 0 |
| `no-inline-box-shadow` | 0 |
| `no-raw-asset-string` | 0 |
| `no-raw-border-radius` | 0 |
| `no-with-opacity` | 0 |

Strict categories (Phase C scope — deferred):

| Gate | Count |
|---|---:|
| `no-inline-text-style` | 0 |
| `no-raw-edge-insets` | 0 |
| `no-raw-font-family` | 0 |
| `no-raw-radius-only` | 0 |
| `no-raw-sized-box-literal` | **377** |
| `no-raw-duration` | **28** |

`flutter analyze`: no errors introduced by token work; 310 pre-existing
issues unchanged (mostly `non_constant_identifier_names`, `avoid_print`,
`use_build_context_synchronously`, and one missing-asset-directory
warning).

### Follow-ups (when picked up later)

1. **Phase C** — `SizedBox` (377) and `Duration` (28) sweeps. Tokens
   already exist in `AppSpacing` / `AppDurations`; the work is
   mechanical sed across the codebase plus a few new outlier tokens.
   See the C.1 / C.2 / C.3 sections above.
2. **Phase E remainder** — `inputDecorationTheme`, `cardTheme`,
   `bottomSheetTheme`, `dialogTheme`, `chipTheme`. Each is one PR with
   a screenshot diff. The deferred-fields comment block in
   `lib/app/theme.dart` is the live punch list.
3. **`custom_lint` Dart plugin** — replace the grep-based gate script
   with an analyzer plugin so violations surface in the IDE. See
   `DESIGN_TOKENS_RULES.md` → Automated enforcement.
4. **Pubspec assets warning** — `assets/profile/` declared but
   missing; unrelated to tokens but worth cleaning up.

---

## Changelog

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-05-26 | Initial completion plan covering Phases A–F |
| 1.1 | 2026-05-26 | Phase A/B/D/E executed; Phase C deferred; Phase E narrowed to textTheme + dividerTheme. Final state recorded above. |
