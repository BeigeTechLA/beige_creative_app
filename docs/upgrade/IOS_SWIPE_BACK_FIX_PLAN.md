# App-wide iOS swipe-back fix plan

Created: 2026-11-04

**Plan status:** Approved by user on 2026-11-04. Phases 1–4 Completed; Phase 6
review/handoff Completed; Phase 5 remains In Progress for interactive human
gesture QA (Q01–Q18) and physical-device smoke only. Both automated native
integration suites pass 14/14 (iOS 27 sim + Pixel 9 API 36 emulator).
**Scope:** Navigation compatibility follow-up to U-09 in `FLUTTER_IOS27_UPGRADE.md`; not a new migration phase.
**Owner:** Implementing agent; manual device QA results recorded by the tester.

## Problem and confirmed evidence

GoRouter 18.1.1 detects `MaterialApp` from `package:material_ui`, while this
application uses `package:flutter/material.dart`. Those classes are distinct.
GoRouter therefore selects its WidgetsApp fallback and creates
`NoTransitionPage` for ordinary builder-based routes. These routes lack the
Cupertino edge-swipe detector even when their back stack can pop.

A diagnostic widget test on the iOS target reproduced this: a drag from x=1
failed to return from Details with default page creation, but passed with an
explicit Flutter SDK `MaterialPage`. Both cases used `AppTheme.dark()` and the
app's keyboard-dismiss tap detector. The temporary diagnostic is at
`/tmp/beige_swipe_back_diagnostic_test.dart`; recreate it if unavailable.
This establishes the cause, not completion of full-app or device QA.

## Intended behavior and boundaries

- Explicitly create Flutter SDK `MaterialPage`s for ordinary application routes.
  Use a small shared page-builder helper to retain page key, route name,
  arguments and restoration ID consistently. Keep feature argument parsing and
  widget construction in their existing feature route files.
- Audit and handle the `StatefulShellRoute` page explicitly as well as its branch
  pages; do not rely on the mismatched automatic app-type detection.
- Preserve custom `pageBuilder`s, including the shoot-cancellation sheet's
  opacity, barrier and slide transition. Do not make every modal swipe-pop-able.
- Preserve named routes, paths, redirect rules, argument contracts, return
  values, navigator ownership, restoration behavior and existing `PopScope`s.
- Keep current UI imports and dependency versions. No package-cache patches,
  package downgrade, wholesale UI-library migration or global drag detector.
- Screen appearance, API calls and business logic are outside this fix.
  The shoot back arrow remains plain white and scrolls with the photo.
- Root destinations and replacement navigation do not acquire artificial back
  history. Back gestures apply only where a previous route exists and guards
  permit popping.

## Phase status tracking

Allowed status values: `Not Started`, `In Progress`, `Completed`.
Update a phase and its tasks when work starts or finishes. A phase is complete
only when its done criteria are met. Record failures, blockers and verification
results in the execution log; do not mark unexecuted QA as passed.

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Confirm root cause and audit navigation entry points | This plan; read `lib/app/router.dart`, feature route files, `lib/shared/layouts/app_shell.dart` | Root cause reproduced; drawer navigation classified; preliminary scope recorded | Completed |
| 2 | Introduce explicit SDK page creation and prove swipe behavior | New `lib/app/route_page_builder.dart`; new `test/app/route_page_builder_test.dart` | Shared helper preserves page metadata; completed/cancelled edge-swipe tests and no-history case pass | Completed |
| 3 | Apply page policy to routes, shell and drawer destinations | `lib/app/router.dart`; `lib/features/*/presentation/routes/*_routes.dart`; shell only if a demonstrated defect requires it | Ordinary routes and shell covered; custom pages unchanged; call-site navigation semantics preserved | Completed |
| 4 | Verify navigation regressions across platforms | `test/app/`; relevant feature and shell tests | Targeted tests, full existing suite, static analysis and whitespace checks pass; failures investigated | Completed |
| 5 | Execute simulator/device manual QA | QA result tables in this plan | Required iOS and Android cases recorded; drawer/state/gesture cases pass; unavailable real-device checks remain explicitly pending | In Progress (automated native 14/14 both platforms; interactive human Q01–Q18 + physical iPhone pending) |
| 6 | Final review and handoff | This plan; `MIGRATION_LOG.md`; `docs/AI_HANDOFF.md`; parent upgrade plan | Diff reviewed, verification evidence recorded, remaining limitations explicit, no unverified completion claims | Completed |

## Phase-wise task checklist

