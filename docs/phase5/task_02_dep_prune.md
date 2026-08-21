# Task 5.02 — Dependency prune

**Phase:** 5 · **Status:** 🟢 Completed · **Est:** 0.5d · **Completed:** 2026-05-31

| Field | Value |
|---|---|
| Owner | Claude |
| Branch | `improvments-phase1` (continuation) |

## Goal
Drop unused or now-redundant packages: `http`, `flutter_stripe` (if not wired), `image_cropper` (0 imports), `photo_view` (0 imports).

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §5 Package Conflicts; §4 Risk #12

## Files in scope
- `pubspec.yaml`

## Steps
- [x] Grepped `package:http/` / `http.get` / `http.post` / `http.put` / `http.delete` / `http.Client` / `http.Response` in `lib/` + `test/` → 0 hits. Dropped `http: ^1.4.0`.
- [x] Grepped `package:flutter_stripe` / `Stripe.` / `stripe.` in `lib/` + `test/` → 0 hits. User confirmed drop. Dropped `flutter_stripe: ^12.1.1`. `Env.stripePublishableKey` retained as forward-compatible config; readd dep when payment lands.
- [x] Grepped `package:image_cropper` / `ImageCropper` / `CropAspectRatio` / `CroppedFile` → 0 hits. Dropped `image_cropper: ^10.0.0+1`.
- [x] Grepped `package:photo_view` / `PhotoView` → 0 hits. Dropped `photo_view: ^0.15.0`.
- [x] `flutter pub get` — 9 packages no longer depended on (4 direct + 5 transitive: `stripe_android`, `stripe_ios`, `stripe_platform_interface`, `image_cropper_for_web`, `image_cropper_platform_interface`).
- [x] `flutter analyze` — 80 issues (no change vs post-5.01 baseline). No errors.
- [x] `flutter test` — 145/145 passing.

## Acceptance
- [x] `http`, `flutter_stripe`, `image_cropper`, `photo_view` absent from `pubspec.yaml`.
- [x] Pubspec resolves with smaller dep closure (9 packages dropped).
- [ ] App builds + boots (manual smoke — deferred to user).

## Notes
- `flutter_stripe` removal sign-off: user confirmed via `AskUserQuestion` prompt. `Env.stripePublishableKey` constant in `lib/config/env.dart` is kept harmless (compile-time string, no runtime cost) so re-adding stripe later only needs the dep + wiring.
- `http` was a direct dep with 0 imports — likely a holdover from pre-Dio era. Removing it does not affect Firebase / google_maps_flutter (they pull their own transitive `http`).
- See `MIGRATION_LOG.md` entry `2026-05-31: Task 5.02`.
