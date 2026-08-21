# Asset & Image Cleanup Plan

Audit + remediation plan for `assets/` tree, `lib/app/assets.dart`, and
`pubspec.yaml` asset declarations. Goal: consistent naming, no dead files, Dart
style compliance, hi-DPI raster support, optional codegen.

Total `AppAssets.*` call sites at audit time: **~182** across `lib/`.

## Status Legend

- ✅ **DONE** — task complete, verified.
- 🔄 **IN PROGRESS** — partially done; remaining work noted.
- ⏸️ **DEFERRED** — moved to later phase (reason noted).
- ⏳ **PENDING** — not started.
- ❌ **SKIPPED** — out of scope or rejected.

## Progress Summary

| Phase | Status | Date |
|---|---|---|
| A — Folder & File Renames | ✅ DONE | 2026-06-03 |
| B — `pubspec.yaml` Cleanup | ✅ DONE | 2026-06-03 |
| C — `AppAssets` Const Rewrite | ✅ DONE | 2026-06-03 |

**All planned phases complete.** 21 renames, 12 deletions, 39 const renames, 6 dead consts dropped, 3 dead-code drops (`fontHelveticaNeue`, `fontFamilyHelvetica`, `detailingText`). 38 feature files touched in C (124 insertions / 139 deletions). `flutter analyze` clean throughout.

## Centralization Audit (pre-work, confirmed clean)

`rg -nP "['\"]assets/" lib/ --type dart` → matches only inside
`lib/app/assets.dart`. No hardcoded asset path literals in feature code.

`rg -nP "(SvgPicture|Image|Lottie)\.asset\(\s*['\"]" lib/ --type dart` → zero
matches outside `lib/app/assets.dart`. All `*.asset()` calls receive either
`AppAssets.*` directly or a variable that traces back to `AppAssets.*`
(`_socialIcons`, `_portfolioIcons` in `my_profile_screen.dart`,
`image: AppAssets.onboding1` in `onboarding_screen.dart`, etc.).

Runtime-only strings (not bundled assets, no action needed):
- `crop_${ts}.png` temp files in `signup1_crop_sheet.dart` +
  `profile_image_crop_sheet.dart`.
- `.endsWith('.svg')` discriminators in `signup3_*` and `profile_*` sheets.

**Conclusion**: no migration of stray literals required. Phase C const rewrite
is the only large-blast-radius step.

---

## Phase A — Folder & File Renames (filesystem hygiene)

Low-risk renames. Each task = rename + update `pubspec.yaml` + update every
`AppAssets` path constant + run `flutter analyze` + `flutter test`.

### A.01 — Rename top-level asset folders ✅ DONE (2026-06-03)
- `assets/Active/` → `assets/active/`
- `assets/NonActive/` → `assets/inactive/`
- `assets/onboding/` → `assets/onboarding/`
- `assets/svg/Shoot/` → `assets/svg/shoots/`
- Fold `assets/home/grouplogo.png` → `assets/images/group_logo.png`, drop `assets/home/`.

**Impacted**:
- `pubspec.yaml` (lines 89-98 assets block).
- `lib/app/assets.dart` private dir consts `_active`, `_inactive`, `_onboarding`, `_shootSvg`, `_home`.
- Git history (`git mv` to preserve blame).
- iOS/Android build cache (clean build after).

**Execution notes**:
- macOS case-insensitive FS → two-step `git mv` for case-only renames (`Active` → `active_tmp` → `active`, same for `NonActive`, `Shoot`).
- `_home` private const removed from `assets.dart`; `group_logo` repointed to `$_images/group_logo.png`.
- `pubspec.yaml` assets block alphabetized + dead comment `#    - assets/images/` dropped.
- Verify: `flutter analyze` → `No issues found! (ran in 2.9s)`. 21 paths staged as `R` in git.

### A.02 — Rename files with spaces / parens / suffix noise ✅ DONE (2026-06-03)
- `assets/svg/Social Media Icon (5).svg` → `assets/svg/behance.svg`.
- `assets/lottie/Untitled_file.json` → **deleted** (orphan dupe, not referenced).
- `assets/lottie/Untitled file.json` → `assets/lottie/untitled_file.json` (semantic rename deferred — needs visual content check).
- `assets/inactive/shoots(1).svg` → `assets/inactive/shoots_inactive.svg`.
- `assets/inactive/messages(1).svg` → `assets/inactive/messages_inactive.svg`.
- `assets/inactive/filemanager(1).svg` → `assets/inactive/file_manager_inactive.svg`.
- `assets/inactive/manageavailability(2).svg` → `assets/inactive/manage_availability_inactive.svg`.
- `assets/inactive/dashboard-square-02.svg` → `assets/inactive/dashboard_inactive.svg`.
- `assets/active/messages_active_.svg` → `assets/active/messages_active.svg`.

