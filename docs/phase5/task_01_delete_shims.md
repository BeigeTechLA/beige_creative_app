# Task 5.01 — Delete transitional shims

**Phase:** 5 · **Status:** 🟢 Completed · **Est:** 0.5d · **Completed:** 2026-05-31

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` (continuation) |

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
- [x] Migrated 14 call sites: `ApiService.imageURL` → `Env.imageUrl`; `ApiService().getImageURL(x)` → `Env.imageUrl + x`; multipart shim usage in 2 profile repos inlined to `_client.dio.post(...)` with `FormData`; `SharedService.logout()` → `sessionStoreProvider.clearSession()` + `authStateProvider = false`; `SharedService.bind(session)` removed from `startApp` (already injected via provider override).
- [x] Deleted `lib/service/api_service.dart`, `lib/service/shared_service.dart`.
- [x] `grep -rn "ApiService\|SharedService\|ColorCode\|AppImages" lib/ test/` → 0 hits.
- [x] `flutter analyze` — 80 issues (down 2 from 82 baseline, all pre-existing lint infos, no errors).
- [x] `flutter test` — 145/145 passing.
- [ ] Smoke run both flavors (manual — deferred to user).

## Acceptance
- [x] `lib/service/` no longer contains `api_service.dart` or `shared_service.dart`.
- [x] `lib/utility/` no longer contains `colorcode.dart` or `imges_icons.dart` (already absent before this task).
- [x] `flutter analyze` clean (no errors, no new infos).
- [ ] App boots, login + home + profile all work (manual smoke — deferred to user).

## Notes
- All 14 call sites migrated cleanly to canonical APIs (`Env.imageUrl`, `DioClient`, `SessionStore`, `authStateProvider`). No Phase 4 carry-overs surfaced.
- Multipart inlined per repo (not extracted to a shared helper) — only 3 call sites with distinct field-name conventions (`profile_photo`, `files[]`).
- Logout now flips `authStateProvider` (was implicit via `context.goNamed(login)`), aligning with `delete_account_providers.dart`.
- See `MIGRATION_LOG.md` entry `2026-05-31: Task 5.01` for full decision log.
