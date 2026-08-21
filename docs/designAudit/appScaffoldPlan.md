# Centralised `AppScaffold` + SafeArea Plan

Date: 2026-06-08
Scope: `lib/` Flutter UI
Goal: Replace 32 hand-rolled `Scaffold(...)` call-sites with one shared
`AppScaffold` widget. Move SafeArea, background colour, status-bar style, and
keyboard-resize defaults into one place so every new screen inherits correct
behaviour. Prerequisite to `designFixing.md` Task 1 (SafeArea audit).

Companion to: [`designFixing.md`](designFixing.md).

## Status legend

| Marker | Meaning      |
| ------ | ------------ |
| 🔴      | Not started  |
| 🟡      | In progress  |
| 🟢      | Done         |

Update the **Status** column on every task / file row as work moves. Keep the
top-level task table in sync with bucket sub-tables.

---

## Why

- 32 `Scaffold(...)` sites in `lib/features/` — 14 missing SafeArea, 6 with
  Dynamic Island collisions, all repeat the same `backgroundColor: AppColors.background`
  + `resizeToAvoidBottomInset: true` defaults.
- One central widget = one place to fix DI overlap, status-bar style, future
  edge-to-edge changes, and golden-test baselines.
- Future screens get safe-area + bg + keyboard handling for free.

## Non-goals

- Replace `Scaffold` inside `AppShell` (`lib/shared/layouts/app_shell.dart`) —
  shell is the host of `StatefulShellRoute`, stays raw.
- Replace dialog-host `Scaffold` in `common_file_viewer.dart:29` — internal
  full-screen viewer, keep raw.
- Wrap `MaterialApp` in `SafeArea` — breaks drawer / sheet edge-to-edge.
- Tablet / landscape layouts. Out of scope per `designFixing.md`.

---

## Proposed API

`lib/shared/layouts/app_scaffold.dart` (new file).

```dart
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Color? backgroundColor;

  /// SafeArea wrapping around [body]. Defaults: top=true, bottom=false,
  /// left=true, right=true. bottom=false because `bottomNavigationBar`
  /// and the home-indicator are already inset by Flutter.
  final bool safeTop;
  final bool safeBottom;
  final bool safeLeft;
  final bool safeRight;

  /// Set false when a decorative Stack should bleed under the status bar.
  /// Handle the back-row offset inline with `MediaQuery.padding.top`.
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.backgroundColor,
    this.safeTop = true,
    this.safeBottom = false,
    this.safeLeft = true,
    this.safeRight = true,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final wantsSafeArea = safeTop || safeBottom || safeLeft || safeRight;
    final content = wantsSafeArea
        ? SafeArea(
            top: safeTop,
            bottom: safeBottom,
            left: safeLeft,
            right: safeRight,
            child: body,
          )
        : body;
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
```

### Decorative-bleed pattern (safeTop:false)

```dart
AppScaffold(
  safeTop: false,
  body: Stack(
    children: [
      // Decorative hero, intentional bleed under status bar.
      Positioned.fill(child: heroImage),
      // Back row sits below status bar inset, computed inline.
      Positioned(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        child: backRow,
      ),
    ],
  ),
)
```

---

## Migration buckets

### Bucket A — DI collision (no SafeArea, `Positioned(top: 50)`)

Migrate to `AppScaffold` with default `safeTop: true`. **Drop** the manual
`top: 50` offset from internal `Positioned` and from header widgets.

| Status | File                                                                                       | Scaffold line | Internal offset to drop                                                                                |
| ------ | ------------------------------------------------------------------------------------------ | ------------- | ------------------------------------------------------------------------------------------------------ |
| 🟢      | `lib/features/auth/presentation/screens/signup2_screen.dart`                               | 124           | header `top: 50` → `AppSpacing.sm`. Internal `Positioned(top:-40)` is decorative card overlap — kept.   |
| 🟢      | `lib/features/auth/presentation/screens/signup3_screen.dart`                               | 215           | header `top: 50` → `AppSpacing.sm`. Internal `top:-24` / `top:-30` are decorative card overlaps — kept. |
| 🟢      | `lib/features/auth/presentation/screens/reset_password_screen.dart`                        | 86            | `Positioned(top: 50)` → `AppSpacing.md`                                                                |
| 🟢      | `lib/features/auth/presentation/screens/forgot_password_screen.dart`                       | 62            | `Positioned(top: 50)` → `AppSpacing.md`                                                                |
| 🟢      | `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart`                   | 113           | `Positioned(top: 50)` → `AppSpacing.md`                                                                |
| 🟢      | `lib/features/profile/presentation/screens/profile_new_password_screen.dart`               | 73            | `Positioned(top: 50)` → `AppSpacing.md`                                                                |
| 🟢      | `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`         | 37            | `safeTop: false` (330pt hero bleeds); `top: 50` → `MediaQuery.padding.top + AppSpacing.sm`             |

