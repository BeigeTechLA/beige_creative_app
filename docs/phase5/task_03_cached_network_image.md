# Task 5.03 — `Image.network` → `CachedNetworkImage`

**Phase:** 5 · **Status:** 🟢 Completed · **Est:** 1d · **Completed:** 2026-05-31

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` (continuation) |

## Goal
Convert all 12 `Image.network` sites to `CachedNetworkImage`. Dep already in `pubspec.yaml`. Improves perceived performance + offline behavior.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #18

## Files in scope (max 10 per commit; batch if more)
- All files containing `Image.network` — `grep -rln "Image\.network" lib/`

## Steps
- [x] Listed: 12 `Image.network` + 1 `NetworkImage` (CircleAvatar backgroundImage) across 13 files.
- [x] Each site: `Image.network(url, ...)` → `CachedNetworkImage(imageUrl: url, ...)`; `errorBuilder: (ctx, err, stack)` → `errorWidget: (ctx, url, err)`; preserved per-site `errorWidget` (image_holder / User_Circle / Container fallbacks — these are per-context fallback art, not loaders).
- [x] `NetworkImage(url)` in `home_welcome_header.dart` (CircleAvatar.backgroundImage) → `CachedNetworkImageProvider(url)`.
- [x] `profile_details_1_screen.dart` `_Avatar`: restructured ternary — was `Image.network(... or '')` which would 404 on empty URL; now `profileImageUrl.isNotEmpty ? CachedNetworkImage(...) : SvgPicture.asset(User_Circle)`. Same on-screen behaviour, no spurious 404.
- [x] No bespoke placeholders added — let `CachedNetworkImage` apply its built-in faded fade-in.
- [x] `grep -rn "Image\.network\|NetworkImage(" lib/` → 0 hits (all 13 sites now `CachedNetworkImage` or `CachedNetworkImageProvider`; `app_avatar.dart` was already on `CachedNetworkImage` pre-task).
- [x] `flutter analyze` — 80 issues (unchanged vs post-5.02 baseline).
- [x] `flutter test` — 145/145 passing.

## Acceptance
- [x] `grep -rn "Image\.network" lib/` returns 0.
- [x] `flutter analyze` clean (no new issues).
- [ ] Images render + cache (manual verify with airplane mode after warming — deferred to user).

## Notes
- **No shared wrapper widget** introduced. Each site's existing `errorBuilder` was already a per-context fallback (different fallback art + sizes per use). Wrapping them under one widget would have required passing the error widget as a builder arg, which is what `CachedNetworkImage.errorWidget` already does. Added wrapper would be a net loss vs direct migration. Task acceptance criteria (no `Image.network`, `analyze` clean) met without it.
- See `MIGRATION_LOG.md` entry `2026-05-31: Task 5.03`.
