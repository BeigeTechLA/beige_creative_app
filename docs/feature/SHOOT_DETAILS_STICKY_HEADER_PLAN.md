# Shoot Details sticky header plan

Created: 2026-11-13
Status: Implemented and verified on 2026-11-13; physical-device and Android-native checks remain pending.
Related task: [4.13](../phase4/task_13_groupD_upcoming_details.md).

## Scope and decision

Planning target is `UpcomingShootViewDetails` in this CP repository, based on
the preceding discussion. Figma node `7343:62991` shows a creator profile that
was not found here; it is a visual reference, not an exact screen mapping.
User approved implementation for this CP Shoot Details target.

Implemented a collapsing photo header with a pinned, full-width toolbar. This
supersedes the November 4 non-sticky preference for this screen. Keep the plain arrow without a circular background.

## Intended behavior

- Expanded: retain the photo, shoot name, status and ID; white back arrow sits
  above a dark overlay that stays dark through the entire toolbar before fading.
- Scrolling: photo and its metadata collapse smoothly; an opaque charcoal
  toolbar emerges before body content reaches the controls. Avoid a floating
  arrow overlapping readable content and avoid duplicate visible titles.
- Collapsed: a 56-logical-pixel toolbar below the status bar shows Back and the
  project name (single line, ellipsis; `Shoot Details` while unavailable).
- Back uses the existing asset at 24 pixels with a 48×48 tap area, tooltip,
  semantic label, and press feedback. Apply the larger target locally.
- Keep status-bar icons light against a dark backing throughout scrolling.
  Use existing app colors, typography and spacing tokens.
- Preserve loading/submitting overlays, data loading, image placeholders,
  error handling, body sections and existing actions.
- Shoot Details has no Share/Favourite actions: adding these is outside scope.

## Implementation approach

Replace the screen's main `SingleChildScrollView` with `CustomScrollView`.
Use `SliverAppBar(pinned: true, floating: false, snap: false)` and place existing
body content in `SliverToBoxAdapter`. Keep the outer Stack for existing overlays.
Keep `AppScaffold(safeTop: false)` and let the app bar account for the top inset
once. Preserve the current 362-pixel total expanded hero footprint at standard
text size, accounting for the inset in the sliver height calculation. Allow
extra height if needed for large text rather than clipping hero metadata.

Derive toolbar/background/title transitions from sliver layout constraints;
avoid a global scroll listener or manual horizontal gesture recognizer.
Extract a feature-local header widget if necessary to keep the screen readable.
Use SDK Material widgets consistent with the existing route page helper.

Retain `context.canPop() ? context.pop() : context.goNamed(Routes.shoots.name)`.
The fallback applies to the visible button. Do not force root-level system back
or iOS swipes to synthesize route history. Keep `appPageBuilder` and route extras.

## Phases

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Review target, behavior and implementation plan | This plan; task 4.13; migration log | Screen mapping limitation and design decisions recorded; plan ready for review | Completed |
| 2 | Build collapsing photo and pinned toolbar | `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`; `lib/features/shoots/presentation/widgets/shoot_details_header.dart` | Expanded and collapsed states readable, safe-area correct, body preserved | Completed |
| 3 | Verify back events and scroll interaction | `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart`; `test/features/shoots/presentation/widgets/shoot_details_header_test.dart`; `integration_test/navigation_back_test.dart` | Arrow pops exactly once in both states; root button fallback; completed/cancelled iOS swipe; Android Back; vertical scroll does not pop | Completed |
| 4 | Visual QA and handoff | This plan; task 4.13; `MIGRATION_LOG.md`; `docs/AI_HANDOFF.md` | Focused checks and analysis pass; device results or limitations recorded; approved preference supersedes old note | Completed |

## Verification

Add behavioral widget coverage for the real screen's expanded/collapsed back
button, no-history fallback, title transition, retained controls after scroll,
and production-route swipe after collapse. Use existing fake providers so no
backend mutations are required. Exercise long names, large text and bright or
failed images for layout/contrast. Keep existing shared route tests.