### Bucket B — decorative bleed (`safeTop: false`)

Migrate to `AppScaffold(safeTop: false, ...)`. Convert any `Positioned(top: 90)`
to `MediaQuery.padding.top + AppSpacing.lg` so spacing tracks the system inset
instead of a magic number.

| Status | File                                                                                       | Scaffold line | Notes                                                                  |
| ------ | ------------------------------------------------------------------------------------------ | ------------- | ---------------------------------------------------------------------- |
| 🟢      | `lib/features/profile/presentation/screens/my_profile_screen.dart`                         | 234           | `safeTop: false`. `ProfileHeader` `Positioned(top: 90)` → `MediaQuery.padding.top + AppSpacing.lg` (2 sites) |
| 🟢      | `lib/features/file_manager/presentation/screens/file_viewer_screen.dart`                   | 25            | `safeTop: false`. `Positioned(top: 90)` → `MediaQuery.padding.top + AppSpacing.lg` (2 sites). `bottom: -48` overlap kept |
| 🟢      | `lib/features/auth/presentation/screens/login_screen.dart`                                 | 76            | `safeTop: false`. 0.35-height hero banner intact                       |

### Bucket C — already has SafeArea (just adopt wrapper)

Migrate to `AppScaffold(safeTop: true, ...)`. Drop the explicit `SafeArea(...)`
wrap around the body — `AppScaffold` does it.

