# Design Fixing — Static Sizing & Safe-Area Audit

Date: 2026-06-07
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

## Task 1 — SafeArea / status-bar coverage

> **Status (2026-06-08): superseded by [`appScaffoldPlan.md`](appScaffoldPlan.md).**
>
> All 32 feature `Scaffold(...)` call-sites migrated to the shared `AppScaffold` widget. SafeArea handling now lives in one place (`lib/shared/layouts/app_scaffold.dart`):
>
> - Default screens — `AppScaffold(body: ...)` applies `SafeArea(top: true, bottom: false, left: true, right: true)` automatically. Status bar / Dynamic Island clearance is handled.
> - Decorative-bleed screens — `AppScaffold(safeTop: false, body: ...)` keeps the historical "art bleeds under status bar" behaviour. Back-row offsets use `MediaQuery.of(context).padding.top + AppSpacing.lg` (or `.sm`).
> - Screens with `AppBar` — `AppScaffold(safeTop: false, appBar: ...)`. The AppBar already covers the inset.
> - Overlay modals (`shoot_cancelled_screen`) — `AppScaffold(safeTop: false, backgroundColor: <dim>)`.
>
> Buckets A–G below remain as the **as-of-2026-06-07 audit snapshot**. Migration completion + status markers per-file live in `appScaffoldPlan.md`. New screens should use `AppScaffold` directly — do not hand-roll `Scaffold( body: SafeArea(...))` patterns.

### Audit state (re-checked 2026-06-07)

`SafeArea` usage in `lib/`:

| Status                                    | Count | Notes                                                            |
| ----------------------------------------- | ----- | ---------------------------------------------------------------- |
| Feature `Scaffold` files total            | 32    | `rg -ln "Scaffold\(" lib/features/`                              |
| With `SafeArea` somewhere                 | 18    | Body / bottomNavigationBar / partial section                     |
| **No `SafeArea` at all**                  | 14    | Listed below                                                     |
| `Drawer` (`app_shell.dart`) has SafeArea  | 1     | Side menu — does NOT cover body of host screen                   |

Critical mental model:

- `SafeArea` resets the origin to where system insets end. A `Positioned(top: N)`
  *inside* SafeArea is `N` below the status bar — safe.
- A `Positioned(top: N)` *outside* SafeArea is `N` from screen edge. On iPhone
  15 Pro the Dynamic Island bottom is ~59pt, status bar inset is ~59pt. Any
  `top: 30` or `top: 50` outside SafeArea collides with DI.
- Centered-only screens (splash, lottie confirmations, "you're all set") have
  no top widget and do not need SafeArea unless we add one later.

### Cases by severity

**A. Confirmed DI / status-bar collision — NO SafeArea + small top inset (HIGH PRIO)**

These have `body: Stack` or `body: SingleChildScrollView` with no SafeArea wrap
AND a `Positioned(top: 50)` (or smaller) for a back button or progress chip.
On iPhone 15 Pro the chip / icon sits inside the Dynamic Island.

- `lib/features/auth/presentation/screens/signup2_screen.dart:125` — `body: Stack`, no SafeArea. Internal `Positioned` at line 288 + `SignUp2Header` (`signup2_header.dart:24` `top: 50`).
- `lib/features/auth/presentation/screens/signup3_screen.dart:217` — `body: Stack`, no SafeArea. `SignUp3Header` (`signup3_header.dart:24` `top: 50`) + internal `Positioned` lines 406, 454.
- `lib/features/auth/presentation/screens/reset_password_screen.dart:87` — `body: SingleChildScrollView` (no SafeArea) wrapping Stack with `Positioned(top: 50)` for back arrow.
- `lib/features/auth/presentation/screens/forgot_password_screen.dart:63` — same pattern, `top: 50`.
- `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart:114` — same pattern, `top: 50`.
- `lib/features/profile/presentation/screens/profile_new_password_screen.dart:74` — `body: Stack`, no SafeArea, `Positioned(top: 50)` back arrow.

**B. NO SafeArea but top inset large enough to clear DI (MEDIUM PRIO — visual only)**

Back arrow / icons at `top: 90` from screen edge. Above the DI on every iPhone
(DI ends at ~59pt) and above status bar on every Android. Acceptable
functionally, but inconsistent — same screens should not mix manual offsets
with SafeArea screens. Decorative `Stack` background art (`rectangleProfile`,
hero `CachedNetworkImage`) is intentionally allowed to extend under the status
bar.

- `lib/features/profile/presentation/screens/my_profile_screen.dart:234` — `ProfileHeader` `Positioned(top: 90)` lines 47, 62.
- `lib/features/profile/presentation/screens/featuredwork_details_screen.dart:97` — has its own `AppBar`, so it is actually safe. Drop from list.
- `lib/features/file_manager/presentation/screens/file_viewer_screen.dart:26` — `Positioned(top: 90)` lines 45, 53, plus `bottom: -48` line 65 (intentional overlap).
- `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart:38` — `Positioned(top: 50)` for back arrow. Move to bucket A — `top: 50` on iPhone 15 Pro = DI collision.
- `lib/features/auth/presentation/screens/login_screen.dart:77` — no SafeArea, but body is `SingleChildScrollView` whose first child is a `0.35 * height` banner. No top buttons — system status bar overlays the banner gradient. Acceptable today; revisit if a back / language toggle is added.