| Task | Work | Status |
|------|------|--------|
| 1.1 | Confirm GoRouter app-type mismatch and inspect fallback implementation | Completed |
| 1.2 | Compare actual edge swipe with automatic page and explicit SDK MaterialPage | Completed |
| 1.3 | Classify drawer profile push versus branch selection; inspect drawer edge-drag behavior | Completed |
| 2.1 | Define shared page helper using SDK MaterialPage and stable route metadata | Completed |
| 2.2 | Reproduce the old failure in a regression harness and verify helper fixes it | Completed |
| 2.3 | Test completed swipe, cancelled swipe, root/no-history behavior and route result propagation | Completed |
| 3.1 | Enumerate every ordinary route, custom page and shell page; record exceptions | Completed |
| 3.2 | Apply helper to Shoots, Home-accessible routes, Availability and Meetings | Completed |
| 3.3 | Apply helper to Profile, Auth, File Manager and Messages ordinary routes | Completed |
| 3.4 | Configure root shell and branch pages with stable keys/navigator ownership | Completed |
| 3.5 | Verify drawer profile pushes and all drawer branch selections retain current semantics | Completed |
| 3.6 | Check custom sheets, guarded routes and redirects against the exception inventory | Completed |
| 4.1 | Test actual production route definitions for explicit page coverage and metadata | Completed |
| 4.2 | Test main tab → details → back, drawer → profile → back and nested profile flow | Completed |
| 4.3 | Test branch-state preservation, drawer dismissal and gesture interaction | Completed |
| 4.4 | Run auth/redirect, route-argument, analytics and pop-guard regression tests | Completed |
| 4.5 | Run Android navigation tests, full Flutter suite and fatal-info analysis | Completed |
| 5.1 | Freshly launch iOS dev build and run manual cases below | In Progress |
| 5.2 | Run Android emulator smoke and repeat key gestures on physical iPhone if available | In Progress |
| 5.3 | Record device/OS/build, expected versus actual results and any defects | In Progress |
| 6.1 | Review scope, update parent upgrade tracking and record commands/results | Completed |
| 6.2 | Update handoff with explicit page convention and unresolved QA items | Completed |

User approved execution on 2026-11-04; phases 2–6 are authorized. Tests should exercise real route
configuration where feasible; a helper-only test does not establish app-wide
coverage. Reopen an earlier phase if later QA exposes an implementation defect.

## Drawer and main-tab behavior contract

Current implementation: `lib/shared/layouts/app_shell.dart`. The drawer closes
with `Navigator.pop` before `shell.goBranch`; the profile card closes the drawer
then calls `pushNamed(Routes.myProfile.name)`. The drawer drag area currently
covers 30% of the screen width. Do not change that width without evidence of a
remaining conflict after page creation is fixed.

| Entry point | Current navigation | Required result |
|-------------|--------------------|-----------------|
| Bottom bar: Dashboard, Shoots, File Manager, Messages | `goBranch` | Retain branch state; do not add previous-tab swipe history |
| Drawer: Dashboard, Shoots, File Manager, Messages | Close drawer, then `goBranch` | Same branch behavior as bottom navigation |
| Drawer: Meetings, Manage Availability, Affiliate | Close drawer, then `goBranch` | Remain shell branches; preserve existing bottom-bar visibility rules |
| Payouts shell branch | Defined in shell; not currently listed in drawer | Keep existing branch routing; do not add a new drawer item |
| Drawer profile card | Close drawer, then named push | Swipe/back returns to the originating branch and its preserved state |
| Details opened from a branch | Named push | Pop returns to originating screen, including drawer-only branches |
| Drawer open on branch root | Drawer local history/dismissal | Close drawer; do not accidentally pop shell or switch branches |
| Reselect current branch | Existing `initialLocation` rule | Preserve current branch-reset behavior |

## Automated verification and acceptance

1. iOS gesture tests must use the test framework's iOS platform variant. Verify
   navigation after a completed left-edge drag, retention after cancellation,
   and vertical scrolling without a pop. Include the app's tap-to-unfocus wrapper.
2. Test default page coverage against the production route tree, including
   shell/branch pages. Enumerate intentional custom-page exceptions instead of
   silently skipping them. Confirm parameterized screens still receive their
   existing arguments and popped results reach callers.
3. Test preservation of active tab, branch navigation stack and scroll state.
   Profile opened from a drawer-only branch must return there. Exercise the
   current drawer-close and tab-reselection rules.
4. Preserve signup/unsaved-change guards, pending/rejected access restrictions,
   and expired-session/logout redirects. A back gesture must not restore a
   forbidden authenticated screen after logout.
