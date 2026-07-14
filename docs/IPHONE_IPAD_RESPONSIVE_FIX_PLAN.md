# iPhone and iPad Responsive Fix Plan

Date: 2026-07-13

## Scope

This plan converts the responsive/design review findings into a tracked fix list.
Implementation was approved on 2026-07-13 and the phone-safety items have been
executed. Broader iPad polish and modal-sheet consistency remain deferred to a
separate visual pass to avoid broad layout churn in this change set.

## Status Legend

| Status | Meaning |
|---|---|
| 🔴 Not Started | Approved plan item, no implementation started |
| 🟡 In Progress | Implementation started |
| 🟢 Done | Implemented and verified |
| ⏭️ Deferred | Explicitly postponed or out of scope |

## Fix Plan

| ID | Status | Priority | Finding | Files to Change | Planned Change | Verification |
|---|---|---:|---|---|---|---|
| R-01 | 🟢 Done | High | Custom bottom bars can sit too close to, or under, the iPhone home indicator because `AppScaffold` does not wrap `bottomNavigationBar` in bottom safe area by default. | `lib/shared/layouts/app_scaffold.dart`; `lib/features/auth/presentation/screens/login_screen.dart`; `lib/features/profile/presentation/screens/enter_profile_details_screen.dart`; `lib/features/profile/presentation/screens/featured_work_list_screen.dart`; `lib/features/profile/presentation/screens/edit_personal_details_screen.dart`; `lib/features/profile/presentation/screens/delete_account_screen.dart`; `lib/features/profile/presentation/screens/my_profile_screen.dart`; `test/shared/layouts/app_scaffold_test.dart` | Added opt-in `safeBottomNavigationBar` to `AppScaffold` and enabled it for custom footer screens. Existing spacing remains owned by each footer. | `flutter test test/shared/layouts/app_scaffold_test.dart` passed; focused screen batch passed. Manual simulator check not run. |
| R-02 | 🟢 Done | High | Analyzer fatal gate currently fails before responsive work can be trusted. | `lib/shared/widgets/app_button.dart`; `test/features/messages/presentation/screens/messages_screen_test.dart` | Removed the unused import and unnecessary nested `const` markers. | `flutter analyze --fatal-infos` passed. |
| R-03 | 🟢 Done | High | `ChatThreadScreen` test fails because `ChatThreadNotifier` reads a provider during `onDispose` after the provider container is disposed. | `lib/features/messages/presentation/providers/chat_thread_providers.dart`; `test/features/messages/presentation/screens/messages_screen_test.dart` | Captured the active-room controller during build and guarded cleanup with `mounted` checks so dispose does not read from a disposed container. Preserved best-effort `leaveConversation`. | `flutter test test/features/messages/presentation/screens/messages_screen_test.dart` passed as part of both focused suites. |
| R-04 | 🟢 Done | Medium | Many custom icon-only controls are smaller than the iOS 44x44 touch target. | `lib/shared/widgets/app_icon_tap_target.dart`; auth back/close screens; profile back/edit screens; shoot detail/cancel screens; `test/shared/widgets/app_icon_tap_target_test.dart` | Added `AppIconTapTarget` with a 44x44 default hit area and migrated high-risk back, close, edit, and delete-style icon-only controls. Signup header visual anchors were preserved against the existing device-matrix goldens. | `flutter test test/shared/widgets/app_icon_tap_target_test.dart test/golden/device_matrix_test.dart` passed. |
| R-05 | ⏭️ Deferred | Medium | Full-width phone layouts are functional but stretch awkwardly on iPad. | Future pass: `lib/shared/layouts/app_scaffold.dart` or new `lib/shared/layouts/adaptive_content.dart`; high-traffic screens such as login, signup, home, profile, meetings, messages, manage availability, file manager, and shoots. | Deferred. Add a reusable centered max-width content wrapper for tablet widths in a dedicated visual pass. Use `LayoutBuilder`/constraints, not device-type checks. | Not run in this pass. Existing iPad-mini header matrix remains covered. |
| R-06 | 🟢 Done | Medium | Calendar event labels scale below readable size on compact iPhones. | `lib/shared/widgets/common_calendar.dart`; `test/shared/widgets/common_calendar_test.dart` | Clamped weekday, day, and event-tag font sizes to readable compact-phone minimums with caps for larger widths. Kept event tags single-line and ellipsized. | `flutter test test/shared/widgets/common_calendar_test.dart` passed. |
| R-07 | 🟢 Done | Medium | Existing device-matrix golden coverage only covers signup headers, not whole screens or footers. | `test/shared/layouts/app_scaffold_test.dart`; `test/shared/widgets/app_icon_tap_target_test.dart`; `test/shared/widgets/common_calendar_test.dart`; existing `test/golden/device_matrix_test.dart` | Added focused invariant tests for footer SafeArea wrapping, 44x44 icon hit targets, and compact calendar label readability. Reused the existing signup header device matrix to guard visual drift. | Focused responsive suite and existing device matrix passed. |
| R-08 | ⏭️ Deferred | Low | Some modal bottom sheets are manually sized and may need consistency review after footer/touch-target work. | Future pass: signup social/portfolio/featured/lookup sheets; profile social/portfolio/featured/image-crop sheets; meetings filter/details sheets. | Deferred. Review and patch sheets only after a bottom-sheet device matrix identifies concrete failures. | Not run in this pass. |