**Impacted**:
- `lib/app/assets.dart` path strings updated for consts: `be`, `lottie1`, `inactiveShoots`, `inactiveMessages`, `inactiveFileManager`, `inactiveManageAvailability`, `inactiveDashboard`, `activeMessages` (8 path strings).
- Const **names** unchanged (Phase C scope) → zero call-site churn.

**Execution notes**:
- `Component10.json` (referenced by `lottie2`) kept as-is — no spaces/parens, out of A.02 scope.
- `lottie1` semantic name still pending — `untitled_file.json` placeholder. Defer to phase C/D after lottie inspection.
- Verify: `flutter analyze` → `No issues found! (ran in 3.0s)`.

### A.03 — Fix typo'd filenames ✅ DONE (2026-06-03)
- `assets/svg/calender.svg` → `calendar.svg`.
- `assets/svg/mycalender.svg` → `my_calendar.svg`.
- `assets/svg/dcalender.svg` → **deleted** (orphan, not referenced).
- `assets/svg/doller.svg` → `dollar.svg`.
- ⏸️ `assets/svg/SQAREPEN.svg` → DEFERRED to A.04 deletion (const `SQAREPEN` unused).
- ⏸️ `assets/svg/clude.svg` → DEFERRED to A.04 deletion (const `clude` unused).
- ⏸️ `assets/svg/infosvg.svg` + `assets/svg/Info.svg` → DEFERRED to C.03 (needs visual diff between two info glyphs before pick).

**Impacted**: 3 path strings in `lib/app/assets.dart` (`calender`, `mycalender`, `doller`).

**Execution notes**:
- Verify: `flutter analyze` → `No issues found! (ran in 3.0s)`.

### A.04 — Resolve orphan files (delete or wire in) ✅ DONE (2026-06-03)
Files on disk, not in `AppAssets` → deleted (10 files):
- `assets/active/dashboard.svg`
- `assets/active/filemanager.svg`
- `assets/active/messages.svg`
- `assets/active/shoots.svg`
- `assets/svg/SQAREPEN.svg` (carried from A.03)
- `assets/svg/clude.svg` (carried from A.03)
- `assets/svg/filter.svg` (unused const `filter`)
- `assets/svg/myprofileeditphoto.svg` (unused const `myprofileeditphoto`)
- `assets/images/weddingevent.png` (unused const `weddingevent`)
- `assets/images/avtarstack.png` (unused const `avtarstack`)

**Execution notes**:
- Diff vs `inactive/`: 4 active-folder orphans were NOT dupes (different SVG content) — but had zero references via `AppAssets` or hardcoded paths. Safe delete.
- `assets/svg/dcalender.svg` deleted earlier in A.03 batch.
- Consts pointing to deleted files (6 of them: `weddingevent`, `avtarstack`, `filter`, `myprofileeditphoto`, `SQAREPEN`, `clude`) will be dropped in **C.02**. Currently dead (verified zero refs) — runtime safe.
- `flutter analyze` → `No issues found! (ran in 4.4s)`.

---

## Phase B — `pubspec.yaml` Cleanup

### B.01 — Remove dead lines + reorder ✅ DONE (2026-06-03, folded into A.01)
- Dropped commented `#    - assets/images/` (was line 90).
- Asset list alphabetized.
- Renamed paths (Phase A) reflected.

### B.02 — Audit declared fonts ✅ DONE (2026-06-03)
- `fontHelveticaNeue` font NOT registered in `pubspec.yaml` → silent OS fallback at runtime.
- Use chain: `fontHelveticaNeue` → `AppTextStyles.fontFamilyHelvetica` → `AppTextStyles.detailingText` (italic 12 w500).
- `detailingText` had **zero callers** → entire chain dead.
- Action taken: **dropped all 3** symbols:
  - `lib/app/assets.dart`: removed `fontHelveticaNeue`.
  - `lib/app/text_styles.dart`: removed `fontFamilyHelvetica` const + `detailingText` style.

**Impacted**: `lib/app/assets.dart`, `lib/app/text_styles.dart`. Zero call-site changes (style was unused).

**Execution notes**:
- License consideration: Helvetica Neue is proprietary — option to ship `.ttf` files rejected. Drop chosen.
- `flutter analyze` → `No issues found! (ran in 3.2s)`.

---

## Phase C — `lib/app/assets.dart` Const Rewrite ✅ DONE (2026-06-03)

Highest blast radius (~182 refs). Single working batch. Codemod via Perl one-liner per pair.

### C.01 — Rename consts to Dart lowerCamelCase ✅ DONE (2026-06-03)
Mapping:

