# Manual Smoke Checklist — Design-Audit Tasks 1-4

Last updated: 2026-06-09
Scope: post-merge sanity pass for the static-sizing / SafeArea work in
[`designFixing.md`](designFixing.md). Run on real devices / simulators —
the device-matrix goldens (`test/golden/device_matrix_test.dart`) catch
header drift only.

Run BEFORE marking a release branch shippable. Append a row to the
verification log at the bottom with the date + tester.

---

## Device matrix (run all four for each release)

| # | Device                          | Why                                                            |
| - | ------------------------------- | -------------------------------------------------------------- |
| 1 | iPhone SE 1st gen simulator     | iOS small-screen floor (320 x 568). Header overlap / overflow. |
| 2 | iPhone 15 Pro simulator         | Dynamic Island. Status-bar / DI collision with top widgets.    |
| 3 | Pixel 4a (real or emulator)     | Compact Android (360 x 800). Camera cutout, status-bar inset.  |
| 4 | iPad mini OR foldable open      | XL viewport (≥744 wide). Caps on header / hero / map heights.  |

---

## Per-screen checks

For every screen below, on every device:

- [ ] No widget overlaps the status bar / Dynamic Island.
- [ ] No widget sits under the home indicator.
- [ ] No `>25%` wasted vertical space on the XL device.
- [ ] No horizontal whitespace beside hero / card images.

### Auth screens

- [ ] **Login** (`login_screen.dart`)
  - Hero clamps 220-320pt. SE: not crushed. iPad: not stretched.
  - Welcome subtitle wraps without manual `\n`.
- [ ] **Signup step 1** (`signup1_screen.dart` + `signup1_header.dart`)
  - Header 180-240pt. `1/3` chip + subtitle do not overlap on SE.
  - Subtitle wraps naturally (no hard `\n`).
- [ ] **Signup step 2** (`signup2_screen.dart` + `signup2_header.dart`)
  - Header 180-240pt. Back arrow + `2/3` chip clear of DI on iPhone 15 Pro.
- [ ] **Signup step 3** (`signup3_screen.dart` + `signup3_header.dart`)
  - Header 180-240pt. Back arrow + `3/3` chip clear of DI on iPhone 15 Pro.
- [ ] **Forgot password** (`forgot_password_screen.dart`) — header 200-280pt.
- [ ] **Forgot password OTP** (`forgot_password_otp_screen.dart`) — header 200-280pt.
- [ ] **Reset password** (`reset_password_screen.dart`) — header 200-280pt.
- [ ] **Profile new password** (`profile_new_password_screen.dart`) — header 180-240pt.

### Home / shoots

- [ ] **Home pending-shoot card** (`home_pending_shoot_card.dart`)
  - Hero scales 16:9 with card width on all devices.
  - Gradient overlay fills the new height correctly.
- [ ] **Upcoming shoot view-details** (`upcoming_shoot_view_details_screen.dart`)
  - Hero scales 16:9. Back arrow clears DI on iPhone 15 Pro.

### Profile

- [ ] **My profile** (`my_profile_screen.dart` + `profile_header.dart`)
  - Header SVG scales 16:9. Back arrow + title above DI on iPhone 15 Pro.
- [ ] **Featured-work list card** (`featured_work_card.dart`)
  - Card 4:3 with width. Edit / delete pills don't crop.
- [ ] **Featured-work details** (`featuredwork_details_screen.dart`)
  - Images 16:9 inside the AppBar layout.
- [ ] **Edit personal details** (`edit_personal_details_screen.dart`)
  - Google Map height = `min(250, h * 0.35)`, ≥200. Map interactive.

### File manager

- [ ] **File viewer** (`file_viewer_screen.dart`)
  - Header 16:9. Title text centered. Folder pill (`bottom: -48`) sits below.
- [ ] **Pre-production** (`pre_production_screen.dart`)
  - Upload drop zone 200-260pt. Icon + label centred.

### Crop sheets (keyboard test)

- [ ] **Profile image crop** (`profile_image_crop_sheet.dart`)
  - Sheet ≤ 85% screen height. Save button visible above keyboard if any.
  - **Known limitation:** crop area still hard-coded 320×320 — looks tight
    on iPhone SE. See follow-up in `designFixing.md` Task 3.
- [ ] **Signup1 crop** (`signup1_crop_sheet.dart`) — same as above.
- [ ] **Decline shoot sheet** (`shoot_cancelled_screen.dart`)
  - Pick "Others" → TextField appears, keyboard opens.
  - Sheet shrinks; Decline / Cancel buttons stay above keyboard.
  - Reasons list scrolls instead of being clipped.

### Bottom sheets / upload zones

- [ ] **Featured-work upload sheet** (`featured_work_upload_sheet.dart`)
  - Empty drop zone 180-240pt.
  - Grid 220-360pt — grows on iPad but capped.
- [ ] **Signup3 featured sheet** (`signup3_featured_sheet.dart`)
  - Grid 220-360pt.

---

## Accessibility — Larger Text 200%

Run on iPhone SE 1st gen simulator (smallest floor):

- [ ] Settings → Accessibility → Display & Text Size → Larger Text → 200%.
- [ ] Re-walk the **Auth screens** section. Header subtitles wrap; no
      `RenderFlex overflowed` red bars in the debug log.
- [ ] Re-walk the **Profile / Home cards** section. Card text + buttons
      stay inside the AspectRatio frame without cropping.
- [ ] Re-walk the **Crop sheets**. Save button still tappable.

---

## Verification log

| Date       | Branch / build           | Tester    | Devices run | Notes / issues filed |
| ---------- | ------------------------ | --------- | ----------- | -------------------- |
| YYYY-MM-DD | improvments-phase1 @ sha | name      | 1, 2, 3, 4  |                      |
