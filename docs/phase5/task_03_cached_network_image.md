# Task 5.03 — `Image.network` → `CachedNetworkImage`

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/cached-images` |

## Goal
Convert all 12 `Image.network` sites to `CachedNetworkImage`. Dep already in `pubspec.yaml`. Improves perceived performance + offline behavior.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §4 Risk #18

## Files in scope (max 10 per commit; batch if more)
- All files containing `Image.network` — `grep -rln "Image\.network" lib/`

## Steps
- [ ] List call sites: `grep -rn "Image\.network" lib/`
- [ ] Per file: replace with `CachedNetworkImage(imageUrl: ..., placeholder: (_,__) => loader, errorWidget: (_,__,___) => fallback)`
- [ ] Use a shared `loader` + `fallback` widget from `lib/shared/widgets/`
- [ ] Batch commits ≤5 files per commit

## Acceptance
- [ ] `grep -rn "Image\.network" lib/` returns 0
- [ ] Images render + cache (verify by toggling airplane mode after warming cache)
- [ ] `flutter analyze` clean

## Notes
A single shared placeholder + error widget keeps UI consistent. Don't introduce per-call-site bespoke loaders.