5. Check observer route names, completed-pop reporting and cancelled-swipe
   behavior; no duplicate or anonymous screen events introduced by helper metadata.
6. Commands: targeted `flutter test --no-pub <test paths>`, then full
   `flutter test --no-pub`, `flutter analyze --no-pub --fatal-infos`, and
   `git diff --check`. Record actual totals and failures. Rebaseline goldens only
   for understood, intentional changes; never to conceal regressions.
7. Validate fresh simulator launch rather than relying solely on hot reload:
   router configuration/provider instances may survive a reload.

## Risks and controls

| Risk | Control |
|------|---------|
| Stable keys or shell navigator ownership change | Preserve GoRouter page keys and current navigator keys; test branch state |
| Custom sheets become fullscreen routes | Leave existing custom page builders intact; test barrier, return value and dismissal |
| Swipe bypasses a form/auth restriction | Keep existing guards; test allowed and denied pops explicitly |
| Drawer edge drag competes with route swipe | Test root drawer opening separately from top-page popping and open-drawer dismissal |
| Analytics/restoration lose page identity | Preserve route name, arguments and restoration ID; test observers and metadata |
| Android receives an unintended iOS animation | Use SDK MaterialPage platform behavior; verify Android system back and transitions |
| Deep-link/root entry has no prior page | No fabricated swipe destination; retain explicit back-button fallback where present |

Implementation can be reverted by reverting only the page-helper integration
and its associated tests. Preserve unrelated working-tree changes, including
previous shoot-header edits. Do not alter package caches or dependency pins.

## Route inventory and implementation evidence

- All 45 named production GoRoutes have explicit page builders (44 ordinary
  SDK Material pages and the existing custom shoot-cancellation page).
- The main StatefulShellRoute uses an explicit SDK Material page; its eight
  branches keep their current navigator ownership and tab-switch semantics.
- Meetings currently has no separate child route declarations to migrate.
- Existing intentional pop blockers remain: Signup Step 2 cancels signup through
  its exit flow; Featured Work details intercepts back to return `hasChanges`.
  Neither screen is newly enabled for an iOS swipe by this compatibility fix.
- `state.extra` parsing remains inside existing feature builders. Page arguments
  mirror GoRouter's previous URL-parameter map, not arbitrary extra payloads.
- Added `integration_test/navigation_back_test.dart` to run deterministic gesture
  and real AppShell cases using the existing integration binding. This supplements
  manual QA; it does not exercise live account/backend workflows.

## Native verification results

| Check | Environment | Result | Evidence |
|-------|-------------|--------|----------|
| Full unit/widget/golden suite | Flutter host tests | 761/761 passed | `/tmp/beige-swipe-back-full-tests.log` |
| Full static analysis | `flutter analyze --no-pub --fatal-infos` | No issues | Completed after test-only lint corrections |
| Native navigation integration | iPhone 18 Pro simulator, iOS 27.0, dev | 14/14 passed | `/tmp/beige-swipe-ios-integration.log` |
| Normal app fresh launch | Same iOS simulator, `lib/main_dev.dart` | Build and startup passed; Firebase initialized | Screenshot `/tmp/beige-swipe-fixed-app.png` |
| Native navigation integration | Pixel 9 API 36 emulator (`emulator-5554`), Android 16, dev | 14/14 passed | `/tmp/beige-swipe-android-integration.log` |

Native tests run deterministic screen content and the real AppShell; they do
not substitute for the manual live-account matrix below. Platform variants in
tests do not change the native host OS. First Android attempt omitted
`--dart-define-from-file=env/dev.json` and failed the Maps build prerequisite;
retry uses the existing dev configuration without changing secrets or dependencies.

## Execution log

| Date | Phase | Evidence / Decision | Remaining work |
|------|-------|---------------------|----------------|
| 2026-11-04 | 6 | Diff reviewed: `route_page_builder.dart` helper preserves page key, name, arguments and restoration ID; `router.dart` + 6 feature route files apply `appPageBuilder`/`appRoutePage` to all 45 ordinary routes and the shell; shoot-cancellation `CustomTransitionPage` and all guards/redirects unchanged. Parent upgrade plan U-09 follow-up + `AI_HANDOFF.md` page convention recorded; `MIGRATION_LOG.md` updated. No unverified completion claims: interactive manual QA stays open. | Interactive human/manual gesture QA (Q01–Q18) and physical-device smoke |
| 2026-11-04 | 5 | Android native integration 14/14 passed on Pixel 9 API 36 (`emulator-5554`, Android 16) via retry with `--dart-define-from-file=env/dev.json`. Final `adb uninstall` returned `DELETE_FAILED_INTERNAL_ERROR` as post-test cleanup noise, not a test failure. Both iOS and Android deterministic native suites are now green. | Interactive human/manual gesture QA (Q01–Q18) and physical-device smoke |
| 2026-11-04 | 5 | iOS native integration 14/14 passed; normal app rebuilt and relaunched successfully. Android emulator started for native verification. | Android results; human/manual and physical-device QA |
| 2026-11-04 | 2–4 | Shared helper and route integration complete. 57 targeted checks and 761 full-suite tests pass; full fatal-info analysis clean. | Native integration and manual/device QA |
| 2026-11-04 | 1 | Default GoRouter page edge-swipe diagnostic failed; explicit SDK MaterialPage control passed. Drawer branch/profile behavior audited. | Plan review; implementation and full-app QA |

