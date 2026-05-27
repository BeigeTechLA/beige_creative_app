# Phase 5 — Cleanup

**Overall status:** 🔴 Not Started · 0 / 8 tasks done · **Est:** 7 effort-days

| Field | Value |
|---|---|
| Goal | Delete transitional shims, prune unused deps, sweep comment + lint hygiene, finalize router. After Phase 5 the codebase has no legacy facades. |
| Branch | `migration/phase5/<task-slug>` per task |
| References | [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §7 Phase 5 |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

---

## Task list

| # | Task | Status | Files | Est. |
|---|---|---|---|---|
| [5.01](task_01_delete_shims.md) | Delete `api_service.dart`, `shared_service.dart`, design re-exports | 🔴 | 5–10 | 0.5d |
| [5.02](task_02_dep_prune.md) | Drop `http`, `flutter_stripe` (if unused), `image_cropper`, `photo_view` | 🔴 | 2 | 0.5d |
| [5.03](task_03_cached_network_image.md) | Migrate 12 `Image.network` sites to `CachedNetworkImage` | 🔴 | ~10 | 1d |
| [5.04](task_04_comment_hygiene.md) | Remove 60+ block comments + 104 dead lines + resolved TODO markers | 🔴 | many | 1d |
| [5.05](task_05_lint_fatal_infos.md) | Promote `--fatal-infos` in CI + fix punch list | 🔴 | many | 1d |
| [5.06](task_06_standardization.md) | Standardize date/time helpers, analytics names, asset literals | 🔴 | ~10 | 1d |
| [5.07](task_07_naming_polish.md) | Rename 5 colliding `Data` classes; audit `_screen.dart` suffix | 🔴 | ~10 | 0.5d |
| [5.08](task_08_router_final.md) | Router split if >400 LOC + typed params + optional deep links | 🔴 | 5–8 | 1.5d |

---

## Acceptance (whole phase)

- [ ] `lib/service/` directory gone.
- [ ] `lib/utility/colorcode.dart` and `lib/utility/imges_icons.dart` gone.
- [ ] `http`, `flutter_stripe` (if not wired), `image_cropper`, `photo_view`, `flutter_dotenv` absent from `pubspec.yaml`.
- [ ] All `Image.network` sites converted (verify with grep).
- [ ] No commented-out code blocks anywhere under `lib/`.
- [ ] CI runs `flutter analyze --fatal-infos` and stays green.
- [ ] Naming polish complete; no class named just `Data`.
- [ ] §1.3 shippable check passes on each commit.

## Dependencies

- **In:** Phase 4 fully done.
- **Out:** Phase 6 testing depends on shims being gone (otherwise tests test the wrong code).