**C. Already inside a SafeArea — fine, no work needed**

- `lib/features/auth/presentation/screens/signup1_screen.dart:215` — `body: SafeArea(child: Stack(...))`. `SignUp1Header` `Positioned(top: 30)` is 30pt below the inset — safe.
- All files in the `SafeArea` grep list above. Sanity-check that their SafeArea wraps the relevant `Positioned` subtree and not only a sibling Column.

**D. Centered-only screens — no SafeArea required**

- `lib/features/splash/presentation/screens/splash_screen.dart`
- `lib/features/shoots/presentation/screens/shoot_cancelled_lotties_screen.dart`
- `lib/features/profile/presentation/screens/profile_youre_all_set_screen.dart`
- `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart`

Verify nothing is added near the top edge later; if it is, add SafeArea.

### Bottom-inset (home indicator) audit

Most fixed bottoms are routed through `bottomNavigationBar:` of `Scaffold`, which
Flutter already pads for the home indicator. Two exceptions found:

- `lib/features/availability/presentation/screens/add_availability_screen.dart:373` —
  `bottomNavigationBar: SafeArea(top: false, ...)`. Correct.
- `lib/features/home/presentation/widgets/home_welcome_header.dart:51` —
  `SafeArea(bottom: false, ...)`. Correct (header at the top).

No fixed-position bottom buttons inside `body` Stacks were found. If one is
added later, wrap in `SafeArea(top: false, minimum: EdgeInsets.only(bottom: AppSpacing.md))`.

### Pattern to apply (Bucket A files)

**Resolved via `AppScaffold` migration.** See [`appScaffoldPlan.md`](appScaffoldPlan.md) §"Proposed API" for the canonical patterns:

- Default (Bucket A, C, D, onboarding): `AppScaffold(body: ...)` — implicit `SafeArea(top: true, bottom: false, left: true, right: true)`.
- Bleed (Bucket B, login hero, file viewer hero, my-profile hero): `AppScaffold(safeTop: false, body: Stack(...))` with `Positioned(top: MediaQuery.of(context).padding.top + AppSpacing.lg, ...)` for back rows.
- AppBar host (`featuredwork_details_screen`): `AppScaffold(safeTop: false, appBar: AppBar(...))` — AppBar covers the inset.
- Overlay modal (`shoot_cancelled_screen`): `AppScaffold(safeTop: false, backgroundColor: AppColors.black.withValues(alpha: 0.4), ...)`.