| Status | File                                                                                       | Scaffold line | Existing SafeArea to remove                                  |
| ------ | ------------------------------------------------------------------------------------------ | ------------- | ------------------------------------------------------------ |
| 🟢      | `lib/features/auth/presentation/screens/signup1_screen.dart`                               | 214           | dropped SafeArea wrap around root Stack                       |
| 🟢      | `lib/features/file_manager/presentation/screens/post_production_screen.dart`               | 39            | dropped SafeArea, also dropped redundant `backgroundColor: AppColors.background` |
| 🟢      | `lib/features/file_manager/presentation/screens/pre_production_screen.dart`                | 40            | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/enter_profile_details_screen.dart`              | 81            | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/certificates_screen.dart`                       | 35            | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/profile_otp_screen.dart`                        | 119           | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/featured_work_list_screen.dart`                 | 130           | dropped Stack-child SafeArea (kept Stack)                     |
| 🟢      | `lib/features/profile/presentation/screens/delete_account_screen.dart`                     | 47            | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/change_password_screen.dart`                    | 64            | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/profile_details_1_screen.dart`                  | 26            | dropped Stack-child SafeArea (kept Stack)                     |
| 🟢      | `lib/features/profile/presentation/screens/app_preferences_screen.dart`                    | 23            | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/delete_account_otp_screen.dart`                 | 116           | dropped SafeArea                                              |
| 🟢      | `lib/features/profile/presentation/screens/edit_personal_details_screen.dart`              | 195           | dropped Stack-child SafeArea (kept Stack)                     |
| 🟢      | `lib/features/profile/presentation/screens/resume_screen.dart`                             | 35            | dropped SafeArea                                              |

### Bucket D — centred-only (no top widget)

Migrate to `AppScaffold(safeTop: true, ...)` for consistency. No visual change.

| Status | File                                                                                       | Scaffold line |
| ------ | ------------------------------------------------------------------------------------------ | ------------- |
| 🟢      | `lib/features/splash/presentation/screens/splash_screen.dart`                              | 76            |
| 🟢      | `lib/features/shoots/presentation/screens/shoot_cancelled_lotties_screen.dart`             | 33            |
| 🟢      | `lib/features/profile/presentation/screens/profile_youre_all_set_screen.dart`              | 33            |
| 🟢      | `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart`              | 33            |

### Bucket E — uses `AppBar` (no SafeArea needed on body)

Migrate to `AppScaffold(appBar: ..., safeTop: false, ...)`. `AppBar` already
covers the status-bar inset.

| Status | File                                                                                       | Scaffold line | Notes                                |
| ------ | ------------------------------------------------------------------------------------------ | ------------- | ------------------------------------ |
| 🟢      | `lib/features/profile/presentation/screens/featuredwork_details_screen.dart`               | 75            | `safeTop: false` (AppBar covers status bar inset)        |
| 🟢      | `lib/features/onboarding/presentation/screens/onboarding_screen.dart`                      | 67            | dropped body SafeArea wrap; default `safeTop: true`      |

### Bucket F — overlay / modal-style Scaffold

Migrate to `AppScaffold(backgroundColor: ..., safeTop: false, ...)`.

| Status | File                                                                                       | Scaffold line | Background                            |
| ------ | ------------------------------------------------------------------------------------------ | ------------- | ------------------------------------- |
| 🟢      | `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart`                     | 51            | `safeTop: false`, kept `backgroundColor: AppColors.black.withValues(alpha: 0.4)`; dropped redundant `resizeToAvoidBottomInset: true` (now default) |

### Bucket G — keep raw `Scaffold`

| Status | File                                                       | Reason                                                            |
| ------ | ---------------------------------------------------------- | ----------------------------------------------------------------- |
| 🟢      | `lib/shared/layouts/app_shell.dart:59`                     | Shell host. Owns drawer + bottom bar across branches.             |
| 🟢      | `lib/shared/widgets/common_file_viewer.dart:29`            | Inline dialog builder, isolated.                                  |
| 🟢      | `lib/features/availability/presentation/screens/add_availability_screen.dart:200` | Migrated to `AppScaffold`. `bottomNavigationBar: SafeArea(top: false, ...)` left in place — `AppScaffold` does not own bottom-nav SafeArea. |

---

## Tasks

| Status | Task | Title                                       | Files touched                                            | Risk   |
| ------ | ---- | ------------------------------------------- | -------------------------------------------------------- | ------ |
| 🟢      | T-0  | Land `AppScaffold` widget + unit test       | +1 new file: `lib/shared/layouts/app_scaffold.dart` + `test/shared/layouts/app_scaffold_test.dart` | low    |
| 🟢      | T-1  | Migrate Bucket A (DI collision)             | 7 screens + 2 header widgets (`signup2_header.dart`, `signup3_header.dart`) | medium |
| 🟢      | T-2  | Migrate Bucket B (decorative bleed)         | 3 screens + `profile_header.dart`                        | medium |
| 🟢      | T-3  | Migrate Bucket C (drop redundant SafeArea)  | 14 screens                                               | low    |
| 🟢      | T-4  | Migrate Bucket D (centred-only)             | 4 screens                                                | low    |
| 🟢      | T-5  | Migrate Bucket E + F + opt-in G screens     | 4 screens (featuredwork_details, onboarding, shoot_cancelled, add_availability) | low    |
| 🟡      | T-6  | Re-baseline goldens, manual matrix QA       | Re-run `flutter test --update-goldens test/golden/`; manual pass on SE / 15 Pro / Pixel 4a | low    |
| 🟢      | T-7  | Update `designFixing.md` Task 1 to delta    | docs only                                                | none   |

### T-0 — Land `AppScaffold`

- Create `lib/shared/layouts/app_scaffold.dart` per API above.
- Unit test: default render uses SafeArea with top=true, bottom=false; `safeTop:false` skips top inset; backgroundColor falls back to `AppColors.background`.
- No call-site changes yet.

### T-1 — Bucket A migration (DI collision)

- For each of the 7 screens: replace `Scaffold(` with `AppScaffold(`, drop `backgroundColor:` if it equals `AppColors.background`.
- Drop `Positioned(top: 50, ...)` → `Positioned(top: AppSpacing.md, ...)` (or `AppSpacing.sm` if visually tighter).
- Update `signup2_header.dart` + `signup3_header.dart`: `top: 50` → `AppSpacing.sm`.
- QA on iPhone 15 Pro simulator. Verify back arrow / progress chip clears DI.

### T-2 — Bucket B migration (decorative bleed)

- `AppScaffold(safeTop: false, ...)` per screen.
- `Positioned(top: 90)` → `MediaQuery.of(context).padding.top + AppSpacing.lg`.
- Verify hero image still bleeds under status bar visually.

### T-3 — Bucket C migration (drop SafeArea wrap)

- For each: replace outer `Scaffold(...)` with `AppScaffold(...)`, delete the inner `SafeArea(child: ...)` wrap, hoist its child to `body:`.
- Verify nothing renders behind status bar.

### T-4 — Bucket D migration (centred-only)

- Mechanical rename to `AppScaffold`. No SafeArea change needed visually but applied for consistency.

### T-5 — Bucket E + F + opt-in G

- `featuredwork_details_screen.dart`: keep `appBar:`, switch to `AppScaffold(safeTop: false, appBar: ..., body: ...)`.
- `onboarding_screen.dart`: `AppScaffold(safeTop: true, body: ...)`.
- `shoot_cancelled_screen.dart`: `AppScaffold(safeTop: false, backgroundColor: AppColors.black.withValues(alpha: 0.4), body: ...)`.
- `add_availability_screen.dart`: convert if diff stays small. `bottomNavigationBar: SafeArea(top:false, ...)` stays — `AppScaffold` does not own bottomNav SafeArea.

### T-6 — Goldens + manual QA

Automated (done):

- `flutter test test/golden/` — **13/13 pass, no re-baseline required**. Goldens cover shared widget primitives (`AppButton`, `AppCard`, `AppTextField`, `AppAvatar`); migration did not touch those widgets.
- `flutter analyze` — clean.
- `flutter test` (full suite) — **477 pass, 1 fail**. Single failure is `test/features/messages/presentation/screens/messages_screen_test.dart` (`MessagesScreen renders placeholder empty state` — expects `find.text('messages')` but screen renders `'Messages'`). Pre-existing on `main` (verified via `git stash`), unrelated to this migration.

Deferred (manual, needs simulator):

- [ ] iPhone SE 1st gen sim — back arrow + chip clearance on all Bucket A + B screens; no DI overlap (no DI on SE but verifies SafeArea bias).
- [ ] iPhone 15 Pro sim — DI clearance on all Bucket A + B screens; specifically `signup2/3_header`, all 5 password / OTP back-arrow screens, `my_profile_screen`, `file_viewer_screen`, `upcoming_shoot_view_details_screen`, `login_screen` hero bleed.
- [ ] Pixel 4a — camera-cutout clearance; verify safeTop:false bleed screens still bleed correctly under Android status bar.
- [ ] iOS Larger Text 200% on iPhone SE — confirm Bucket A back-row + DI clearance still holds, no `signup2/3_header` overlap.
- [ ] Keyboard open on `enter_profile_details_screen`, `change_password_screen`, `profile_otp_screen`, `delete_account_otp_screen`, `add_availability_screen` — confirm `resizeToAvoidBottomInset` still works.
- [ ] Decorative bleed screens (`my_profile_screen`, `file_viewer_screen`, `login_screen`) — confirm hero / banner art still bleeds under status bar, no black gap.
- [ ] `shoot_cancelled_screen` overlay sheet — confirm dim background still covers full viewport, keyboard resize works.

Lock T-6 once manual matrix is signed off. Status remains 🟡 until then.

### T-7 — Doc sync

- Edit `designFixing.md` Task 1 to read "Set `safeTop: true` on Bucket A files (already done via T-1)" instead of the manual SafeArea-wrap recipe.
- Drop the redundant `// Before / // After` snippet from `designFixing.md` §107-129.

---

## Execution order

T-0 → T-1 → T-3 → T-4 → T-5 → T-2 → T-6 → T-7.

Reason: T-0 lands the widget; T-1 has highest user-visible win; T-3 / T-4 / T-5
are mechanical and low-risk so they batch cheaply; T-2 last among code changes
because decorative-bleed needs careful visual check; T-6 locks; T-7 closes
loop.

Each task independently shippable.

## Verification

- `flutter analyze` — clean.
- `flutter test` — clean. Goldens re-baselined in T-6.
- Manual: iPhone SE + iPhone 15 Pro + Pixel 4a.
- No nested `Scaffold` warnings in debug overlay.
- No double SafeArea inset (visible as extra top whitespace) on any migrated screen.

## Rollback

Each task is one widget rename per file. Revert by file. T-0 widget can stay
indefinitely with zero call-sites if a bucket is rolled back.
