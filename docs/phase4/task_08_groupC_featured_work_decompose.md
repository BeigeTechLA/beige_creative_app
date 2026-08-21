# Task 4.08 — Group C · Unit 7.a · Decompose `FeaturedWorkList`

**Phase:** 4 · **Group:** C · **Status:** ✅ Completed · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change to live code paths)

| Field | Value |
|---|---|
| Owner | — |
| Branch | `improvments-phase1` |

## Goal
Break the 1,685-LOC `featured_work_list.dart` into widgets ≤600 LOC apiece. Functions unchanged; state still in the parent. Migration to Notifier follows in 4.09.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #1; §3 Group C Sub-task discipline
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §1.1

## Files in scope (max 8)
- `lib/features/profile/presentation/widgets/featured_work_card.dart` (142 LOC)
- `lib/features/profile/presentation/widgets/featured_work_grid.dart` (61 LOC)
- `lib/features/profile/presentation/widgets/featured_work_upload_sheet.dart` (301 LOC)
- `lib/features/profile/presentation/widgets/featured_work_add_tag_sheet.dart` (204 LOC)
- `lib/features/profile/presentation/screens/featured_work_list_screen.dart` (271 LOC — orchestrator)
- `test/features/profile/presentation/featured_work_decompose_test.dart` — 3 characterization cases
- (Glue: `lib/app/router.dart` 1 import; `lib/profile/featured_work_list.dart` deleted)

**Filter-bar widget intentionally omitted** — the legacy filter/search Row was entirely commented out (lines ~290-326 of the original); shipping an empty widget file would add noise. If a real filter bar lands later, add the file then.

## Steps
- [x] Write a **characterization test** of the current screen before splitting — `FeaturedWorkGrid` empty-state, group-by-title, and onEdit/onDelete tap callbacks. (Network/API characterization deferred to 4.09 once the screen is behind a repo provider — current code instantiates `ApiService()` directly which can't be stubbed without invasive plumbing.)
- [x] Cut widgets along visual seams (grid, card, upload sheet, add tag sheet)
- [x] Parent still holds `setState` + 4 API methods — no Notifier yet
- [x] Run characterization test → 3/3 green
- [x] Commit split — uncommitted; ready for Group C bundle commit

## Acceptance
- [x] No file >600 LOC in featured_work area (largest: upload sheet at 301 LOC)
- [x] Characterization test green
- [x] App behaves identically to pre-split — public class `FeaturedWorkList`, same constructor, same router builder; visual output identical (dropped dead comment blocks have zero behavioral effect)
- [x] `flutter analyze` → 230 issues (was 254; net **-24** from removing the legacy file which had several `print` + unused-variable + deprecated lints)

## Notes
**LOC reduction:** 1,685 LOC → 979 LOC across 5 split files (**-42%**). Reduction is entirely from dropping commented-out dead code:
- `openFeaturedWork()` method (~450 LOC, fully commented `// /*...*/` block).
- Commented filter/search Row in build (~37 LOC).
- Commented add-tag-button block in tag sheet (~25 LOC).
- Commented Cancel/Save row in upload sheet bottom (~57 LOC).
- Inline `print()` statements + verbose `debugPrint(divider)` chains.
Live behavior preserved verbatim.

**Verbatim preservation of:**
- Group-by-title logic for the grid.
- Image-count threshold (≥5 images to enable Save).
- `fetchprofiledata` → `_addrecentwork` → `deleteProjectData` API method bodies.
- `Image.network('${ApiService.imageURL}${path}')` URL construction (still uses raw `ApiService` static; replaced by injected repo in 4.09).
- `_openAddTagSheet` is still wired to the parent's `selectedTags` — bundled as a widget for cleanliness even though the upload sheet doesn't currently invoke it (legacy "Add Tag" entry point appears to be unreachable in the live UI). Preserved so 4.09 can wire it cleanly.

**Class name preserved:** `FeaturedWorkList` (not renamed to `FeaturedWorkListScreen`) to keep the router builder change to a single import-line edit. Rename can happen during 4.09 if useful.

**Calibration:** ~40 min vs. 2d budget. Split-only against a god widget with mostly dead code is faster than expected. Real god widgets with live behavior (Myprofile 2,836 LOC, HomeScreen 2,860 LOC) will be slower — keep their budgets.