## Manual Test Summary

Run on the iPhone 18 Pro simulator first; repeat core gesture cases on a physical
iPhone when available. Record Android emulator behavior separately. Use approved
or test accounts as appropriate; avoid destructive account actions and live
shoot mutations solely to test navigation.

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| Q01 | From Home open shoot details; drag from left edge past halfway | Returns to Home with original state | Bright header image, loaded/error state |
| Q02 | From Shoots select a filter, scroll, open details and swipe back | Same tab, filter and scroll position remain | Multiple consecutive visits |
| Q03 | Begin a short slow edge swipe, then release before completion | Details remains; no accidental pop | Start a second swipe immediately afterward |
| Q04 | Scroll details vertically and use its back arrow | No sticky arrow covering content; button returns correctly | Arrow scrolls away with header; image unavailable |
| Q05 | Open drawer from each bottom tab and tap profile; swipe back | Drawer closes before navigation; returns to originating tab/state | Repeat from Meetings, Availability and Affiliate branches |
| Q06 | Select every listed drawer destination | Correct branch and existing bottom-bar visibility | No fabricated history between branch roots |
| Q07 | Open drawer by edge drag, close via swipe/scrim/close icon | Drawer dismisses without leaving branch | Android system back also closes drawer first |
| Q08 | From a tab open a pushed screen; perform left-edge back swipe | Top page pops; underlying drawer does not open | Drawer drag zone overlaps gesture starting area |
| Q09 | Switch tabs repeatedly; reselect active tab | Branch state and existing reselection behavior preserved | Open child route before switching where UI permits |
| Q10 | Open profile → personal/professional details, portfolio, certificates and resume | Each allowed swipe returns exactly one route | Validation/unsaved edits follow existing rules |
| Q11 | Navigate login, forgot-password and signup paths | Back works where history/guards allow it | Resumed signup, temporary auth, pending/rejected accounts |
| Q12 | Logout or simulate session expiry, then attempt back | Protected screens remain inaccessible | Gesture begun near redirect; guest restrictions |
| Q13 | Open shoot-cancellation sheet, then dismiss without submitting | Existing slide, dimming, barrier and return behavior preserved | Swipe must not remove underlying details unexpectedly |
| Q14 | Open File Manager, chat and meeting child routes and return | Correct parent and preserved data/selection | Keyboard open, scrollable content, supported modal sheets |
| Q15 | Open an existing supported direct entry with no earlier page | No swipe pop; existing button fallback handles navigation | Missing/invalid extras retain established handling |
| Q16 | Repeat normal back, nested navigation and drawer cases on Android | System back and platform transitions work as before | Drawer open, keyboard open, branch root |
| Q17 | Repeat Q01–Q03, Q05 and Q08 on physical iPhone | Interactive swipe and cancellation behave naturally | Different screen size; repeated rapid gestures |
| Q18 | Inspect screen analytics during push, completed and cancelled swipe | Correct route identities and expected event counts | Shell/branch transitions; no duplicate events |

### Manual QA result tracker

All checks are pending until executed. For each run, record build/commit,
platform/device/OS, actual result and evidence. Use the phase status vocabulary;
record a failure or blocker in Notes while the row remains `In Progress`.

| Cases | Device / OS / Build | Status | Result / Evidence / Notes |
|-------|---------------------|--------|---------------------------|
| Q01–Q04 | iOS simulator — record at execution | Not Started | |
| Q05–Q09 | iOS simulator — record at execution | Not Started | |
| Q10–Q12 | iOS simulator/test accounts — record at execution | Not Started | |
| Q13–Q15 | iOS simulator — record at execution | Not Started | |
| Q16 | Android emulator — record at execution | Not Started | |
| Q17 | Physical iPhone — availability pending | Not Started | |
| Q18 | Test telemetry/logs — record at execution | Not Started | |
