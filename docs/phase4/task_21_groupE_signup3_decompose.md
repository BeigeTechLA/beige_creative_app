# Task 4.21 — Group E · Unit 17.a · Decompose `SignUp3`

**Phase:** 4 · **Group:** E · **Status:** 🔴 Not Started · **Est:** 2d
**Type:** Decomposition (split-only — zero behavioral change). **Largest single engineering risk in the project.**

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase4/groupE-signup3-split` |

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
- [ ] **Land characterization tests first** — full submit flow API-call snapshot
- [ ] Split state into 4 slices (resume, portfolio, certs, recent work)
- [ ] Each sub-screen reads + writes its slice; final submit aggregates
- [ ] Hardcoded URL into `ApiEndpoints`
- [ ] Add a progress indicator widget shared across the 4 routes
- [ ] Characterization test green: submit produces identical API call body

## Acceptance
- [ ] No file >600 LOC in signup3 area
- [ ] All 4 sub-screens render + nav forward/back
- [ ] Original submit API call byte-identical
- [ ] `flutter analyze` clean

## Notes
Track as its own PR series (`a1`, `a2`, `a3`, `a4` if needed). Pair-program. If actual time exceeds estimate by >50%, raise risk in `MIGRATION_LOG.md` and consider a 5th sub-screen.
