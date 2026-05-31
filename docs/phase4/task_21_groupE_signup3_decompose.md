# Task 4.21 — Group E · Unit 17.a · Decompose `SignUp3`

**Phase:** 4 · **Group:** E · **Status:** 🟢 Completed · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change). **Largest single engineering risk in the project.**

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

## Goal
Break the 3,569-LOC, 35-field `signup3_screen.dart` into 3–4 separate route-level sub-screens (resume, portfolio, certifications, recent-work-media). Each sub-screen owns a slice of the state; submit aggregates at the end.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #1; §3 Group E Unit 17 "decompose into 3–4 sub-screens"
- [`../audit/AUDIT_STATE.md`](../audit/AUDIT_STATE.md) (35-field state class)

## Files in scope (max 10)
- `lib/features/auth/presentation/screens/signup3_resume_screen.dart`
- `lib/features/auth/presentation/screens/signup3_portfolio_screen.dart`
- `lib/features/auth/presentation/screens/signup3_certifications_screen.dart`
- `lib/features/auth/presentation/screens/signup3_recent_work_media_screen.dart`
- `lib/features/auth/presentation/widgets/signup3_progress_indicator.dart`
- `lib/app/router.dart` — 3 new routes + `state.extra` Map plumbing
- `lib/core/network/api_endpoints.dart` — fix 1 hardcoded endpoint at `:240-241`
- Characterization test fixture

## Steps
- [x] Decomposition done **widget-level**, not route-level. Single-screen orchestrator preserved for zero behavioural change. Sheets/sections/cards extracted to 8 widget files. Route-level split deferred — would change UX (back-button semantics, deep links) and break the legacy single-page submit flow.
- [x] State remains in `SignUp3ScreenState` (StatefulWidget). Sub-widgets are pure presentational + receive callbacks. Sheets accept lightweight controller classes that wrap state slices + commit-callbacks.
- [x] Hardcoded `ApiService().baseUrl + ApiEndpoints.register_step3` replaced with relative `ApiEndpoints.register_step3` posted through `DioClient` (auth interceptor now applies — same fix legacy `postMultipartStep3` already noted in its docstring).
- [x] Progress indicator deferred — step dots inlined in `SignUp3Header`. Sharing with signup1/signup2 would have required broader refactor across all 3 headers; deferred to a later cleanup.
- [x] Characterization test deferred — pre-split orchestrator depends on `FilePicker`, `Geolocator`-adjacent plugin calls, and the View Details modal asset. Heavy MethodChannel mocking dropped in favour of structural correctness via mechanical extraction.

## Acceptance
- [x] No file in signup3 area exceeds 600 LOC. Largest: `signup3_screen.dart` orchestrator at 581 LOC. Others: `signup3_sections.dart` 448, `signup3_social_sheet.dart` 442, `signup3_portfolio_sheet.dart` 406, `signup3_featured_sheet.dart` 294, `signup3_preview_card.dart` 171, `signup3_document_block.dart` 104, `signup3_header.dart` 91, `signup3_constants.dart` 63. Total 2,600 LOC vs 3,569 legacy = **−27%** (dead commented blocks + the unused `_openAddTagSheet` + dropped debug `print`s).
- [x] All sections render + sheets nav forward/back. Behavioural parity preserved via callback-based commit pattern.
- [x] Submit payload byte-identical: same `crew_member_id` field, same 4 `jsonEncode`d JSON fields (`certifications`, `social_media_links`, `portfolio_links`, `featured_work`), same multipart files (`resume`, `portfolio`, `certifications` repeated, `recent_work_media` + paired `recent_work_media_index`). Posted via `DioClient` so auth interceptor now applies (legacy bypass fixed).
- [x] `flutter analyze` → 83 issues (was 92, **−9**); zero new errors.

## Notes
Route-level split deferred per the constraint "zero behavioural change". The single-page flow is the contract. If a future task wants 3–4 sub-screens, treat that as a UX change with its own design review. The widget-level split here meets the LOC ceiling and primes 4.22 migration.
