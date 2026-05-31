# Task 5.07 — Naming polish

**Phase:** 5 · **Status:** 🟢 Completed (2026-05-31) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` |

## Goal
Rename 5 colliding `Data` classes (`AUDIT_QUALITY.md` flagged) to feature-specific names. Audit `_screen.dart` suffix consistency. Re-enable `camel_case_types` lint (deferred from 5.05).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.F

## Renames (29 files touched: 8 model files + 19 consumers + 2 test sweeps)

**Inner `Data` classes (5):**
| Old | New | Source file |
|---|---|---|
| `Data` | `DashboardCountData` | `dashboard_count_model.dart` |
| `Data` | `ShootCountData` | `shoot_count_model.dart` |
| `Data` | `CreatorDashboardData` | `create_dashboard_details_model.dart` |
| `Data` | `MyProfileData` | `myprofile_model.dart` |
| `Data` | `ShootsData` | `shoots_model.dart` |

**Snake/camel-case legacy classes (2 + 7):**
| Old | New | File |
|---|---|---|
| `shootstatusdata` | `ShootStatusData` | `shoot_status_model.dart` |
| `upcomingdatum` | `UpcomingShootDatum` | `upcoming_shoots_model.dart` |
| `Dashboardcountmodel` | `DashboardCountModel` | `dashboard_count_model.dart` |
| `Shootcountmodel` | `ShootCountModel` | `shoot_count_model.dart` |
| `Creatordashboarddetailsmodel` | `CreatorDashboardDetailsModel` | `create_dashboard_details_model.dart` |
| `Myprofilemodel` | `MyProfileModel` | `myprofile_model.dart` |
| `Shootstatusmodel` | `ShootStatusModel` | `shoot_status_model.dart` |
| `Upcomingshootsmodel` | `UpcomingShootsModel` | `upcoming_shoots_model.dart` |
| `Upcomingshootviewmodel` | `UpcomingShootViewModel` | `upcoming_shootview_model.dart` |

**Screen suffix:**
| Old | New | File |
|---|---|---|
| `CancelScreen` | `ShootCancelledScreen` | `shoot_cancelled_screen.dart` (filename was already correct; class lacked the `Shoot` prefix). Also updated router.dart consumer. |

## Steps
- [x] Listed `Data` classes via `rg "^class Data\b" lib/` → 5 hits, all in `lib/model_class/`.
- [x] Per-file `replace_all` rename, then propagated via `flutter analyze` error list (3 passes).
- [x] Audited screens: all files under `presentation/screens/` end in `_screen.dart`. All top-level public classes end in `Screen` *except* `CancelScreen` — fixed to `ShootCancelledScreen`.
- [x] Private widget helpers in screen files (`_FolderList`, `_PersonalCard`, `_StatCard`, etc.) intentionally left as-is — they are widget extractions co-located with the screen, not screens themselves. Strict reading of "every class ends with `Screen`" would require renaming dozens of internal helpers to no benefit; scope interpretation: top-level public screen classes only.
- [x] Re-enabled `camel_case_types` (default true via removing the override).
- [x] Marked `constant_identifier_names` permanently disabled (documented WHY: asset filenames + API endpoint paths mirror server-side snake_case keys verbatim — `upload_resume`, `delete_allfiles`, `image_holder.svg` — renaming the Dart constants decouples them from source-of-truth and adds zero clarity).
- [x] `flutter analyze --fatal-infos` clean.

## Acceptance
- [x] `rg "^class Data\b" lib/` returns 0.
- [x] Every file under `presentation/screens/` ends with `_screen.dart`.
- [x] Every public, top-level screen class in those files ends with `Screen`.
- [x] App boots — `flutter test` 145/145 passing (includes router + smoke test).

## Notes
Per-class commit not pursued — task is internal renames with zero behavior change. One squashed commit on the phase branch matches the existing 5.0x cadence and keeps history readable; reverting any single rename can still be done file-by-file via `git checkout`.
