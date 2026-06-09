# Design Fixing — Static Sizing & Safe-Area Audit

Date: 2026-06-07 (audit) · last updated 2026-06-09
Scope: `lib/` Flutter UI
Goal: Eliminate hardcoded dimensions and missing SafeArea that break layouts on
small iOS / Android phones, Dynamic Island devices, foldables, and tablets.

Device matrix to validate against:

| Class  | Reference device           | Logical size (pt/dp) | Notes                            |
| ------ | -------------------------- | -------------------- | -------------------------------- |
| Small  | iPhone SE 1st gen          | 320 x 568            | Floor for iOS                    |
| Small  | Pixel 4a (compact Android) | 360 x 800            | Floor for Android                |
| Medium | iPhone 13 / 14             | 390 x 844            | Standard iOS                     |
| Notch+ | iPhone 15 Pro              | 393 x 852            | Dynamic Island, top inset ~59pt  |
| Large  | iPhone 15 Pro Max          | 430 x 932            | Big phone                        |
| XL     | iPad mini / foldable open  | 744+ x 1133+         | Headers must not waste 35% space |

---

## Status summary

| Task                                      | Status           |
| ----------------------------------------- | ---------------- |
| Task 1 — SafeArea / status-bar coverage   | ✅ Done           |
| Task 2 — Auth-header proportional heights | ✅ Done           |
| Task 3 — Bottom-sheet fixed heights       | ✅ Done (partial — see crop-dim follow-up) |
| Task 4 — Hero / card image heights        | ✅ Done           |
| Task 5 — Cosmetic fixed sizes             | ✅ Won't fix      |
| Task 6 — Device-matrix goldens            | ✅ Done (partial — see screen-level follow-up) |

---

## Task 1 — SafeArea / status-bar coverage ✅ DONE

Verified 2026-06-09. All 32 feature `Scaffold(...)` call-sites migrated to the
shared `AppScaffold` (`lib/shared/layouts/app_scaffold.dart`). Zero raw
`Scaffold(` left in `lib/features/`. Defaults applied:

- `safeTop: true`, `safeBottom: false`, `safeLeft/Right: true`,
  `resizeToAvoidBottomInset: true`.

Bucket A (DI/status-bar collision) — all fixed:

| File                                    | Pattern                                                  |
| --------------------------------------- | -------------------------------------------------------- |
| `signup2_screen.dart:125`               | default `AppScaffold`; header `top: AppSpacing.sm`       |
| `signup3_screen.dart:216`               | default `AppScaffold`; header `top: AppSpacing.sm`       |
| `reset_password_screen.dart:87`         | default `AppScaffold`; inner `Positioned(top: AppSpacing.md)` |
| `forgot_password_screen.dart:63`        | default `AppScaffold`; inner `Positioned(top: AppSpacing.md)` |
| `forgot_password_otp_screen.dart:114`   | default `AppScaffold`; inner `Positioned(top: AppSpacing.md)` |
| `profile_new_password_screen.dart:74`   | default `AppScaffold`; inner `Positioned(top: AppSpacing.md)` |

Bucket B (decorative bleed) — `safeTop: false` + `MediaQuery.padding.top + AppSpacing.*`
applied in `login_screen.dart`, `my_profile_screen.dart` /
`profile_header.dart`, `file_viewer_screen.dart`,
`upcoming_shoot_view_details_screen.dart`,
`featuredwork_details_screen.dart` (has AppBar),
`shoot_cancelled_screen.dart` (overlay modal).

New screens MUST use `AppScaffold` — do not hand-roll `Scaffold( body: SafeArea(...))`.

### Residual nit (optional)

- `lib/features/auth/presentation/widgets/signup1_header.dart:22` still uses
  raw `top: 30`. Functionally safe (inside default SafeArea) but inconsistent
  with `signup2_header` / `signup3_header` which use `AppSpacing.sm`.
  Token-ize for consistency or leave.

---

## Task 2 — Auth-header proportional heights ✅ DONE

Applied 2026-06-09. Clamp pattern picked (Option A) so existing layout math
stays untouched. Bounds derived per multiplier from the device matrix:

| Multiplier | Files                                                                                                                                                                                                                                                                                                  | Clamp           | Rationale                                                |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- | -------------------------------------------------------- |
| `0.28`     | `signup1_header.dart:15`, `signup2_header.dart:17`, `signup3_header.dart:17`, `profile_new_password_screen.dart:81`                                                                                                                                                                                     | `180.0, 240.0`  | SE 159→180 (+21 prevents `1/3` chip + subtitle overlap); iPad 317→240 (saves 77pt waste) |
| `0.32`     | `forgot_password_screen.dart:68`, `forgot_password_otp_screen.dart:119`, `reset_password_screen.dart:92`                                                                                                                                                                                                | `200.0, 280.0`  | SE 182→200; iPad 363→280                                  |
| `0.35`     | `login_screen.dart:83`                                                                                                                                                                                                                                                                                  | `220.0, 320.0`  | SE 199→220; iPad 397→320                                  |

Also dropped hardcoded `\n` line break in `signup1_header.dart` subtitle —
`"Create your profile to get discovered by\n production teams."` →
`"Create your profile to get discovered by production teams."` so
`TextAlign.center` wraps naturally under larger text-scale settings.

`signup2_header.dart` and `signup3_header.dart` subtitles still carry `\n` —
left as-is since doc only flagged signup1. Revisit if text-scale audits
surface overflow.

`flutter analyze` clean post-change (2 pre-existing unused-import warnings
in `core/providers/core_providers.dart` unrelated).

**Verification still pending.** iPhone SE + iPad manual run. No overlap,
no >25% wasted vertical on iPad.

---

## Task 3 — Bottom-sheet containers with fixed proportional height ✅ DONE (partial)

Applied 2026-06-09. Lower-risk path picked over full
`DraggableScrollableSheet` rewrite — same keyboard-aware behaviour, no API
churn for callers.

Pattern: swap `Container(height: h * X)` for
`Container(constraints: BoxConstraints(maxHeight: h * X))`. Combined with
existing `resizeToAvoidBottomInset: true` (AppScaffold default) / sheet
`isScrollControlled: true`, the sheet shrinks when the keyboard pushes the
body up instead of getting clipped. Crop sheets also add
`bottom: AppSpacing.base + viewInsets.bottom` to padding so controls lift
above the keyboard.

| File                                                                 | Before               | After                                  |
| -------------------------------------------------------------------- | -------------------- | -------------------------------------- |
| `shoot_cancelled_screen.dart:58`                                     | `height: h * 0.75`   | `constraints.maxHeight: h * 0.85`      |
| `profile_image_crop_sheet.dart:43`                                   | `height: h * 0.85`   | `constraints.maxHeight: h * 0.85` + `viewInsets.bottom` padding |
| `signup1_crop_sheet.dart:47`                                         | `height: h * 0.85`   | `constraints.maxHeight: h * 0.85` + `viewInsets.bottom` padding |

`flutter analyze` clean post-change (2 pre-existing unused-import warnings
in `core/providers/core_providers.dart` unrelated).

**Verification still pending.** iPhone SE with keyboard open — confirm
"Others" TextField stays visible and Save buttons stay above keyboard.

### Follow-up — crop UI dimension on small phones

NOT yet done. Crop sheets still hard-code visible `SizedBox(320, 320)` +
`CustomPaint(Size(320, 320))` + `Image.file(width: 340, height: 340)` plus
`_cropImage` constants (`uiSize = 360 / 320`, `cropUI = 260`,
`CircleHolePainter` radius `130`). On iPhone SE (320 width) the crop region
overflows the sheet padding.

Doc target: `cropDim = min(size.width - 2 * AppSpacing.xl, 340.0)` and
scale every coupled constant by `cropDim / 320` to preserve crop fidelity.

Risk: crop math is tuned by hand — `profile_image_crop_sheet.dart` uses
`uiSize = 360` while `signup1_crop_sheet.dart` uses `uiSize = 320`. No
unit tests cover crop output. Defer to a follow-up sprint with a
golden / round-trip test for `_cropImage` before resizing.

Files for follow-up:
- `profile_image_crop_sheet.dart:102-128` (SizedBox + CustomPaint) +
  `:239-240` (`uiSize`, `cropUI` constants).
- `signup1_crop_sheet.dart:105-127` (SizedBox + CustomPaint) +
  `:213-214` (`uiSize`, `cropUI`) + `:271` (`CircleHolePainter` radius).

---

## Task 4 — Hero / card images with fixed pixel heights ✅ DONE

Applied 2026-06-09. Pattern picked per use:

| Category    | Aspect / bounds              | Files                                                                                                                                                                                                                       |
| ----------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hero 16:9   | `AspectRatio(16 / 9)`        | `upcoming_shoot_view_details_screen.dart` (was 330), `home_pending_shoot_card.dart` (was 220 × 3 → single wrap), `featuredwork_details_screen.dart` (was 240), `file_viewer_screen.dart` (was 200), `profile_header.dart` (was 200) |
| Card 4:3    | `AspectRatio(4 / 3)`         | `featured_work_card.dart` (was 250)                                                                                                                                                                                          |
| Google Map  | `ConstrainedBox(min 200, max h * 0.35)` | `edit_personal_details_screen.dart` (was 250), `signup1_form.dart` (was 280)                                                                                                                                                |
| Dropzone    | `ConstrainedBox(min 200, max 260)` | `pre_production_screen.dart` (was 230)                                                                                                                                                                                       |
| Empty zone  | `ConstrainedBox(min 180, max 240)` | `featured_work_upload_sheet.dart` `_emptyDropZone` (was 220)                                                                                                                                                                |
| Grid wrapper | `ConstrainedBox(min 220, max 360)` | `featured_work_upload_sheet.dart` `_imageGrid` (was 320), `signup3_featured_sheet.dart` (was 300)                                                                                                                            |

Notes:

- `home_pending_shoot_card.dart` had triple-nested `height: 220` (image,
  error fallback, empty fallback). Collapsed into one `AspectRatio` wrapping
  the ternary and dropped the inner `Center` wrappers.
- `featured_work_card.dart`: `AspectRatio` wraps the whole decorated card
  Container — keeps the surface shadow + radius proportional to width.
- Dropzones / GridView wrappers are not images but were listed in T4. Used
  `ConstrainedBox` min/max so they grow with text-scale yet cap on iPad.

`flutter analyze` clean post-change (2 pre-existing unused-import warnings
in `core/providers/core_providers.dart` unrelated).

**Verification still pending.** Pixel 4a portrait + iPad portrait manual
run. Image aspect consistent, no horizontal whitespace, Google Map
interactive at min size.

---

## Task 5 — Drag handle, status pill, progress dots (cosmetic fixed sizes) ✅ WON'T FIX

Low priority. Fixed `width: 40-42, height: 5` drag handles and pill dots are
intentional UI tokens. Leave alone unless rebranding.

---

## Task 6 — Add device-matrix golden / smoke check ✅ DONE (partial)

Applied 2026-06-09.

**Device-matrix goldens — `test/golden/device_matrix_test.dart`.**
Renders the 3 signup headers at the 3 reference viewports
(`320 × 568`, `393 × 852`, `744 × 1133`) via `tester.binding.setSurfaceSize`.
9 baselines under `test/golden/goldens/signup{1,2,3}_header_<size>.png`.

Regenerate after a deliberate header change:

```bash
flutter test --update-goldens test/golden/device_matrix_test.dart
```

Re-run on the same Flutter SDK that produced the baselines — cross-SDK
diffs are noise. Phase 6.10 golden conventions still apply.

**Manual smoke checklist — `docs/designAudit/manualSmoke.md`.**
Per-screen + per-device checklist covering every screen touched in
Tasks 1-4, plus an iOS Larger Text 200% accessibility pass. Includes a
verification log table for sign-off per release.

### Follow-up — screen-level goldens

NOT yet done. The matrix only covers the signup-header widgets because
they are dependency-free. Full-screen goldens (login, forgot-password,
my-profile, home pending-shoot card, crop sheets) need provider /
network image mocking before they can be pumped in widget tests:

- `CachedNetworkImage` widgets require an `HttpClient` override or a fake
  image-cache layer.
- Screens are `ConsumerWidget` / `ConsumerStatefulWidget` — need
  `ProviderScope` with overrides for `sessionStoreProvider`,
  `dioClientProvider`, and any repository providers they touch.
- Router-based screens depend on `GoRouter` context — pump under a
  minimal router or refactor the body widgets to accept the data the
  notifiers would supply.

Until that infra lands, regression coverage for those screens is the
manual smoke checklist.

---

## Execution Order (remaining)

Suggested merge order, each independently shippable:

1. Task 3 crop-dim follow-up — add `_cropImage` round-trip test, then
   parameterize crop dim per `min(w - 2 * AppSpacing.xl, 340)`.
2. Task 6 screen-level goldens — needs provider + network-image mocking
   infra (see Task 6 follow-up section).

## Out of Scope

- Tablet-specific layouts (two-pane, master-detail).
- Landscape orientation (app is portrait-locked today).
- Reskin of design tokens. Only sizing / safe-area fixes.