| Current | New |
|---|---|
| `group_logo` | `groupLogo` |
| `Ball` | `ball` |
| `Pencil` | `pencil` |
| `User_Circle` | `userCircle` |
| `Phone_Calling` | `phoneCalling` |
| `Image_zoom` | `imageZoom` |
| `Upload` | `upload` |
| `HourglasTime` | `hourglassTime` (also typo fix) |
| `SQAREPEN` | `squarePen` |
| `info_svg` | (merge with `info`) |
| `book_video` | `bookVideo` |
| `box_edit` | `boxEdit` |
| `edit_circle` | `editCircle` |
| `circle_arrow` | `circleArrow` |
| `mail_icon` | `mailIcon` |
| `more_vert` | `moreVert` |
| `myprofile_edit` | `myProfileEdit` |
| `notificationbell` | `notificationBell` |
| `notificationsetting` | `notificationSetting` |
| `appperference` | `appPreference` (typo fix) |
| `appversion` | `appVersion` |
| `rectangle_profile` | `rectangleProfile` |
| `image_holder` | `imageHolder` |
| `search_icon` | `searchIcon` |
| `clock_icon` | `clockIcon` |
| `photo_icon` | `photoIcon` |
| `video_icon` | `videoIcon` |
| `calendar_icon` | `calendarIcon` |
| `declined_icon` | `declinedIcon` |
| `calender` | `calendar` |
| `mycalender` | `myCalendar` |
| `youtube` | (already correct) |
| `lottie1` | `lottieSuccess` (semantic) |
| `lottie2` | `lottieSplash` (semantic) |
| `onboding1` | `onboardingHero` |
| `be` | `behance` (clarity) |
| `v` | `vimeo` (clarity) |
| `googledrive` | `googleDrive` |
| `userid` | `userId` |
| `person_icons` | `personIcon` (also singular) |
| `doller` | `dollar` |

**Impacted**: 38 files in `lib/`, 39 renamed consts. Codemod:
```bash
while IFS=: read -r old new; do
  rg -l "AppAssets\.${old}\b" lib/ --type dart | \
    xargs perl -i -pe "s/\bAppAssets\.${old}\b/AppAssets.${new}/g"
done < rename_map.txt
```

**Execution notes**:
- Path-only consts (where filename was already correct, only const name changed): `Ball`, `Pencil`, `Upload`, etc.
- Path + filename will diverge cosmetically for some (`Pencil` → `pencil` const still points to `Pencil.svg` because file is PascalCase on disk — fold into A.05 file rename later if desired).
- 0 `flutter analyze` errors after codemod. AppAssets ref count: 183 (was 182, +1 from new code in unrelated commit `6ac2d09`).

### C.02 — Drop unused consts ✅ DONE (2026-06-03)
Dropped from `lib/app/assets.dart`:
- `weddingevent`, `avtarstack`, `filter`, `myprofileeditphoto`, `SQAREPEN`, `clude`.

Kept in use (verified via grep, do NOT drop):
- `delete` (4 file refs).
- `dropdown` (4 file refs).

Already dropped in B.02:
- `fontHelveticaNeue`.

**Impacted**: `lib/app/assets.dart` only. Zero call-site touch.

### C.03 — Consolidate duplicate `info` / `infoFilled` 🔄 PARTIAL (2026-06-03)
- `info_svg` renamed → `infoFilled` (placeholder; points to `Info.svg`).
- `info` kept canonical (points to `infosvg.svg`).
- ⏸️ Full consolidation (pick winner + delete loser) DEFERRED — needs visual
  diff between the two info glyphs. User to inspect, then drop one + repoint
  callers.

---

## Execution Order + Risk

| Phase | Status | Risk | Call-site churn | Suggested PR |
|---|---|---|---|---|
| A.01 folders | ✅ DONE | Low | Path strings only | PR 1 |
| A.02 files | ✅ DONE | Low | Path strings only | PR 1 |
| A.03 typos | ✅ DONE | Low | Path strings only | PR 1 |
| A.04 orphans | ✅ DONE | Low | None | PR 1 |
| B.01 pubspec | ✅ DONE | Low | None | PR 1 |
| B.02 fonts | ✅ DONE | Low | 0-few text styles | PR 1 |
| C.01 const rename | ✅ DONE | **High** | 38 files / 39 consts | PR 2 |
| C.02 unused drop | ✅ DONE | Low | 0 | PR 2 |
| C.03 info dedupe | 🔄 PARTIAL | Low | 1 rename done; consolidation deferred | PR 2 |

---

## Verification Per Phase

