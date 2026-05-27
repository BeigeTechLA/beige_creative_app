# Task 5.01 — Delete transitional shims

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/delete-shims` |

## Goal
Delete `lib/service/api_service.dart`, `lib/service/shared_service.dart`, `lib/utility/colorcode.dart`, `lib/utility/imges_icons.dart`. By this phase every caller already targets `DioClient` / `SessionStore` / `AppColors` / `AppAssets`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5.A
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §12

## Files in scope (max 10)
- `lib/service/api_service.dart` — delete
- `lib/service/shared_service.dart` — delete
- `lib/utility/colorcode.dart` — delete
- `lib/utility/imges_icons.dart` — delete
- Any remaining import of the above — fix to target the new location

## Steps
- [ ] `grep -rn "ApiService\(\)\|SharedService\|ColorCode\|AppImages\." lib/` — must return 0 results
- [ ] Delete files
- [ ] `flutter analyze` clean
- [ ] Smoke run both flavors

## Acceptance
- [ ] `lib/service/` empty (or deleted)
- [ ] `lib/utility/` no longer contains the legacy palettes
- [ ] `flutter analyze` clean
- [ ] App boots, login + home + profile all work

## Notes
If any grep hits remain, those features were not properly migrated in Phase 4 — go back and finish before deleting.