Header widgets (`signup2_header.dart`, `signup3_header.dart`): inner `Positioned(top: 50)` is now `top: AppSpacing.sm` (host body is inside `AppScaffold`'s SafeArea).

Pick one approach per screen — do not mix. Do not hand-roll `Scaffold( body: SafeArea(...))` in new code; use `AppScaffold`.

### Verification

- iPhone SE 1st gen simulator (no notch) + iPhone 15 Pro simulator (DI) +
  Pixel 4a (camera cutout).
- Status bar / Dynamic Island must never overlap interactive widgets.
- Home indicator must never sit on top of a button.
- Toggle iOS Control Center "Larger Text" 200% and confirm the header chip /
  back row still has space.

---

## Task 2 — Auth-header proportional heights

**Problem.** `height: MediaQuery.of(context).size.height * 0.28` (and `0.32` /
`0.35`) is used for top banners. On iPhone SE (568 * 0.28 = 159pt) the centered
Column with multi-line subtitle and the `1/3` badge overlap. On iPad / foldable
(1133 * 0.28 = 317pt) headers waste large vertical space.

**Files:**

- `lib/features/auth/presentation/widgets/signup1_header.dart:15` — `0.28`
- `lib/features/auth/presentation/widgets/signup2_header.dart:17` — `0.28`
- `lib/features/auth/presentation/widgets/signup3_header.dart:17` — `0.28`
- `lib/features/auth/presentation/screens/login_screen.dart:81` — `0.35`
- `lib/features/auth/presentation/screens/forgot_password_screen.dart:67` — `0.32`
- `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart:118` — `0.32`
- `lib/features/auth/presentation/screens/reset_password_screen.dart:91` — `0.32`
- `lib/features/profile/presentation/screens/profile_new_password_screen.dart:80` — `0.28`

**Pattern to apply.** Clamp the proportional height, or switch to
`IntrinsicHeight` + min padding so content drives the size.

```dart
// Option A — clamp
height: (MediaQuery.of(context).size.height * 0.28).clamp(180.0, 240.0),

// Option B — content-driven
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 180, maxHeight: 240),
  child: IntrinsicHeight(child: ...),
),
```

Also drop the hardcoded `\n` line break in the subtitle of `signup1_header.dart`
(`"Create your profile to get discovered by\n production teams."`) — let
`TextAlign.center` wrap naturally so it survives larger text scale factors.

**Verification.** iPhone SE + iPad. No overlap, no >25% wasted vertical on iPad.

---

## Task 3 — Bottom-sheet containers with fixed proportional height

**Problem.** Bottom sheets use `Container(height: size.height * 0.75 / 0.85)`
which ignores keyboard. `resizeToAvoidBottomInset: true` is set but the fixed
inner Container will not shrink — content gets cut on small phones when the
soft keyboard opens.

**Files:**

- `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart:57` — `0.75`
- `lib/features/profile/presentation/widgets/profile_image_crop_sheet.dart:43` — `0.85`
- `lib/features/auth/presentation/widgets/signup1_crop_sheet.dart:47` — `0.85`

Crop sheets additionally wrap a fixed `320 / 340` px crop area
(`profile_image_crop_sheet.dart:103-114`). On iPhone SE that leaves ~80pt for
controls — cramped.

**Pattern to apply.** Replace the fixed-height Container with
`DraggableScrollableSheet` (for resizable sheets) or wrap content in
`SingleChildScrollView` + `Padding(bottom: viewInsets.bottom)` so keyboard
resizes correctly. Crop area sizing should derive from
`min(size.width - 2 * AppSpacing.xl, 340)`.

```dart
showModalBottomSheet(
  isScrollControlled: true,
  builder: (_) => DraggableScrollableSheet(
    initialChildSize: 0.75,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    expand: false,
    builder: (_, scrollController) => ...,
  ),
);
```

**Verification.** iPhone SE with keyboard open. Form fields stay visible. Crop
area not larger than viewport width.

---

## Task 4 — Hero / card images with fixed pixel heights

**Problem.** Image widgets pin `height: 220 / 230 / 240 / 250 / 300 / 320 / 330`
with `width: double.infinity`. On narrow Android phones (360dp) and tablets the
aspect ratio distorts and content shifts off-grid.

**Files:**

- `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart:47` — `height: 330`
- `lib/features/home/presentation/widgets/home_pending_shoot_card.dart:71,78,88` — `height: 220` (triple-nested)
- `lib/features/profile/presentation/widgets/featured_work_card.dart:41` — `height: 250`
- `lib/features/profile/presentation/screens/featuredwork_details_screen.dart:106` — `height: 240`
- `lib/features/file_manager/presentation/screens/pre_production_screen.dart:324` — `height: 230`
- `lib/features/file_manager/presentation/screens/file_viewer_screen.dart:36` — `height: 200`
- `lib/features/profile/presentation/widgets/profile_header.dart:37` — `height: 200`
- `lib/features/profile/presentation/widgets/featured_work_upload_sheet.dart:149,186` — `height: 220, 320`
- `lib/features/profile/presentation/screens/edit_personal_details_screen.dart:266` — `height: 250`
- `lib/features/auth/presentation/widgets/signup1_form.dart:146` — Google Map `height: 280`
- `lib/features/auth/presentation/widgets/signup3_featured_sheet.dart:139` — `height: 300`

**Pattern to apply.** Use `AspectRatio` so the image scales with the column
width.

```dart
// Before
SizedBox(height: 220, width: double.infinity, child: image)

// After (16:9 hero, 4:3 card, pick per use)
AspectRatio(aspectRatio: 16 / 9, child: image)
```

For the Google Map, keep a min-height to stay interactive but cap to viewport:

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minHeight: 200,
    maxHeight: MediaQuery.of(context).size.height * 0.35,
  ),
  child: GoogleMap(...),
),
```

**Verification.** Pixel 4a portrait + iPad portrait. Image aspect stays
consistent, no horizontal whitespace.

---

## Task 5 — Drag handle, status pill, progress dots (cosmetic fixed sizes)

Low priority. Fixed `width: 40-42, height: 5` drag handles and pill dots are
fine — they are intentional UI tokens. Leave alone unless rebranding.

---

## Task 6 — Add device-matrix golden / smoke check

After Tasks 1-4:

1. Add golden tests under `test/golden/` for the auth screens, profile header,
   home pending-shoot card, and crop sheets at three viewport sizes
   (320x568, 393x852, 744x1133) using `tester.binding.setSurfaceSize`.
2. Add a manual smoke checklist to `docs/designAudit/` documenting the steps
   to run on iPhone SE simulator + iPhone 15 Pro simulator + Pixel 4a +
   foldable / iPad before marking the task complete.
3. Toggle iOS Larger Text (Accessibility) to 200% on iPhone SE to confirm fixed
   image heights do not overflow scaled text.

---

## Execution Order

Suggested merge order, each independently shippable:

1. Task 1 (SafeArea) — single mechanical pattern, high user-visible win.
2. Task 2 (auth header clamp) — touches 4 screens, single pattern.
3. Task 4 (AspectRatio for images) — visual polish across home / profile.
4. Task 3 (bottom-sheet rewrite) — riskier, needs keyboard + crop QA.
5. Task 6 (golden + manual matrix) — locks the wins.

## Out of Scope

- Tablet-specific layouts (two-pane, master-detail).
- Landscape orientation (app is portrait-locked today).
- Reskin of design tokens. Only sizing / safe-area fixes.
