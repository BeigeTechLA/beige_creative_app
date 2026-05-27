# Color Migration — Phase 2 Plan

> **Goal:** Eliminate every inline color literal in widget code, retire the `ColorCode` shim, and dedupe any zero-reference constants in `AppColors`.
>
> **Companion:** `DESIGN_IMPROVE_PHASE1.md` · `DESIGN_TOKENS_MIGRATION.md` · `DESIGN_TOKENS_RULES.md`
> **Reference:** `guides/FLUTTER_DESIGN_SYSTEM.md`

---

## 1. Scope

| Item | Count | Strategy |
|------|-------|----------|
| Inline `Color(0x…)` in widgets | 171 | Replace with matching `AppColors.<name>` |
| `Colors.<name>` Material refs | 123 | Replace with matching `AppColors.<name>` |
| `ColorCode.<name>` legacy refs | 1300+ | Replace with the aliased `AppColors.<name>` |
| Pure-duplicate constants in `AppColors` | TBD | Remove constants that have zero remaining references |
| `ColorCode` class | — | Delete after migration completes |

**Decisions confirmed:**
- Semantic doubles retained (e.g., `warning` vs `statusOnWay`, `success` vs `statusArrived`).
- All 294 inline literals migrated in a single pass.
- All `ColorCode` references migrated in the same pass.

---

## 2. Mapping tables

### 2.1 `Colors.<name>` → `AppColors`

| Material | Replacement |
|---|---|
| `Colors.white` | `AppColors.white` |
| `Colors.black` | `AppColors.black` |
| `Colors.white70` | `AppColors.white70` |
| `Colors.white54` | `AppColors.white54` |
| `Colors.white38` | `AppColors.white38` |
| `Colors.white24` | `AppColors.white24` |
| `Colors.white12` | `AppColors.dividerDark` |
| `Colors.red` | `AppColors.error` |
| `Colors.redAccent` | `AppColors.redAccent` |
| `Colors.green` | `AppColors.success` |
| `Colors.greenAccent` | `AppColors.greenAccent` |
| `Colors.orange` | `AppColors.orange` |
| `Colors.blue` | `AppColors.blue` |
| `Colors.grey` | `AppColors.neutralGrey` |
| `Colors.black38` | `AppColors.black38` |
| `Colors.transparent` | `AppColors.transparent` |

### 2.2 `ColorCode.<name>` → `AppColors`

Already encoded in the alias block inside `lib/app/colors.dart`. Sed rules derived programmatically by parsing that block.

### 2.3 `Color(0x…)` → `AppColors`

Every unique hex used in widget code already has a matching `AppColors` constant (Step 1 of Phase 1 ensured 100% coverage). Sed rules generated from `AppColors` field declarations.

---

## 3. Execution phases

### Phase A — Generate mapping rules

1. Parse `lib/app/colors.dart` to build:
   - Hex → AppColors mapping (for inline `Color(0x…)` migration)
   - ColorCode field → AppColors target mapping (for legacy migration)

### Phase B — Insert missing imports

1. Find widget files that reference `Colors.<name>` but have no `app/colors.dart` import.
2. Insert `import '<relative-path>/app/colors.dart';` near the top of each affected file.

### Phase C — Mechanical replacement

Run sed sequentially per file in this order (longest patterns first):

1. **`ColorCode.<name>` → `AppColors.<target>`** — 85+ patterns, sorted by length desc.
2. **`Color(0x[Ff][Ff]…)` → `AppColors.<name>`** — case-insensitive 8-digit and 32-bit variants.
3. **`Colors.<name>` → `AppColors.<name>`** — word-boundary regex.
4. **`const AppColors.<name>` → `AppColors.<name>`** — strip now-redundant `const` keyword.

### Phase D — Dedupe pass

1. After Phase C, run `grep -rE "AppColors\.<name>" lib/` for every constant in `AppColors`.
2. Any constant with **zero references** is removed.
3. Semantic doubles (named per spec) are preserved even if their hex matches another constant.

### Phase E — Retire ColorCode

1. Delete the `ColorCode` class block from `lib/app/colors.dart`.
2. `flutter analyze` must show zero `undefined_identifier` errors.

### Phase F — Verification

| Check | Expectation |
|---|---|
| `flutter analyze` | Zero new errors. Baseline (390 issues) maintained or reduced. |
| `grep "Color(0x" lib/ \| grep -v lib/app/` | Zero matches |
| `grep "\bColors\." lib/ \| grep -v lib/app/` | Zero matches |
| `grep "\bColorCode\." lib/` | Zero matches |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart` | Build succeeds |
| Manual smoke on iOS sim | Splash → login → home → drawer → profile → file manager → messages |

---

## 4. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Sed substring collision (`ColorCode.white` partial-matching `ColorCode.whiteTransparent`) | Sort patterns longest-first; use word-boundary anchors |
| `const` context breakage | `AppColors.<name>` is `static const Color` — safe |
| Widget file missing import | Phase B adds imports before Phase C |
| Hex case variants (`0xFF` vs `0xff`) | Sed regex handles both via `[Ff]` pattern |
| Loss of semantic distinction | Phase D only removes constants with zero remaining references |
| Visual regression | Phase F build + smoke test |
| Unintended replacement in strings/comments | Sed restricted to recognised import + token patterns |

---

## 5. Rollback

Each phase is a discrete commit. If Phase F surfaces a regression:
- `git reset --hard HEAD~<n>` to the last verified phase.
- ColorCode class is restorable from git history.

---

## 6. Diff estimate

| Metric | Estimate |
|---|---|
| Files touched | ~50 widget files + `lib/app/colors.dart` |
| Line replacements | ~1,700 (294 inline + 1,300 ColorCode + imports + dedupe) |
| Effort | ~30 min mechanical + ~15 min verification |

---

## Changelog

| Version | Date | Notes |
|---------|------|-------|
| 1.0 | 2026-05-23 | Initial Phase 2 plan |