- `flutter analyze` → clean.
- `flutter test` → green.
- `rg "AppAssets\." lib/ | wc -l` → matches expected delta.
- `rg "assets/" lib/ --include="*.dart" | grep -v "app/assets.dart"` → 0 hardcoded paths.
- Manual smoke: bottom nav icons, onboarding screen, profile screen, shoot
  card, file manager, login eye toggle, lottie loader.
- Build: `flutter build apk --flavor dev ...` to catch asset-not-found at
  compile-asset bundling.

---

## Out of Scope

- App launcher icons (Android adaptive done in `3458fc0` / `67552b1`).
- Firebase / push notification icons.
- Splash screen assets.

---

## Execution Log

### 2026-06-03 — Phase A + B landed (single working batch)

**A.01 folders** — 5 dir renames + 1 file move + 1 empty dir drop (`assets/home/` removed).

**A.02 files** — 8 renames + 1 orphan delete (`Untitled_file.json` dupe). Path strings updated: `be`, `lottie1`, `inactiveDashboard`, `inactiveShoots`, `inactiveFileManager`, `inactiveMessages`, `inactiveManageAvailability`, `activeMessages`.

**A.03 typos** — 3 renames (`calender`→`calendar`, `mycalender`→`my_calendar`, `doller`→`dollar`) + 1 orphan delete (`dcalender.svg`).

**A.04 orphans** — 10 file deletes:
- Mis-placed actives: `active/{dashboard,filemanager,messages,shoots}.svg`.
- Dead-const SVGs: `SQAREPEN`, `clude`, `filter`, `myprofileeditphoto`.
- Dead-const PNGs: `weddingevent`, `avtarstack`.

**B.01 pubspec** — folded into A.01 (alphabetize + drop dead comment).

**B.02 fonts** — dropped dead Helvetica chain: `AppAssets.fontHelveticaNeue`, `AppTextStyles.fontFamilyHelvetica`, `AppTextStyles.detailingText`.

**Aggregate diff**: 21 renames, 12 deletions, 8 path-string updates, 3 dead symbols removed.

**Files touched**:
- `pubspec.yaml`
- `lib/app/assets.dart`
- `lib/app/text_styles.dart`
- `assets/**` (filesystem renames + deletes)

**Verification**: `flutter analyze` clean (3.2s) on final state. No call-site changes (Phase C scope).

**Carry-over notes for Phase C**:
- 6 dead consts ready for C.02 drop: `weddingevent`, `avtarstack`, `filter`, `myprofileeditphoto`, `SQAREPEN`, `clude`.
- `lottie1` placeholder name `untitled_file` — pick semantic name during C.01.
- `info` / `info_svg` consolidation needs visual diff before C.03.

### 2026-06-03 — Phase C landed

**C.01 const rename** — 39 consts renamed to Dart `lowerCamelCase` + 4 typo fixes (`calender`/`mycalender`/`doller`/`appperference`/`HourglasTime`) + 6 semantic clarifications (`be`→`behance`, `v`→`vimeo`, `lottie1`→`lottieSuccess`, `lottie2`→`lottieSplash`, `onboding1`→`onboardingHero`, `person_icons`→`personIcon`).

**C.02 drop unused** — 6 consts removed (`weddingevent`, `avtarstack`, `filter`, `myprofileeditphoto`, `SQAREPEN`, `clude`). Files were already deleted in A.04.

**C.03 info dedupe** — partial: `info_svg` → `infoFilled` rename only. Full consolidation deferred (need visual diff).

**Codemod**: Perl one-liner per pair, word-boundary anchored. 38 feature files touched. Files containing renamed refs found via `rg -l "AppAssets\.<old>\b" lib/`.

**Aggregate diff (Phase C)**:
- `lib/app/assets.dart`: rewrite — 39 renames, 6 drops, sections re-grouped.
- 38 feature files: 124 insertions / 139 deletions.

**Verification**:
- `flutter analyze` → `No issues found! (ran in 3.1s)`.
- `rg "AppAssets\." lib/ -o | wc -l` → 183 (was 182 — +1 from prior unrelated commit).
- `rg "AppAssets\.[A-Z_][a-z_]*_[a-z_]+\b|AppAssets\.[A-Z][A-Z]+\b" lib/` → 0 stale snake_case/PascalCase refs.

**Open items (descope decision 2026-06-03 — not pursuing)**:
- Hi-DPI raster variants (was Phase D) — removed from scope.
- Target layout reorg (was Phase E) — removed from scope.
- `info` / `infoFilled` full consolidation (C.03 remainder) — pending visual diff if user wants to revisit.
- PascalCase filenames on disk (`Pencil.svg`, `Phone_Calling.svg`, `Image_zoom.svg`, `Info.svg`) — cosmetic only; const names already lowerCamelCase, runtime unaffected.