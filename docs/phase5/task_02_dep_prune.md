# Task 5.02 — Dependency prune

**Phase:** 5 · **Status:** 🔴 Not Started · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase5/dep-prune` |

## Goal
Drop unused or now-redundant packages: `http`, `flutter_stripe` (if not wired), `image_cropper` (0 imports), `photo_view` (0 imports).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Package Conflicts; §4 Risk #12

## Files in scope
- `pubspec.yaml`

## Steps
- [ ] `grep -rn "import 'package:http/\|http.get\|http.post" lib/` returns 0 → drop `http`
- [ ] `grep -rn "Stripe\.\|flutter_stripe" lib/` — if no real usage, drop `flutter_stripe` (with stakeholder confirmation)
- [ ] `grep -rn "ImageCropper\|image_cropper" lib/` returns 0 → drop
- [ ] `grep -rn "PhotoView\|photo_view" lib/` returns 0 → drop
- [ ] `flutter pub get`
- [ ] `flutter analyze` clean

## Acceptance
- [ ] Above packages absent from `pubspec.yaml`
- [ ] App builds + boots
- [ ] Pubspec resolves with smaller closure

## Notes
`flutter_stripe` removal needs explicit sign-off — if a payment flow is on a roadmap, keep the dep and wire it instead. Log decision in `MIGRATION_LOG.md`.