## Proposed Implementation Order

| Step | Status | IDs | Reason |
|---|---|---|---|
| 1 | 🟢 Done | R-02, R-03 | Restored clean automated checks before layout changes. |
| 2 | 🟢 Done | R-01 | Fixed the highest iPhone breakage risk: home-indicator overlap for custom footers. |
| 3 | 🟢 Done | R-04, R-06 | Improved mobile usability and readability without broad layout churn. |
| 4 | 🟢 Done | R-07 | Added regression coverage for the fixed behavior. |
| 5 | ⏭️ Deferred | R-05, R-08 | Broader iPad/tablet polish and modal consistency need a dedicated visual pass. |

## Approval Gate

Implementation was approved and executed for R-01, R-02, R-03, R-04, R-06, and
R-07. R-05 and R-08 remain intentionally deferred and should receive separate
approval before broad visual changes.

## Baseline Verification From Review

| Command | Result |
|---|---|
| `flutter analyze --fatal-infos` | Failed: one unused import in `app_button.dart`, two unnecessary `const` infos in messages test |
| `flutter test test/golden/device_matrix_test.dart` | Passed |
| `flutter test test/shared/layouts/app_scaffold_test.dart test/shared/layouts/app_shell_test.dart` | Passed |
| Main screen widget batch | Failed only on `ChatThreadScreen shows optimistic message while sending` due provider dispose read |

## Execution Verification

| Command | Result |
|---|---|
| `dart format <touched Dart files>` | Passed; 32 files checked, 0 changed |
| `flutter analyze --fatal-infos` | Passed |
| `git diff --check` | Passed |
| `flutter test test/shared/widgets/app_icon_tap_target_test.dart test/golden/device_matrix_test.dart` | Passed after preserving signup header visual anchors |
| `flutter test test/shared/layouts/app_scaffold_test.dart test/shared/widgets/app_icon_tap_target_test.dart test/shared/widgets/common_calendar_test.dart test/features/messages/presentation/screens/messages_screen_test.dart test/golden/device_matrix_test.dart` | Passed |
| Main screen widget batch | Passed: login, signup3, forgot/reset password, home, my profile, shoots, upcoming shoot details, availability, meetings, messages |

## Remaining Follow-Up

| ID | Status | Reason |
|---|---|---|
| R-05 | ⏭️ Deferred | Tablet max-width wrappers affect many screens and should be reviewed visually across iPad portrait/landscape before coding. |
| R-08 | ⏭️ Deferred | Bottom-sheet consistency should be driven by a dedicated sheet matrix so only concrete failures are patched. |
| Manual simulator smoke | ⏭️ Deferred | Automated tests passed, but no physical or simulator iPhone/iPad manual pass was run in this execution. |