Run focused details and route/page tests, then scoped Flutter analysis and
`git diff --check`. Run navigation integration on available iOS and Android
devices; record unavailable-device checks as pending. Capture expanded,
intermediate and collapsed screenshots; automated widget tests alone do not
establish visual contrast or physical-device gesture quality.

Baseline before implementation: 13/13 focused route/page/details tests passed
on 2026-11-13. Button pop/fallback was source-reviewed; no fresh device gestures
were performed in that review.

## Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Open details with bright/white and dark photos | Arrow and status icons clearly visible | Image loading, missing image, image failure |
| 2 | Scroll slowly through collapse and expand again | Smooth transition; opaque pinned toolbar; no title overlap or jump | Short content, overscroll, rapid direction changes |
| 3 | Tap Back before and after collapse | Returns once to the actual caller | Home versus Shoots entry; rapid taps |
| 4 | Open without pop history and tap Back | Navigates to named Shoots | Gesture/system back retains normal root behavior |
| 5 | Complete and cancel an iOS left-edge swipe in both header states | Complete returns once; cancel retains screen and scroll state | Start near toolbar; diagonal/vertical scrolling |
| 6 | Use Android Back button and system back gesture | Returns to caller without duplicate navigation | Expanded and collapsed states |
| 7 | Check small screen, notch and large text | No clipping; title ellipsizes; 48×48 target remains usable | Long/missing project name, landscape |
| 8 | Inspect loading/submitting and error states | Existing behavior retained; header remains legible | Failed detail API and retry |


## Execution results — 2026-11-13

- Extracted `ShootDetailsHeader` and replaced the main scroll view with slivers.
  Toolbar remains pinned; the project name appears on collapse. Existing photo
  loading/failure rendering and body/loader behavior are retained.
- Visual review of a synthetic pure-white photo exposed the gradient scrolling
  away at intermediate collapse. Moved it outside the photo's FlexibleSpaceBar
  background so it stays fixed behind the toolbar. Pixel regression checks now
  cover expanded, intermediate and collapsed offsets.
- Host verification: **23/23** across header contrast, details screen and shared
  route/page suites. Tests include narrow/notched layout with 2× text, fallback
  title, 48×48 button, expanded/collapsed pop and root fallback, scroll/expand,
  cancelled/completed iOS swipe and Android system back.
- Native verification: **29/29** in `integration_test/navigation_back_test.dart`
  on iPhone 18 Pro simulator, iOS 27.0. Final log:
  `/tmp/cp-sticky-header-ios-tests.log`. Android platform variants in this run
  are not equivalent to native Android device testing.
- Scoped Flutter analysis and `git diff --check` pass. Full suite not rerun.
- Updated dev app built and launched on the iPhone 18 Pro simulator after
  integration testing; Firebase initialized and Flutter attached successfully.
- Rendered expanded/middle/collapsed states inspected at 390×844 with a 59-point
  top inset; `/tmp/shoot-header-{expanded,middle,collapsed}.png` (temporary QA
  artifacts). These are Flutter renders with synthetic imagery, not live data.
- Remaining manual checks: physical iPhone/Android gestures, landscape,
  authenticated live photos and error/retry behavior. No Android device was
  connected. Existing backend error for some shoot types remains out of scope.

## How to reach the screen

1. Open the CP app and log in with an approved crew account.
2. Tap **Shoots** in the bottom navigation.
3. Tap **View Details** on an available shoot card (use **Confirmed Shoots**
   or the **Shoots** segmented option if needed to find an assigned shoot).
4. Scroll up: the photo collapses and Back + project name remain at the top.
5. Tap Back, or use the platform back gesture, to return to the caller.

Alternate path: **Home → Upcoming Shoots → View Details**. Both paths use the
same named route and header. No acceptance/decline action is needed.
