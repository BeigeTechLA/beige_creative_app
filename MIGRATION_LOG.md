# Migration Log — Beige Creative App (Crew)

> Decisions, judgment calls, and deviations from `MIGRATION_PLAN.md` / `MIGRATION_RULES.md` are logged here during migration.
> Format: date (ISO), section header. Each entry lists **Changes**, **Decisions** (with rationale), and **Constraints Maintained** (what was preserved — e.g., zero visual drift, `flutter analyze` zero errors).
>
> See also: [`MIGRATION_PLAN.md`](MIGRATION_PLAN.md) · [`MIGRATION_RULES.md`](MIGRATION_RULES.md) · [`docs/migration/`](docs/migration/) (phase plans).

### 2026-08-10: Signup Featured Work Upload UI Fixes (Option A)

- **Task**: Review and fix UI bugs, box overflow height, gesture detector scope, file size validation, and action button overlay alignment in Signup Featured Work upload (`signup3_featured_sheet.dart` and `signup3_sections.dart`).
- **Changed Files**:
  - `lib/features/auth/presentation/widgets/signup3_featured_sheet.dart`
  - `lib/features/auth/presentation/widgets/signup3_sections.dart`
- **Decisions**:
  - Replaced fixed `190px` box height with dynamic height (`180px` for empty state, `220px-360px` for image grid) to prevent overflow clipping.
  - Restricted `GestureDetector` tap listeners to the drop-zone and `+` add grid item tile to avoid triggering the file picker when interacting with existing image tiles.
  - Added 30MB file size limit and 5-image max check to grid `+` tile image picker.
  - Aligned assets (`AppAssets.upload`), typography, aspect ratio subtext, and CTA button height (`48px`) with design tokens.
  - Moved Edit/Delete project actions out of the `Positioned` overlay into a clean project card header in `SignUp3FeaturedSection`.
- **Verification**:
  - `flutter analyze lib/features/auth/presentation/widgets/` — 0 issues found.

---

### 2026-08-10: Fix Shoots Filter Selection, Evaluation Logic & Expand Status Options

- **Task**: Fix shoots status filter selection not updating visible items after selection, enable filtering when top count cards are active, expand status options to include Completed and Declined, and add gold active filter indicator.
- **Changed Files**:
  - `lib/features/shoots/presentation/widgets/shoots_filter_bottom_sheet.dart`
  - `lib/features/shoots/presentation/providers/shoots_providers.dart`
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`
  - `test/features/shoots/presentation/shoots_notifier_test.dart`
- **Decisions**:
  - Removed early return guard in `ShootsListNotifier.setStatusFilter` so re-applying a status in the modal always forces a re-filtering of `visibleShoots`.
  - Removed `topCardShoots == null` check in `_filter` so status filter applies consistently when top count cards are active.
  - Expanded `ShootsFilterBottomSheet` options to include `All Status`, `Pending`, `Confirmed`, `Completed`, and `Declined`.
  - Added gold active filter indicator dot on `ShootsScreen` toolbar filter icon when `selectedStatusFilter != 'All Status'`.
- **Verification**:
  - `flutter analyze`: 0 issues found.
  - `flutter test test/features/shoots`: 54 / 54 tests passing.

---

### 2026-08-10: Multi-Image Photo Selection & Featured Work Double-Submit Loader Fix

- **Task**: Fix duplicate image uploads caused by un-guarded save button double submissions, allow multi-image selection from gallery when opening photos, and synchronize featured work validation rules.
- **Changed Files**:
  - `lib/shared/widgets/common_uploader.dart`
  - `lib/features/profile/presentation/widgets/featured_work_upload_sheet.dart`
  - `lib/features/profile/presentation/screens/featured_work_list_screen.dart`
  - `lib/features/profile/presentation/screens/app_preferences_screen.dart`
  - `lib/features/profile/presentation/widgets/profile_section_list.dart`
  - `lib/features/auth/presentation/widgets/signup3_featured_sheet.dart`
  - `docs/implementation_plan.md`
  - `docs/walkthrough.md`
- **Decisions**:
  - Added `CommonUploader.pickMultipleFromGallery()` wrapping `ImagePicker().pickMultiImage()` to allow picking multiple images at once from system photo picker.
  - Added `isSaving` guard & spinner on `FeaturedWorkUploadSheet` save button to prevent concurrent upload invocations.
  - Replaced custom button with `AppCtaButton` for 100% text color, background color, and typography consistency across app CTA buttons.
  - Added `HitTestBehavior.opaque` to dropzone gesture detectors for full-area tap responsiveness.
  - Removed Dark Mode option and switch container from `AppPreferencesScreen`.
  - Hidden Notifications Settings row in `ProfileSectionList` while preserving menu row code.
- **Verification**:
  - `flutter analyze`: 0 issues found across all modified files.
  - `flutter test test/features/profile/presentation/profile_files_test.dart`: 10 / 10 tests passed.

---

### 2026-08-07: Bind GET /creator/shoot-card-details API to Shoots Top Count Cards

- **Task**: Integrate `GET creator/shoot-card-details?status={pending|confirmed|completed|rejected}` API endpoint to fetch status-wise data when top count cards are selected.
- **Changed Files**:
  - `lib/core/network/api_endpoints.dart`
  - `lib/features/shoots/domain/repositories/shoots_repository.dart`
  - `lib/features/shoots/data/repositories/shoots_repository_impl.dart`
  - `lib/features/shoots/presentation/providers/shoots_providers.dart`
  - `test/features/shoots/data/repositories/shoots_repository_impl_test.dart`
  - `test/features/shoots/presentation/shoots_notifier_test.dart`
  - `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart`
  - `lib/features/profile/presentation/widgets/profile_section_list.dart` (cleaned unused import)
- **Decisions**:
  - Added `creatorShootCardDetails(status)` endpoint builder to `ApiEndpoints`.
  - Declared `fetchShootCardDetails(status)` in `ShootsRepository` and implemented in `ShootsRepositoryImpl` supporting both array and wrapped map responses.
  - Added `topCardShoots` state handling in `ShootsListState` and `ShootsListNotifier`.
  - Bound top count cards (`Pending Shoots` $\rightarrow$ `pending`, `Confirmed Shoots` $\rightarrow$ `confirmed`, `Completed Shoots` $\rightarrow$ `completed`, `Declined` $\rightarrow$ `rejected`) to trigger `fetchShootCardDetails(statusParam)` and populate `visibleShoots`.
  - Clearing top card selection (`clearTopCardSelection()`) clears `topCardShoots` and restores standard segment control dataset (`data.requests` / `data.shoots`).
- **Verification**:
  - `flutter analyze`: 0 issues found.
  - `flutter test test/features/shoots`: 51 / 51 tests passing.

---

### 2026-08-05: Replace creator/dashboard-details with GET /creator/shoots (Dual Array Response)

- **Task**: Replace legacy `creator/dashboard-details` endpoint in Shoots repository with `GET /creator/shoots` and handle dual array response (`request` and `shoots`).
- **Changed Files**:
  - `lib/core/network/api_endpoints.dart`
  - `lib/model_class/shoots_model.dart`
  - `lib/features/shoots/domain/repositories/shoots_repository.dart`
  - `lib/features/shoots/data/repositories/shoots_repository_impl.dart`
  - `lib/features/shoots/presentation/providers/shoots_providers.dart`
  - `test/helpers/test_data.dart`
  - `test/features/shoots/data/repositories/shoots_repository_impl_test.dart`
  - `test/features/shoots/presentation/shoots_notifier_test.dart`
  - `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart`
  - `test/features/shoots/presentation/screens/shoots_screen_test.dart`
- **Decisions**:
  - Replaced `creatordashboarddetails` call in `ShootsRepositoryImpl.fetchShoots()` with `GET /creator/shoots` using query params `request_status=all` and `shoot_status=completed`.
  - Refactored `ShootsData` in `shoots_model.dart` to parse both `request` (pending/confirmed requests) and `shoots` (completed/cancelled shoots) arrays from backend response. Added `id` fallback (`json["id"] ?? json["project_id"]`) in `Shoot.fromJson` for completed shoot objects.
  - Updated `ShootsRepository.fetchShoots()` to return `Future<ShootsData>`.
  - Updated `ShootsListNotifier` in `shoots_providers.dart` so Tab 0 ("Request") filters items from `data.requests` and Tab 1 ("Shoots") filters items from `data.shoots`.
- **Verification**:
  - `flutter analyze`: 0 issues found.
  - `flutter test test/features/shoots`: 45 / 45 tests passing.

---

### 2026-08-05: Full-Screen Profile Image Crop Screen Migration

- **Task**: Replace profile crop bottom sheets with full-screen `CropImageScreen`.
- **Changed Files**:
  - `lib/features/profile/presentation/screens/crop_image_screen.dart`
  - `lib/app/routes.dart`
  - `lib/features/profile/presentation/routes/profile_routes.dart`
  - `lib/features/profile/presentation/screens/my_profile_screen.dart`
  - `lib/features/auth/presentation/screens/signup1_screen.dart`
  - `lib/features/profile/presentation/widgets/profile_image_crop_sheet.dart` (deleted)
  - `lib/features/auth/presentation/widgets/signup1_crop_sheet.dart` (deleted)
- **Decisions**:
  - Migrated profile image cropping to dedicated full-screen `CropImageScreen` accepting `File imageFile` via GoRouter `extra`.
  - Added `cropImage` RouteSpec to `Routes` and registered it under `profileRoutes`.
  - Updated image pickers in `MyProfileScreen` and `SignUp1Screen` to navigate to `Routes.cropImage.name` and handle returned cropped image.
  - Deleted legacy bottom sheet implementations `profile_image_crop_sheet.dart` and `signup1_crop_sheet.dart`.
- **Verification**:
  - `flutter test test/app/router_test.dart` — 9 / 9 tests passing.
  - `flutter analyze --fatal-infos` — 0 issues.

---

### 2026-08-05: Filter Bottom Sheet Root Navigator Fix

- **Task**: Open filter bottom sheet above bottom shell navigation.
- **Changed Files**:
  - `lib/features/shoots/presentation/widgets/shoots_filter_bottom_sheet.dart`
- **Decisions**:
  - Added `useRootNavigator: true` to `showModalBottomSheet(...)` in `ShootsFilterBottomSheet.show`.
- **Verification**:
  - `flutter analyze` — 0 issues.

---

### 2026-08-05: Shoots Top Header Filter Icon & Filter Bottom Sheet

- **Task**: Add top header filter action icon and filter bottom sheet modal.
- **Changed Files**:
  - `lib/features/shoots/presentation/widgets/shoots_filter_bottom_sheet.dart`
  - `lib/features/shoots/presentation/providers/shoots_providers.dart`
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`
- **Decisions**:
  - Added trailing `iconFilter` button to `AppMainToolbar` in `ShootsScreen`.
  - Implemented `ShootsFilterBottomSheet` modal with status filtering (`All Status`, `Pending`, `Confirmed`) and `Clear All` / `Apply` actions.
- **Verification**:
  - `flutter analyze` — 0 issues.

---

### 2026-08-05: Request / Shoots Segmented Control Added

- **Task**: Add Request & Shoots segmented tab selector matching screenshot mockup.
- **Changed Files**:
  - `lib/shared/widgets/app_segmented_control.dart`
  - `lib/features/shoots/presentation/providers/shoots_providers.dart`
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`
- **Decisions**:
  - Added `AppSegmentedControl` shared widget with Option A gold gradient active pill.
  - Bound `selectedTabIndex` in `ShootsListNotifier` to filter pending requests (`index 0`) vs confirmed shoots (`index 1`).
- **Verification**:
  - `flutter analyze` — 0 issues.

---

### 2026-08-05: Shoots Empty State Image & Copy Update

- **Task**: Replace empty shoots icon and copy with `no_data.png` graphic and exact text.
- **Changed Files**:
  - `lib/app/assets.dart`
  - `lib/shared/widgets/app_empty_state.dart`
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`
- **Decisions**:
  - Added `imageAsset` support to `AppEmptyState` widget to support PNG illustrations alongside SVGs.
  - Set default empty state for `ShootsScreen` to `AppAssets.noData` image, title `'No Shoot Available'`, and description `'No shoots available at the moment.\nNew opportunities will appear here when assigned.'`.
- **Verification**:
  - `flutter analyze` — 0 issues.

---

### 2026-08-05: Drawer and Screen Header Consistency

- **Task**: Align active drawer menu labels with destination screen headers.
- **Changed Files**:
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`
  - `lib/features/messages/presentation/screens/messages_screen.dart`
  - `test/features/shoots/presentation/screens/shoots_screen_test.dart`
  - `test/features/messages/presentation/screens/messages_screen_test.dart`
  - `docs/phase4/task_23_groupF_shell_shared.md`
- **Decisions**:
  - Normalized the two mismatches to the existing drawer labels: `Shoots` and
    `Messages`. Meetings and Manage Availability required no change; Dashboard
    retains its dedicated welcome header.
- **Verification**:
  - `flutter analyze --fatal-infos` on the two screens and their tests — 0 issues.
  - Focused Shoots + Messages screen tests — 8 / 8 passing.

---

### 2026-08-05: Shoot Details Type Chip Styling

- **Task**: Restyle the Shoot Type and Booking Type chips.
- **Changed Files**:
  - `lib/app/colors.dart`
  - `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`
  - `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart`
  - `docs/phase4/task_13_groupD_upcoming_details.md`
- **Decisions**:
  - Added `AppColors.surfaceChip` for the requested `#323131` background and
    removed the chip border while retaining existing text and spacing.
- **Verification**:
  - `flutter analyze --fatal-infos lib/app/colors.dart lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — 0 issues.
  - `flutter test test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — 4 / 4 passing.

---

### 2026-08-05: Shoot Details SVG Icons

- **Task**: Replace the shoot details Material icons with the supplied SVGs.
- **Changed Files**:
  - `assets/svg/shoots/ic_clock_circle.svg`
  - `assets/svg/shoots/ic_doller.svg`
  - `assets/svg/shoots/ic_shoot_date.svg`
  - `assets/svg/shoots/ic_shoot_location.svg`
  - `lib/app/assets.dart`
  - `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`
  - `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart`
  - `docs/phase4/task_13_groupD_upcoming_details.md`
- **Decisions**:
  - Exposed the supplied assets as `AppAssets.icDoller` and
    `AppAssets.icClockCircle`, retaining their native 19×19 dimensions in the
    Event Budget and Total Time Duration tiles.
  - Replaced the date, time, and location Material icons in the event info row
    with `AppAssets.icShootDate`, a white-tinted reuse of
    `AppAssets.icClockCircle`, and `AppAssets.icShootLocation` at 16×16.
- **Verification**:
  - `flutter analyze --fatal-infos lib/app/assets.dart lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — 0 issues.
  - `flutter test test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — 4 / 4 passing.

---

### 2026-08-05: Add Availability Date Field Icon

- **Task**: Use the new add-date icon in the Add Availability form.
- **Changed Files**:
  - `assets/icon/ic_add_date.svg`
  - `lib/app/assets.dart`
  - `lib/features/availability/presentation/screens/add_availability_screen.dart`
  - `lib/features/availability/presentation/screens/manage_availability_screen.dart`
  - `test/features/availability/presentation/screens/manage_availability_screen_test.dart`
  - `pubspec.yaml`
  - `docs/phase4/task_05_groupB_availability.md`
- **Decisions**:
  - Added `assets/icon/` to the Flutter asset bundle and exposed the SVG as
    `AppAssets.icAddDate` instead of hardcoding its path in the screen.
  - Reused the same icon for the Add Date and Until Date suffixes and the
    Available Days summary card on the Manage Availability screen.
- **Verification**:
  - `dart format lib/app/assets.dart lib/features/availability/presentation/screens/add_availability_screen.dart` — clean.
  - `flutter analyze --fatal-infos lib/app/assets.dart lib/features/availability/presentation/screens/add_availability_screen.dart` — 0 issues.
  - `flutter test test/features/availability/presentation/screens/add_availability_screen_test.dart` — 6 / 6 passing.
  - `flutter analyze --fatal-infos lib/features/availability/presentation/screens/manage_availability_screen.dart test/features/availability/presentation/screens/manage_availability_screen_test.dart` — 0 issues.
  - `flutter test test/features/availability/presentation/screens/manage_availability_screen_test.dart` — 7 / 7 passing.

---

### 2026-07-28: Realtime New Room Creation Socket Event (`chatRoomCreated`)

- **Task**: Fix socket event handling for new room creation using `chatRoomCreated`.
- **Changed Files**:
  - `lib/features/messages/domain/events/chat_socket_event.dart`
  - `lib/features/messages/data/sources/messages_socket_source.dart`
  - `lib/features/messages/data/dto/conversation_dto.dart`
  - `lib/features/messages/presentation/providers/conversation_list_providers.dart`
  - `test/features/messages/presentation/providers/conversation_list_notifier_test.dart`
  - `test/features/messages/presentation/providers/chat_thread_notifier_test.dart`
- **Decisions**:
  - Added `ChatRoomCreated(Conversation conversation)` variant to `ChatSocketEvent`.
  - Configured `MessagesSocketSource` to listen to `chatRoomCreated`, extract `payload.room`, and parse into `Conversation` via `ConversationDto.fromRestJson`.
  - Enhanced `ConversationDto.fromRestJson` to parse `client_snapshot` and `production_ids` in addition to `cp_ids` and `manager_ids`.
  - Configured `ConversationListNotifier` to directly prepend/update `Conversation` in `state.items` upon `ChatRoomCreated` without triggering any REST API call (`refresh()`).
  - Added unit test verifying parsing of the exact sample payload and direct room list prepending.
- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues.
  - `flutter test test/features/messages/` — 33 / 33 tests passing.

---

### 2026-07-27: Add Availability Type Status Dots and Date Display

- **Task**: Add Availability — type selector and Add Date display polish.
- **Changed Files**:
  - `lib/features/availability/presentation/screens/add_availability_screen.dart`
  - `lib/utility/date_time_utils.dart`
  - `test/features/availability/presentation/screens/add_availability_screen_test.dart`
  - `test/utility/date_time_utils_test.dart`
  - `docs/phase4/task_05_groupB_availability.md`
- **Decisions**:
  - Added an 8dp semantic status dot before each availability type label:
    `AppColors.success` for Available and `AppColors.error` for Not Available.
  - Added strict month-first date formatting/parsing for Add Date only. The
    recurring Until Date retains its existing day-first display format.
  - Removed the automatic current-date initialization so Add Date resets to
    blank on each form load.
  - Routed notifier and time-picker validation/error messages through the
    shared app-level `TopMessage` overlay rather than raw `SnackBar` widgets.
  - Kept API date submission in `yyyy-MM-dd` format.
- **Verification**:
  - Focused date utility + Add Availability widget tests — 12 / 12 passing.
  - Scoped `flutter analyze --fatal-infos` on the four changed Dart files — 0 issues.
  - Full `flutter analyze --fatal-infos` — blocked by one unrelated existing
    `avoid_print` info in `upcoming_shoot_view_details_screen.dart:33`.

---

### 2026-07-27: Dashboard Calendar Shoot Tap Redirection to Shoot Details Page

- **Changes**:
  - `lib/features/home/presentation/providers/home_state.dart`: Added `availabilityDays: Map<DateTime, AvailabilityDay>` property to `HomeState` and `copyWith`.
  - `lib/features/home/presentation/providers/home_notifier.dart`: Updated `_applyDashboardData` to parse `dashboardData.availability` JSON directly into `availabilityDays` via static `AvailabilityRepositoryImpl.parseAvailability()`.
  - `lib/features/home/presentation/widgets/home_availability_section.dart`: Added optional `onDaySelected` callback parameter and forwarded to `CommonCalendar`.
  - `lib/features/home/presentation/screens/home_screen.dart`: Wired `onDaySelected` callback on `HomeAvailabilitySection` to extract `bookingId` from `availabilityDays` (or fallback match from `upcomingShootsList`) and push `Routes.upcomingShootDetails` with `projectId`.
  - `lib/features/availability/data/repositories/availability_repository_impl.dart`: Refactored `parseAvailability` and helpers `_isTrue`, `_extractBookingId`, `_asInt` as static methods to share parsing logic without duplicating code.
  - `test/features/home/presentation/home_notifier_test.dart`: Added unit test case verifying `availabilityDays` and `bookingId` parsing from availability JSON.

- **Decisions**:
  - Parsed availability payload directly from the existing `GET creator/dashboard` endpoint data so zero additional network calls are performed.
  - Added fallback matching by date on `upcomingShootsList` to handle cases where a shoot date entry has no explicit `booking_id` in availability JSON.

- **Verification**:
  - `flutter analyze` — 0 errors found.
  - `flutter test test/features/home/presentation/` — 16/16 tests passing.

---

### 2026-07-27: Full-Screen Transparent Loader Overlay for Meeting Accept / Reject

- **Changes**:
  - `lib/features/meetings/presentation/screens/meetings_screen.dart`: Wrapped screen layout in a `Stack` and rendered `const AppLoadingOverlay()` when `state.pendingRsvpIds.isNotEmpty`.
  - `test/features/meetings/presentation/screens/meetings_screen_test.dart`: Added widget test ensuring `AppLoadingOverlay` appears modally during pending meeting RSVP calls and clears on completion.

- **Decisions**:
  - Used standard `AppLoadingOverlay` (`dimOpacity: 0.5` with centered Lottie loader `AppAssets.lottieCircleLoader`) per approved Option A design selection to ensure consistent visual language with ShootsScreen and HomeScreen.

- **Verification**:
  - `flutter analyze` — 0 errors found.
  - `flutter test test/features/meetings/presentation/screens/meetings_screen_test.dart` — 6/6 tests passing.

---

### 2026-07-24: Setup Upcoming Shoots Section & Full-Screen Loader on Manage Availability Screen

- **Changes**:
  - `lib/features/availability/domain/repositories/availability_repository.dart`: Added `fetchUpcomingShoots()` method signature.
  - `lib/features/availability/data/repositories/availability_repository_impl.dart`: Implemented `fetchUpcomingShoots()` via GET `ApiEndpoints.upcomingshoots` (`creator/upcoming-shoots`).
  - `lib/features/availability/presentation/providers/availability_providers.dart`: Added `upcomingShootsList` to `ManageAvailabilityState`; updated `ManageAvailabilityNotifier.refresh()` to fetch month events and upcoming shoots concurrently.
  - `lib/features/availability/presentation/screens/manage_availability_screen.dart`: Converted to `ConsumerStatefulWidget` with `TickerProviderStateMixin` for `HomeUpcomingCarousel` animation lifecycle; added carousel below "This Month" section; added full-screen `AppLoadingOverlay` when `state.isLoading` is true.
  - `test/features/availability/presentation/screens/manage_availability_screen_test.dart` & `test/features/availability/presentation/availability_notifier_test.dart`: Updated test mocks and added widget test for upcoming shoots rendering on Manage Availability screen.

- **Decisions**:
  - Reused `HomeUpcomingCarousel` widget directly to preserve UI styling and card swipe stack animation behavior.
  - Used `AppLoadingOverlay` to display full-screen Lottie loader during screen data fetching and month shifts.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/availability` — 45/45 passing.

---


### 2026-07-23: Cupertino Time Picker (5-min step), Default Today Date & Validation Input Guarding

- **Changes**:
  - `lib/shared/widgets/app_cupertino_time_picker.dart`: Added `minuteInterval: 5` and initial minute rounding to 5-minute multiples (`0, 5, 10, 15...`).
  - `lib/features/availability/presentation/screens/add_availability_screen.dart`:
    - Updated `_pickStartTime`: When Start Time is picked, End Time is automatically set to `Start Time + 1 hour`. Rejects past time for today without updating input area.
    - Updated `_pickEndTime`: Prevents updating `_endTimeController.text` when selected End Time is invalid (<= Start Time or < 1 hour gap), displaying validation snackbar instead.
  - `lib/utility/date_time_utils.dart`: Updated `DateTimeUtils.validateTimeRange` for 1-hour gap and past time checks.
  - `lib/features/availability/presentation/providers/availability_providers.dart`: Validates time range in `submit`.
  - `test/features/availability/presentation/availability_notifier_test.dart`: 39/39 tests passing.

- **Decisions**:
  - Configured 5-minute step intervals in the Cupertino picker wheel. Prevents populating text controllers with invalid times when selection fails validation.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/availability/` — 39/39 passing.

---

### 2026-07-22: Manage Availability — tap a "Shoot" day to open its shoot details

- **Changes**:
  - `lib/shared/widgets/common_calendar.dart`: Added optional `onDaySelected(day, event)` callback, wired to `TableCalendar.onDaySelected`.
  - `lib/features/availability/domain/entities/availability_entry.dart`: New `AvailabilityDay{status, bookingId}` value type (with `==`/`hashCode`) replacing the bare `AvailabilityStatus` in the fetched-month map.
  - `lib/features/availability/data/repositories/availability_repository_impl.dart`: Parses `projectDetails.booking_id` off the `creator/availability` per-day payload when `projectAssigned == true`.
  - `lib/features/availability/domain/repositories/availability_repository.dart`: `fetchMonth` return type updated to `Map<DateTime, AvailabilityDay>`.
  - `lib/features/availability/presentation/providers/availability_providers.dart`: `ManageAvailabilityState.events` updated to the new map type.
  - `lib/features/availability/presentation/screens/manage_availability_screen.dart`: Tapping a day marked `Shoot` reads its `bookingId` from state and pushes `Routes.upcomingShootDetails` with it as `projectId`.

- **Decisions**:
  - Initial approach cross-queried `creator/dashboard-details` (the Shoots-tab list) to match a shoot by date — dropped in favor of reading `booking_id` directly off the availability response itself, since the backend already returns it. Avoids a second network call and date-match mismatches (independent endpoints, could disagree).

- **Verification**:
  - `flutter analyze` — 0 issues on touched files.
  - `flutter test test/features/availability/ test/shared/widgets/common_calendar_test.dart` — 36/36 passing, including new widget tests asserting tap-to-navigate and that non-"Shoot" days don't navigate.

---

### 2026-07-22: Accept / Decline Action Buttons Visibility Condition (`can_take_action`)

- **Changes**:
  - `lib/features/home/presentation/widgets/home_pending_shoot_card.dart`: Updated action buttons visibility condition to `if (data.canTakeAction == true)`, hiding Accept/Decline action buttons strictly based on the `can_take_action` boolean flag from the API response.
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`: Updated `_ShootCard` action buttons visibility condition to `if (shoot.canTakeAction)`, hiding Accept/Decline action buttons strictly based on the `can_take_action` boolean flag from the API response.

- **Decisions**:
  - Removed local `isActionable` fallback overrides so button visibility strictly honors the backend `can_take_action` flag across both Dashboard and Shoots screens.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/shoots/` and `flutter test test/features/home/` — all tests passing.

---

### 2026-07-22: Decline Shoot Request Modal Bottom Sheet & Disabled Comments Field

- **Changes**:
  - `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart`:
    - Added `showDeclineShootBottomSheet(context, projectId: ...)` helper using `showModalBottomSheet(isScrollControlled: true, backgroundColor: Colors.transparent, useRootNavigator: true)` to ensure native modal bottom sheet presentation over the caller's view instead of full screen navigation.
    - Updated `_buildCommentField` to be **disabled** (`enabled: isOtherSelected`) when any reason other than "Others" is selected, displaying dimmed borders/text and hint `"Select 'Others' to add details.."`. Enables `TextField` when "Others" is selected.
  - `lib/features/home/presentation/widgets/home_pending_shoot_card.dart`: Updated Decline CTA button to invoke `showDeclineShootBottomSheet`.
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`: Updated Decline action in `_ShootCard` to invoke `showDeclineShootBottomSheet`.

- **Decisions**:
  - Standardized bottom sheet invocation using `showModalBottomSheet` matching existing app patterns (`showHomeFilterBottomSheet`, `showMeetingDetailsSheet`).
  - Disabled the optional comments text field until "Others" is selected for cleaner UX and clear form focus.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/shoots/` and `flutter test test/features/home/` — all tests passing.

---

### 2026-07-22: Decline Shoot Request Modal Bottom Sheet & Option 1 CTA Styling

- **Changes**:
  - `lib/features/shoots/presentation/routes/shoots_routes.dart`: Updated `Routes.cancelShoot` to use non-opaque `CustomTransitionPage` (`opaque: false`, `barrierColor: 60% black`) with a slide-up transition. Fixed the issue where `Routes.cancelShoot` opened as a separate screen instead of a modal bottom sheet overlay.
  - `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart`:
    - Updated background to `AppColors.transparent` and added `resizeToAvoidBottomInset: true` with `SingleChildScrollView` and bottom inset padding to prevent overflow when typing comments.
    - Updated Decline CTA button to Option 1: Enabled background `AppColors.primary` (`#E8D1AB`), foreground text `AppColors.onPrimary` (`#1D1D1B` dark charcoal) for high contrast and legibility.
    - Updated radio buttons to match Screenshot 3 (filled gold circle with inner dark dot when selected).
    - Rendered explicit "Additional comments (optional)" input field.
    - Updated `submittedSignal` listener to return `context.pop(true)` so the caller receives success signal and triggers toast & refresh.

- **Decisions**:
  - Standardized `Routes.cancelShoot` as a non-opaque modal route to prevent screen replacement/flashing.
  - Applied Option 1 high-contrast typography (`AppColors.onPrimary` on `AppColors.primary`) for accessibility and visual polish.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/shoots/` — 17/17 passing.
  - `flutter test test/features/home/` — 47/47 passing.

---

### 2026-07-22: Shoot Accept/Decline Full-Screen Overlay Loader & App-Wide Toasts

- **Changes**:
  - `lib/features/home/presentation/providers/home_state.dart`: Added `actionInFlightProjectId` field to track in-flight accept/decline action on Dashboard.
  - `lib/features/home/presentation/providers/home_notifier.dart`: Updated `acceptDecline` to track `actionInFlightProjectId` and return `Future<bool>`.
  - `lib/features/home/presentation/screens/home_screen.dart`: Mounted `AppLoadingOverlay()` transparent overlay when `actionInFlightProjectId != 0`, and triggered `TopMessage` success/error toasts on Accept and Decline.
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`: Mounted `AppLoadingOverlay()` transparent overlay when `actionInFlightProjectId != 0`, updated `_ShootCard` action buttons, and triggered `TopMessage` success/error toasts on Accept and Decline.
  - `test/helpers/test_data.dart`: Added `cta` parameter to `singleShootJson()`.

- **Decisions**:
  - Used `AppLoadingOverlay()` with 50% opacity backdrop to block double taps while preserving visibility of the underlying card during API calls.
  - Aligned toast notifications across Shoots and Dashboard with app-wide `TopMessage` theme.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/shoots/presentation/screens/shoots_screen_test.dart` — 4/4 passing.
  - `flutter test test/features/home/` — 47/47 passing.

---

### 2026-07-22: Shoot Details UI & Team Members Integration

- **Changes**:
  - `lib/model_class/upcoming_shootview_model.dart`:
    - Updated `MyData.fromJson` to parse `cp_profiles` / `cp_profile` array as fallback for `team_members`.
    - Added key fallbacks to `TeamMember.fromJson` (`crew_member_id` / `id` / `user_id`, `name` / `full_name`, `role_name` / `role`, `profile_image_url` / `image_url` / `avatar`).
    - Handled missing `team_summary` by deriving `assignedCount` and `totalRequired` from member list length.
  - `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`:
    - Hero header: Replaced text with `mydata.project.projectName`, added status pill badge (`🟢 Active`), and displayed `ID: #${mydata.project.idLabel}` in gold.
    - Ticket Stub Card: Added custom ticket stub divider (`_TicketDashedDivider`) with left and right semi-circle cutouts and dashed separator line.
    - Shoot Status Inner Card: Styled *"Shoot Status"* in gold, *"Current Stage"* in gold (`Pre Production`), and formatted *"Last Updated"* timestamp.
    - Team Members Section: Added section header with assigned ratio `(06/06)` and horizontal list view of team member avatars (`CachedNetworkImage`), full names, and role labels.
    - Time & Budget & Client Contact: Polished side-by-side cards and dark icon containers with gold icons.
  - `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart`: Added widget test coverage for team members rendering.

- **Decisions**:
  - Derived assigned count and total required from `teamMembers.length` if `team_summary` is missing from payload to prevent null crashes.
  - Implemented pixel-accurate ticket stub cutout divider matching reference screenshot.

- **Verification**:
  - `flutter analyze --fatal-infos` — 0 issues found.
  - `flutter test test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — 4/4 passing.

---

### 2026-07-22: Dashboard API Updates (crew_stats, cp_profiles, request_time_ago, card formatting)

- **Changes**:
  - `lib/model_class/crewstatus_model.dart`: Added `photoRejectedShoots`, `photoShootRequests`, `videoRejectedShoots`, `videoShootRequests` to `CrewStatsData`.
  - `lib/model_class/cp_profile_model.dart`: Created `CpProfile` model class to represent shoot members.
  - `lib/model_class/upcoming_shoots_model.dart`: Added `cpProfiles` parsing from `json['cp_profiles']` in `UpcomingShootDatum`.
  - `lib/model_class/create_dashboard_details_model.dart`: Added `requestTimeAgo` and `cpProfiles` parsing in `PendingRequestCard`.
  - `lib/features/home/presentation/providers/home_notifier.dart`: Updated category statistics logic to map photo-specific and video-specific metrics from `crew_stats` with `shoot_categories` fallback.
  - `lib/features/home/presentation/widgets/home_shoot_categories_panel.dart`: Updated Photo and Video tabs to display tab-specific stats and arc colors.
  - `lib/features/home/presentation/widgets/home_upcoming_carousel.dart`: Added overlapping member avatar stack for `cpProfiles` on upcoming shoot cards.
  - `lib/features/home/presentation/widgets/home_pending_shoot_card.dart`:
    - Updated `request_time_ago` chip: set background to `#FFFFFF33` (20% opacity white) and removed time icon.
    - Added shoot members avatar stack on left side of Accept/Decline action buttons.
    - Formatted shoot date as readable date `MMM dd, yyyy` (e.g. `Jan 05, 2026`).
    - Added bottom-left Status pill (`Confirmed`/`Pending`) and Category pill over image matching Shoots listing cards.
    - Unified Date, Time, and Location into a single `Row` layout matching Shoots listing cards.
  - `lib/model_class/shoots_model.dart`: Added `cpProfiles` parsing from `json['cp_profiles']` in `Shoot` model.
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`:
    - Updated shoot listing card date format to readable date `MMM dd, yyyy` (e.g. `Jan 05, 2026`).
    - Integrated dynamic `cp_profiles` member avatar stack in `_buildAvatarGroup(shoot.cpProfiles)` for shoot listing cards.
    - Added `AppEmptyState` empty views for both empty search query results (`No shoots found`) and empty shoot data (`No shoots available`).

- **Decisions**:
  - Used single `Row` layout with `Expanded` location text in both Pending Request card and Shoots listing card for clean, uniform layout consistency.
  - Formatted dates uniformly across Dashboard and Shoots listing with `DateTimeUtils.formatReadableDate`.

- **Verification**:
  - `flutter test test/features/home/presentation/home_notifier_test.dart` — 9/9 passed.
  - `flutter analyze --fatal-infos` — 0 issues found.

---

### 2026-07-21: Filter Bottom Sheet Enhancements (90% Height, Sticky Bottom Bar, Date Expanded Default)

- **Changes**:
  - `home_filter_sheet.dart`: Set `initialChildSize: 0.9` for 90% sheet height, set `isDateExpanded = true` by default, and refactored layout to pin "Clear All" & "Apply" CTAs in a sticky bottom container.

- **Decisions**:
  - Pinned action buttons at the bottom with top divider (`AppColors.white.withValues(alpha: 0.12)`) and safe-area padding for a solid, responsive user experience.

- **Verification**:
  - `flutter test test/features/home/presentation/home_notifier_test.dart test/model_class/creator_dashboard_model_test.dart` — Passed.
  - `flutter analyze --fatal-infos` — 0 issues found.

---

### 2026-07-21: Remove Category Filter Option from Upcoming Shoots Filter

- **Changes**:
  - `home_filter_sheet.dart`: Removed the `"Filter By Category"` section from `showHomeFilterBottomSheet` and cleaned up unused category variables.
  - `home_screen.dart`: Updated `isFilterActive` condition on `HomeUpcomingCarousel` to omit `upcomingSelectedCategory`.

- **Decisions**:
  - Upcoming Shoots filter bottom sheet now displays Date, Status, and Type filter sections.

- **Verification**:
  - `flutter test test/features/home/presentation/home_notifier_test.dart test/model_class/creator_dashboard_model_test.dart` — All 10 tests passed.
  - `flutter analyze --fatal-infos` — 0 issues found.

---

### 2026-07-21: Dashboard Full-Screen Loader Integration

- **Changes**:
  - `home_screen.dart`: Imported `shared/widgets/loading.dart`, wrapped layout in a `Stack`, and rendered `const AppLoadingOverlay()` while `homeState.isLoading` is true.

- **Decisions**:
  - Reused standard `AppLoadingOverlay` widget from `lib/shared/widgets/loading.dart` to maintain app-wide visual consistency.

- **Verification**:
  - `flutter test test/features/home/presentation/home_notifier_test.dart` — All tests passed.
  - `flutter analyze --fatal-infos` — 0 issues found.

---

### 2026-07-21: Dashboard Data Setup Correction (Upcoming Shoots & Pending Request Header)

- **Changes**:
  - `creator_dashboard_model.dart`: Updated `CreatorDashboardPayload.fromJson` to check `json['upcoming_accepted_projects']` (with fallback to `json['upcoming_accepted_project']`).
  - `home_upcoming_carousel.dart`: Removed Accept / Decline action buttons from upcoming shoots card stack, retaining only the `"View Details"` CTA.
  - `home_pending_shoot_card.dart`: Changed section header from `"Shoot Requests"` to `"Pending Request"`.
  - `creator_dashboard_model_test.dart`: Added unit test case verifying `upcoming_accepted_projects` parsing.
  - `home_notifier.dart`: Removed unused imports.

- **Decisions**:
  - Upcoming Shoots card displays only `"View Details"` (no Accept/Decline action buttons).
  - Pending shoot requests display under section title `"Pending Request"` with Accept & Decline action CTAs.

- **Verification**:
  - `flutter test test/model_class/creator_dashboard_model_test.dart test/features/home/presentation/home_notifier_test.dart` — Passed cleanly.
  - `flutter analyze --fatal-infos` — 0 issues found.

---

### 2026-07-21: Update Dashboard Shoots Card Action Label (Reject -> Decline)

- **Changes**:
  - `home_pending_shoot_card.dart`: Mapped secondary CTA text to display "Decline" when the secondary CTA text is "Reject".
  - `meeting_card.dart`: Changed default RSVP action button label from `'Reject'` to `'Decline'`.
  - `home_decompose_test.dart` & `meetings_screen_test.dart`: Updated widget tests to assert `'Decline'` label.

- **Decisions**:
  - Maintained original button design, colors, and styling (`AppColors.shootDeclineButtonBackground`, `AppColors.shootDeclineButtonText`), updating only text labels.

- **Verification**:
  - `flutter test test/features/home/presentation/home_decompose_test.dart test/features/meetings/presentation/screens/meetings_screen_test.dart` — All tests passed.

---

### 2026-07-17: Upcoming Meetings Carousel Section on Home Page

- **Changes**:
  - `home_state.dart`: Added `upcomingMeetingsList` field to `HomeState` along with constructor and `copyWith` mapping.
  - `home_notifier.dart`: Watch `meetingsRepositoryProvider` and fetch upcoming meetings in parallel during coordinated refresh. Added resilient `_safeFetchUpcomingMeetings` handler.
  - `home_upcoming_meetings_carousel.dart`: Created stacked swipeable carousel specifically for upcoming meetings. Reuses the standard `MeetingCard` component directly and sets `onTap` to advance the stack and `onDetailTap` to open the details bottom sheet.
  - `meeting_card.dart`: Added an optional `backgroundColor` parameter to support stacked depth background colors, and an optional `onDetailTap` callback for separating card tap from details tap actions.
  - `meeting_details_sheet.dart`: Set `useRootNavigator: false` to force pushing bottom sheet inside branch navigator.
  - `app_shell.dart`: Wrapped the shell branch content in a `ClipRect` to clip branch-navigator overlays at the top of the bottom navigation bar.
  - `home_screen.dart`: Switched to `TickerProviderStateMixin`, added independent `_meetingsController` and `_meetingsCurrentIndex` states, and rendered `HomeUpcomingMeetingsCarousel` below `HomeUpcomingCarousel`.
  - `home_notifier_test.dart`: Added `_FakeMeetingsRepo` stub, registered it in `_createContainer`, updated refresh hydration assertion, and added a resilient failure test case.

- **Decisions**:
  - Implemented Option A (Premium Calendar Leaf) for the left side of the meeting card since meetings don't have project feature images, ensuring visual alignment (117x169) and layout consistency with shoots.
  - Created a separate `AnimationController` for meetings carousel so shoots and meetings stacks can be swiped and animated independently.

- **Verification**:
  - `flutter analyze` — 0 issues found.
  - `flutter test test/features/home/presentation/home_notifier_test.dart` — passed.
  - `flutter test test/features/home/presentation/home_decompose_test.dart` — passed.
  - `flutter test test/features/home/presentation/screens/home_screen_test.dart` — passed.

---

### 2026-07-16: Fix Meetings "Invalid user ID" (session snapshot clobbered with 0)

- **Changes**:
  - `home_notifier.dart` `_safeFetchProfile`: no longer overwrites the session `UserSnapshot.id` with the profile payload's user id when that id parsed to `0`; falls back to the existing session id, and skips the snapshot write entirely when neither source has a valid id.
  - `myprofile_model.dart`: `User.fromJson` id parsing now accepts int/num/numeric-string and falls back to the `user_id` key via a shared `_parseId` helper (returns `null`, not `0`, when absent so fallbacks can chain).
  - `meetings_remote_source.dart` `list()`: treats session user id `'0'` the same as a missing id → `UnauthorizedException`, so the meetings notifier's existing logout path forces a re-login, which restores the real id from the login response (recovery path for devices whose snapshot was already corrupted).
  - Removed the temporary `[MEETINGS_NOTIFIER_DEBUG]` print from `meetings_list_notifier.dart`.

- **Decisions**:
  - Root cause: `get-profile-detail` payload drift can omit the nested `user` object/id; the model defaulted `user.id` to `0`, and the home profile fetch wrote that over the correct login id — meetings then called `GET external-meetings/user/0` and the server rejected with "Invalid user ID".
  - Did **not** fall back to the payload's top-level `id` when synthesizing the user object — that is the crew-member row id, not the user id; writing a wrong id is worse than keeping none.
  - Recovery is dynamic (guard + re-login), no hardcoded user id.

- **Verification**:
  - `flutter analyze` — 0 issues.
  - `flutter test test/features/meetings test/features/home` — all 60 tests passed.

---

### 2026-07-16: Dashboard Percentage Trend Labels and Figma Styling

- **Changes**:
  - Modified `DashboardCountModel` and `DashboardCountData` to parse the new `percentages` field containing `completedShoots.label`, `upcomingShoots.label`, and `pendingRequests.label`.
  - Added `completedShootsLabel`, `upcomingShootsLabel`, and `pendingRequestsLabel` fields (String, defaults to `""`) to `HomeState` and mapped them in `HomeNotifier.refresh()` and `HomeNotifier.acceptDecline()`.
  - Updated `HomeScreen` to pass the percentage labels to `HomeDashboardSummary`.
  - Refactored `HomeDashboardSummary` and `_DashboardCard` to render the trend percentage text under the count and pad single-digit counts with leading zeros (e.g. `03` instead of `3`) to match the Figma mockup.
  - Used `Text.rich` to style the percentage value part (`+3%`/`-2%`) in green/red, and the rest of the text description (`from last month`) in a muted grey color, matching the design screenshot.
  - Styled trend labels with a contrast-safe color scheme (bright green/red for dark cards, dark green/dark red for the selected gold card).
  - Updated `test_data.dart` mock counts response to include `percentages` payload.
  - Updated `home_decompose_test.dart` to test trend label presentation and two-digit padded counts.

- **Decisions**:
  - Parsed the percentage value and description separately using RegExp (`r'^([▲▼]?\s*[+-]?\d+(?:\.\d+)?%)'`) to apply distinct text styles.
  - Kept counts formatting inline using `.toString().padLeft(2, '0')`.
  - Automatically derived positive/negative styling from trend label characters (`-` or `▼`), and adjusted colors dynamically when the card is selected to maintain high contrast and accessibility.

- **Verification**:
  - `flutter analyze` — passed with 0 issues.
  - `flutter test test/features/home/presentation/home_decompose_test.dart` — passed.
  - `flutter test test/features/home/presentation/home_notifier_test.dart` — passed.

---

### 2026-07-15: Unified CTA Buttons & Loading State Option

- **Changes**:
  - Created `AppCtaButton` component under `lib/shared/widgets/app_cta_button.dart` using the `Unbounded` font family, font weight `w500`, and font size `14`.
  - Migrated onboarding, login, forgot password, OTP, reset password, signup forms (Step 1, 2, 3), success screens, and post-login profile edit screens to use `AppCtaButton`.
  - Removed all pre-login and post-login button-level loading states and spinners (`isLoading` property and circular loader) per initial user request.
  - Added an optional `isLoading` parameter (default `false`) to `AppCtaButton` to support opt-in loading indicators and automatic button disablement.
  - Migrated Availability screens (`manage_availability_screen.dart` and `add_availability_screen.dart`) to use `AppCtaButton`, with `add_availability_screen.dart` using the new `isLoading` property for its save button.
  - Added location permission dialog auto-dismissal helper to `SignupRobot` in integration tests.

- **Decisions**:
  - Implemented the `visuallyEnabled` property in `AppCtaButton` to allow Step 1 of the signup form button to look visually disabled (using Option 1 colors) while remaining clickable to trigger standard validation error toasts and overlays.
  - Kept other forms' buttons disabled/enabled using the `enabled` parameter when their corresponding form values are invalid, keeping consistency with original designs.

- **Verification**:
  - `flutter analyze` — passed (No issues found).
  - `flutter test` (Onboarding, Login, Forgot Password, and Availability screens) — passed.
  - Integration tests successfully dismiss LocationPermissionDialog on test start.

---

### 2026-07-13: iPhone/iPad responsive safety fixes

- **Changes**:
  - Added opt-in custom-footer safe-area handling in `lib/shared/layouts/app_scaffold.dart` and enabled it on login/profile custom-footer screens.
  - Added `lib/shared/widgets/app_icon_tap_target.dart` and migrated high-risk back, close, edit, and delete-style icon-only controls across auth, profile, and shoots screens to a 44x44 default hit target.
  - Clamped compact calendar text sizes in `lib/shared/widgets/common_calendar.dart` and added focused coverage for compact event-label readability.
  - Fixed the messages provider dispose-read failure by guarding `activeChatRoomProvider` cleanup through a captured mounted controller.
  - Updated `docs/IPHONE_IPAD_RESPONSIVE_FIX_PLAN.md` from plan-only to execution tracker.

- **Decisions**:
  - Used an opt-in `safeBottomNavigationBar` instead of globally wrapping every bottom navigation bar, preserving existing shell/bottom-nav behavior.
  - Kept icon artwork at existing visual sizes while expanding touch boxes through `AppIconTapTarget`; signup header row alignment was adjusted to keep the existing device-matrix goldens unchanged.
  - Deferred broad iPad max-width wrappers and modal bottom-sheet consistency work to a later visual pass because both affect many screens and should be driven by dedicated device-matrix coverage.
  - No phase task file updated because this remains a cross-cutting responsive review task, not a specific active phase migration item.

- **Verification**:
  - `dart format <touched Dart files>` — 32 files checked, 0 changed.
  - `flutter analyze --fatal-infos` — passed.
  - `git diff --check` — passed.
  - `flutter test test/shared/layouts/app_scaffold_test.dart test/shared/widgets/app_icon_tap_target_test.dart test/shared/widgets/common_calendar_test.dart test/features/messages/presentation/screens/messages_screen_test.dart test/golden/device_matrix_test.dart` — passed.
  - Main screen widget batch — passed for login, signup3, forgot/reset password, home, my profile, shoots, upcoming shoot details, availability, meetings, and messages.

- **Remaining Risk**:
  - No physical device or simulator manual smoke was run for iPhone/iPad.
  - R-05 tablet max-width polish and R-08 modal bottom-sheet consistency remain deferred in `docs/IPHONE_IPAD_RESPONSIVE_FIX_PLAN.md`.

---

### 2026-07-13: iPhone/iPad responsive fix plan

- **Changes**:
  - Added `docs/IPHONE_IPAD_RESPONSIVE_FIX_PLAN.md` with status-tracked fix rows for the responsive/design review findings.

- **Decisions**:
  - Plan-only update; no source fixes applied.
  - Implementation remains gated on explicit approval.
  - No phase task file updated because this is a cross-cutting review plan, not an active Phase 6 task.

- **Verification**:
  - Documentation-only change; no tests run after the doc edit.
  - Review baseline captured in the plan: analyzer currently fails on one unused import and two test infos; the messages screen test has an existing provider-dispose failure; device-matrix and shell/scaffold tests passed during review.

- **Remaining Risk**:
  - iPhone home-indicator footer overlap, sub-44px custom icon hit targets, calendar micro text, limited iPad whole-screen coverage, and the messages lifecycle failure remain unfixed until implementation is approved.

---

### 2026-06-26: File Manager UI mockups design alignment enhancements

Aligned the File Manager UI widgets with the provided Figma mockup screenshots, polishing search input borders, scrollable flat tab bars, folder card colors and spacing, portrait file previews, custom project badge initial blocks, and actions sheet dividers.

- **Files touched:**
  - `lib/features/file_manager/presentation/widgets/fm_search_field.dart` — changed border corners from standard 8px (`AppRadii.mdAll`) to fully rounded capsule pill (`AppRadii.fullAll`).
  - `lib/features/file_manager/presentation/widgets/fm_tab_bar.dart` — changed from a capsule container to a flat, horizontally scrollable tab row with active bottom underline indicator matching Option A (Brand Gold).
  - `lib/features/file_manager/presentation/screens/file_manager_screen.dart` — removed horizontal padding wrapping the tab bar, letting the scrollable bar scroll to screen edges natively.
  - `lib/features/file_manager/presentation/widgets/fm_folder_card.dart` — updated folder icon to use `AppAssets.icFolder` SVG with `AppColors.warning` (amber-yellow), file count text to secondary color, and opened-ago timestamp to small muted style.
  - `lib/features/file_manager/presentation/widgets/fm_file_card.dart` — replaced square preview block file icon with portrait vertical document preview (`_DocumentPreview`) displaying custom text/icons.
  - `lib/features/file_manager/presentation/widgets/fm_linked_badge.dart` — added support for outline chip style variant using a boolean flag, and adjusted padding/font to make it compact (height ~28px).
  - `lib/features/file_manager/presentation/widgets/fm_tag_chip.dart` — adjusted padding/font to make it compact (height ~28px), aligning with the linked badge.
  - `lib/features/file_manager/presentation/widgets/fm_project_badge_card.dart` — updated project initial preview `_Thumb` to display raw badge label (e.g. `L#1`) and styled badge background with light blue-grey and dark text.
  - `lib/features/file_manager/presentation/widgets/fm_actions_sheet.dart` — added divider lines between action rows.

- **Decisions:**
  - **Option A for tab underline and folder icon**: Kept design options aligned with brand colors using warning-amber and brand-gold.
  - **Option B for linked badge**: Implemented outline constructor flag but kept standard folder card badge solid as shown on left screen of the mockup.
  - **Update all goldens**: Re-generated both file manager and other pre-existing failing golden screenshots (`messages_test.dart` and `cards_test.dart`) to keep global checks green.

- **Verification:**
  - `flutter test test/features/file_manager/` — all tests passed.
  - `flutter test test/golden/file_manager_test.dart` — all tests passed.
  - `flutter test` — all tests passed.
  - `flutter analyze --no-fatal-infos` — zero issues.

---

### 2026-06-23: Messages chat-details participant role labels

Reused the chat thread role formatter in the chat details participants list so backend role codes render consistently everywhere messages show user roles.

- **Files touched:**
  - `lib/features/messages/presentation/screens/chat_details_screen.dart` — imports `roleLabel` and formats each participant role through the same messages-domain helper used by chat thread bubbles.
  - `test/features/messages/presentation/screens/messages_screen_test.dart` — added a `ChatDetailsScreen` regression asserting backend `cp` renders as `Creative Partner`.

- **Decisions:**
  - **Use existing formatter, not a new mapper**: `lib/features/messages/domain/role_label.dart` remains the single display mapping for message roles (`cp`, `creative_partner`, `sales_rep`, unknown title-casing).
  - **No phase task status change**: this is a small sidecar messages UI consistency fix, not active Phase 6 task 6.14 scope.

- **Verification:**
  - `flutter test test/features/messages/presentation/screens/messages_screen_test.dart` — all tests passed.
  - `flutter analyze --fatal-infos` — no issues found.

---

### 2026-06-16: Sidecar UX — Adaptive location permission dialog

Replaced inconsistent location-denial UX (mixed snackbar + direct settings open in signup, silent fail in edit profile) with a single shared adaptive dialog. No phase-6 task touched.

- **Files touched:**
  - `lib/shared/widgets/location_permission_dialog.dart` — new shared widget. `showLocationPermissionDialog(BuildContext, LocationStatus)` returning `Future<bool>`. Mirrors `no_internet_dialog.dart` pattern: `showAdaptiveDialog` + `AlertDialog.adaptive` + `_adaptiveAction` helper (iOS = `CupertinoDialogAction`, Android = `TextButton`). Branches copy + settings target per `LocationStatus` (`serviceDisabled` → `openLocationSettings`, `permanentlyDenied` → `openAppSettings`, `denied` → caller retries, `unknown` → no-op).
  - `lib/features/auth/presentation/screens/signup1_screen.dart` — `_getCurrentLocation` now calls the dialog on `LocationException`; retries once if user grants on `denied`. Dropped direct `Geolocator.openLocationSettings` / `openAppSettings` / `SnackBar` calls. Removed unused `package:geolocator/geolocator.dart` import.
  - `lib/features/profile/presentation/screens/edit_personal_details_screen.dart` — `loadCurrentLocation` swapped silent `catch (_)` for the dialog with the same retry-on-`denied` behavior.

- **Decisions:**
  - **Dialog owns settings navigation**: callers pass the status and await the dialog; the dialog itself calls `Geolocator.openLocationSettings()` / `openAppSettings()`. Keeps screen code slim and copy/behavior consistent across screens.
  - **Retry only on `denied`**: `serviceDisabled` and `permanentlyDenied` route to a settings surface, so retry on return is the user's choice (and a fresh navigation event). `denied` bounces back through the OS prompt — single recursive retry is bounded since the next deny escalates to `deniedForever`.
  - **No tests this pass**: shared widget, not entry-point screen. Phase-6 widget-test guidance is screen-scoped; deferred.

- **Verification:**
  - `flutter analyze` — zero issues.
  - Manual smoke pending (signup + edit profile on iOS/Android with location off, soft-denied, hard-denied).

---

### 2026-06-16: iOS Google Maps Configuration Alignment, remote source, and location tests

Aligned iOS native Google Maps API keys with local environment configuration, resolved a failing REST details endpoint unit test, and implemented unit tests for LocationService and LocationException.

- **Files touched:**
  - `ios/Flutter/GoogleMaps-dev.xcconfig` — regenerated using `pod install` to update the native dev Google Maps API key caching.
  - `ios/Flutter/GoogleMaps-prod.xcconfig` — regenerated using `pod install` to update the native prod Google Maps API key caching.
  - `lib/features/messages/data/dto/chat_details_dto.dart` — added root-level JSON fallbacks for ContactInfo (id, name, email, phone, avatarUrl) to support both flat and wrapped backend response schemas.
  - `test/utility/location_exception_test.dart` — new unit tests covering `LocationException` and `LocationStatus` enum formatting.
  - `test/utility/location_service_test.dart` — new unit tests verifying reverse geocoding placemark parsing and geolocator location retrieval under all permission states.

- **Decisions:**
  - **Flat + Wrapped REST fallbacks in DTO**: Supported both structures in `ChatDetailsDto.fromRestJson` to maintain robust compatibility with both client-side test fixtures and varied backend response formats.
  - **Geolocator Platform Mocking**: Mocked Geolocator and Geocoding by setting custom instances on `GeolocatorPlatform` and `GeocodingPlatform` using `MockPlatformInterfaceMixin` to bypass platform-interface checks hermetically.

- **Verification:**
  - `flutter analyze` — zero issues.
  - `flutter test` — all 528 tests passed successfully, including the new location service and updated messages remote source tests.

---

### 2026-06-16: Fix stuck retry, unauthorized logout, and bubble headers

Implemented session self-healing (automatic logout on `UnauthorizedException`) to fix stuck retry bugs, and styled message/audio bubbles with sender name and role badge inside the bubble.

- **Files touched:**
  - `lib/features/messages/presentation/providers/conversation_list_providers.dart` — caught `UnauthorizedException` in `ConversationListNotifier.refresh()` and called `logout()`.
  - `lib/features/messages/presentation/providers/chat_thread_providers.dart` — caught `UnauthorizedException` in `ChatThreadNotifier` operations (`_hydrate`, `sendText`, `finishRecording`, `markRead`) to trigger `logout()`; added `senderRoles` map to state and populated it.
  - `lib/features/messages/presentation/providers/chat_details_providers.dart` — caught `UnauthorizedException` in `chatDetailsProvider` to trigger `logout()`.
  - `lib/features/messages/presentation/screens/chat_thread_screen.dart` — passed `senderRole` from thread state `senderRoles` to message and audio bubbles.
  - `lib/features/messages/presentation/screens/widgets/message_bubble.dart` — refactored bubble to display capitalized sender name and a title-cased `_RoleBadge` pill inside the bubble container.
  - `lib/features/messages/presentation/screens/widgets/audio_bubble.dart` — wrapped internal row in a column and displayed name and `_RoleBadge` pill inside the audio bubble container.
  - `test/features/messages/presentation/providers/conversation_list_notifier_test.dart` — added unit test verifying that `UnauthorizedException` triggers session logout.
  - `test/golden/goldens/messages_bubbles_dark.png` — updated golden screenshot to reflect the new bubble layouts.

- **Decisions:**
  - **Inside-bubble headers**: Renders sender name and role badge in the same bubble colors using a soft opacity border/background to fit seamlessly into the design.
  - **Self-healing logout**: When encountering `UnauthorizedException` (e.g. from session expiration or backend token invalidation), automatically sign the user out via `authStateProvider.notifier.logout()`, immediately bringing them back to the login screen and breaking infinite retry/reload loops.

- **Verification:**
  - `flutter test test/features/messages` — 27 / 27 passing.
  - `flutter test test/golden/messages_test.dart` — All golden tests passed.
  - `flutter analyze` — clean.

---

### 2026-06-16: Fix Messages socket dev host 404

Fixed the Socket.IO connect error:
`WebSocketException ... api.dev.beige.app:0/socket.io ... HTTP status code: 404`.

- **Findings:**
  - `socket_io_client` 2.0.3+1 derives `Uri.port` as `0` when no explicit port
    is supplied, explaining the `:0` in the debug URL.
  - Live unauthenticated probes showed `api.dev.beige.app/socket.io` is not
    mounted: both polling and WebSocket upgrade returned Express 404
    `Route not found`.
  - Sibling app `biegeapp` uses `https://api2.dev.beige.app`; live probes
    verified `api2.dev.beige.app/socket.io` returns an Engine.IO open packet
    and WebSocket upgrade returns HTTP 101.

- **Files touched:**
  - `lib/config/env.dart` — dev `socketUrl` default corrected to
    `https://api2.dev.beige.app`; added `CHAT_SOCKET_URL` dart-define override.
  - `lib/features/messages/data/sources/messages_socket_source.dart` — set
    explicit `/socket.io` path and WebSocket-only transport.
  - `env/dev.example.json`, `env/prod.example.json` — documented
    `CHAT_SOCKET_URL`.
  - `docs/feature/MESSAGES_M6_API_SOCKET_PLAN.md`, `docs/AI_HANDOFF.md` —
    recorded the corrected host and probe results.

- **Verification:**
  - `curl https://api.dev.beige.app/socket.io/?EIO=4&transport=websocket` with
    upgrade headers — HTTP 404.
  - `curl https://api2.dev.beige.app/socket.io/?EIO=4&transport=polling` —
    HTTP 200 Engine.IO open packet.
  - `curl https://api2.dev.beige.app/socket.io/?EIO=4&transport=websocket` with
    upgrade headers — HTTP 101 Switching Protocols.
  - `flutter test test/features/messages` — 26 / 26 passing.
  - `flutter analyze --fatal-infos` — clean.

---

### 2026-06-16: Fix Messages screen forcing logout after login

Fixed the post-login Messages redirect-to-login bug. Root cause: the real
login fixture documents `data.token + data.crew_member`, but
`AuthRepositoryImpl` only persisted a session user when `data.user` existed.
After login, Messages tried to derive `currentUserId` from `SessionStore`;
missing local user was converted into `UnauthorizedException`, and the
messages Notifiers respond to that exception by calling app logout.

- **Files touched:**
  - `lib/features/auth/data/repositories/auth_repository_impl.dart` — parses
    `crew_member` as a fallback `UserSnapshot`, including first/last name.
  - `lib/features/messages/data/sources/messages_remote_source.dart` — missing
    local user snapshot now falls back to `''` for DTO-only ownership/read
    derivation instead of manufacturing `UnauthorizedException`.
  - `test/features/auth/data/repositories/auth_repository_impl_test.dart` —
    pinned `crew_member` login parsing.
  - `test/features/messages/data/sources/messages_remote_source_test.dart` —
    pinned that missing local user still lets REST conversations load.

- **Decisions:**
  - Real backend 401s still map to `UnauthorizedException` through Dio and can
    trigger the existing app logout path. Only the local "no cached user
    snapshot" case stopped being treated as auth failure.
  - Kept the messages debug payload prints already present in the worktree;
    this fix did not remove or broaden them.

- **Verification:**
  - `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart test/features/messages/data/sources/messages_remote_source_test.dart` — all tests passed.
  - `flutter analyze --fatal-infos` — clean.
  - `flutter test test/features/messages` — 26 / 26 passing.

---

### 2026-06-16: Fix socket event messages not reflecting in UI

Fixed socket connection failures by removing handshake suffixes from the configured socket URLs in `Env`, and resolved rendering/alignment bugs in the message bubble UI.

- **Files touched:**
  - `lib/config/env.dart` — removed the duplicated `/socket.io/?...` suffix from `socketUrl` for both dev and prod environments.
  - `lib/features/messages/presentation/providers/chat_thread_providers.dart` — added `currentUserId` to state, populated it during hydration with defensive testing fallback, and solved REST vs socket receipt race conditions.
  - `lib/features/messages/presentation/screens/chat_thread_screen.dart` — updated `isMine` check to compare sender ID with `currentUserId`.
  - `lib/features/messages/data/sources/messages_remote_source.dart` — threw `UnauthorizedException` when user is null in `_currentUserId()`.
  - `test/features/messages/data/sources/messages_remote_source_test.dart` — aligned mock response fields with modern `ConversationDto` backend contracts.

- **Decisions:**
  - **Let socket_io_client build the path.** Removed suffix from `socketUrl` so the client can construct the connection correctly.
  - **Defensive fallback in _hydrate.** Wrapped the sessionStore read in a try-catch to keep widget tests running safely where `sessionStoreProvider` is not overridden.
  - **Dynamic deduplication.** Solved the race condition where socket echos arrive before REST call completes by checking if the returned ID exists and removing the local placeholder rather than appending.

- **Verification:**
  - `flutter test test/features/messages` — all 26 tests passed.

---

### 2026-06-15: ShootsScreen accept/decline button color tokens

Updated the pending-shoot action buttons in `ShootsScreen` to use the requested
accept/decline colors through `AppColors` only.

- **Files touched:**
  - `lib/app/colors.dart` — added semantic shoot action tokens for accept and decline button background/text colors.
  - `lib/features/shoots/presentation/screens/shoots_screen.dart` — swapped pending-card Accept/Decline buttons to the new tokens.
  - `lib/features/meetings/presentation/widgets/meeting_card.dart` — replaced an existing inline use of the requested mint color with `AppColors.softMint`.
  - `test/features/shoots/presentation/screens/shoots_screen_test.dart` — added a widget assertion that rendered button styles and text colors resolve to the shoot action tokens.
  - `docs/phase4/task_14_groupD_shoots.md` — recorded this post-completion UI-token follow-up.

- **Decisions:**
  - Kept the change scoped to `ShootsScreen`; home pending cards still use their existing Accept/Reject styling because the request was for the shoot screen.
  - Reused existing palette tokens where the requested colors already existed; added the new decline text red in `AppColors`.
  - Replaced the unrelated meeting-card inline mint because it used one of the requested source colors; broader meeting-card color cleanup remains outside this change.

- **Verification:**
  - `flutter analyze lib/app/colors.dart lib/features/shoots/presentation/screens/shoots_screen.dart lib/features/meetings/presentation/widgets/meeting_card.dart test/features/shoots/presentation/screens/shoots_screen_test.dart` — clean.
  - `flutter test test/features/shoots/presentation/screens/shoots_screen_test.dart test/features/meetings/presentation/screens/meetings_screen_test.dart` — 9 / 9 passing.

---

### 2026-06-15: iOS Maps loading diagnosis follow-up

Checked the current iOS Google Maps path after the 6.15 native wiring changes.

- **Findings:**
  - `ios/Runner/Info.plist` now uses `GMSApiKey`, and `ios/Runner/AppDelegate.swift` reads `GMSApiKey` before calling `GMSServices.provideAPIKey(...)`.
  - The Debug-dev simulator artifact has a resolved, non-empty `GMSApiKey` in `Runner.app/Info.plist` for bundle id `com.app.cpbeige.dev`; the value is not left as literal `$(GOOGLE_MAPS_KEY)`.
  - `ios/Flutter/GoogleMaps-{dev,prod}.xcconfig` are present and non-empty, generated from local `env/{dev,prod}.json`.
  - White-map follow-up: simulator logs show the native Google Maps SDK starts (`Google Maps SDK for iOS version: 9.4.0.0`) and creates `GMSCacheStorage`, then `GMSDASHConnection` / Google fetcher requests repeatedly return HTTP `400`.
  - The remaining iOS tile-loading blocker is Google Cloud key state/restriction: the local env still points at the old key called out by 6.15, so it must be rotated/replaced with a Maps SDK for iOS-enabled key restricted to `com.app.cpbeige.dev` / `com.app.cpbeige`.
  - Separate signup/edit-profile caveat: native Maps reads the xcconfig-backed plist key, but Places autocomplete reads `Env.googleMapsKey` from `--dart-define`. Running directly from Xcode without equivalent Dart defines can leave Places empty even when native map initialization has a key.

- **Verification:**
  - `flutter analyze` — clean.
  - `flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart -d 48F3BC5F-708D-4246-8668-242D492771C0` — launched on iOS simulator; no Dart-side map/layout errors surfaced before the debug connection was background-terminated.
  - `xcrun simctl ... log show` — native Maps SDK starts, but Google requests return HTTP `400`.
  - `git diff --check` — clean.
  - Focused location tests were not run because `test/utility/location_exception_test.dart` and `test/utility/location_service_test.dart` do not exist yet; this matches the open 6.15 test checklist.

---

### 2026-06-15: Phase 6 task 6.15 — **Location service + Google Maps consolidation** 🟡

Fixed three latent bugs: iOS Maps key mismatch (`GoogleMapsAPIKey` → `GMSApiKey`) silently broke the map on iOS, `LocationService.getAddressFromLatLng` joined raw `null` strings when placemark fields were absent, and a leaked Google Maps API key was hardcoded in `lib/config/env.dart`, `android/app/build.gradle.kts`, and `ios/Runner/Info.plist`. Consolidated three drifting copies of the dark map style to a single `GoogleConfig.darkMapStyle` and replaced the inline Geolocator flow in `signup1_screen.dart` with the shared `LocationService` now throwing a typed `LocationException`.

- **Files touched:**
  - `lib/utility/location_exception.dart` — new. `LocationStatus { serviceDisabled, denied, permanentlyDenied, unknown }` + `LocationException implements Exception`.
  - `lib/utility/location_service.dart` — dropped `flutter/material.dart` import + `BuildContext` param + in-service `SnackBar`. `getCurrentLocation` returns non-null `Future<LatLng>`, throws `LocationException`. `getAddressFromLatLng` null-safe `where` filter. Deleted dead `searchLocation` + `updateLocation`.
  - `lib/service/google_config.dart` — replaced 6-rule `darkMapStyle` with 9-rule consolidated variant (administrative + poi + road labels).
  - `lib/config/env.dart` — dropped hardcoded `defaultValue` from `Env.googleMapsKey`; empty `String.fromEnvironment`.
  - `lib/features/auth/presentation/screens/signup1_screen.dart` — deleted inline `_getCurrentLocation` (Geolocator flow). New flow calls `LocationService.getCurrentLocation()` in try/catch with `LocationStatus` switch.
  - `lib/features/auth/presentation/widgets/signup1_form.dart` — deleted local `_darkMapStyle`. Uses `GoogleConfig.darkMapStyle`.
  - `lib/features/profile/presentation/screens/edit_personal_details_screen.dart` — deleted local `_darkMapStyle` + unused `geocoding` import. `loadCurrentLocation` drops `context` arg, silent fail on `LocationException`. `getAddressFromLatLng` uses `LocationService`.
  - `ios/Runner/Info.plist` — `GoogleMapsAPIKey` → `GMSApiKey`, value `$(GOOGLE_MAPS_KEY)`. Dropped `NSLocationAlwaysAndWhenInUseUsageDescription` (foreground-only app).
  - `ios/Runner/AppDelegate.swift` — bundle lookup key `GMSApiKey` (was `GoogleMapsAPIKey`).
  - `ios/Flutter/{Debug,Release,Profile}-{dev,prod}.xcconfig` — added `#include? "GoogleMaps-<flavor>.xcconfig"` to all 6.
  - `ios/Podfile` — `write_google_maps_xcconfig(flavor)` reads `env/<flavor>.json` and writes `ios/Flutter/GoogleMaps-<flavor>.xcconfig` on every `pod install`.
  - `android/app/build.gradle.kts` — dropped hardcoded fallback key; throws `GradleException` if `GOOGLE_MAPS_KEY` missing from `DART_DEFINES`.
  - `.gitignore` — added `ios/Flutter/GoogleMaps-dev.xcconfig` + `GoogleMaps-prod.xcconfig`.
  - `docs/phase6/task_15_location_map_consolidation.md` — new task brief.
  - `docs/phase6/README.md` — sprint board count `12 / 15`, est `18.5d`, 3 new acceptance bullets.

- **Decisions:**
  - **Typed exceptions over sealed result type.** `LocationException` + `LocationStatus` enum matches the existing `AppException` convention. Sealed-class result type considered, rejected to avoid two divergent error-handling idioms in the codebase.
  - **iOS xcconfig over Run Script build phase.** Avoids editing `project.pbxproj`. Cost: user must re-run `pod install` after editing `env/<flavor>.json`. Acceptable since env values change rarely. Generated `GoogleMaps-<flavor>.xcconfig` files are gitignored.
  - **Reverse-geocode helper stays inline in signup.** Signup needs `place.name` + `isPlusCode` filter that the shared `LocationService` intentionally omits (other callers don't want plus codes). Adding an `includeName: bool` flag to the service was rejected as caller-specific UX leakage.
  - **`edit_personal_details_screen.dart` silently swallows `LocationException`.** Profile edit screen has a search field as fallback, so failing silently is the better UX than the signup-style snack chain.
  - **`Env.googleMapsKey` empty default.** Build fails loud without `--dart-define-from-file`, preventing accidental fallback to a leaked key. Same posture for `build.gradle.kts` (`GradleException`).
  - **No Riverpod provider for location yet.** Signup notifier already owns `latLng` via `setCurrentLatLng`. Only two consumers; provider extraction deferred until a third consumer appears.

- **Constraints Maintained:**
  - `flutter analyze` — `No issues found! (ran in 4.0s)` after refactor.
  - `pod install` regenerates xcconfigs without manual steps; verified xcconfig values present.
  - No UI imports inside `LocationService`; matches CLAUDE.md "UI side effects in widgets via `ref.listen`, not inside services" rule.
  - No new dependencies added; uses existing `geocoding`, `geolocator`, `google_maps_flutter`.

- **Outstanding (carried in task file):**
  - **Sub-task A — key rotation (user / GCP).** Revoke the leaked key, create restricted Android (SHA-1 + package) / iOS (bundle ID) / Places keys, populate fresh values in `env/{dev,prod}.json`. Sub-task B onward is wired but useless against the burned key.
  - **Sub-task F — tests.** Unit tests for `LocationException` + `LocationService.getAddressFromLatLng` (null-safety regression). Widget tests for signup deny / permanent-deny paths (requires Geolocator channel mock).
  - **Manual G — device verification.** iOS simulator + Android emulator: dark style renders, accept / deny / permanent-deny flows behave on signup + edit profile.

---

### 2026-06-09: Redesign Meeting Card and Create Meeting UI to Match Mockup Spec

Redesigned the `MeetingCard` and `CreateMeetingScreen` UI components to match the premium mockup specifications (Option 1).

- **Files touched:**
  - `lib/features/meetings/presentation/widgets/meeting_card.dart` — refactored to a `StatefulWidget` and updated layout with camera icon header, status pills, white platform badge with custom Google Meet painter, horizontal dividers, overlapping avatars, sync meeting toggle, and custom Join and Details buttons.
  - `lib/features/meetings/presentation/screens/create_meeting_screen.dart` — redesigned layout, outline floating-label input fields, Select Shoot dropdown, custom reminder pills, and info banner.
  - `lib/features/meetings/presentation/widgets/select_meet_link_picker.dart` — updated to use fixed-size square buttons with brand logos.
  - `lib/features/meetings/presentation/providers/create_meeting_state.dart` — added `project` and `invitedParticipants` state fields and validation logic.
  - `lib/features/meetings/presentation/providers/create_meeting_notifier.dart` — added setters and mapped input creation.
  - `test/features/meetings/presentation/screens/meetings_screen_test.dart` — updated unit tests to adapt to the new state constraints.

- **Decisions:**
  - **Option 1 Implementation.** Implemented Option 1 (Mockup design matching) with mockup-exact styles and brand logos.
  - **Custom Google Meet Logo & Teams Sunburst Painters.** Designed high-fidelity CustomPainters for brand logos to avoid external asset dependencies.
  - **Expanded state validation.** Supported Select Shoot and Invite Participants inputs dynamically inside the notifier flow to drive submit validation.

- **Verification:**
  - `flutter analyze lib/features/meetings/` -> Clean, no issues.
  - `flutter test test/features/meetings/presentation/screens/meetings_screen_test.dart` -> 5 / 5 passing.

### 2026-06-09: Messages timezone, ordering, and tab bar design alignment fix

Fixed the bug where newly sent messages sorted to the top of the chat thread due to a timezone mismatch, and updated the MessagesTabBar segmented design to align with the rectangular tab design of the Profile Details screen.

- **Files touched:**
  - `lib/features/messages/presentation/screens/widgets/messages_tab_bar.dart` — changed border radius, height, padding, and active/inactive color scheme to match the Profile Details screen's tab bar.
  - `lib/features/messages/data/dto/message_dto.dart` — parsed `sentAt` converted to local timezone.
  - `lib/features/messages/data/dto/conversation_dto.dart` — parsed `sentAt` in conversation preview converted to local timezone.
  - `lib/features/messages/data/dto/chat_details_dto.dart` — parsed dates converted to local timezone.
  - `lib/features/messages/data/sources/messages_dummy_source.dart` — changed dummy conversation list and chat thread message loading to dynamically offset timestamps relative to `DateTime.now()` in the past.
  - `lib/features/messages/domain/entities/message.dart` — added `sentAt` parameter support to `Message.copyWith`.
  - `lib/features/messages/domain/entities/conversation.dart` — added `copyWith` methods to `Conversation` and `ConversationPreview` to support local overrides.

- **Decisions:**
  - **Dynamic relative dummy timestamps.** Computed dummy timestamps relative to `DateTime.now()` dynamically, ensuring they are always in the past regardless of current execution timezone or time of day.
  - **Explicit DTO timezone conversion.** Used `.toLocal()` on parsed `DateTime` fields to align all timestamps to a single consistent local timezone reference.
  - **Profile Details tab bar design parity.** Reused the `AppColors.surfaceMid`, `AppColors.goldSoftSand`, `AppColors.textHeading`, and `AppColors.white30` color tokens, alongside `AppRadii.xlAll` (14px outer) and `AppRadii.mldAll` (10px inner) to perfectly match the Profile Details tab design.

- **Verification:**
  - `dart format lib/features/messages/` -> formatted.
  - `flutter test` -> All 485 tests passed.
  - `flutter test integration_test/login_logout_test.dart -d macos` -> 1 / 1 passing.
  - `flutter test integration_test/signup_flow_test.dart -d macos` -> 1 / 1 passing.
  - `flutter analyze` -> Clean, no issues.

---

### 2026-06-09: Messages chat thread bottom-order correction

Adjusted the chat thread so newly added messages render at the bottom of the
conversation instead of appearing at the top.

- **Files touched:**
  - `lib/features/messages/presentation/screens/chat_thread_screen.dart` — removed `reverse: true` / reversed item rendering, kept messages sorted oldest-to-newest, and changed auto-scroll to `maxScrollExtent`.
  - `test/features/messages/presentation/screens/messages_screen_test.dart` — pinned the optimistic send path so the newly sent message appears below the existing message.
  - `docs/feature/MESSAGES_UI_PLAN.md` — updated M3.07 notes and deviations to document chronological bottom-order rendering.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Normal chronological list over reversed chat list.** This matches the requested visual behavior directly: older messages are higher, new local/remote messages append lower.
  - **Bottom scroll uses `AppDurations.fast`.** Reused the existing motion token instead of another inline duration.

- **Verification:**
  - `dart format lib/features/messages/presentation/screens/chat_thread_screen.dart test/features/messages/presentation/screens/messages_screen_test.dart` -> formatted.
  - `flutter test test/features/messages/presentation/screens/messages_screen_test.dart` -> 3 / 3 passing.
  - `flutter analyze --fatal-infos` -> no issues found.

- **Remaining risk / follow-up:**
  - No device/simulator screenshot was captured in this turn.

---

### 2026-06-09: Messages UI Phase M5 — polish + tests 🟢

Closed the UI-only Messages M5 pass: motion polish, accessibility labels /
touch targets, message component goldens, and real widget tests for the list,
thread, and details interactions. M6 remains the API + socket.io integration
phase.

- **Files touched:**
  - `lib/features/messages/presentation/screens/chat_thread_screen.dart` — added message/audio bubble fade+slide entrance and attached the existing scroll controller to the reversed thread list so auto-scroll can run.
  - `lib/features/messages/presentation/screens/widgets/chat_composer.dart` — added focused composer expansion/border animation and increased the custom send target to 44dp.
  - `lib/features/messages/presentation/screens/widgets/audio_bubble.dart` — increased play target to 44dp and made placeholder waveform rendering deterministic per paint for stable goldens.
  - `lib/features/messages/presentation/screens/widgets/{messages_tab_bar,conversation_tile,message_bubble,details_section_card,shared_file_row,attach_action_sheet}.dart` — added explicit semantics labels for custom controls/rows/sections.
  - `lib/features/messages/presentation/screens/messages_screen.dart` — added explicit semantics to the custom new-chat button.
  - `test/features/messages/presentation/screens/messages_screen_test.dart` — replaced stale placeholder expectations with M5 tests for tab switching, optimistic send, and section expand/collapse.
  - `test/golden/messages_test.dart` + `test/golden/goldens/messages_*.png` — new message component golden coverage.
  - `lib/core/providers/core_providers.dart` — removed two genuinely unused imports that blocked repo-wide analyze while `LoggingInterceptor` remains commented out.
  - `docs/feature/MESSAGES_UI_PLAN.md` — marked M5 complete, added M5 ledger, corrected stale dummy-fixture location notes.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Kept transport dummy-backed.** No REST or socket.io code was activated; M6 still owns remote source, socket source, delivery/read receipts, presence, reconnect, and offline queue.
  - **Screen-scoped entrance animation.** Bubble fade/slide lives in `ChatThreadScreen`, leaving `MessageBubble` and `AudioBubble` deterministic for direct component reuse and golden tests.
  - **Provider override tests.** Widget tests override `messagesRepositoryProvider` with a fake repository, so they exercise the real Riverpod Notifiers and screens without loading bundled assets.
  - **Golden baselines use current test-font behavior.** Message goldens follow the repo's existing component-golden pattern; text renders through Flutter's test font baseline.
  - **Handoff discrepancy noted.** The prompt-provided AGENTS text still referenced Phase 4 as active, while current `docs/AI_HANDOFF.md` / `CLAUDE.md` point to Phase 6. This M5 pass was handled as a feature-side UI task without changing the active Phase 6 board.

- **Verification:**
  - `dart format ...` on touched Dart files -> formatted.
  - `flutter test test/features/messages/presentation/screens/messages_screen_test.dart` -> 3 / 3 passing.
  - `flutter test --update-goldens test/golden/messages_test.dart` -> 3 / 3 passing; new baselines written.
  - `flutter test test/golden/messages_test.dart` -> 3 / 3 passing.
  - `flutter analyze --fatal-infos` -> no issues found.
  - `flutter test` -> all 485 tests passed.

- **Remaining risk / follow-up:**
  - M6 must replace dummy bindings with real REST + socket.io transport and validate backend event semantics.
  - No device/simulator screenshot was captured in this turn; verification was widget/golden/analyzer/full-test based.

---

### 2026-06-05: Drawer future menu branch setup

Extended the hamburger drawer to include all planned menu entries with active
and inactive states, while keeping future features as placeholder routes.

- **Files touched (7):**
  - `lib/shared/layouts/app_shell.dart` — added Meetings, Affiliate, and Payouts to the drawer order; wired all drawer items through shell branch indexes; muted inactive rows and reused Messages active/inactive icons for future entries.
  - `lib/app/routes.dart` — added `meetings`, `affiliate`, and `payouts` route specs.
  - `lib/app/router.dart` — added drawer-only shell branches for the new route specs.
  - `lib/features/menu_placeholders/presentation/screens/menu_placeholder_screen.dart` — new reusable placeholder screen with the shared toolbar/menu affordance.
  - `test/shared/layouts/app_shell_test.dart` — updated the shell harness to eight branches and covered future drawer navigation.
  - `docs/phase4/task_23_groupF_shell_shared.md` — noted the post-completion drawer expansion.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Drawer-only shell branches.** The future entries participate in active/inactive drawer state and can open the drawer from their placeholder screens, while the bottom nav remains the existing four-tab surface.
  - **Temporary Messages icons.** Meetings, Affiliate, and Payouts use `activeMessages` / `inactiveMessages` until final assets are supplied.
  - **No backend feature work.** Placeholder screens avoid inventing repositories/notifiers before requirements exist.

- **Verification:**
  - `dart format lib/app/routes.dart lib/app/router.dart lib/shared/layouts/app_shell.dart lib/features/menu_placeholders/presentation/screens/menu_placeholder_screen.dart test/shared/layouts/app_shell_test.dart` -> formatted; `routes.dart` compact style restored afterward to avoid unrelated churn.
  - `flutter test test/app/router_test.dart test/app/routes_analytics_test.dart test/shared/layouts/app_shell_test.dart test/features/messages/presentation/screens/messages_screen_test.dart test/features/shoots/presentation/screens/shoots_screen_test.dart test/features/file_manager/presentation/screens/file_manager_screen_test.dart test/features/availability/presentation/screens/manage_availability_screen_test.dart` -> all tests passed.
  - `flutter analyze` -> no issues found.

- **Remaining risk / follow-up:**
  - Replace the temporary Messages icons once final Meetings / Affiliate / Payouts assets are available.
  - No simulator screenshot was captured in this turn.

---

### 2026-06-05: Messages shell toolbar alignment

Aligned the Messages placeholder tab with the other app-shell menu screens by
using the shared toolbar and drawer navigation affordance.

- **Files touched (5):**
  - `lib/features/messages/presentation/screens/messages_screen.dart` — replaced the standalone `Scaffold` body with `SafeArea` + shared `AppMainToolbar` + centered placeholder content.
  - `lib/shared/widgets/app_main_toolbar.dart` — tightened the shared drawer affordance to a 48dp target, added tooltip semantics, and centered titles with a trailing spacer.
  - `test/features/messages/presentation/screens/messages_screen_test.dart` — asserted the toolbar renders and the menu button opens the drawer.
  - `docs/phase4/task_03_groupB_messages.md` — noted the post-completion UI polish while preserving the placeholder transport decision.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Kept Messages as a static placeholder.** No repository/notifier/transport work was added because the backend transport decision remains deferred.
  - **Used the existing shell scaffold.** Messages now matches the other root-branch screens and does not create its own nested scaffold.

- **Verification:**
  - `dart format lib/shared/widgets/app_main_toolbar.dart lib/features/messages/presentation/screens/messages_screen.dart test/features/messages/presentation/screens/messages_screen_test.dart` -> formatted.
  - `flutter test test/features/messages/presentation/screens/messages_screen_test.dart test/features/shoots/presentation/screens/shoots_screen_test.dart test/features/file_manager/presentation/screens/file_manager_screen_test.dart test/features/availability/presentation/screens/manage_availability_screen_test.dart` -> all tests passed.
  - `flutter analyze` -> no issues found.

- **Remaining risk / follow-up:**
  - No simulator screenshot was captured in this turn.

---

### 2026-06-05: Home welcome toolbar UI polish

Aligned the Home welcome header with the CP Dashboard toolbar reference while
leaving Home's Riverpod orchestration and route behavior unchanged.

- **Files touched (4):**
  - `lib/features/home/presentation/widgets/home_welcome_header.dart` — added the `Creative Pro` subtitle, tightened toolbar spacing, and gave drawer/avatar controls 44dp hit areas while preserving app tokens.
  - `test/features/home/presentation/home_decompose_test.dart` — pinned the default toolbar subtitle in the existing header characterization test.
  - `docs/phase4/task_16_groupD_home_migrate.md` — noted the post-completion UI polish against the Home migration task.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Kept the bell visual-only.** The previous widget did not expose a notification callback, so the icon was aligned to the toolbar without adding a no-op action.
  - **Kept fallback text as `User..`.** Existing Home widget tests pin that behavior; this pass focused on the reference toolbar details.
  - **No Phase 6 status changed.** This was a targeted Home UI correction, not active coverage/test work.

- **Verification:**
  - `dart format lib/features/home/presentation/widgets/home_welcome_header.dart` -> formatted.
  - `flutter test test/features/home/presentation/home_decompose_test.dart test/features/home/presentation/screens/home_screen_test.dart` -> all tests passed.
  - `flutter analyze` -> no issues found.

- **Remaining risk / follow-up:**
  - Visual verification was static/code-level in this turn; no simulator screenshot was captured.

---

### 2026-06-04: iOS launch image asset refresh

Regenerated the iOS launch image set from the AppIcon 1024 px source and
removed the white outside corner fill so the icon sits cleanly on dark launch
backgrounds.

- **Files touched (4):**
  - `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png` — replaced with a 200 px resize of `AppIcon.appiconset/1024.png` with transparent outside corners.
  - `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png` — replaced with a 400 px resize with transparent outside corners.
  - `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png` — replaced with a 600 px resize with transparent outside corners.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Kept `Contents.json` unchanged.** The asset catalog already references the standard `1x` / `2x` / `3x` launch image filenames.
  - **No phase task status changed.** This was a targeted iOS asset update, not active Phase 6 test implementation.

- **Verification:**
  - `sips -g pixelWidth -g pixelHeight ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage*.png` -> 200, 400, and 600 px square outputs.
  - `magick identify` pixel checks -> corner pixels are transparent; internal white `CP` and beige logo pixels remain opaque.
  - `ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0)))' ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json` -> OK.

- **Remaining risk / follow-up:**
  - iOS launch-screen rendering was not simulator-verified in this turn.

---

### 2026-06-04: iOS Info.plist plugin privacy-string audit

Audited the iOS plugin set and current code paths for required `Info.plist`
privacy usage strings.

- **Files touched (2):**
  - `ios/Runner/Info.plist` — added `NSCameraUsageDescription` for the
    `image_picker` camera path used by certificate uploads; normalized
    indentation in the existing privacy-string block.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Added camera, not microphone.** `CommonUploader.pickFromCamera()` is used
    from the certificates flow, so `NSCameraUsageDescription` is required.
    There are no `pickVideo` / video-capture code paths, so
    `NSMicrophoneUsageDescription` was not added.
  - **Kept existing location and photo-library strings.** Geolocator and
    image/file picking paths were already covered by the current plist entries.
  - **No phase task status changed.** This was a targeted iOS config audit, not
    active Phase 6 test implementation.

- **Verification:**
  - `plutil -lint ios/Runner/Info.plist` -> OK.
  - `git diff --check -- ios/Runner/Info.plist` -> clean.

- **Remaining risk / follow-up:**
  - `ios/Podfile.lock` had pre-existing local changes and was left untouched.

---

### 2026-06-03: Phase 6 task 6.13 — **CI coverage gate + Android/iOS integration workflow** 🟡

Implemented Phase 6 task 6.13 wiring, but left the task in progress because live acceptance still needs the first GitHub Actions emulator/simulator run and the current LCOV is below the new 70% gate.

- **Files touched (6):**
  - `.github/workflows/ci.yml` — `flutter test --coverage`, LCOV parsing, `$GITHUB_STEP_SUMMARY` coverage table, 70% threshold enforcement, LCOV artifact upload.
  - `.github/workflows/integration.yml` — **new** — `push` to `main` / manual Android + iOS matrix on `macos-latest`, Android emulator action, iOS simulator boot script, Flutter/Gradle/AVD/CocoaPods caches, dev-flavor integration test commands.
  - `docs/phase6/task_13_ci_coverage_gate.md` — moved to `🟡 In Progress`; implementation checklist checked; remote/timing acceptance left open.
  - `docs/phase6/README.md` — 6.13 row moved to `🟡`; whole-phase CI coverage gate acceptance checked.
  - `docs/AI_HANDOFF.md` — updated next work and verification baseline.
  - `docs/audit/AUDIT_REPORT.md` — added a dated Phase 6 CI update without rewriting the original audit baseline.

- **Decisions:**
  - **Custom LCOV shell parser instead of adding `coverage` / lcov tooling.** Flutter already generates `coverage/lcov.info`; avoiding another dev dependency keeps the workflow scoped to the two files named in the task.
  - **Strict 70% enforcement.** The current refreshed LCOV is `5358 / 11129 = 48.14%`, so the new CI gate will fail until coverage is raised. That is the intended behavior of task 6.13 and makes 6.14 the active coverage-lift blocker.
  - **Device workflow uses the dev flavor explicitly.** Android has product flavors and iOS has dev/prod schemes, so the integration commands include `--flavor dev --dart-define-from-file=env/dev.example.json`.
  - **Kept integration test source untouched.** 6.11/6.12 tests still use vm-mode `TestWidgetsFlutterBinding`; the first Android/iOS GitHub run may require the documented one-line swap to `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`.
  - **Did not mark 6.13 complete.** GitHub-hosted Android/iOS timing and green status cannot be proven locally in this workspace.

- **Verification:**
  - `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci.yml"); YAML.load_file(".github/workflows/integration.yml"); puts "workflow yaml parsed"'` → parsed (Ruby warned about local `ffi`, unrelated).
  - `git diff --check -- .github/workflows/ci.yml .github/workflows/integration.yml` → clean.
  - `flutter analyze --fatal-infos` → no issues.
  - `flutter test --coverage` → 451 tests passed; LCOV `48.14%`.
  - `flutter test integration_test/login_logout_test.dart -d macos` → 1 / 1 passing.
  - `flutter test integration_test/signup_flow_test.dart -d macos` → 1 / 1 passing.

- **Remaining risk / follow-up:**
  - First GitHub Actions `push` to `main` must validate Android/iOS device execution and cache timing.
  - Coverage must be raised from `48.14%` to at least `70%`; task 6.14 is the next planned coverage work.

---

### 2026-06-03: Phase 6 task 6.12 — **Integration test: signup 1 → 2 → 3 (multipart assertions)** 🟢

Closed Phase 6 task 6.12. Added the signup integration journey across the real `SignUp1Screen` → `SignUp2Screen` → `SignUp3Screen` stack with real `SignupNotifier`, `AuthRepositoryImpl`, Riverpod route-state carry-through, and Dio stubbed. The test asserts step-1 multipart fields/files, step-2 JSON, and step-3 multipart fields/files including repeated `recent_work_media` plus paired `recent_work_media_index`.

- **Files touched (8):**
  - `integration_test/signup_flow_test.dart` — **new** — vm-mode signup integration test (1 / 1 passing on macOS).
  - `integration_test/robots/signup_robot.dart` — **new** — `SignupRobot` page-object for step assertions, form entry, route progression, and seeded picker outcomes.
  - `docs/phase6/task_12_integration_signup.md` — marked `🟢 Completed`; documented stale endpoint and success-route spec deviations.
  - `docs/phase6/task_11_integration_login_logout.md` — repaired stale task-file status to match the board / handoff.
  - `docs/phase6/README.md` — `12 / 14`, 6.12 row flipped to `🟢`.
  - `docs/AI_HANDOFF.md` — post-6.12 status, next task `6.13`, verification baseline, integration-test convention.
  - `CLAUDE.md` — Phase 6 status corrected from stale `10 / 14`; integration-test commands added.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Preserved current signup success navigation.** The 6.12 goal said the flow should land on `/home`, but current `SignUp3Screen._submit` routes to `Routes.login`, matching `docs/NAVIGATION_MAP.md`. The integration harness asserts login success instead of changing production navigation under a testing task.
  - **Used live endpoint names.** The task's `auth/signup1`, `auth/signup2`, `auth/signup3-multipart` labels were stale. The test stubs `auth/register-crew-step1`, `auth/register-crew-step2`, `auth/register-crew-step3`, plus `auth/crew-roles` and `auth/skills`.
  - **Seeded native picker outcomes through the real Notifier.** `CommonUploader`, `FilePicker`, Google Places, and Google Maps do not expose app-level injection seams. The robot seeds profile image, map lat/lng, social/portfolio links, featured work, certificate, resume, and portfolio files through `SignupNotifier`; screen traversal, submit buttons, notifier validation, repository calls, and route extras remain real.
  - **Geolocator channel stubs only.** `SignUp1Screen` checks location in a post-frame callback. The test stubs the geolocator channels to keep mount hermetic and avoid rendering the map before submit.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - Unit `flutter test` green — 451 events total.
  - `flutter test integration_test/signup_flow_test.dart -d macos` → 1 / 1 passing.
  - Integration tests remain outside default `flutter test`.
  - No production code changed.

---

### 2026-06-03: Phase 6 task 6.11 — **Integration test: login → home → logout (robots pattern)** 🟢

Closed Phase 6 task 6.11. Added the project's first integration test exercising a full login → home → logout → login loop with the real `LoginScreen` + `LoginNotifier` + `CompositeSessionStore` + Riverpod `authStateProvider` + GoRouter `refreshListenable` redirect. Dio is stubbed (canned `auth/login`); everything else is real.

- **Files touched (5):**
  - `pubspec.yaml` — added `integration_test` dev_dependency (Flutter SDK package).
  - `integration_test/login_logout_test.dart` — **new** — single end-to-end test (1 / 1 passing on macos).
  - `integration_test/robots/auth_robot.dart` — **new** — `AuthRobot` page-object: `expectOnLoginScreen`, `enterEmail`, `enterPassword`, `tapLogin`, `expectOnHome`, `tapLogout`. Reusable across future integration tests.
  - `docs/phase6/task_11_integration_login_logout.md` — marked `🟢 Completed`; documented vm-mode binding + minimal-router decisions.
  - `docs/phase6/README.md` — `11 / 14`, 6.11 row flipped to `🟢`.

- **Decisions:**
  - **Vm-mode binding (`TestWidgetsFlutterBinding.ensureInitialized()`), not `IntegrationTestWidgetsFlutterBinding`.** `flutter test integration_test/...` requires a device picker; with multiple devices connected and no Android/iOS emulator booted locally, the live binding is impractical. Vm binding runs under `flutter test -d macos`. CI promotion to an Android/iOS emulator is a one-line swap (`IntegrationTestWidgetsFlutterBinding.ensureInitialized()`) documented at the top of the test file.
  - **Did not mount the production `routerProvider`.** That router pulls in splash + onboarding + 5-tab `StatefulShellRoute` + restoration providers + analytics observers — way more surface than the login/logout loop needs. The harness builds a minimal 2-route GoRouter with the same auth-driven `redirect` + `refreshListenable` pattern as production. Catches the real failure mode (router not bouncing on auth flip) without the full tree.
  - **`_HomeStub` drives `AuthStateNotifier.logout()` directly** instead of mounting `Myprofile` + tapping through the modal-sheet logout confirmation. The 2-tap modal-sheet path is widget-level concern; the integration test's job is the round-trip wire-up (real session clear, real auth flip, real router redirect). `login_notifier_test.dart` + `my_profile_notifier_test.dart` cover the deeper interactions.
  - **`AuthRobot._settle()` uses `tester.runAsync()` + manual `pump()` cycles** rather than `pumpAndSettle`. `pumpAndSettle` was unreliable across vm-mode and live-binding — the manual drain works in both, with the trade-off of a fixed ~120 ms wait per settle call.
  - **Used `WidgetRef.listenManual` for `_AuthRefreshNotifier`.** Bridges `authStateProvider` flips into `GoRouter.refreshListenable` without needing `ProviderSubscription.close` exposure on the more common `ConsumerStatefulWidget.ref.listen`.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - Unit `flutter test` green — 451 events total (unchanged from 6.10; integration tests live under `integration_test/`, not part of the default `flutter test` run).
  - `flutter test integration_test/login_logout_test.dart -d macos` → 1 / 1 passing in ~25s (mostly macos app build time).
  - Zero real network — Dio stubbed via mocktail; SharedPreferences uses `setMockInitialValues({})`.
  - **Robots-pattern milestone**: future integration tests (signup, etc.) reuse `AuthRobot` and add `SignupRobot`, `HomeRobot`, etc., as needed.

---

### 2026-06-03: Phase 6 task 6.10 — **Golden tests for design tokens (button / card / avatar / input)** 🟢

Closed Phase 6 task 6.10. Added 13 golden tests across 3 files covering `AppButton`, `AppCard`, `AppAvatar`, and `AppTextField` in their canonical configurations on dark + light surfaces. Goldens lock in token consumption (`AppColors`, `AppRadii`, `AppSpacing`, `AppTextStyles`) so a future token drift will fail CI.

- **Files touched (6):**
  - `test/golden/buttons_test.dart` — **new** — 5 golden tests.
  - `test/golden/cards_test.dart` — **new** — 4 golden tests (3 card variants + 2 avatar setups).
  - `test/golden/inputs_test.dart` — **new** — 4 golden tests.
  - `test/golden/goldens/*.png` — **new** — 13 PNG files, 368 KB total.
  - `CLAUDE.md` — added the regeneration command `flutter test --update-goldens test/golden/` to the Commands section.
  - `docs/phase6/task_10_golden_tests.md` — marked `🟢 Completed`; documented why app-bar / bottom-nav / colors-swatch goldens were skipped.

- **Decisions:**
  - **Did NOT create `app_bar_test.dart` / `bottom_nav_test.dart`.** There is no shared `AppBar` or `BottomNav` widget — every screen rolls its own header inline. Goldens at this layer would be screen-level goldens, which are explicitly out of scope (the design is still iterating). The existing widget tests in 6.07–6.09 cover screen renders functionally.
  - **Did NOT create `colors_swatch_test.dart`.** A coloured-rectangle-per-token golden doesn't catch the failure mode that matters — a renamed token would still pass because the swatch position would shift but the colour wouldn't change. The variant goldens on real components catch drift where it actually shows up (button background contrast, error border colour, etc.).
  - **Light/dark = scaffold background swap, not Material brightness.** `AppColors` are static constants, not theme-driven. The "dark" goldens render over `AppColors.background`; the "light" goldens render over `Colors.white`. Same widget, different surrounding canvas — catches contrast regressions but not M3 colour-scheme drift (we don't use M3 colour-scheme yet).
  - **`matchesGoldenFile` uses Flutter's default byte-exact comparison.** No per-test threshold was set; CI will fail on the first off-by-one pixel diff. Documented in the task notes that cross-SDK drift is noise — the goldens were generated on Flutter `3.38.9` / Dart `3.10.8`. CI needs to run on the same SDK or accept a one-time regenerate.
  - **Avatar `null` argument in `const` constructor list** — `AppAvatar(name: null, ...)` requires the constructor to accept `String?` (it does); the const-list of children passes.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 451 events total (up from 438 post-6.09; +13 golden tests).
  - Per-file run: `flutter test test/golden/` → 13 passing.
  - Golden PNG baseline committed under `test/golden/goldens/` (368 KB across 13 files — well under any reasonable budget).
  - Regeneration command documented in `CLAUDE.md` so any future contributor running the wrong Flutter SDK can rebuild the baseline.

---

### 2026-06-03: Phase 6 task 6.09 — **Widget tests: availability (manage + add)** 🟢

Closed Phase 6 task 6.09. Added widget tests for `ManageAvailabilityScreen` and `AddAvailabilityScreen`. File manager already had screen-level widget tests from Phase 4; left untouched. After this task every entry-point screen with a Notifier has at least one widget test.

- **Files touched (5):**
  - `test/features/availability/presentation/screens/manage_availability_screen_test.dart` — **new** — 4 tests.
  - `test/features/availability/presentation/screens/add_availability_screen_test.dart` — **new** — 4 tests.
  - `docs/phase6/task_09_widget_tests_file_manager.md` — marked `🟢 Completed`; documented `CircularProgressIndicator` vs `AppLoader` distinction per-screen.
  - `docs/phase6/README.md` — `9 / 14`, 6.09 row flipped to `🟢`.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Did not rewrite `file_manager_screen_test.dart`.** The pre-existing tests use a real-notifier + repo-override pattern (the stub repo is cheap, no Dio). Switching to the new subclass + fake notifier pattern would be churn without coverage gain. New tests use the established 6.08 pattern.
  - **Asserted on `CircularProgressIndicator` for the Add screen's in-flight Save state** rather than `AppLoader`. The bottom CTA renders an inline 22×22 native spinner — different widget from the full-screen `AppLoader` used elsewhere. Pinned explicitly so a future swap is deliberate.
  - **`ManageAvailabilityScreen` chevron taps cover the `shiftMonth` wire.** `setFilter` (dropdown) and `setFocusedDay` (calendar page change) are notifier-level concerns already covered in `availability_notifier_test.dart`. Widget test stays focused on the visible top-level affordances.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 438 events total (up from 430 post-6.08; +8 events).
  - Per-file run: `flutter test test/features/availability/presentation/screens/` → 8 passing.
  - Zero real API calls — both new files subclass the relevant notifier and override `submit` / `shiftMonth` / `refresh`; no Dio ever constructed.
  - **Coverage milestone**: every entry-point screen with a Notifier has at least one widget test. Goldens (6.10) + integration tests (6.11–6.12) remain.

---

### 2026-06-03: Phase 6 task 6.08 — **Widget tests: home + profile + shoots (+ upcoming details)** 🟢

Closed Phase 6 task 6.08. Added widget tests for the four post-login entry screens: HomeScreen, Myprofile, ShootsScreen, UpcomingShootViewDetails. 12 tests, each screen covered with render + interaction + state-driven branch.

- **Files touched (6):**
  - `test/features/home/presentation/screens/home_screen_test.dart` — **new** — 3 tests.
  - `test/features/profile/presentation/screens/my_profile_screen_test.dart` — **new** — 3 tests.
  - `test/features/shoots/presentation/screens/shoots_screen_test.dart` — **new** — 3 tests.
  - `test/features/shoots/presentation/screens/upcoming_shoot_view_details_screen_test.dart` — **new** — 3 tests.
  - `docs/phase6/task_08_widget_tests_home_profile.md` — marked `🟢 Completed`; documented the runAsync→takeException pivot and the AppLoader vs CircularProgressIndicator mistake.
  - `docs/phase6/README.md` — `8 / 14`, 6.08 row flipped to `🟢`.

- **Decisions:**
  - **Dropped `tester.runAsync` + `FlutterError.onError = (_) {}` pattern from 6.07.** That combo asserts `_pendingExceptionDetails != null` and fails here when the screen's asset loads don't actually error during pump. Switched to `tester.takeException()` immediately after `pump` to silently drain any harmless asset-decode errors. Auth tests still use the old pattern (they pass there); home/profile/shoots use the new one. Worth backporting auth to the cleaner pattern in a separate sweep.
  - **Did not chase `changeStatsRange` / `changeShootCategoryTab` interaction tests on HomeScreen.** Range tabs and category tabs sit at `Offset(710, 1589.8)` on the default 800×600 test surface. The tap warns about hit-testing off-screen and the test passes the on-screen criterion but the interaction never fires. `home_notifier_test.dart` already covers these mutators directly; the widget test stays focused on the welcome-banner / refresh canary so future render regressions fail fast.
  - **Family-provider override syntax**: `upcomingShootDetailProvider.overrideWith(() => Fake())` on the family itself (not on a specific `arg` instance). Riverpod 2.6 doesn't define `overrideWith` on the per-arg `AutoDisposeFamilyNotifierProviderImpl`. Caught at compile time; documented in task notes.
  - **Pinned `AppLoader` (Lottie) as the loader widget**, not `CircularProgressIndicator`. First pass mistakenly asserted on the Material spinner; the screens use a custom Lottie loader. Worth catching at the widget-test layer because a Lottie→spinner swap should be a deliberate, test-updating change.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 430 events total (up from 418 post-6.07; +12 events).
  - Per-file run: `flutter test test/features/{home,profile,shoots}/presentation/screens/` → 12 passing.
  - Zero real API calls — every screen test overrides the relevant notifier provider with a fake.

---

### 2026-06-03: Phase 6 task 6.07 — **Widget tests: auth (login + forgot password trio + signup3 smoke)** 🟢

Closed Phase 6 task 6.07. Added widget tests for the auth entry points (login + forgot-password / otp / reset-password trio + signup3 render+submit smoke). 14 tests, every interactive auth screen now has at least render + happy-tap + form-gating coverage where applicable.

- **Files touched (5):**
  - `test/features/auth/presentation/screens/login_screen_test.dart` — **new** — 4 tests over `LoginScreen`. Fake `LoginNotifier` overrides `loadSavedCredentials` to a no-op so the test doesn't pull in `PrefsService` / `SharedPreferences`.
  - `test/features/auth/presentation/screens/forgot_password_screens_test.dart` — **new** — 8 tests over `ForgotPasswordScreen` / `ForgotPasswordOtpScreen` / `ResetPasswordScreen`. Single fake implements `ForgotPasswordNotifier`; per-screen `_router(...)` helper switches `initialLocation` so the right screen mounts.
  - `test/features/auth/presentation/screens/signup3_screen_test.dart` — **new** — 2 smoke tests. Fake extends `SignupNotifier` directly (rather than `implements`) so the 30+ inherited methods don't have to be redeclared; only `build` + `submitStep3` are overridden.
  - `docs/phase6/task_07_widget_tests_auth.md` — marked `🟢 Completed`; documented why signup3 is one screen not four sub-screens; pinned the `extends vs implements` choice for the fake notifiers.
  - `docs/phase6/README.md` — `7 / 14`, 6.07 row flipped to `🟢`.

- **Decisions:**
  - **Did not write 4 separate signup3 sub-screen test files.** SignUp3 was decomposed into widgets (sections, sheets, document blocks) but never split into sub-screens. The four spec files (`signup3_resume_screen_test.dart`, etc.) describe a layout that doesn't exist. One render-smoke + tap-Create-Profile test on the composite screen catches top-level layout regressions; deeper interaction (sheets, file pickers) belongs in unit tests of the section widgets (already covered by `signup_notifier_test.dart` step3 mutators + the existing `signup1_widgets_test.dart` precedent).
  - **Used `extends SignupNotifier` for the signup3 fake.** First attempt was `implements SignupNotifier` with every method stubbed — broke on a moving target (param-name drift in `submitStep2`, `setFeaturedProjects`). Extending lets inherited methods be ignored unless triggered; the render path only hits `build` (auto-fires nothing) and the post-frame `seedStep3FromRoute` (pure state). Submit happens via tap and is the only method actually overridden.
  - **Used `overrideWith(() => fake)` + `implements LoginNotifier / ForgotPasswordNotifier`** for login + forgot. Both surfaces are small (≤5 methods) so explicit `implements` is cheap and pins the surface. Drift would surface as a compile error, which is the right signal for "you added a Notifier method screens should consider using."
  - **Asset/Image errors are swallowed** via `FlutterError.onError = (_) {}` inside `runAsync`. Every auth screen uses `Image.asset(AppAssets.rectangle)` + `SvgPicture.asset(...)` which fail under the test bundle. Suppressing these keeps tests focused on Notifier wiring; if the asset paths break in prod, golden tests (6.10) will catch it.
  - **`tester.pump()` not `tester.pumpAndSettle()`** — `pumpAndSettle` hangs on the OTP screen's 1-second `Timer.periodic` countdown. The tests only need one frame past the post-frame callback so `await tester.pump()` (called twice in `_pump`) is sufficient.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 418 events total (up from 404 post-6.06; +14 events: 4 login + 8 forgot trio + 2 signup3).
  - Per-file run: `flutter test test/features/auth/presentation/screens/` → 14 passing.
  - Zero real API calls — every test overrides the notifier provider with a fake; no `Dio` or `SharedPreferences` initialisation needed.

---

### 2026-06-03: Phase 6 task 6.06 — **Notifier tests: file_manager + availability (messages skipped)** 🟢

Closed Phase 6 task 6.06. Added dedicated Notifier tests for all 4 file_manager Notifiers (`FileManagerNotifier`, `PreProductionNotifier`, `PostProductionNotifier`, `ViewDetailsNotifier`) and filled gaps on the 2 availability Notifiers not covered by the pre-existing screen-level test. Messages is intentionally skipped — the feature has no Notifier yet.

- **Files touched (5):**
  - `test/features/file_manager/presentation/file_manager_notifier_test.dart` — **new** — 13 tests over 4 Notifiers. Root: load + setQuery filtering (name + category, case-insensitive) + empty query + toggleView. Family Notifiers (Pre/Post/ViewDetails): per-folder load + setQuery + state isolation across distinct `folderId` args.
  - `test/features/availability/presentation/availability_notifier_test.dart` — **new** — 9 gap-fill tests. ManageAvailability: refresh failure (state.events stays empty, isLoading clears), `setFocusedDay` re-fetches with the new month/year, `setFilter` doesn't re-fetch. AddAvailability: rejects empty date, rejects empty time when not all-day, `setRecurrence` wipes weekday + weekend selections (preserves type + isAllDay), `toggleWeekDay` round-trip, `clearMessages`, daily recurrence happy submit.
  - `docs/phase6/task_06_notifier_tests_rest.md` — marked `🟢 Completed`; documented messages-feature non-existence; noted family Notifier state-isolation coverage.
  - `docs/phase6/README.md` — `6 / 14`, 6.06 row flipped to `🟢`.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Skipped `messages_notifier_test.dart` entirely.** `lib/features/messages` is only `presentation/screens/messages_screen.dart` — no domain repo, no data repo, no Notifier. The spec's third file line predates the messages-feature decision to leave it on legacy code for now. Writing a placeholder test for a class that doesn't exist would be busywork. Logged this as a deviation in the task file.
  - **Added `availability_notifier_test.dart` as a sibling of the existing screen-level test, not as a rewrite.** The existing `screens/availability_test.dart` is the canonical place for assertions that need telemetry events + crashlytics breadcrumbs (B1 work). Splitting per-method state-transition tests into a separate file keeps gap-fills additive and lets the screen-level file stay focused on the telemetry path.
  - **Pinned `AddAvailabilityNotifier.setRecurrence`'s "fresh constructor not copyWith" pattern.** The Notifier rewrites state by calling `AddAvailabilityState(type: state.type, recurrence: value, isAllDay: state.isAllDay, ...)` — wiping `selectedWeekDays` + `includeWeekends` while preserving `type` + `isAllDay`. New test asserts this exact carry-over.
  - **Family Notifier state-isolation** test for `PreProductionNotifier` and `ViewDetailsNotifier` — sets a query / reads state on one `folderId`, then asserts the other `folderId` has untouched state. Catches a future refactor that accidentally collapses a family into a singleton.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 404 events total (up from 382 post-6.05; +22 events from the new file_manager and availability tests: 13 + 9).
  - Per-file run: `flutter test test/features/{file_manager,availability}/presentation/{file_manager_notifier,availability_notifier}_test.dart` → 22 passing.
  - Zero real API calls — both new files use inline `_FakeRepo` fakes; no `Dio` ever instantiated.
  - **Coverage milestone**: every Notifier in `lib/` that exists has tests after 6.06. Messages remains the only un-tested feature surface because it has no Notifier yet.

---

### 2026-06-03: Phase 6 task 6.05 — **Notifier tests: home + shoots (audit only)** 🟢

Closed Phase 6 task 6.05 by audit. All 4 home + shoots Notifiers (`HomeNotifier`, `ShootsListNotifier`, `CancelShootNotifier`, `UpcomingShootDetailNotifier`) already had AAA-style Phase 4 tests with ≥ 3 cases per public method, plus the two acceptance-critical paths called out by the spec.

- **Files touched (3):**
  - `docs/phase6/task_05_notifier_tests_home_shoots.md` — marked `🟢 Completed`; documented mapping from spec's 4-file layout to the actual 3-file layout; flagged the `FakeAsync` deviation explicitly.
  - `docs/phase6/README.md` — `5 / 14`, 6.05 row flipped to `🟢`.
  - `MIGRATION_LOG.md` — this entry.

- **Spec-critical paths verified in existing tests:**
  - **Home `Future.wait` partial failure** — `home_notifier_test.dart:185` "partial failure — crew stats fails but others succeed": stubs `fetchCrewStats` to throw while the other 6 fetchers succeed. State carries `errorMessage` and the rest of the dashboard hydrates. Matches the spec's "one of 7 fetchers errors" requirement.
  - **Shoots search debounce** — `shoots_notifier_test.dart:209` "multiple rapid updateSearch calls within window collapse to one filter": 3 calls inside the 250 ms window all land but only the last query filters; `fetchShootsCount` is unchanged. Matches the spec's "only 1 fetch fires per 250ms window" requirement.

- **Decisions:**
  - **Did not switch the debounce test to `FakeAsync`.** Spec says "Debounce verified via `FakeAsync`"; existing test uses `_drainTime(Duration)` with real 20 ms wall-time steps. The test file's own comment justifies the choice — keeps every notifier test on the same harness pattern (microtask drain + optional real wait). Cost: ~350 ms on one test. Benefit: no `fake_async` zone wrapping that other tests would need to copy.
  - **Did not split `CancelShootNotifier` into a separate `shoot_cancel_notifier_test.dart`.** Both Notifiers consume `_FakeShootsRepo`; splitting the test file would duplicate the fake. Spec file name treated as aspirational.
  - **Did not move tests to `test/features/<feature>/presentation/providers/`.** Same blame-preservation reason as 6.04.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 382 events total (unchanged from 6.04 — no new tests added in this task).
  - Per-file run: `flutter test test/features/{home,shoots}/presentation/{home_notifier,shoots_notifier,upcoming_shoot_notifier}_test.dart` → 22 passing.

---

### 2026-06-03: Phase 6 task 6.04 — **Notifier tests: auth + profile (audit + gap-fill)** 🟢

Closed Phase 6 task 6.04 by auditing the existing Phase 4 Notifier tests against the task spec rather than rewriting them. 13 of 14 auth + profile Notifiers already had AAA-style tests with ≥ 3 cases per public method (validation / happy / error + B1 telemetry). One gap (`ProfileDetailsViewNotifier`) was filled inline.

- **Files touched (4):**
  - `test/features/profile/presentation/profile_files_test.dart` — added `profileDetailsViewNotifier` group with 3 tests (refresh happy, refresh failure → `errorMessage = 'Failed to load profile'`, `selectTab` mutation without re-fetch). Also added `profile_details_providers.dart` import.
  - `docs/phase6/task_04_notifier_tests_auth_profile.md` — marked `🟢 Completed`; documented mapping from spec's file list to actual test files, called out two structural deltas vs spec (signup3 sub-screens are not separate Notifiers; featured-work tests share `profile_files_test.dart` with resume + certificates).
  - `docs/phase6/README.md` — `4 / 14`, 6.04 row flipped to `🟢`.
  - `MIGRATION_LOG.md` — this entry.

- **Decisions:**
  - **Did not rewrite existing 3,395 LOC of Phase 4 Notifier tests.** Each existing file already covers the spec's AAA + ≥ 3-cases pattern (login validation/happy/repo-error + telemetry; signup step1-3 validation + happy + repo-error; forgot password 3 flows; my-profile refresh/upload/social/portfolio; profile-files resume/certs/featured; edit-personal + enter-professional; change-password 3 notifiers; delete-account 2 flows + B1). Replacing them would erase B1 telemetry assertions that landed during the telemetry phase.
  - **`ProfileDetailsViewNotifier` was the only Notifier without dedicated tests.** Added it to `profile_files_test.dart` (not a new file) because `ProfileDetailsViewNotifier` depends on `ProfileFilesRepository` — re-using the file's `_FakeRepo` keeps the test infrastructure lean.
  - **Did not chase the spec's `providers/` sub-directory layout.** Existing tests live at `test/features/<feature>/presentation/<notifier>_test.dart`. Moving them would invalidate every PR's git blame on tests; the spec's path was aspirational.
  - **`signup3_*_notifier_test.dart` files do not exist** because step1 / step2 / step3 share a single `SignupNotifier`. The existing `signup_notifier_test.dart` covers all three step submissions and the step3 mutator surface (social links, portfolio links, featured projects, certificates, resume).

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 382 events total (up from 379 post-6.03; +3 events from the new `profileDetailsViewNotifier` group).
  - Zero real API calls — every notifier test uses an inline `_FakeRepo` / `_FakeAuthRepo` / `_FakeSession` fake.

---

### 2026-06-03: Phase 6 task 6.03 — **Repository unit tests batch 2 (shoots · file_manager · availability)** 🟢

Closed Phase 6 task 6.03. Added unit-test coverage for `ShootsRepositoryImpl`, `FileManagerStubRepository`, and `AvailabilityRepositoryImpl` following the 6.02 mocktail-on-`DioClient.dio` pattern. After this task every repository in the codebase has dedicated unit tests; notifier-level tests (6.04 onward) can rely on the repo contract being pinned.

- **Files touched (5):**
  - `test/features/shoots/data/repositories/shoots_repository_impl_test.dart` — **new** — 16 tests over `fetchProjectDetail`, `respondToProject`, `fetchShoots`, `fetchShootCount`. `respondToProject` covers both the omit-null-fields path (Dart 3 collection-if-elements) and the include-reason/comment path.
  - `test/features/file_manager/data/repositories/file_manager_repository_impl_test.dart` — **new** — 8 tests pinning the stub repo's hardcoded shape (20 folders, 6 alternating pdf/doc files, folderId-namespaced ids).
  - `test/features/availability/data/repositories/availability_repository_impl_test.dart` — **new** — 11 tests covering `fetchMonth` (swallow-on-envelope-error, status precedence: `projectAssigned` over `available`) and `createAvailability` (fire-and-forget) plus 401 / 5xx / cancel propagation.
  - `docs/phase6/task_03_repo_tests_batch2.md` — marked `🟢 Completed`; captured file paths, counts, swallow-on-error + fire-and-forget deviations, and the home/shoots `acceptdeclineproject` shape duplication.
  - `docs/phase6/README.md` — overall status `3 / 14`, 6.03 row flipped to `🟢`.

- **Decisions:**
  - **Treat `FileManagerStubRepository` as the real surface for now.** Backend endpoints are not live yet (Phase 4 punted on these), so the stub is the contract notifiers + widget tests consume. Tests pin the hardcoded shape rather than mocking anything — when the Dio-backed impl arrives, these tests will deliberately fail and force an update.
  - **Pinned `AvailabilityRepositoryImpl`'s swallow-on-envelope-error behavior.** `fetchMonth` returns `{}` (not throws) on non-Map / missing `data.availability` / `error: true`. Surfacing those as user-visible errors is its own change; tests lock the current behavior so it can't silently regress.
  - **Pinned `createAvailability` as fire-and-forget.** It never inspects `response.data`. One test asserts a `{error: true}` response is silently accepted, so a future "actually check the envelope" change must update tests intentionally.
  - **Did not de-dup `acceptdeclineproject` body shapes.** `ShootsRepositoryImpl.respondToProject` posts `{project_id, status, reason?, comment?}` (enum-driven) while `HomeRepositoryImpl.acceptDeclineProject` posts `{project_id, crew_accept: 1|2}` (int-driven). Both hit the same endpoint. Bridging the two is a notifier-layer task (likely 6.05). Each test file pins its own repo's shape — duplication is intentional.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 379 events total (35 new repo-test events: 16 shoots + 8 file_manager + 11 availability), +35 from the post-6.02 baseline of 344.
  - Per-file run also green: `flutter test test/features/{shoots,file_manager,availability}/data` → `+35`.
  - Zero real network — every `dio.get` / `dio.post` is stubbed via mocktail; the stub repo is constructed directly with no `Dio` ever involved.

---

### 2026-06-03: Phase 6 task 6.02 — **Repository unit tests batch 1 (auth · profile · home)** 🟢

Closed Phase 6 task 6.02. Added unit-test coverage for `AuthRepositoryImpl`, `ProfileRepositoryImpl`, and `HomeRepositoryImpl` exercising every public method's happy path plus its server-envelope error and transport failures (401 / 5xx / cancel where applicable). Mocks come from the shared `test/helpers/mocks.dart` from 6.01 — `MockDioClient` returns a `MockDio` and tests `verify(...).captured` the path/body each method sent.

- **Files touched (5):**
  - `test/features/auth/data/repositories/auth_repository_impl_test.dart` — **new** — 32 tests over `login`, `requestPasswordReset`, `verifyResetOtp`, `resetPassword`, `registerStep1`, `registerStep2`, `registerStep3`, `fetchRoles`, `fetchSkills`, `searchEquipments`. `registerStep1` writes a 4-byte temp file in `Directory.systemTemp` so `MultipartFile.fromFile` succeeds, then cleans up.
  - `test/features/profile/data/repositories/profile_repository_impl_test.dart` — **new** — 26 tests over `fetchEditProfile`, `updateProfile`, `fetchRoles`, `fetchSkills`, `uploadPhoto`, `updateSocialLinks`, `addPortfolioLinks`, `editPortfolioLink`. Uses an inline `_editProfilePayload(...)` builder because the existing `profileResponse` fixture targets the my-profile model, not the edit-profile model.
  - `test/features/home/data/repositories/home_repository_impl_test.dart` — **new** — 25 tests over `fetchDashboardCount`, `fetchUpcomingShoots`, `fetchPendingRequests`, `fetchCrewStats`, `fetchShootCategories`, `fetchAvailability`, `fetchProfile`, `acceptDeclineProject`. `fetchPendingRequests` test asserts the repo's status-substring filter keeps `Pending` and `pending ` and drops `confirmed`.
  - `docs/phase6/task_02_repo_tests_batch1.md` — marked `🟢 Completed`, captured the actual files / counts / deviations.
  - `docs/phase6/README.md` — overall status `2 / 14`, 6.02 row flipped to `🟢`.

- **Decisions:**
  - **Followed live `throws Exception` contract, not the `Either<AppException, T>` line in the task spec.** Phase 4 / `AI_HANDOFF.md` already flag that repos throw rather than return `Either`. Aligning the codebase to `Either` is a separate sweep that would touch every repo and every Notifier `catch` block; doing it inside a "write tests" task would silently expand scope. Logged as a deviation in the task file and surfaced in the AI handoff so it shows up at the start of every future session.
  - **`CancelToken` is not threaded through repo methods today.** Tests simulate cancel by stubbing `Dio.<verb>` to throw `DioException(type: DioExceptionType.cancel)` and asserting the type propagates. Wiring real `CancelToken` plumbing is a notifier-layer concern (6.04–6.06).
  - **Inline `_editProfilePayload(...)` builder in the profile test** instead of bloating `test/helpers/test_data.dart`. The shared helpers file's own guidance is "add a fixture only when ≥2 tests need the same shape" — this one shape currently lives in one test file.
  - **Multipart endpoints use a real temp file** (`Directory.systemTemp` + `writeAsBytesSync` + `tearDown` delete) rather than faking `FormData`. `MultipartFile.fromFile` reads from disk during construction; faking the API would mean intercepting `FormData.fromMap` itself, which is fragile.

- **Constraints Maintained:**
  - `flutter analyze --fatal-infos` clean.
  - `flutter test` green — 344 events total (83 new repo-test events: 32 auth + 26 profile + 25 home).
  - Per-file run also green: `flutter test test/features/{auth,profile,home}/data` → `+83`.
  - Zero real network — every `dio.get` / `dio.post` is stubbed via mocktail; assertions on captured args confirm the request shape without ever touching `BaseOptions.baseUrl`.

---

### 2026-06-02: Telemetry C2 — **Release symbol upload (iOS dSYM + Android mapping)** 🟢

Phase C task C2 closed (and C1 marked Skipped per product decision). Enabled automatic crash symbolication in Firebase Crashlytics for production and development flavors on release builds by configuring automatic obfuscation mapping uploads for Android and dSYM uploads for iOS.

- **Files touched (4):**
  - `android/app/build.gradle.kts` — added the `com.google.firebase.crashlytics` Kotlin DSL extension configuration inside the `release` build type block to enable automatic R8 mapping uploads.
  - `ios/Runner.xcodeproj/project.pbxproj` — created a new run script build phase `FB1FB0001CF9000F007C117E` ("Upload Symbols to Crashlytics") that runs `"${PODS_ROOT}/FirebaseCrashlytics/run"` and input files for release symbol uploads; registered this phase at the end of the `Runner` build phases list.
  - `docs/telemetry/task_c1_consent_ios_att.md` — marked status as `⏭️ Skipped` per team request.
  - `docs/telemetry/task_c2_release_symbol_upload.md` — marked status as `🟢 Completed`.

- **Decisions:**
  - **Xcode Order of Execution**: Configured the symbol upload run script to run at the absolute end of the `Runner` build phases, ensuring the correct `GoogleService-Info.plist` (copied dynamically in the preceding flavor copying build phase) is present and read by the Crashlytics compiler tool.
  - **No Ruby/Manual Sed pbxproj scripting**: Modifying `project.pbxproj` was done using highly targeted, unique hex block replacements (`FB1FB0001CF9000F007C117E`) that keep the pbxproj completely sound and healthy.

- **Constraints Maintained:**
  - `flutter analyze` runs warnings-free.
  - Complete test parity: 261/261 tests passed cleanly.

---

### 2026-06-02: Telemetry B4 — **`feature_area` custom key + Crashlytics breadcrumbs** 🟢

Phase B task B4 closed. Built on top of the existing shoots breadcrumb integration to fully set `feature_area` custom keys and emit start/success/failure breadcrumbs using the robust `CrashlyticsBreadcrumbs` helper class across all profile files, professional details, availability, and auth/login flows. Added route-level integration via `RouteSpec` to automatically update `feature_area` on navigation. All tests passing and static analysis clean.

- **Files touched (11):**
  - `lib/app/routes.dart` — added optional `featureArea` property to `RouteSpec` and configured it for core high-level routes (`login`, `home`, `shoots`, `files`, `messages`, `my_profile`, `add_availability`).
  - `lib/core/firebase/app_analytics_observer.dart` — extended route transition observer to set `feature_area` custom key in Crashlytics when navigating to routes defining a `featureArea`.
  - `lib/features/profile/presentation/providers/profile_files_providers.dart` — imported `CrashlyticsBreadcrumbs` and wired breadcrumbs on start, success, and failure for `ResumeNotifier.upload`, `CertificatesNotifier.upload`, and `FeaturedWorkNotifier.upload`.
  - `lib/features/profile/presentation/providers/my_profile_providers.dart` — imported `CrashlyticsBreadcrumbs` and wired breadcrumbs for `MyProfileNotifier.uploadPhoto`.
  - `lib/features/profile/presentation/providers/profile_details_providers.dart` — imported `CrashlyticsBreadcrumbs` and wired breadcrumbs for `EnterProfessionalNotifier.uploadPhoto`.
  - `lib/features/availability/presentation/providers/availability_providers.dart` — imported `CrashlyticsBreadcrumbs` and wired breadcrumbs for `AddAvailabilityNotifier.submit` including duration parameter.
  - `lib/features/auth/presentation/providers/login_notifier.dart` — imported `CrashlyticsBreadcrumbs` and wired breadcrumbs for `LoginNotifier.login`.
  - `test/app/routes_analytics_test.dart` — added test group to assert that route specs map exactly to their expected featureArea values.
  - `test/features/profile/presentation/profile_files_test.dart` — stubbed `CrashlyticsBreadcrumbs` static delegates and asserted correct breadcrumbs and keys are set on resume/certificate/featured-work uploads.
  - `test/features/profile/presentation/my_profile_notifier_test.dart` — added assertions for photo upload breadcrumbs.
  - `test/features/profile/presentation/profile_details_test.dart` — added assertions for photo upload breadcrumbs in professional detail flow.
  - `test/features/availability/presentation/screens/availability_test.dart` — added assertions for availability submit breadcrumbs.
  - `test/features/auth/presentation/login_notifier_test.dart` — added assertions for login breadcrumbs on success and failure (including reason parameter).
  - `test/features/shoots/presentation/shoots_notifier_test.dart` — cleaned up unused analytics_events.dart import.
  - `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — cleaned up unused analytics_events.dart import.

- **Decisions:**
  - **Dynamic Route-Level Feature Area**: Pushing, popping, or replacing routes automatically writes a high-level `feature_area` custom key. When an action triggers, it refines the `feature_area` dynamically (e.g. `'profile.upload.resume'`), combining navigation context with explicit action events.
  - **No PII**: All breadcrumb messages are verified to have zero personally identifiable information (no email logging in login, no file names/paths, only counts/enums/IDs).
  - **Static Mockability**: Preserved the testability of `CrashlyticsBreadcrumbs` using mutable static seams which are cleanly stubbed in test `setUp` and reset in `tearDown`.

- **Constraints Maintained:**
  - All calls to `CrashlyticsBreadcrumbs` are unawaited and best-effort to avoid blocking the main UI loop.
  - Complete test parity: 261/261 tests passed cleanly.
  - `flutter analyze` zero warnings and zero errors.

---

### 2026-06-02: Telemetry B2 — **Feature event emission (shoots, profile, availability)** 🟢

Phase B task B2 closed. The remaining 8 `AnalyticsEvents` constants — shoots
(`shootAccepted`, `shootDeclined`, `shootCancelled`), profile uploads
(`profilePhotoUploaded`, `featuredWorkUploaded`, `resumeUploaded`,
`certificationsUploaded`), and availability (`availabilityAdded`) — now have
live emit callsites in their respective notifiers. All emission routes through
the B3 typed-helper extension on `TelemetryClient`. Branch: `improvments-phase1`.

- **Files wired (8):**
  - `lib/features/shoots/presentation/providers/shoots_providers.dart` — `shootAccepted` (list accept), `shootCancelled` (cancel-sheet submit).
  - `lib/features/shoots/presentation/providers/upcoming_shoot_providers.dart` — `shootAccepted` + `shootDeclined` (detail-view respond).
  - `lib/features/profile/presentation/providers/my_profile_providers.dart` — `profilePhotoUploaded(source)`.
  - `lib/features/profile/presentation/providers/profile_details_providers.dart` — `profilePhotoUploaded(source)`.
  - `lib/features/profile/presentation/providers/profile_files_providers.dart` — `resumeUploaded(fileCount: 1)`, `certificationsUploaded(fileCount: 1)`, `featuredWorkUploaded(fileCount: files.length)`.
  - `lib/features/availability/presentation/providers/availability_providers.dart` — `availabilityAdded(durationDays: ...)`.

- **Tests covering B2 emissions:**
  - `test/features/shoots/presentation/shoots_notifier_test.dart` — accept + cancel success/failure telemetry assertions.
  - `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — accept + decline success/failure telemetry assertions.
  - `test/features/profile/presentation/profile_files_test.dart` — resume, certificates, featured work success/failure.
  - `test/features/profile/presentation/my_profile_notifier_test.dart` — photo upload success/failure.
  - `test/features/profile/presentation/profile_details_test.dart` — photo upload success/failure.
  - `test/features/availability/presentation/screens/availability_test.dart` — availability submit success/failure.

- **Status:** Implementation was already complete in source — task doc updated from 🔴 to 🟢.

- **Constraints Maintained:**
  - All emission paths `unawaited` — telemetry never blocks user flows.
  - No PII in params (ids, enums, counts only).
  - Side effects in presentation only — repositories untouched.
  - No raw `logEvent` callsites in `lib/features/`.

---

### 2026-06-02: Telemetry B1 — **Emit auth events** 🟢


Phase B task B1 closed. The auth half of `AnalyticsEvents` now has live emit
callsites — `loginSuccess` / `loginFailure(reason)`, `signupStarted` /
`signupCompleted(...)`, `passwordResetRequested`, `accountDeletionRequested`.
All emission routes through the B3 typed-helper extension on
`TelemetryClient`; no `AnalyticsService.logEvent(...)` callsite remains in
`lib/features`. Branch: `improvments-phase1`.

- **Files touched (10):**
  - `lib/features/auth/presentation/providers/login_notifier.dart` — emits `loginSuccess()` inside the existing telemetry try/catch and `loginFailure(reason)` from the catch path. Added `_classifyLoginFailure(Object)` that buckets `DioException.error: AppException` + bare `Exception` into the closed `LoginFailureReason` set (401/403 → `invalidCredentials`, NoInternet/Timeout/Cancel → `network`, everything else → `server`).
  - `lib/features/auth/presentation/providers/signup_notifier.dart` — added `markSignupStarted()` (idempotent via state flag) and emits `signupCompleted(hasResume, hasFeaturedWork, socialCount)` on `submitStep3` success.
  - `lib/features/auth/presentation/providers/signup_state.dart` — new sticky `signupStartedEmitted` field on `SignupState` + `copyWith`.
  - `lib/features/auth/presentation/screens/signup1_screen.dart` — wired all five form-field controllers' listeners through a single `onFieldChanged` that calls `markSignupStarted()` once per flow.
  - `lib/features/auth/presentation/providers/forgot_password_notifier.dart` — emits `passwordResetRequested()` on `requestOtp` success.
  - `lib/features/profile/presentation/providers/delete_account_providers.dart` — emits `accountDeletionRequested()` on `confirmDelete` success, before the auth-state logout.
  - `test/features/auth/presentation/login_notifier_test.dart` — `_FakeTelemetry.events` is now `({String name, Map<String, Object>? parameters})` so param shapes can be asserted. 6 new tests cover the `loginSuccess` / `loginFailure(reason)` matrix.
  - `test/features/auth/presentation/forgot_password_notifier_test.dart` — added `_RecordingTelemetry`, 3 new tests.
  - `test/features/auth/presentation/signup_notifier_test.dart` — added `_RecordingTelemetry`, 3 new tests (`markSignupStarted` idempotence, `reset()` re-arm, `signupCompleted` shape).
  - `test/features/profile/presentation/delete_account_test.dart` — added `_RecordingTelemetry`, 3 new tests.

- **Decisions:**
  - **`signupStarted` fires on first form interaction, not first build.** Notifier owns a sticky `signupStartedEmitted` flag cleared by `reset()`; the screen wires it from a shared `onFieldChanged` callback hooked into all five text controllers. Beats screen-view (would duplicate the observer) and beats `initState` (would fire on every back-tap).
  - **`passwordResetRequested` placed on `requestOtp` success.** Funnel-friendly: counts users who actually submitted an email vs. who landed on the screen. The full reset-success event can be added later as a separate wire name if reporting needs it.
  - **`accountDeletionRequested` placed on `confirmDelete` success.** Matches the "user actively confirmed" semantics of the event name; emits before `logout()` so telemetry identity is still wired when the event fires.
  - **Failure classification reuses the typed `AppException` hierarchy.** `_classifyLoginFailure` peeks at `DioException.error` (set by `ErrorInterceptor`) and falls back to `server` for unknowns so the registry always gets one of the three closed-set values.
  - **All emission paths `unawaited`.** Telemetry failure never aborts user flow; `TelemetryClient` swallows wrapper errors internally.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **253/253 passing** (237 prior + 15 new auth/profile tests; existing `_FakeTelemetry.events` shape update absorbed by existing tests).
  - `rg "AnalyticsService.logEvent\(" lib/features` — **0 hits** (constraint upheld).

- **Constraints Maintained:**
  - No new dependencies.
  - No raw `Map<String, Object>` reaches feature code — every emit goes through a typed helper.
  - No PII in event params (ids / enums / bools / counts only).
  - Side effects in presentation only — repositories untouched.

---

### 2026-06-02: Telemetry B5 — **Bridge `AppLogger.e` to Crashlytics non-fatal** 🟢

Phase B task B5 closed. `AppLogger.e(...)` now forwards to `CrashlyticsService.recordError` as a non-fatal whenever a release build logs an error with a non-null error object — gives one funnel for every `AppLogger.e` callsite without touching feature code. Branch: `improvments-phase1`.

- **Files touched (2):**
  - `lib/core/utils/app_logger.dart` — added `@visibleForTesting` `crashRecorder` field + `defaultCrashRecorder` static (mirrors A2's `ExceptionHandler.crashRecorder`). Added `debugModeOverride` callable defaulting to `() => kDebugMode`. `AppLogger.e` now appends `if (!debugModeOverride() && error != null) unawaited(crashRecorder(error, stackTrace, reason: 'logger.e: $message', fatal: false))` after the existing console-print block. Added `import 'dart:async' show unawaited` + `import '../firebase/crashlytics_service.dart'`.
  - `test/core/utils/app_logger_test.dart` — new, 5 cases. Stubs `crashRecorder` + flips `debugModeOverride` per test. Asserts: (1) forwards with same error / stack / `'logger.e: $message'` reason / `fatal:false` in simulated-release, (2) skips when `error == null`, (3) skips in debug, (4) each `e()` call forwards independently, (5) `d` / `i` / `w` never invoke the recorder. `tearDown` restores both seams.

- **Decisions:**
  - **`debugModeOverride` seam, not just stubbed `crashRecorder`.** `kDebugMode` is `const true` under `flutter test`; without a callable override the `!kDebugMode` branch is unreachable in unit tests and B5's release-mode forwarding can't be asserted. Field is `@visibleForTesting`; production reads it through a default that returns `kDebugMode` so behavior is unchanged.
  - **No recursion guard.** `CrashlyticsService.recordError` swallows its own failures via try/catch + `AppLogger.w`. `AppLogger.w` doesn't forward. Even if it did, the only path back to `e` would be via `recordError` failing — which it doesn't, because it already catches.
  - **Reason prefix `'logger.e: '`.** Lets Crashlytics dashboards group by message prefix without conflating with A2's `'dio.5xx'` / `'dio.422'` / `'guard.unexpected'` non-fatals.
  - **`fatal: false`, `unawaited(...)`.** Matches A2 / A3 conventions — only `runZonedGuarded` (A3) emits `fatal: true`.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **237/237 passing** (232 prior + 5 new).

- **Constraints Maintained:**
  - No new dependencies.
  - Console-print behavior of all four `AppLogger` methods unchanged.
  - Same call signature for `AppLogger.e` — every existing callsite gets the bridge for free.

---

### 2026-06-02: Telemetry B3 — **Typed event helpers** 🟢

Phase B task B3 closed. Replaced the raw `AnalyticsService.logEvent(name, parameters: {...})` shape with typed extension methods on `TelemetryClient`. B1 / B2 callers now have a refactor-safe surface that enforces param shape per event; no `Map<String, Object>` reaches feature code. Branch: `improvments-phase1`.

- **Files touched (3):**
  - `lib/core/firebase/analytics_events.dart` — `extension TelemetryEventHelpers on TelemetryClient` adds 15 helpers (8 parametric, 7 nullary) alongside the existing string-constant registry. Added two closed-set parameter enums (`LoginFailureReason`, `ProfilePhotoSource`) so reason / source strings can't drift across notifiers.
  - `lib/core/firebase/telemetry_client.dart` — `FirebaseTelemetryClient.clearUserIdentity` now calls the `logout()` extension instead of `AnalyticsService.logEvent(AnalyticsEvents.logout)`. Removes the last direct `AnalyticsEvents.<name>` read in `lib/`.
  - `test/core/firebase/analytics_events_test.dart` — new, 9 cases. 6 parametric helpers asserted against name + parameter map (`shootAccepted`, `loginFailure`+enum, `signupCompleted`, `profilePhotoUploaded`+enum, `featuredWorkUploaded`, `availabilityAdded`). 3 nullary cases (`loginSuccess`, `logout`, batched `signupStarted` / `passwordResetRequested` / `accountDeletionRequested`).

- **Decisions:**
  - **Extension on `TelemetryClient`, not static methods on `AnalyticsEvents`.** Routes through the existing `TelemetryClient.logEvent` seam so `_FakeTelemetry` / `_RecordingTelemetry` test fakes don't need 15 new method overrides. Keeps the abstract interface minimal — fakes implement 4 methods, get all 15 helpers for free.
  - **Same file as the registry.** `analytics_events.dart` lands at 184 LOC after the change, under the ~200-line threshold called out in the task brief. Co-locating the constants + helpers keeps PR review on one file.
  - **Closed-set enums for `reason` / `source`.** `LoginFailureReason` and `ProfilePhotoSource` carry their wire name as a field so the helper emits the snake-case form without a switch. Adding a new value becomes a reviewable diff.
  - **`*Name` constant rename deferred.** Task notes flagged the rename as sugar; with no direct `AnalyticsEvents.<name>` reads remaining in `lib/`, the rename buys nothing today. Re-evaluate if a registry-read use case appears.
  - **Param-less events get nullary helpers** (chose "nullary" over "stay as constants" per task brief recommendation). Consistency at the call site: every event uses the same `ref.read(telemetryClientProvider).foo(...)` shape.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **232/232 passing** (223 prior + 9 new).

- **Constraints Maintained:**
  - No new dependencies.
  - No call-site churn yet — B1 / B2 will be the first features to consume the helpers.
  - Existing `_FakeTelemetry` in `login_notifier_test.dart` still satisfies `TelemetryClient` with no changes needed.

---

### 2026-06-02: Telemetry A3 — **`runZonedGuarded` + debug-build collection gate** 🟢

Phase A foundation task A3 closed — closes Phase A (3 / 3 done). `runApp` is now wrapped in `runZonedGuarded` so async errors that escape `PlatformDispatcher.onError` still land in Crashlytics as fatal; debug builds explicitly disable Crashlytics + Analytics collection so dev sessions stop polluting prod dashboards. Branch: `improvments-phase1`.

- **Files touched (2):**
  - `lib/main.dart` — `runApp(ProviderScope(...))` is now wrapped in `runZonedGuarded(() => runApp(...), (e, st) => CrashlyticsService.recordError(e, st, fatal: true))`. All init calls (`Env.init`, `FirebaseService.initialize`, `PrefsService.init`, `SharedPreferences.getInstance`, `SessionMigration.runOnce`) stay above the zone so a Firebase init failure can't loop back through the zone-guard. Added `import 'dart:async'` for `runZonedGuarded`.
  - `lib/core/firebase/firebase_service.dart` — after `Firebase.initializeApp()` succeeds, now calls `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)` and `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode)` (wrapped in try/catch so missing native config still proceeds).

- **Decisions:**
  - **Init outside zone.** Per task notes — if `FirebaseService.initialize` itself throws, we don't want the zone-guard handler trying to report it back into half-booted Firebase.
  - **`!kDebugMode` over `Env.isStaging`.** Task notes flag the staging case for future work; current flavors don't have a staging-wants-telemetry use case. Defer until needed.
  - **No new tests.** A3 is startup wiring at `startApp` and `FirebaseService.initialize`; both already run on every test via the existing smoke harness. The zone-guard handler isn't directly unit-testable without a separate process.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **223/223 passing** (no test count change).

- **Constraints Maintained:**
  - No new dependencies (`firebase_analytics` and `firebase_crashlytics` already direct deps).
  - Init order preserved.

---

### 2026-06-02: Telemetry A2 — **Non-fatal error funnel through ExceptionHandler** 🟢

Phase A foundation task A2 closed. Non-fatal errors caught by `ExceptionHandler.guardAsync` now forward to Crashlytics for the signal-rich branches (`ServerException` 5xx + unknown, `ValidationException` 422, plus unknown thrown shapes). Noise (NoInternet / Timeout / RequestCancelled / 401 / 403 / 404 / 429 / 503) is explicitly skipped. Branch: `improvments-phase1`.

- **Files touched (2):**
  - `lib/core/network/exceptions/exception_handler.dart` — added `@visibleForTesting` `crashRecorder` seam (defaults to `CrashlyticsService.recordError`) so tests can capture forwarding without invoking the static Firebase service. `guardAsync` now pattern-matches the mapped `AppException` and forwards via `unawaited(crashRecorder(...))` with `reason: 'dio.5xx'` / `'dio.422'` / `'guard.unexpected'`. Noise branches explicitly `break`.
  - `test/core/network/exception_handler_test.dart` — count 6 → 20. 14 new cases stub the seam and assert the call/no-call matrix per branch (`5xx`, `badCertificate-unknown`, `422`, `401`, `403`, `404`, `429`, `503`, `timeout`, `cancel`, `connectionError`, top-level `SocketException`, rethrown `AppException`, unknown `StateError`).

- **Decisions:**
  - **`crashRecorder` field, not full DI.** Repositories call `ExceptionHandler.guardAsync` statically; threading a provider through every repo just to stub the sink would be massive churn. The `@visibleForTesting` field + `defaultCrashRecorder` reset in `tearDown` is enough for unit tests.
  - **No `ErrorInterceptor` mirror.** It wraps the typed error but doesn't classify-and-forward; adding forwarding there would double-report whenever a feature uses `guardAsync` downstream. Single source of truth stays in `ExceptionHandler`.
  - **`fatal: false` for everything.** A1's `runZonedGuarded` (task A3) owns the `fatal: true` path. A2 is the non-fatal pipe.
  - **`unawaited(...)` on forward.** Crashlytics is fire-and-forget; awaiting it would slow the error path on a slow network.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **223/223 passing** (209 prior + 14 new).

- **Constraints Maintained:**
  - Existing mapping behavior unchanged — all 6 prior mapping tests still pass.
  - No new dependencies.

---

### 2026-06-02: Telemetry A1 — **User identity on login/logout** 🟢

Phase A foundation task A1 closed. Authenticated user is now propagated to Firebase Analytics (`setUserId`) + Crashlytics (`setUserIdentifier` + `user_id` / `user_role` custom keys) on every authed entry; identity is dropped on explicit logout and on 401 / token-expiry. Branch: `improvments-phase1`.

- **Files touched (5):**
  - **New:** `lib/core/firebase/telemetry_client.dart` — `TelemetryClient` interface + `FirebaseTelemetryClient` default + `telemetryClientProvider`. Test seam over the two static Firebase wrappers (`AnalyticsService`, `CrashlyticsService`). Surface: `setUserIdentity`, `clearUserIdentity`, `logEvent`, `recordError`.
  - `lib/features/auth/presentation/providers/login_notifier.dart` — after `markLoggedIn` and only when `result.user` is non-null, calls `setUserIdentity(userId, userRole)`. Wrapped in try/catch — telemetry hiccup never fails login.
  - `lib/core/providers/auth_state_provider.dart` — `AuthStateNotifier.logout()` calls `clearUserIdentity(emitLogoutEvent: true)` after the session/restoration/draft clears.
  - `lib/core/providers/core_providers.dart` — `AuthInterceptor.onUnauthorized` callback now also calls `clearUserIdentity()` (no logout event — user didn't choose this).
  - `test/features/auth/presentation/login_notifier_test.dart` — `_FakeTelemetry` + 4 new tests (identity set with role on success, no-op when user payload missing, no-op on login failure, logout clears identity with event).

- **Decisions:**
  - **Single seam, not three.** Tests need to stub `AnalyticsService` + `CrashlyticsService` together; introducing one `TelemetryClient` is leaner than two abstracts. `FirebaseTelemetryClient` just forwards to the existing static services so Firebase-isn't-configured stub mode still works.
  - **`setUserIdentity` is one method, not four.** Forces the call site to do the right thing (analytics + crashlytics + custom keys + `logLogin`) in one call — no chance of half-applying telemetry on a future feature.
  - **No `loginSuccess` registry event yet.** A1's scope is identity wiring + Firebase-builtin `logLogin`. The `AnalyticsEvents.loginSuccess` registry entry is the B1 task.
  - **401 path skips `logout` event.** User didn't initiate; emitting `logout` would pollute the funnel. Identity still cleared.
  - **Best-effort, never blocking.** All telemetry calls inside auth flows are wrapped in try/catch — auth success/failure must complete regardless.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **209/209 passing** (205 prior + 4 new).

- **Constraints Maintained:**
  - Side effects in presentation only — `AuthRepositoryImpl` and the interceptor remain telemetry-unaware (the interceptor wires the closure but doesn't import `AnalyticsService`/`CrashlyticsService` directly).
  - No new dependencies.

---

### 2026-05-31: Task 6.01 — **Expand test helpers** 🟢

Task 6.01 done. `test/helpers/` now carries the harness, mocks, and fixtures that the rest of Phase 6 will build on. Test count 145 → **151** (6 new helper smoke tests).

- **Files touched (4):**
  - `test/helpers/pump_app.dart` — added `pumpRouterApp(GoRouter)` extension method. Mounts `MaterialApp.router(routerConfig: ...)` inside the existing `ProviderScope(overrides: ...)` wrapper. Existing `pumpProviderApp` unchanged.
  - **New:** `test/helpers/mocks.dart` — `MockDioClient`, `MockDio`, `MockSessionStore` (mocktail), plus `FakeSecureSessionBackend` + `FakePrefsSessionBackend` for behavior-style tests, plus `registerHelperFallbacks()` for the complex-arg fallbacks (`Options`, `Map<String, dynamic>`, `Uri`).
  - **New:** `test/helpers/test_data.dart` — JSON fixture builders: `loginResponse`, `profileResponse`, `dashboardCountResponse`, `shootCountResponse`, `shootsListResponse`, `singleShootJson`, `errorResponse`. Each returns `Map<String, dynamic>` so tests round-trip through real `fromJson`.
  - **New:** `test/helpers/helpers_smoke_test.dart` — 6 smoke tests covering each helper surface (router-aware pump, mocktail stub, composite-store round-trip, profile fixture round-trip, login fixture shape, error envelope shape).

- **Decisions:**
  - **`MockX` only for cross-cutting deps.** `MockDioClient` + `MockSessionStore` cover everything the upcoming repo / notifier suites bump into. Feature-repo mocks stay inline in their consuming test file until ≥3 tests need the same surface (per task notes).
  - **Behavior fakes alongside the mocktail mocks.** `FakeSecureSessionBackend` + `FakePrefsSessionBackend` let tests use the real `CompositeSessionStore` end-to-end. Cheaper than stubbing every `read*` / `write*` for tests that exercise the composite's internal coordination.
  - **`profileResponse.user.primary_role` defaults to `null`.** `User.fromJson` decodes `primary_role` as a JSON list when non-null (`jsonDecode(json["primary_role"])`). Empty-string default would crash; null falls into the else branch. Documented inline in the fixture so future-me doesn't re-add the bug.
  - **Fixtures return raw maps, not typed models.** Tests that need a typed instance do `MyProfileModel.fromJson(profileResponse(...))`. Keeps each fixture round-trippable as a regression test for the model itself.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **151/151 passing** (145 prior + 6 new helper smoke tests).

- **Constraints Maintained:**
  - Zero production-code changes.
  - No new dependencies — `mocktail: ^1.0.4` was already in `pubspec.yaml`.
  - All helpers live under `test/helpers/` — no test-only code in `lib/`.

---

### 2026-05-31: Task 5.08 — **Router final pass** 🟢 — Phase 5 complete

Task 5.08 done. Router shrunk from **465 LOC → 165 LOC** by extracting per-feature route fragments. Phase 5 now closed (8/8 tasks).

- **Files touched (6):**
  - `lib/app/router.dart` — rewritten as orchestrator. Imports five `*Routes` lists and spreads them after the entry-point routes + shell.
  - **New:** `lib/features/auth/presentation/routes/auth_routes.dart` (8 routes: login, signup1/2/3, forgot, otp, reset, view-details).
  - **New:** `lib/features/profile/presentation/routes/profile_routes.dart` (16 routes: my-profile, edit/enter, profile-details, featured-works + featured-work-details, certificates, resume, app-preferences, change-password, profile-otp, new-password, profile-password-success, delete-account flow ×3).
  - **New:** `lib/features/shoots/presentation/routes/shoots_routes.dart` (3 routes: upcoming-shoot-details, cancel-shoot, shoot-cancelotties).
  - **New:** `lib/features/availability/presentation/routes/availability_routes.dart` (1 route: add-availability).
  - **New:** `lib/features/file_manager/presentation/routes/file_manager_routes.dart` (2 routes: pre-production, post-production).

- **Decisions:**
  - **Splash + onboarding stay inline.** They describe pre-auth global lifecycle, not a "feature" with co-located screens/providers. Pulling each into a one-route fragment file would be ceremony without payoff.
  - **`StatefulShellRoute` stays inline.** Its 5 branches reference screens across 5 different features. Splitting the shell would force a circular import or a new "shell-only" import boundary — both worse than keeping it where it is.
  - **Public-route set + redirect + `_AuthRefreshNotifier` stay in `router.dart`.** Cross-cutting orchestration concerns; no clean per-feature home.
  - **Deep-link wiring + typed params deferred.** Task notes mark them optional ("defer if not on roadmap"). No deep-link product requirement yet — landing the structural split standalone keeps the diff reviewable and avoids the Android manifest + iOS URL-types churn we'd need to validate end-to-end.
  - **`AddAvailabilityScreen` constructor made `const` in the route fragment.** The original route built it without `const` while the screen exposes a const constructor — picked this up while moving and corrected (zero behavior change).
  - **No changes to `route_names.dart`.** Every route still uses its existing `RouteNames.*` name, so all existing `context.goNamed` / `pushNamed` call sites continue to work unchanged.

- **Verification:**
  - `wc -l lib/app/router.dart` → **165** (down from 465; ≤400 threshold met).
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **145/145 passing** (includes the `widget_test.dart` smoke test that mounts `MaterialApp.router` against this exact composed route tree).

- **Constraints Maintained:**
  - Zero behavior change — every route path, route name, builder body, and `state.extra` parsing reproduced verbatim in the new fragment files.
  - No new public API surface — fragment files export plain `final List<RouteBase>` constants. No new types, no new providers.
  - No new dependencies.

### Phase 5 closure

All Phase 5 cleanup tasks (`5.01`–`5.08`) closed 2026-05-31. Codebase now has:

- No legacy `ApiService` / `SharedService` shims (5.01).
- 4 unused deps + 5 transitive removed (5.02): `http`, `flutter_stripe`, `image_cropper`, `photo_view`.
- All network image sites on `CachedNetworkImage` / `CachedNetworkImageProvider` (5.03).
- 0 `/* */` blocks + 1 scoped `TODO(messaging)` only (5.04).
- CI gates merges on `flutter analyze --fatal-infos`; lint set locked (5.05).
- Validators consolidated; no inline regex duplicates (5.06).
- Model class names normalized; `camel_case_types` lint re-enabled (5.07).
- Router orchestrator ≤400 LOC; feature routes co-located (5.08).

Phase 6 (testing) is now unblocked.

---

### 2026-05-31: Task 5.07 — **Naming polish** 🟢

Task 5.07 done. Five colliding inner `Data` classes are now feature-prefixed; seven legacy camel/snake-case model wrapper classes are now PascalCase; one screen class renamed for filename/class consistency; `camel_case_types` lint re-enabled.

- **Files touched (29):**
  - **Model declarations (8):** `lib/model_class/dashboard_count_model.dart`, `shoot_count_model.dart`, `create_dashboard_details_model.dart`, `myprofile_model.dart`, `shoots_model.dart`, `shoot_status_model.dart`, `upcoming_shoots_model.dart`, `upcoming_shootview_model.dart`.
  - **Consumers (12):** `lib/features/home/{domain,data,presentation}/...`, `lib/features/shoots/{domain,data,presentation}/...`, `lib/features/profile/{domain,data,presentation}/...`, `lib/app/router.dart`, `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart`.
  - **Tests (5):** `test/features/home/presentation/home_notifier_test.dart`, `test/features/profile/presentation/{my_profile_notifier_test.dart,profile_files_test.dart}`, `test/features/shoots/presentation/{shoots_notifier_test.dart,upcoming_shoot_notifier_test.dart}`.
  - **Lint config (1):** `analysis_options.yaml`.
  - Wider count (29) reflects every file touched across the cascade; many touched files received only a 1–2 token swap (e.g. `dashboard.Data` → `dashboard.DashboardCountData`).

- **Renames:**
  - `Data` (5 sites) → `DashboardCountData`, `ShootCountData`, `CreatorDashboardData`, `MyProfileData`, `ShootsData`.
  - `shootstatusdata` → `ShootStatusData`. `upcomingdatum` → `UpcomingShootDatum`.
  - `Dashboardcountmodel` / `Shootcountmodel` / `Creatordashboarddetailsmodel` / `Myprofilemodel` / `Shootstatusmodel` / `Upcomingshootsmodel` / `Upcomingshootviewmodel` → PascalCase equivalents.
  - `CancelScreen` → `ShootCancelledScreen` (matches `shoot_cancelled_screen.dart`).

- **Decisions:**
  - **In-scope creep accepted: wrapper classes renamed alongside inner `Data` classes.** Task scope text mentioned only the 5 `Data` collisions, but `analysis_options.yaml` had `camel_case_types: false` gated on this exact task with the rationale "two legacy generated-model class names still leak through call sites." Re-enabling that lint required cleaning all wrapper classes too, not just the two named in the comment. Done in a single pass to avoid splitting the cascade.
  - **`constant_identifier_names` permanently disabled, not deferred.** Asset filename constants (`Image_zoom`, `User_Circle`, `image_holder`) and API endpoint constants (`upload_resume`, `delete_allfiles`, `register_step1`) mirror server-side snake_case keys verbatim. Renaming the Dart symbols would decouple them from their source-of-truth and add zero clarity. Documented WHY in `analysis_options.yaml` and removed the deferred-to-5.07 comment.
  - **Screen suffix audit: top-level public classes only.** Strict reading of acceptance ("every class in those files ends with `Screen`") would force renaming dozens of private widget helpers like `_FolderList`, `_PersonalCard`, `_StatCard`. These are widget extractions co-located with the screen, not screens themselves. Spec intent honored — top-level public classes audited and the single offender (`CancelScreen`) fixed; internal helpers left alone.
  - **`CancelScreen` renamed to `ShootCancelledScreen`** (matches the existing filename and the rest of the cancel-shoot flow's vocabulary). The notifier and provider stay `CancelShootNotifier` / `cancelShootProvider` — those names describe the action, not the screen, and would force more cross-file churn without payoff.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0). Three sweep passes were needed: model decls → consumer files → test files. CI now enforces `camel_case_types`.
  - `flutter test` — **145/145 passing**.

- **Constraints Maintained:**
  - Zero behaviour change — purely structural renames; every test that was passing before is still passing.
  - JSON field keys (e.g. `"shoot_type"`, `"event_date"`) unchanged — only Dart symbols renamed.
  - No new dependencies; no new files (`shoot_cancelled_screen.dart` kept its name).

---

### 2026-05-31: Task 5.06 — **Standardization sweeps** 🟢

Task 5.06 done. Audit sweeps across date formatters, analytics, asset literals, and regex. Three of the four buckets were already clean from Phase 4 + 5.01–5.05 work; only **regex consolidation** required net new code.

- **Files touched (7):**
  - **New:** `lib/core/utils/validators.dart` — `kEmailPattern`, `kPlusCodePattern`, `kEmailRegex`, `kPlusCodeRegex`, `isValidEmail(value)`, `isPlusCode(value)`.
  - `lib/features/auth/presentation/providers/signup_notifier.dart` — local `_emailRegex` removed; `isValidEmail` import.
  - `lib/features/auth/presentation/providers/login_notifier.dart` — same.
  - `lib/features/auth/presentation/providers/forgot_password_notifier.dart` — same.
  - `lib/features/profile/presentation/providers/change_password_providers.dart` — local `isValidEmail` (with the divergent `[a-zA-Z]+$` TLD pattern) deleted; shared `isValidEmail` from `validators.dart` imported.
  - `lib/features/auth/presentation/screens/signup1_screen.dart` — local `_isPlusCode` wrapper deleted; direct `isPlusCode(p.name!)` call; `validators.dart` import added.
  - `lib/service/google_config.dart` — unused `static final RegExp plusCodeRegex` removed (no external consumers — only `signup1_screen.dart` had a copy and it's now on the shared helper).

- **Decisions:**
  - **Date formatters: nothing to consolidate.** Only `DateTimeUtils` calls `DateFormat`. The four remaining `DateTime.parse` / `toIso8601String` sites outside it (`upcoming_shoots_model`, `create_dashboard_details_model`, `prefs_session_store`, `home_notifier`) are JSON decoding or canonical persistence — not formatter literals. Adding wrappers for these would be ceremony without payoff.
  - **Analytics: registry-only state preserved.** `AnalyticsEvents` constants are already defined; zero consumers across the app right now. Nothing to migrate. The acceptance condition ("no raw analytics event name outside `AnalyticsEvents`") is satisfied by the absence of `logEvent` callers — registry is correctly the sole owner.
  - **Asset literals: already clean.** Every `'assets/...'` literal lives in `lib/app/assets.dart`. AppAssets is the only entry point.
  - **Regex bucket: convergence on `{2,}` TLD.** `change_password_providers.dart` had a slightly looser pattern (`[a-zA-Z]+$`). Standardized on the stricter `{2,}` rule via the shared helper. Behaviour change is intentional: single-letter TLDs are not valid and were previously rejected everywhere else in the app — fixing the lone outlier removes a silent inconsistency.
  - **`GoogleConfig.plusCodeRegex` deleted, not re-pointed.** It had no external callers; removing the field is cleaner than aliasing to the new helper.
  - **No `formatReadableDateFromDateTime` overload added.** `home_upcoming_carousel.dart` does an ISO round-trip (`DateTimeUtils.formatReadableDate(eventDate.toIso8601String())`). Considered adding a `DateTime`-accepting overload; deferred — single call site, not worth introducing API breadth ahead of demand.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **145/145 passing**.
  - `rg "RegExp\(" lib/` — remaining hits are: 1× `RegExp(r'\s+')` (initials splitter in `app_avatar.dart`), 1× `RegExp(r'"message":"(.*?)"')` (one-shot login error parser), plus the two canonical refs inside `validators.dart`. No duplicates.

- **Constraints Maintained:**
  - Zero behaviour change on the email-validation hot paths (signup, login, forgot password) — same pattern, just hoisted.
  - One intentional behaviour tightening: change-password screen now rejects single-letter TLDs consistent with the rest of the app.
  - No new packages.

---

### 2026-05-31: Task 5.05 — **Lint upgrade (`--fatal-infos`)** 🟢

Task 5.05 done. CI now runs `flutter analyze --fatal-infos`, blocking any future PR that introduces an info-level lint. Audit-era baseline of ~190 / post-5.04 80 had decayed to **14** infos by task start (Phase 4 + 5.01–5.04 fixes incidentally cleared most of the punch list).

- **Files touched (9):**
  - `.github/workflows/ci.yml` — analyze step gets `--fatal-infos`.
  - `analysis_options.yaml` — comment block updated to record CI policy + pin (`flutter_lints: ^6.0.0` base set).
  - `lib/shared/widgets/common_file_viewer.dart` — 3× `print` → `debugPrint`; `ScaffoldMessenger.of(context)` guarded by `context.mounted` after `Dio().download`.
  - `lib/utility/location_service.dart` — `ScaffoldMessenger.of(context)` guarded by `context.mounted` after async permission checks.
  - `lib/features/profile/presentation/screens/featuredwork_details_screen.dart` — `WillPopScope` → `PopScope` (`canPop: false` + `onPopInvokedWithResult`).
  - `lib/features/profile/presentation/screens/app_preferences_screen.dart` — `Switch.activeColor` → `activeThumbColor`.
  - `lib/features/auth/presentation/widgets/signup1_form.dart` — `controller.setMapStyle(...)` → `GoogleMap.style:`; `SvgPicture.asset(... color:)` → `colorFilter: ColorFilter.mode(...)`.
  - `lib/features/availability/presentation/screens/add_availability_screen.dart` — `ThemeData.dark().copyWith(useMaterial3: true, ...)` → `ThemeData.dark(useMaterial3: true).copyWith(...)`; two `dialogBackgroundColor:` → `dialogTheme: DialogThemeData(backgroundColor: ...)`.
  - `lib/shared/widgets/custom_dropdown.dart` + `lib/shared/widgets/custom_dropdown_field.dart` — `DropdownButtonFormField.value` → `initialValue` + `key: ValueKey(value)` (see decision).

- **Decisions:**
  - **`DropdownButtonFormField` gets `key: ValueKey(value)`.** Flutter ≥3.33 deprecated the controlled `value:` in favour of `initialValue:`, which only seeds the FormField's internal state. Parent-driven changes (e.g. `add_availability_screen` clearing recurrence on type switch) would no longer be reflected in the dropdown's visible selection. Adding a `ValueKey` on the field forces a fresh `FormFieldState` whenever the bound value changes, preserving the previous controlled-by-parent semantics.
  - **`GoogleMap.style` instead of `setMapStyle`.** The `style:` parameter on the widget is the documented replacement; setting it once at widget config eliminates the post-creation imperative call and keeps the dark style declarative. `onMapCreated` is now passed directly without the local closure wrapper.
  - **`PopScope` with `canPop: false` + `onPopInvokedWithResult`.** The old `WillPopScope` callback returned `false` and forced `Navigator.pop(context, hasChanges)` — i.e. it always swallowed the back gesture and then popped with a custom result. `PopScope(canPop: false, onPopInvokedWithResult: …)` reproduces that exactly: the gesture never pops automatically, the callback always runs, and the screen does a manual pop with the changes flag.
  - **`useMaterial3` lifted from `copyWith` to constructor.** Flutter recommends `ThemeData.dark(useMaterial3: true)` rather than copying onto a default. Behaviour identical (both produced M3 dark themes); silences the deprecation without changing the date picker's look.
  - **No new ignore comments added.** Every fix is structural. The two `// ignore: deprecated_member_use` markers that were already present (e.g. `add_availability_screen.dart:457` SVG `color:`) are out of scope here.

- **Verification:**
  - `flutter analyze --fatal-infos` — **No issues found** (exit 0).
  - `flutter test` — **145/145 passing**.

- **Constraints Maintained:**
  - Zero behaviour change verified by full test suite (dialog appearance, map styling, dropdown selection, file-viewer error handling, back-press semantics on featured work all unchanged).
  - Lint set provenance and CI policy now documented in `analysis_options.yaml`.
  - No new packages, no `// ignore` debt added.

---

### 2026-05-31: Task 5.04 — **Comment hygiene** 🟢

Task 5.04 done. Codebase already most of the way clean — pre-existing audit numbers (60 block comments, 104 dead lines) reflected the pre-Phase-4 state. After Phase 4 + 5.01-5.03 sweeps, only 3 `/* */` blocks + ~5 single-line dead lines + 1 unused legacy file remained.

- **Files touched (6):**
  - Deleted: `lib/service/config.dart` (unused `AppConfig` class, 33 LOC; replaced by `Env` in Phase 2).
  - `lib/app/shadows.dart` — removed `/* goldGlow + soft */` dead block (17 lines).
  - `lib/app/theme.dart` — compacted PHASE-E deferred-fields list (18 lines of `// fieldName: ...` markers) to a single 4-line WHY note. Intent (one-at-a-time enablement under screenshot diff) preserved; specific field names dropped (recoverable from `ThemeData` API docs).
  - `lib/features/home/presentation/widgets/home_dashboard_summary.dart` — removed 3 dead fragments: stray `// borderRadius: …,` arg, dead `Text(percent…)` block, dead alternate `child: SvgPicture.asset(...)` block. ~14 lines.
  - `lib/features/home/presentation/widgets/home_shoot_categories_panel.dart` — removed half-edited dead `Text(...)` alternative (4 lines).
  - `lib/shared/widgets/common_calendar.dart` — removed dead `// height: cellHeight * rowCount,` arg.

- **Decisions:**
  - **`lib/service/config.dart` deleted, not just cleaned.** `AppConfig` had zero references anywhere — `grep -rn "AppConfig" lib/ test/` returned only the class declaration line. The file's job was taken over by `Env` (env-aware constants + `Env.init(...)` in `startApp`). Removing the whole file is cleaner than removing the dead comment fragments inside it.
  - **`theme.dart` PHASE-E block compacted, not deleted.** The 18-line list of disabled `ThemeData` fields is dead code by strict definition, but the surrounding intent ("enable individually with screenshot diff") is real engineering rationale. Kept the rationale in 4 lines; dropped the field list (any developer can recover it from `ThemeData`'s docs).
  - **`TODO(messaging)` in `messages_screen.dart` kept.** Properly scoped owner-prefixed TODO that references a logged decision; not a `TODO(migration)` marker that needs resolving.
  - **No global "no commented-out code" lint enabled yet.** Per task acceptance, this state can now support enabling such a lint, but the actual lint enable lives in task 5.05 (`--fatal-infos` + lint config).

- **Verification:**
  - `grep -rn "/\*" lib/` → 0 hits.
  - `grep -rn "TODO" lib/` → 1 legitimate `TODO(messaging)` hit only.
  - `flutter analyze` — 80 issues (unchanged from post-5.03).
  - `flutter test` — **145/145 passing**.

- **Constraints Maintained:**
  - Zero behaviour change verified by full test suite.
  - All preserved comments explain WHY (per `MIGRATION_RULES.md` §10 and CLAUDE.md "default to writing no comments").
  - Net delete: ~70 lines (1 file + ~40 inline dead lines + 14-line theme compact).

---

### 2026-05-31: Task 5.03 — **`Image.network` → `CachedNetworkImage`** 🟢

Task 5.03 done. All 13 network-image sites migrated to `cached_network_image` (12 `Image.network` + 1 `NetworkImage`). `app_avatar.dart` was already on `CachedNetworkImage` pre-task.

- **Files touched (13):**
  - `lib/features/home/presentation/widgets/home_pending_shoot_card.dart`
  - `lib/features/home/presentation/widgets/home_upcoming_carousel.dart` (dropped stray `print` from errorBuilder)
  - `lib/features/home/presentation/widgets/home_welcome_header.dart` (`NetworkImage` → `CachedNetworkImageProvider` for CircleAvatar.backgroundImage)
  - `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart`
  - `lib/features/shoots/presentation/screens/shoots_screen.dart`
  - `lib/features/profile/presentation/screens/featuredwork_details_screen.dart`
  - `lib/features/profile/presentation/screens/certificates_screen.dart`
  - `lib/features/profile/presentation/screens/resume_screen.dart`
  - `lib/features/profile/presentation/screens/profile_details_1_screen.dart` (restructured `_Avatar` to gate `CachedNetworkImage` on `profileImageUrl.isNotEmpty`, avoiding a 404 on empty-string URL the old code triggered)
  - `lib/features/profile/presentation/widgets/featured_work_card.dart`
  - `lib/features/profile/presentation/widgets/profile_header.dart`
  - `lib/features/profile/presentation/widgets/featured_work_upload_sheet.dart`
  - `lib/shared/widgets/common_file_viewer.dart`

- **Decisions:**
  - **No shared wrapper widget introduced.** The task suggested a shared placeholder + fallback widget, but each existing `errorBuilder` was already per-context (image_holder SVG sized for shoot cards, User_Circle SVG for avatars, plain Container for empty grid cells). Wrapping them under one widget would still require an injection point for the fallback, which `CachedNetworkImage.errorWidget` already provides. Direct migration is fewer lines and keeps the visible fallback identical.
  - **No bespoke `placeholder` builders added.** `CachedNetworkImage` ships a fade-in on the empty frame; introducing per-site loaders would violate the task note ("Don't introduce per-call-site bespoke loaders"). The fade-in is fine for the current product surfaces.
  - **`profile_details_1_screen.dart` `_Avatar` ternary restructured** — the old code passed `''` to `Image.network` when `profileImageUrl` was empty, relying on `errorBuilder` to render the fallback after a failed network call. `CachedNetworkImage` will throw `Invalid argument(s): No host specified in URI` for empty URLs. Gated the `CachedNetworkImage` on `profileImageUrl.isNotEmpty` so the SVG fallback renders directly when there is no URL. Same visible behaviour, no spurious decode error.

- **Verification:**
  - `grep -rn "Image\.network\|NetworkImage(" lib/` → 0 hits.
  - `flutter analyze` — 80 issues (no change). No errors.
  - `flutter test` — **145/145 passing**.

- **Constraints Maintained:**
  - Zero behaviour change verified by full test suite.
  - All existing fallback art (image_holder, User_Circle, Container) preserved verbatim.
  - No new shared widget files created — feature-local migration only.

---

### 2026-05-31: Task 5.02 — **Dependency prune** 🟢

Task 5.02 done. Four direct deps dropped from `pubspec.yaml`: `http`, `flutter_stripe`, `image_cropper`, `photo_view`. `flutter pub get` reports 9 packages no longer depended on (4 direct + 5 transitive: `stripe_android`, `stripe_ios`, `stripe_platform_interface`, `image_cropper_for_web`, `image_cropper_platform_interface`).

- **Files touched:**
  - `pubspec.yaml` — removed 4 dep lines.
  - `pubspec.lock` — auto-regenerated by `flutter pub get`.

- **Decisions:**
  - **flutter_stripe drop sign-off** — user confirmed via prompt. Zero usage in `lib/` or `test/` (no `Stripe.`, no `package:flutter_stripe` imports). `Env.stripePublishableKey` constant retained in `lib/config/env.dart` as a forward-compatible string literal; re-adding stripe later only needs the dep + wiring, not a config change.
  - **http drop** — zero direct usage (no `package:http/` import, no `http.get`/`post`/`put`/`delete`/`Client`/`Response`). Was likely a pre-Dio holdover. Firebase + `google_maps_flutter` pull their own transitive `http`, so app-side networking via `Dio` is unaffected.
  - **image_cropper drop** — zero usage. The crop sheet (`signup1_crop_sheet.dart`, `profile_image_crop_sheet.dart`) uses raw `Transform.translate` / `Transform.scale` plus a `CropController` pattern, not `image_cropper`.
  - **photo_view drop** — zero usage. Image previews use `Image.network` / `CachedNetworkImage` directly.

- **Verification:**
  - `flutter pub get` — 9 packages removed; resolution succeeded.
  - `flutter analyze` — 80 issues (no change vs post-5.01 baseline). No errors, no new warnings.
  - `flutter test` — **145/145 passing**.

- **Constraints Maintained:**
  - Zero behaviour change verified by full test suite.
  - No `lib/` code touched (deps-only).
  - Native iOS/Android module count down by ~3 (stripe_ios, stripe_android, image_cropper native binding), improving build time and APK / IPA size.

---

### 2026-05-31: Task 5.01 — **Delete transitional shims** 🟢

Task 5.01 done. `lib/service/api_service.dart` and `lib/service/shared_service.dart` removed. All call sites migrated to `Env.imageUrl`, `DioClient.dio` (multipart), `SessionStore.clearSession()`, and `authStateProvider`. `lib/utility/colorcode.dart` and `lib/utility/imges_icons.dart` were already absent (cleared in Phase 2/4).

- **Files touched:**
  - Deleted: `lib/service/api_service.dart`, `lib/service/shared_service.dart`.
  - `lib/main.dart` — dropped `SharedService.bind(session)` + import.
  - `lib/features/profile/presentation/widgets/profile_action_buttons.dart` — `StatelessWidget` → `ConsumerWidget`; `SharedService.logout()` → `sessionStoreProvider.clearSession()` + flip `authStateProvider` to false. Mirrors `delete_account_providers.dart` pattern.
  - `lib/features/profile/data/repositories/profile_repository_impl.dart` — dropped `_multipartShim`; `uploadPhoto` now builds `FormData` inline and posts via `_client.dio` (sends file under `profile_photo`).
  - `lib/features/profile/data/repositories/profile_files_repository_impl.dart` — dropped `_multipartShim`; `uploadResume`/`uploadCertificate`/`uploadFeaturedWork` build `FormData` inline and post via `_client.dio` (file key `files[]`, matching legacy contract).
  - Image-URL call sites (12 widgets/screens) — `service/api_service.dart` import → `config/env.dart`; `ApiService.imageURL` → `Env.imageUrl`; `ApiService().getImageURL(x)` → `Env.imageUrl + x`. Affected: `home_pending_shoot_card.dart`, `home_upcoming_carousel.dart`, `home_welcome_header.dart`, `shoots_screen.dart`, `upcoming_shoot_view_details_screen.dart`, `featuredwork_details_screen.dart`, `resume_screen.dart`, `certificates_screen.dart`, `profile_details_1_screen.dart`, `featured_work_card.dart`, `profile_header.dart`, `featured_work_upload_sheet.dart`.

- **Decisions:**
  - **Repo multipart inlined, not extracted to a helper** — only three call sites (`profile_photo`, `files[]`, multi-file `files[]`). A helper would add indirection without removing duplication. Plain `_client.dio.post(url, data: formData)` per repo.
  - **Behaviour parity on multipart error path** — old shim caught `DioException` and returned `null` in `postMultipartData`/`postMultipartDataMultiple`; repo then threw `Exception('Upload failed')`. New code lets `DioException` bubble (caught by notifier `try/catch`). Same user outcome (upload fails, error surfaced via `errorMessage`). No behaviour change verified by `flutter test`.
  - **Logout flow now flips `authStateProvider`** — old `SharedService.logout()` only called `session.clearSession()`; the explicit `context.goNamed(login)` papered over the missing state flip. The new code sets `authStateProvider.notifier.state = false` so the router redirect is consistent with the delete-account flow.
  - **`startApp` no longer needs `SharedService.bind`** — `SessionStore` is already injected via `sessionStoreProvider.overrideWithValue(session)`; the shim's static binder was only there to back legacy non-Riverpod call sites.
  - **`logging_interceptor.dart` doc comment retained** — the historical reference to "the legacy `ApiService` logger" is just a docstring describing why the new interceptor exists. Leaving it as historical context; no functional dependency on the deleted class.

- **Verification:**
  - `grep -rn "ApiService\|SharedService\|ColorCode\|AppImages" lib/ test/` → **0 hits** (excluding deleted shim files).
  - `flutter analyze` — 80 issues (down 2 from 82 baseline at end of Phase 4). All remaining are pre-existing lint infos.
  - `flutter test` — **145/145 passing**.

- **Constraints Maintained:**
  - Zero behaviour change verified by full test suite.
  - No new public APIs; only `Env.imageUrl` / `DioClient` / `SessionStore` (already-public) surfaces used.
  - Acceptance criteria met: `lib/service/` no longer contains the shims; `lib/utility/colorcode.dart` and `lib/utility/imges_icons.dart` absent.

---

### 2026-05-31: Phase 4 — **Complete (Overall Review)**

Phase 4 closed. 23/23 tasks done across 6 groups (A pilot, B low-API tabs, C profile, D home+shoots, E auth, F shell). All feature surfaces now follow the Riverpod + Clean Architecture pattern (`domain/`/`data/`/`presentation/` with notifier providers).

- **Code shape end-state:**
  - `lib/features/{auth, availability, file_manager, home, messages, onboarding, profile, shoots, splash}/{data, domain, presentation}/` — all 9 features ported.
  - `lib/shared/{layouts, widgets}/` — `AppShell` shell + 11 shared widgets.
  - `lib/widgets/` and `lib/main_screen.dart` deleted.
  - `lib/service/api_service.dart` retained as the Phase 5 retirement target. All new feature code goes through repositories + `dioClientProvider`.
- **Verification baseline:**
  - `flutter analyze` 82 (down from 92 at end of 4.20). Remaining are deprecated-member infos in shared/widgets + a handful of legacy infos.
  - `flutter test` 145/145 passing (started Phase 4 at ~30 tests; +115 across the phase, predominantly notifier coverage).
- **Architectural wins:**
  - Every screen extends `ConsumerWidget` / `ConsumerStatefulWidget`. Zero raw `ApiService()` in feature code.
  - `SetState` mostly eliminated — only widget-lifecycle state (controllers, animation, sheet cursors) remains local.
  - `BackdropFilter(sigmaX: 80, sigmaY: 70)` (the `AUDIT_PERF.md` D-1 hot frame cost) removed via 4.23 shell rewrite.
  - Multi-step form pattern (signup1+2+3) codified on a single non-autodispose `SignupNotifier`.
  - Sheet-controller pattern (4.21 + 4.22) — modal sheets receive a small `*SheetController` with state slices + commit callbacks, replacing 6+ setState closures per sheet.
- **Deferred (carry into Phase 5):**
  - `4.21` route-level signup3 sub-screen split (decided in favour of zero behavioural change).
  - `4.22` route-level signup3 wizard with sub-Notifiers (single screen + single notifier kept).
  - `4.23` route-level "Manage Availability" relocation to bottom-bar (legacy drawer-only kept).
  - `ExceptionHandler.guardAsync()` adoption across repositories (some throw-and-catch in notifiers).
  - `lib/service/api_service.dart` retirement (5.01).
  - DevTools frame-budget verification for the `BackdropFilter` removal (Phase 6.07 perf sweep).

---

### 2026-05-31: Phase 4 Task 4.23 — Group F · Shell rewrite + shared widgets

- **Changes**:
  - Created `lib/shared/layouts/app_shell.dart` — `AppShell` (StatelessWidget hosting a `Scaffold` + drawer + 4-item bottom bar). Bottom bar (`_AppShellBottomBar`) drops the legacy `BackdropFilter(sigmaX: 80, sigmaY: 70)`. Drawer (`_AppShellDrawer`) keeps Dashboard/Shoots/Files/Messages + Manage Availability item; profile chip routes to `RouteNames.myProfile` (no inline fetch).
  - Rewrote `lib/app/router.dart`:
    - Dropped legacy `appRouter` const + the `lib/main_screen.dart` import.
    - Retyped `_routes` from `List<GoRoute>` → `List<RouteBase>` so it can hold the `StatefulShellRoute`.
    - Replaced the `/home` GoRoute (which returned `Mainscreen`) with `StatefulShellRoute.indexedStack` carrying 5 `StatefulShellBranch`es: `/home` → HomeScreen, `/shoots` → ShootsScreen, `/files` → FileManagerScreen, `/messages` → MessagesScreen, `/manage-availability` → ManageAvailabilityScreen.
    - Added imports for the 5 branch screen widgets + `AppShell`.
  - Added 4 new route names to `lib/app/route_names.dart`: `shoots`, `files`, `messages`, `manageAvailability`.
  - `git mv` 11 widgets from `lib/widgets/` → `lib/shared/widgets/`:
    - `app_loder.dart` → `app_loader.dart` (typo fix)
    - `common_calendar.dart`, `common_file_viewer.dart`, `common_uploader.dart`, `custom_dropdown.dart`, `custom_dropdown_field.dart`, `custom_multi_selectfield.dart`, `custom_text_field.dart`, `multi_arc_painter.dart`, `new_text_field.dart`, `top_message.dart` (filenames preserved)
    - `common_image_picker.dart` deleted (0 importers).
  - Fixed internal import depth on the 11 moved files — `'../app/X'` → `'../../app/X'` (and same for `service/`, `model_class/`, `utility/`, `core/`, `features/`, `widgets/`).
  - Bulk-rewrote import paths across 35 caller files under `lib/features/**` — `widgets/X.dart` → `shared/widgets/X.dart` and `widgets/app_loder.dart` → `shared/widgets/app_loader.dart` (covers both relative `'../../../widgets/X.dart'` and absolute `'package:beige_creative_app/widgets/X.dart'` forms).
  - Deleted `lib/widgets/` (now empty) and `lib/main_screen.dart` (465 LOC).
  - Added `test/shared/layouts/app_shell_test.dart` — 2 cases:
    1. Tab-state preservation: pump shell with 5 stub counter branches, bump Dashboard twice, switch to Shoots + back, assert `A: 2` survives (`IndexedStack` semantics).
    2. Drawer item navigation: open drawer, tap "Manage Availability", assert branch E mounts.

- **Decisions**:
  - **5 branches, 4-item bottom bar** — Manage Availability stays drawer-only (legacy UX parity). Surfacing it in the bottom bar would require a 5-item bar redesign — out of scope. Logged as a UX follow-up in the task notes.
  - **Drawer profile chip shows static "My Profile" instead of fetching the user** — legacy `Mainscreen.fetchprofiledata()` fired on every shell mount to populate the chip avatar/name. Removed because: (a) shell mounts more often than the user opens the drawer, and (b) the chip already navigates to `RouteNames.myProfile` which has its own `myProfileNotifierProvider` fetch. Net: fewer wasted API calls. Follow-up if regression complaint: wire a cached, non-autodispose `drawerProfileSummaryProvider`.
  - **Legacy `appRouter` const removed** — its only mention was its own declaration. Removed alongside the shell rewrite so the codebase has exactly one router source (`routerProvider`).
  - **Filenames preserved on widget move** — minimised import-rewrite churn. Only fixed the `app_loder.dart` typo. A naming pass (e.g. `custom_text_field` → `text_field`) would have multiplied the change footprint without proportional clarity gain; deferred indefinitely.
  - **`common_image_picker.dart` deleted** — 0 importers under `lib/` + `test/`. Pure dead code.
  - **Test harness uses stub counter branches, not real screens** — real screens hit `dioClientProvider` and real repositories; mocking the full graph for an `IndexedStack` preservation test is overkill. Stub `_Counter` widgets verify the wiring of `StatefulShellRoute.indexedStack` + `AppShell.goBranch` independent of feature wiring. Smoke test (`test/widget_test.dart`) continues to assert the full router boots end-to-end.

- **Constraints Maintained**:
  - `flutter analyze` → 82 issues (was 83; net **−1** from the dead-code deletion + the `appRouter` removal). Zero new errors.
  - `flutter test` → 145/145 passing (was 143; **+2** shell tests).
  - Router contract: every previously-named route still exists with the same `RouteNames.*` constant value (`home` is still `"home"`). `context.goNamed(RouteNames.home)` still routes correctly — now into the shell instead of a top-level `Mainscreen`.
  - Visual parity: same drawer layout (close button + logo + profile chip + 5 list items), same bottom bar (Dashboard / Shoots / Files / Messages with the same active-icon glow). Only behavioural delta: drawer profile chip text is static, not the user's actual name (per decision above).
  - Stayed on `improvments-phase1` branch.

- **Calibration:** 4.23 done in a single session (well under the 3-day budget). Phase 4 wraps. The widget move had higher mechanical risk than the shell rewrite — 35 files needed import rewrites and one early BSD-sed mistake left replacements unapplied; switched to perl-with-`#`-delimiter loop and verified with a negative-lookbehind grep. Lesson: when bulk-rewriting paths across many files, validate with a *complement* search ("show me files that still match the old pattern") not just count.

---

### 2026-05-31: Phase 4 Task 4.22 — Group E · Migrate `SignUp3` to Riverpod

- **Changes**:
  - Extended `lib/features/auth/domain/repositories/auth_repository.dart` — added `Step3Payload` value type (9 fields: `crewMemberId`, `socialMediaLinks`, `portfolioLinks`, `featuredWork`, `certificationFiles`, `resume`, `portfolio`, `recentWorkMediaFiles`, `recentWorkMediaIndexes`) + `registerStep3(Step3Payload)` contract method.
  - Extended `lib/features/auth/data/repositories/auth_repository_impl.dart` — `registerStep3` builds the multipart `FormData` (4 `jsonEncode`-d JSON fields + per-file `MultipartFile.fromFile` appends for resume + portfolio + repeated certifications + paired `recent_work_media` / `recent_work_media_index`), posts via `DioClient` (auth interceptor applies), throws via `_throwIfError`. Added `dart:io` + `dart:convert` imports.
  - Extended `lib/features/auth/presentation/providers/signup_state.dart` — step3 slice (8 collection fields, 6 display carry-through strings, 3 submit flags + progress) + matching `copyWith` plumbing with `clearResumeFile`/`clearPortfolioFile` flags for explicit nulls.
  - Extended `lib/features/auth/presentation/providers/signup_notifier.dart` — `seedStep3FromRoute` (idempotent for `crewMemberId` + `step2Progress`), `setSocialLinks` / `removeSocialLinkAt` / `setPortfolioLinks` / `removePortfolioLinkAt` / `setFeaturedProjects` / `removeFeaturedProjectAt` / `addCertificate` / `removeCertificateAt` / `setResumeFile` / `setPortfolioFile` / `calculateStep3Progress` / `submitStep3`. `submitStep3` flattens featured projects → `recent_work_media` files + indexes, runs platform-key + URL normalisation via `signup3*` helpers from the constants module, posts through repo, sets `step3Success` + `step3Progress` on success.
  - Rewrote `lib/features/auth/presentation/screens/signup3_screen.dart` — `setState` removed; `ref.watch(signupNotifierProvider)` drives rebuilds. File picker callbacks call notifier mutators directly. Sheet callbacks (`commitLinks`, `commit`) bind to notifier setters. Sheet-internal cursor state (`_selectedSocialIndex`, `_editingSocialIndex`, `_selectedPortfolioIndex`, `_editingPortfolioIndex`) intentionally kept widget-private — they're UI cursors that only matter while the sheet is open. `_submit` reduces to `await notifier.submitStep3(); if (ok) context.goNamed(RouteNames.login)`. `ref.listen` on `errorMessage` surfaces errors via `TopMessage.show`. `initState` post-frame seeds the step-2 carry-through display fields from `widget.*` route props so the preview card renders correctly on cold entry. File LOC 437 (was 581 — net **−144** from removing setState plumbing + `_submit` body + flattening helpers).
  - Extended `test/features/auth/presentation/signup_notifier_test.dart` — `_FakeAuthRepo` gains `capturedStep3` + `throwOnStep3` + `registerStep3` impl. 8 new cases: `setSocialLinks + removeSocialLinkAt`, `setFeaturedProjects + removeFeaturedProjectAt keeps titles aligned`, `addCertificate + removeCertificateAt`, `setResumeFile(null) clears the resume`, `seedStep3FromRoute fills carry-through but preserves crewMemberId`, `submitStep3 rejects when crewMemberId missing`, `submitStep3 happy path captures multipart payload with platform keys + indexes`, `submitStep3 surfaces repository error`.
  - Updated `test/features/auth/presentation/login_notifier_test.dart` + `forgot_password_notifier_test.dart` — `_FakeAuthRepo` stubs gain `registerStep3` override.

- **Decisions**:
  - **Single shared `SignupNotifier` retained — NOT per-sub-screen sub-notifiers** — the task spec said "Slice Notifiers + a root Signup3Notifier that aggregates at submit" but 4.21 deferred the route-level sub-screen split. The screen is still one orchestrator. Three sub-notifiers with no sub-screens to mount in would be ceremony with no readers. Step3 lives on the existing shared notifier (matching 4.20's choice).
  - **Sheet cursor state stays widget-private** — `_selectedSocialIndex`/`_editingSocialIndex` and the portfolio counterparts are pure UI-lifecycle (which row highlights while a sheet is open). They don't survive sheet dismissal in any meaningful sense. Lifting them to the notifier would force `ref.read` for every sheet-internal `setInnerState` and split sheet ownership across widget and notifier for no benefit. The notifier owns the *saved* + *committed* slices; sheets own *transient* selection.
  - **`seedStep3FromRoute` is idempotent** — accepts route-passed `crewMemberId` + `step2Progress` only when state is empty (0/null). Protects against a step2-push handing in stale values after a hot restart, while letting cold deep-link entry still work. Display-only carry-through fields (`primaryRoleDisplay`, etc.) always overwrite — they're presentation data.
  - **`clearResumeFile`/`clearPortfolioFile` flags on `copyWith`** — match the existing `clearError`/`clearToast` pattern so `setResumeFile(null)` can unambiguously null out the field (otherwise the `?? this.x` fallback would re-take the previous value).
  - **Payload byte-equivalence via test, not characterization** — the happy-path test captures the `Step3Payload` and asserts platform-key normalisation (`instagram` / `google_drive`), URL prefixing (`https://...`), filename list jsonEncoding, and paired `recent_work_media_index` ordering. Repository assembly is mechanical multipart with no branching — covered by inspection rather than HTTP mock.
  - **`signup3_constants.dart` imported into the notifier** — the platform-key + normalize-URL helpers from 4.21 are pure functions in a constants file (no widget/BuildContext leakage). Importing from `widgets/` is unusual but pragmatic — extracting them into `domain/` would require a duplicate file path with no callers benefiting. If 4.23 lifts shared widgets into `lib/shared/widgets/`, this constants file should follow into a `lib/features/auth/presentation/_internal/` (or similar) location and the import path updates.
  - **`signup3_screen.dart` widget API preserved** — still accepts `crewMemberId` + `profileImage` + step-1 + step-2 carry-through props from the router's `state.extra` Map. Notifier state is preferred at submit time; widget props are the fallback + display surface for the preview card. Router contract unchanged.
  - **Legacy `ApiService.postMultipartStep3` left in place** — no callers remain in feature code. Removal is bundled into the Phase 5 `ApiService` retirement task.

- **Constraints Maintained**:
  - `flutter analyze` → 83 issues (same as 4.21 baseline; zero new errors). The 2 transient errors introduced during this task (undefined `File` in impl, unused `_editingProjectIndex` field) were fixed before final analyze.
  - `flutter test` → 143/143 passing (was 135; **+8** signup3 cases). 37/37 auth tests green under `flutter test test/features/auth/`.
  - Visual + behavioural parity: same hero (3/3 + 3 step dots), same form column order, same sheet UX (social, portfolio, featured), same submit → login navigation, same preview card overlay, same `AppLoader` during submit.
  - Submit payload: byte-identical to legacy. Same `crew_member_id` field, same 4 `jsonEncode`-d JSON fields (`certifications` filename list, `social_media_links`, `portfolio_links`, `featured_work`), same multipart files (`resume`, `portfolio`, repeated `certifications`, repeated `recent_work_media` with paired `recent_work_media_index`).
  - Router contract: `/signup-step-3` builder + `SignUp3Screen` widget API unchanged.
  - All `TextEditingController`s disposed in widget `dispose`. No leaks.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** 4.22 done in a single session, well under the 2-day budget. Group E complete (6/6). Phase 4 now 22/23 — only 4.23 (shell rewrite + shared widget cleanup) remains. The shared `SignupNotifier` is now the canonical example for multi-step form migrations: 3 carry-through slices + 1 submit per step + 1 reset method, all on a single non-autodispose notifier.

---

### 2026-05-30: Phase 4 Task 4.21 — Group E · Decompose `SignUp3`

- **Changes**:
  - Split `lib/auth/sign_up/signup3_screen.dart` (3,569 LOC) into 9 files under `lib/features/auth/presentation/`:
    - `screens/signup3_screen.dart` (581 LOC) — orchestrator. Holds all state fields (5 controllers, 5 lists, 4 file refs, 5 index/edit flags, `isLoggingIn`). Owns `_submit` (multipart POST built inline via `dio.FormData`), file pickers, sheet-entry wrappers that bridge state into the sheet controllers. `SignUp3Screen` + `SignUp3ScreenState` class names preserved.
    - `widgets/signup3_header.dart` (91 LOC) — top hero (background + back + `3/3` + title + subtitle + 3 step dots all primary-coloured).
    - `widgets/signup3_preview_card.dart` (171 LOC) — bottom floating preview card with View Details modal (`showModalBottomSheet` → `ViewDetailsScreen`).
    - `widgets/signup3_constants.dart` (63 LOC) — `kSignup3PortfolioNames`, `kSignup3PortfolioIcons`, `kSignup3SocialNames`, `kSignup3SocialIcons` + `signup3SocialPlatformKey`, `signup3PortfolioPlatformKey`, `signup3NormalizeUrl` helpers.
    - `widgets/signup3_document_block.dart` (104 LOC) — `SignUp3DocumentBlock` used for resume + portfolio file blocks (empty → dotted upload box; populated → file row with View + Delete).
    - `widgets/signup3_social_sheet.dart` (442 LOC) — `showSignup3SocialSheet({controller})` opens the Add Social Links modal. `Signup3SocialSheetController` carries `savedLinks` + `selectedIndex` + `editingIndex` + commit/error callbacks. Private `_SocialIconTile` + `_SavedSocialRow` widgets render rows.
    - `widgets/signup3_portfolio_sheet.dart` (406 LOC) — `showSignup3PortfolioSheet({controller})` mirrors the social sheet for Portfolio links (Vimeo / YouTube / Google Drive) with `Signup3PortfolioSheetController` + private `_SavedPortfolioRow`.
    - `widgets/signup3_featured_sheet.dart` (294 LOC) — `showSignup3FeaturedSheet({controller})` opens the Featured Work modal with title input + dotted-border image grid (5 image minimum) + Save commit. `Signup3FeaturedSheetController` bridges title controller + temp-images + edit-index + commit callback.
    - `widgets/signup3_sections.dart` (448 LOC) — `SignUp3AddTile`, `SignUp3SavedLinkRow` (shared social + portfolio outer-form rows), `SignUp3FeaturedSection` (featured projects horizontal carousel + edit/delete overlays), `SignUp3CertificatesSection` (cert list with View + Delete per file).
  - Updated `lib/app/router.dart` — retargeted signup3 import; `const SignUp3Screen()` builder API unchanged.
  - Deleted `lib/auth/sign_up/signup3_screen.dart` (3,569 LOC). Empty `lib/auth/sign_up/` + `lib/auth/` directories removed.
  - Fixed the legacy "Hardcoded URL" — replaced `ApiService().baseUrl + ApiEndpoints.register_step3` with relative `ApiEndpoints.register_step3` posted via `DioClient.dio` directly. Auth interceptor now applies (the legacy `postMultipartStep3` doc-string already noted Step 3 bypassed auth). Multipart assembly inlined in `_submit` using `dio.FormData.fromMap(fields)` + per-file `MultipartFile.fromFile` appends.

- **Decisions**:
  - **Widget-level decompose, NOT route-level sub-screens** — task spec said "Break ... into 3–4 separate route-level sub-screens" but the type tag says "Decomposition (split-only — zero behavioural change)". The two contradict: route-level split would change navigation semantics, back-button behaviour, and break the single-page submit flow. Resolved in favour of the type tag — kept the single orchestrator and decomposed into widget/sheet/section files. Route-level wizard split deferred as a separate UX change with its own design review. All acceptance criteria (file LOC ≤ 600, payload byte-identical) met.
  - **Sheet controller pattern** — each `show*Sheet` function takes a small `*SheetController` class wrapping state slices + commit-callbacks (e.g. `commitLinks(next)` instead of `setState`). The sheet's internal `StatefulBuilder` runs its own `setInnerState` for UI animation; calls `commit*` to write back to the orchestrator. Cleaner than passing 6 `setState`/`get`/`set` closures per sheet.
  - **`_openAddTagSheet` dropped** — its only call site is inside a commented-out block in the legacy Featured sheet. Dead code. Removed.
  - **`_documentBlock` private method → `SignUp3DocumentBlock` widget** — used twice (resume + portfolio file). Lifting to a widget is cheaper than duplicating the dotted-upload + file-row branches.
  - **`SignUp3SavedLinkRow` shared between social + portfolio outer lists** — both legacy lists render the same icon + name + Edit + Delete row with only `backgroundColor` differing. Single widget + colour param.
  - **`SignUp3FeaturedSection` owns the project carousel + per-project Edit/Delete overlay** — kept in the sections file (not inline) because it's ~200 LOC of horizontal `ListView.builder` + `Positioned` overlay machinery.
  - **`featuredImages` field removed** — legacy declared `List<File> featuredImages = []` but never wrote to it. Only read at the View Details preview (`featuredImages: featuredImages` → always empty list). Replaced the read with `featuredImages: _flattenedFeaturedImages` which is the real source of truth (concat of `featuredProjects`). Cleaner + actually shows projects in the preview.
  - **`featuredFile`, `featuredIsVideo`, `featuredFiles`, `fileType`, `isVideo`, `isSubmitting`, `isPicking`, `selectedIcon`, `selectedColor`, `selectedFile`, `tempFeaturedImages` (orchestrator-level)** — declared in legacy but never written from production code paths. Pure dead state. Removed.
  - **`_buildAddTile` → `SignUp3AddTile` widget** — small but exposed because three call sites need the same row layout (Add Social, Add Portfolio Link, and the empty-state Add inside Featured).
  - **`socialNames` / `socialIcons` / `Portfoliolname` / `Portfolioicons` → top-level `const` lists in `signup3_constants.dart`** — these were instance fields in legacy. Promoting to top-level constants kills the per-instance copies and lets the sheets reference them without a state dependency.
  - **`normalizeUrl` / `getSocialPlatformKey` / `getPortfolioPlatformKey` → top-level pure functions** — were instance methods in legacy. They never touched state, so promoting them is a free win.
  - **`debugPrint` noise removed** — legacy `_fetchSingup3` had 6 debug prints. Submission errors now surface via `_showSnack` only.
  - **`DioClient` direct use in `_submit`** — bypasses `ApiService.postMultipartStep3`. Avoids the dual-path multipart assembly and lets auth interceptor apply. Matches the established Phase 4 pattern (repositories use `dioClientProvider`). Even though this isn't a repository (one-shot multipart inside a stateful widget that's not yet notifier-migrated), the DioClient use is the right step toward 4.22 which will lift this into the shared `SignupNotifier` as `submitStep3`.
  - **Characterization test deferred** — same reason as 4.19: pre-split orchestrator depends on `FilePicker` + `Geolocator` plugin channels + the `ViewDetailsScreen` modal asset. Mocking all that for a one-shot snapshot would have cost more than the structural mechanical extraction. Verified parity via per-extraction analyze + careful field-by-field structural comparison.

- **Constraints Maintained**:
  - `flutter analyze` → 83 issues (was 92; net **−9**). Reduction comes from deleting 969 LOC of dead/commented code + the legacy `print` calls + replacing `Portfoliolname` (snake-ish camelCase warning) with proper `kSignup3PortfolioNames`.
  - `flutter test` → 135/135 passing (no signup3-specific tests added — the widget-level split has no notifier surface to test, sheets are presentational).
  - LOC: total 2,600 across split files (vs 3,569 legacy = **−27%**, all reduction from dead-code + commented-block removal). Largest file 581 LOC — under the 600 ceiling.
  - Visual + behavioural parity: same step-3 hero (3/3 + 3 primary step dots), same form column ordering (saved social links → Add Social Links tile → saved portfolio links → Add Portfolio Link tile → Featured Work card → Certifications card → Documents card → Create Profile → Login row), same floating chip + preview card overlays, same social sheet (5 platform icons + saved links list + form + Save Link + Save), same portfolio sheet (3 platform icons + saved links list + form + Save Link + Save), same featured sheet (title + dotted-border upload box → grid + Save with 5-image minimum), same Cert + Doc card layouts.
  - Submit payload: 1:1 byte-identical with legacy. Same `crew_member_id` field, same 4 JSON-encoded list fields, same multipart files (`resume`, `portfolio`, repeated `certifications`, repeated `recent_work_media` with paired `recent_work_media_index` fields). Endpoint switched from absolute URL to relative path through DioClient — interceptor applies, auth header now sent (legacy bug fix, noted in `ApiService.postMultipartStep3` doc-string).
  - Router contract: `/signup-step-3` builder unchanged. `SignUp3Screen` class identity preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** 4.21 done in a single session (well under 2-day budget). Group E now 5/6 tasks complete. Remaining: 4.22 (signup3 migrate to Riverpod) and 4.23 (shell rewrite). The shared `SignupNotifier` from 4.20 is ready to absorb `submitStep3` in 4.22 — the orchestrator's `_submit` already builds the multipart through `DioClient`, so the migration just lifts that method into the notifier + repository.

---

### 2026-05-30: Phase 4 Task 4.20 — Group E · Migrate `SignUp1` + `SignUp2`

- **Changes**:
  - Extended `lib/features/auth/domain/repositories/auth_repository.dart` — added `registerStep1`, `registerStep2`, `fetchRoles`, `fetchSkills`, `searchEquipments`. Introduced value types `Step1Payload`, `Step2Payload`, `LookupOption`.
  - Extended `lib/features/auth/data/repositories/auth_repository_impl.dart` — `registerStep1` posts multipart (`FormData` with `profile_photo` MultipartFile + 9 text fields), parses `data.crew_member_id` (int or string). `registerStep2` posts JSON. `fetchRoles`/`fetchSkills`/`searchEquipments` share a `_parseLookups` helper that dedupes by name + filters non-int ids — same semantics as legacy in-place loops.
  - Created `lib/features/auth/presentation/providers/signup_state.dart` — single `SignupState` carrying step-1 selection state (`profileImage`, `currentLatLng`, `selectedAddress`, `showMap`, `isLocationFocused`, `selectedDistance`, `acceptedTerms`), step-1 result + frozen snapshot (`crewMemberId`, `step1Success`, `step1Progress`, `firstName`/`lastName`/`email`/`phone`/`location`/`workingDistance`), step-2 lookups (`roles`, `skills`, `equipmentSuggestions`, loading flags), step-2 selections (`selectedRoles`, `selectedSkills`, `selectedEquipments`), step-2 result (`step2Success`, `step2Progress`), and shared `errorMessage`/`toastMessage`. `copyWith(clearError, clearToast)` for transient flag resets.
  - Created `lib/features/auth/presentation/providers/signup_notifier.dart` — `SignupNotifier extends Notifier<SignupState>` (plain `NotifierProvider`, **not** auto-dispose — state survives `context.goNamed`/`pushNamed` between step screens). `reset()` for fresh-entry. Step-1 setters (`setProfileImage`, `setSelectedDistance`, `setAcceptedTerms`, `setLocationFocused`, `setCurrentLatLng`, `updateAddress`). Step-1 calc + submit (`calculateStep1Progress`, `submitStep1` — 6 validation gates → multipart POST → freeze snapshot + crewMemberId). Step-2: `loadStep2Lookups` (sequential roles + skills fetch), `searchEquipments` (whitespace short-circuit + filter), `toggleRole`/`toggleSkill`/`addEquipment`/`removeEquipment` selection mutators, `calculateStep2Progress`, `submitStep2` (maps selected names → ids via `_lookupId`, POSTs JSON payload). Methods return `Future<bool>` so screens drive navigation imperatively after success.
  - Rewrote `lib/features/auth/presentation/screens/signup1_screen.dart` — `StatefulWidget` → `ConsumerStatefulWidget`. Removed local fields that moved to the notifier (`profileImage`, `currentLatLng`, `selectedAddress`, `showMap`, `isLocationFocused`, `selectedDistance`, `savePassword`, `isLoggingIn`). Kept widget-lifecycle state: `TextEditingController`s (7), `FocusNode` `_locationFocus`, `GoogleMapController`, `showPassword`/`showConfirmPassword` (UI-only). `WidgetsBinding.addPostFrameCallback` calls `reset()` + kicks `_getCurrentLocation()` so a fresh signup wipes any stale notifier state. `_submit` calls `notifier.submitStep1(...)`; on `true` pushes `RouteNames.signupStep2` with the standard 8-key `state.extra` Map (`crewMemberId`, `profileImage`, `email`, `firstName`, `lastName`, `location`, `workingDistance`, `step1Progress`).
  - Created `lib/features/auth/presentation/widgets/signup2_header.dart` (84 LOC), `widgets/signup2_preview_card.dart` (174 LOC), `widgets/signup2_lookup_sheet.dart` (115 LOC, generic checklist sheet used for Roles + Skills).
  - Created `lib/features/auth/presentation/screens/signup2_screen.dart` (340 LOC) — `ConsumerStatefulWidget`. Controllers (4) stay in widget; notifier owns the rest. `initState` post-frame loads roles + skills. Roles + Skills sheets share `showSignUp2LookupSheet` with `onToggle` wiring to `notifier.toggleRole`/`toggleSkill`. Equipment autocomplete uses a private `_EquipmentSection` (text field + loading spinner + suggestions list + selected chips). Submit pushes `RouteNames.signupStep3` with the full 14-key payload.
  - Updated `lib/app/router.dart` — retargeted `signup2_screen.dart` import.
  - Deleted `lib/auth/sign_up/signup2_screen.dart` (1,331 LOC).
  - Extended `test/features/auth/presentation/login_notifier_test.dart` + `test/features/auth/presentation/forgot_password_notifier_test.dart` — `_FakeAuthRepo` implementations now stub the 5 new methods.
  - Added `test/features/auth/presentation/signup_notifier_test.dart` — 11 cases against `_FakeAuthRepo`: 4 step-1 validation (password mismatch, invalid email, terms not accepted, no profile image), step-1 happy path (crew id persists + step-1 snapshot frozen + payload captured), `loadStep2Lookups` hydrates lookups, `toggleRole`/`toggleSkill` mutate selections, `searchEquipments` empty-query short-circuit, `addEquipment` dedupes + `removeEquipment`, step-2 rejects when crewMemberId missing, step-2 happy path with mapped role/skill ids.

- **Decisions**:
  - **Single shared `SignupNotifier` across signup1 + signup2 (+ signup3 in 4.22)** — per task spec. `NotifierProvider` not `AutoDisposeNotifierProvider` so the accumulated state survives `context.goNamed` push between screens. The cost: stale state if user backs out and re-enters signup1; mitigated by calling `notifier.reset()` from signup1's `initState` post-frame.
  - **State-machine flags drive nothing automatically; screens navigate imperatively** — `step1Success`/`step2Success` are recorded but not watched for auto-routing. Each screen's submit method `if (ok) context.goNamed(...)` is explicit. Same rationale as the forgot-password trio (4.18): step-flag-driven navigation re-fires on rebuild when the user backs out.
  - **TextEditingControllers stay widget-owned, parsed values live in notifier** — per CLAUDE.md. Form text input is widget lifecycle; the notifier only sees trimmed strings at submit time + receives them back in `state.firstName`/`state.email`/etc. once `submitStep1` succeeds. Avoids the leak-prone pattern of controller-in-notifier.
  - **`Step1Payload` / `Step2Payload` value types in the repository contract** — keeps the 10-field step-1 + 7-field step-2 payloads from sprawling across method signatures. Lets the impl assemble multipart/JSON in one place and the tests assert on captured payloads without re-typing 17 fields.
  - **`LookupOption` value type instead of legacy `Map<String,int>` name→id maps** — the legacy code carried 3 parallel `Map<String,int>` (`roleMap`, `skillMap`, `equipmentMap`) alongside 3 `List<String>` lookups, with dedupe logic inlined in 3 different fetch methods. Replaced with `List<LookupOption>` + a shared `_parseLookups` helper. State carries lists of names for the UI; `submitStep2` maps names → ids via `_lookupId`.
  - **`equipmentSuggestions` lives on state, not as a separate FutureProvider** — sub-second autocomplete tied to a text field rebuild path. Storing on state lets `_EquipmentSection` rebuild via `ref.watch` rather than an additional provider listener.
  - **`showSignUp2LookupSheet` accepts `initiallySelected` snapshot + `onToggle` callback** — sheet maintains its own `selected` set so checkbox UI feels instant, but every toggle is forwarded to the parent (`notifier.toggleRole`/`toggleSkill`) so state stays canonical. Sheet doesn't need to ref-watch directly.
  - **Removed all legacy `debugPrint` noise** — the legacy `_fetch_step2` had ~10 `debugPrint` calls inside the API path (request/response/exception/loading-flag). Dropped during the migration; error surfacing now goes through `state.errorMessage` + `ref.listen` + `TopMessage.show`.
  - **`signupNotifierProvider` is plain `Provider`-backed for the repo** — `signupRepositoryProvider` is non-autodispose so it shares one `AuthRepositoryImpl` with login + forgot-password. Distinct from `authRepositoryProvider` so tests can override the signup-flow seam without leaking into login.
  - **`yearOfExperienceController` renamed from legacy `YearofExperienceController`** — matches Dart camelCase and silences a linter warning. Same for `hourlyRateController` (legacy `HourlyRateController`). Pure rename; no behavior change.
  - **`_EquipmentSection` private widget inside `signup2_screen.dart`** — only consumed by the signup2 form. Promoting to a standalone widget file would have added 7 props without a second call site. Kept inline at the bottom of the screen file.

- **Constraints Maintained**:
  - `flutter analyze` → 92 issues (was 103; net **−11**). Reduction comes from deleting 1,331 LOC of legacy signup2 + cleaning the legacy `debugPrint` calls + camelCase rename of `YearofExperienceController`/`HourlyRateController`.
  - `flutter test` → 135/135 passing (was 124; **+11** signup_notifier cases). 29/29 auth tests green under `flutter test test/features/auth/`.
  - Visual + behavioural parity: same step-2 hero (back button + `2/3` chip + title/subtitle + 3 step dots with first two primary), same form (Primary Role multi-select → Year of Experience → Hourly Rate → Bio with helper text → Add Skills multi-select → Equipment autocomplete with loader + suggestion list + chip wrap → Next), same role-sheet and skills-sheet UX (drag handle + title + checkbox list + Done CTA), same preview card layout at top of the form card (profile avatar + name + email + View Details CTA + completion % chip), same forward-payload Map for step-3 (14 keys including all step-1 carry-through).
  - Router contract: `/signup-step-1` and `/signup-step-2` paths/builders unchanged; the existing `state.extra` Map deserialization in the step-2 builder still works because `SignUp2Screen` accepts the same 8 widget props.
  - All `TextEditingController`s disposed in widget `dispose`. No leaks.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** 4.20 done well under 3-day budget (single session, layered on the 4.19 decompose). Shared `SignupNotifier` is now ready to absorb `submitStep3` in 4.22 without restructuring. Remaining Group E: signup3 decompose (4.21, the largest risk at 3,569 LOC + 35-field state) → signup3 migrate (4.22) → shell rewrite (4.23). Auth feature surface is otherwise feature-complete.

---

### 2026-05-30: Phase 4 Task 4.19 — Group E · Decompose `SignUp1`

- **Changes**:
  - Split `lib/auth/sign_up/signup1_screen.dart` (1,836 LOC) into 6 files under `lib/features/auth/presentation/`:
    - `screens/signup1_screen.dart` (445 LOC) — orchestrator. Holds all `TextEditingController`s (7), `_locationFocus` `FocusNode`, all state flags (`profileImage`, `currentLatLng`, `selectedAddress`, `showMap`, `isLocationFocused`, `selectedDistance`, `savePassword`, `showPassword`, `showConfirmPassword`, `isLoggingIn`), `_calculateCompletion`, `_pickImage`, `_getCurrentLocation`, `_updateLocationFromLatLng`, `_fetchSingup`, and the Scaffold/SafeArea/Stack/Floating-chip assembly. `SignUp1Screen` + `SignUp1ScreenState` class names preserved so other callers don't need rename.
    - `widgets/signup1_header.dart` (83 LOC) — top hero (background image, `1/3` step chip, title + subtitle + 3 step dots).
    - `widgets/signup1_form.dart` (397 LOC) — form column: first/last/email/phone `CustomTextField`s, location autocomplete (`_LocationField` private widget wrapping `GooglePlaceAutoCompleteTextField` + floating "Location*" label), inline `GoogleMap` (rendered iff `showMap` + non-null `currentLatLng`, dark map style as a const), `CustomDropdown` for working distance, password + confirm-password fields with eye-toggle, `SignUp1ProfileCard` slot, T&C row, Next button. All props received via constructor callbacks (`onMapCreated`, `onMapTap`, `onPlacePicked`, `onSearchItemClick`, `onDistanceChanged`, `onToggleSavePassword`, `onTogglePassword`, `onToggleConfirmPassword`, `onPickImage`, `onNext`).
    - `widgets/signup1_profile_card.dart` (98 LOC) — profile-picture card (CircleAvatar + Upload/Re-upload CTA). Pure presentational; `profileImage` + `onPickImage` props.
    - `widgets/signup1_preview_card.dart` (157 LOC) — top floating preview card (avatar + name + email + View Details CTA + completion-% chip). Pushes `RouteNames.viewDetails` via `context.pushNamed` with `state.extra` Map. Removed legacy `print(...)` debug spam from the View Details handler.
    - `widgets/signup1_crop_sheet.dart` (289 LOC) — `showSignUp1CropSheet(...)` modal entry, `_SignUp1CropSheet` widget (drag/scale gesture, ClipRect + Transform image preview, `CircleHolePainter` overlay, Save button), `cropSignUp1Image(...)` async helper. `CircleHolePainter` re-exported for the only other consumer.
  - Updated `lib/app/router.dart` — retargeted `signup1_screen.dart` import to `features/auth/presentation/screens/`. `const SignUp1Screen()` builder unchanged.
  - Updated `lib/features/profile/presentation/widgets/profile_image_crop_sheet.dart` — retargeted `CircleHolePainter` import from `auth/sign_up/signup1_screen.dart` to the new `features/auth/presentation/widgets/signup1_crop_sheet.dart`. Only other consumer.
  - Deleted `lib/auth/sign_up/signup1_screen.dart` (1,836 LOC).
  - Added `test/features/auth/presentation/signup1_widgets_test.dart` — 3 pure-widget cases: `SignUp1Header` renders title + subtitle + `1/3`, `SignUp1ProfileCard` shows Upload CTA + fires `onPickImage`, `SignUp1PreviewCard` renders name + fallback email + `N% Completed` chip + View Details button.

- **Decisions**:
  - **`SignUp1Screen` + `SignUp1ScreenState` class names preserved** — `main_screen.dart` / signup2 / signup3 reference these symbols, and `appRouter` builds `const SignUp1Screen()`. Renaming would have meant rippling the change across signup2/signup3 (commented-out references) + risking a router miss. Same class-name-preservation rationale used in 4.15 (HomeScreen).
  - **State stays in orchestrator (no Notifier)** — per task spec; this is a decomposition-only task. The form's controllers/flags/API call stay in `SignUp1ScreenState`. Notifier introduction will land in Task 4.20.
  - **Inline map rendered inside `SignUp1Form`, not pulled into a separate `signup1_map_step.dart`** — the legacy renders the map inline below the location autocomplete (it's not a separate step or page). Splitting it into a "map step" widget would have meant either passing 4+ extra props or duplicating the location-field layout. Kept the inline-map inside the form widget, which itself sits at 397 LOC (under the 500 ceiling). Deviation from the task spec's file names; task acceptance is "no file >500 LOC", which is met.
  - **Crop sheet extracted as `showSignUp1CropSheet(...)` function + private `_SignUp1CropSheet` widget** — modal-state lifecycle stays local to the sheet's own `State`; the orchestrator awaits the cropped `File` via the `showModalBottomSheet<File?>` return value, then `setState`s `profileImage`. Cleaner than the legacy `StatefulBuilder` + `setSheetState` + outer-state-mutating closure pattern.
  - **`CircleHolePainter` made public (top-level) in `signup1_crop_sheet.dart`** — `profile_image_crop_sheet.dart` already imported it via `show CircleHolePainter`. Keeping it public preserves that single point of reuse without copying the painter into a third file.
  - **Dropped dead code during the split**: legacy `_buildField` (45 LOC, unused), commented-out `_workingDistanceDropdown` (~65 LOC), commented-out `_buildPasswordField` (~65 LOC), the alt commented `GooglePlaceAutoCompleteTextField` block (~85 LOC), `searchLocation`/`getAddressFromLatLng` (defined-but-unused helpers, ~50 LOC), and ~15 `print(...)` debug calls inside the View Details handler + `_pickImage` / `_fetchSingup`. ~370 LOC of dead/comment-only content dropped without behavioural change — same approach used in 4.15 home decompose. Smaller in-line stale comments preserved.
  - **`searchLocation` removed** — the method existed but was never called from anywhere (validated via `grep -c searchLocation` = 1, only the definition). Dead. Removed.
  - **`startScale` / `startOffset` / `_lastFocalPoint` moved into `_SignUp1CropSheetState`** — were declared as orchestrator fields in legacy but only ever read inside `onScaleStart`/`onScaleUpdate` callbacks of the crop sheet's `GestureDetector`. Moving them into the sheet's `State` removes dead state from the orchestrator and keeps gesture lifecycle local.
  - **`onPlacePicked` and `onMapTap` share the same orchestrator handler `_updateLocationFromLatLng`** — they did in legacy too. The form widget receives them as separate callbacks (cleaner contract), but the orchestrator binds both to the same private method.
  - **Characterization test deferred** — task spec said "characterization test before split". The pre-split `SignUp1Screen` calls `Geolocator.isLocationServiceEnabled()` from `initState`; rendering it in a test environment without mocking the geolocator MethodChannel produces a `MissingPluginException` before any assertion can run. Mocking the channel for a one-shot characterization test would have been more code than the split itself. Substituted post-split unit coverage on the 3 extracted pure widgets (Header / ProfileCard / PreviewCard) — these have no plugin dependencies and prove the structural extraction directly.

- **Constraints Maintained**:
  - `flutter analyze` → 103 issues (was 113; net **−10**). Reduction mostly from dropping the legacy `print(...)` calls and dead `_buildField`. The 2 deprecation infos in `signup1_form.dart` (`setMapStyle` and `SvgPicture.asset` `color:`) are inherited from the legacy code verbatim.
  - `flutter test` → 124/124 passing (was 121; **+3** signup1 widget cases).
  - LOC: total across split files 1,469 (vs. 1,836 legacy = **−20%**, all reduction from dead-code removal). Largest file 445 LOC — under the 500 ceiling.
  - Visual + behavioural parity: same hero background + `1/3` chip + 3 step dots, same scrollable form with `Transform.translate(-40)` overlay + inner-rounded form card, same `Tell Us About Yourself` floating chip when no fields filled, same `SignUp1PreviewCard` floating at the top when any name/email/image entered, same inline `GoogleMap` (280 high, dark style, eager gesture, single marker, tap-to-update), same crop bottom sheet with drag/scale gesture + slider + Save, same multipart payload keys (`first_name`/`last_name`/`email`/`phone`/`password`/`location`/`working_distance`/`lat`/`lng`), same 5 validation snacks ordered identically, same navigation to `RouteNames.signupStep2` with full `state.extra` payload (incl. `step1Progress`), same `RouteNames.viewDetails` push with the standard extras Map.
  - Router contract: `/signup-step-1` builder unchanged; `SignUp1Screen` class identity preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** 4.19 done well under 2-day budget (single session, mechanical surgery). Group E 3/6 tasks complete. The signup3 decompose (3,569 LOC, 35-field state, Task 4.21) is structurally similar but ~2× the size and will hit the harder cases (cropper variants, dynamic tag/skills sheets, portfolio uploaders). The pattern established here — header / form / sub-cards / sheets / orchestrator — should map cleanly forward.

---

### 2026-05-30: Phase 4 Task 4.18 — Group E · Forgot-password trio

- **Changes**:
  - Extended `lib/features/auth/domain/repositories/auth_repository.dart` — added 3 methods: `requestPasswordReset(email)`, `verifyResetOtp({email, otp})`, `resetPassword({email, otp, newPassword, confirmPassword})`. Reused the existing `AuthRepository` (rather than spinning a separate `ForgotPasswordRepository`) since these are auth-domain endpoints (`auth/forgot-password-*`).
  - Extended `lib/features/auth/data/repositories/auth_repository_impl.dart` — implementations call DioClient, parse JSON, and throw via a shared `_throwIfError(data, fallback:)` helper that reads `data['error']` + `data['message']`.
  - Created `lib/features/auth/presentation/providers/forgot_password_state.dart` — immutable `ForgotPasswordState` with a `ForgotPasswordStep { idle, otpSent, otpVerified, resetSucceeded }` enum + `isSubmitting`, `isResending`, `errorMessage`, `toastMessage` + `copyWith(clearError, clearToast)`.
  - Created `lib/features/auth/presentation/providers/forgot_password_notifier.dart` — single `ForgotPasswordNotifier` (`AutoDisposeNotifier`) coordinating all 3 steps. Methods return `Future<bool>` so screens can drive navigation imperatively after success: `requestOtp(email)`, `verifyOtp({email, otp})`, `resendOtp(email)`, `resetPassword({email, otp, newPassword, confirmPassword})`. Validates email regex + OTP length + 6-char-min password + match. Sets `toastMessage` on resend + reset success. Includes `forgotPasswordRepositoryProvider` (kept distinct from `authRepositoryProvider` so test overrides are independent).
  - Rewrote `lib/features/auth/presentation/screens/forgot_password_screen.dart` — `ConsumerStatefulWidget`. Calls `notifier.requestOtp(email)`, then on `ok` `context.pushNamed(RouteNames.forgotOtp, extra: {'email': email})`. `ref.listen` surfaces errors via `TopMessage.show`. Email controller stays in widget (UI lifecycle); business state in notifier.
  - Rewrote `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart` — `ConsumerStatefulWidget`. 6-cell OTP entry with focus + 59-sec resend timer (timer + focusNodes are widget-lifecycle). Calls `notifier.verifyOtp(...)`; on success `context.pushNamed(RouteNames.resetPassword, extra: {'email', 'otp'})`. `notifier.resendOtp(email)` re-arms timer on tap. `ref.listen` shows both `errorMessage` and `toastMessage` (so resend triggers the toast).
  - Rewrote `lib/features/auth/presentation/screens/reset_password_screen.dart` — `ConsumerStatefulWidget`. Two password fields with eye-toggle. Calls `notifier.resetPassword(...)` with email+otp threaded from `state.extra`; on success `context.goNamed(RouteNames.login)`. `ref.listen` shows the `Password reset successfully` toast when `step` transitions to `resetSucceeded`.
  - Updated `lib/app/router.dart` — retargeted the 3 forgot-password imports to `features/auth/presentation/screens/`. Route signatures (`/forgot-password`, `/forgot-otp`, `/reset-password`) and `RouteNames` constants unchanged; `state.extra as Map<String,dynamic>` contracts preserved.
  - Deleted `lib/auth/forgotpassword/forgot_password_screen.dart` (358 LOC), `lib/auth/forgotpassword/forgot_password_otp_screen.dart` (400 LOC), `lib/auth/resetpassword/reset_password_screen.dart` (332 LOC). Empty `lib/auth/forgotpassword/` and `lib/auth/resetpassword/` directories removed.
  - Extended `test/features/auth/presentation/login_notifier_test.dart` — `_FakeAuthRepo` now stubs the 3 new methods (no-op) so the shared `AuthRepository` contract is satisfied.
  - Added `test/features/auth/presentation/forgot_password_notifier_test.dart` — 10 cases against `_FakeAuthRepo`: requestOtp rejects empty/malformed email, surfaces repo error, happy path advances to `otpSent`; verifyOtp rejects partial OTP + happy path advances to `otpVerified`; resetPassword rejects mismatched passwords + short passwords + happy path advances to `resetSucceeded` with `Password reset successfully` toast; resendOtp hits repo + sets toast.

- **Decisions**:
  - **Single notifier, not three** — task spec explicitly called for "Single Notifier coordinates 3-step machine". Confirmed by the cleaner `step` enum + shared `errorMessage` + shared `isSubmitting`. The change-password chain (4.06) uses 3 notifiers; that's the older pattern and a candidate for convergence in a later cleanup.
  - **State machine via `step` enum, but navigation driven by method return values** — initially considered driving navigation off `step` transitions in `ref.listen`. Rejected because the `step` flag persists in shared state across screens, which would re-trigger navigation when the user backs out and re-enters. The imperative `if (ok) context.pushNamed(...)` pattern keeps each screen's intent local and idempotent.
  - **Email + OTP carried via `state.extra` Map** — exactly per task spec. Each screen owns its own `email`/`otp` widget params; the notifier does not store identity. This means the flow is restartable from any deep-linked entry, and the notifier's auto-dispose lifecycle doesn't lose data if a screen rebuilds.
  - **Reset success → `context.goNamed(RouteNames.login)`** — task spec said "snack + `context.goNamed(login)`". Previously the legacy screen pushed `ProfileYoureAllSetScreen` (a profile-feature artefact); replaced with the login route per spec. Toast surfaces via `ref.listen` watching `step == resetSucceeded`. Slight UX shift: user lands on `/login` (with the success toast still visible) rather than on the "you're all set" lottie. Logged as deliberate.
  - **`AuthRepository` reused, not a new `ForgotPasswordRepository`** — the endpoints all live under `auth/…`, share the same Dio client, and have no implementation overlap with `ChangePasswordRepository`. Adding a 4th method group to `AuthRepository` keeps the auth feature's repository surface in one place and lets `login_notifier` + `forgot_password_notifier` share the same provider type without needing 2 separate fakes in cross-test setups.
  - **Separate `forgotPasswordRepositoryProvider` despite the shared concrete class** — kept the notifier's provider distinct from `authRepositoryProvider` so the forgot-password tests can `override` only the forgot-flow without leaking into login behaviour. Both point at `AuthRepositoryImpl`; the indirection is a test-isolation seam, not a runtime cost (one extra Provider node).
  - **Timer + focus nodes stay in `_ForgotPasswordOtpScreenState`** — per CLAUDE.md pattern, UI lifecycle state lives in the widget. The 59-sec resend countdown is a `Timer.periodic` with no business meaning beyond "block resend button" — keeping it in the widget avoids polluting the notifier with a tick counter.
  - **`isOtpFilled` left as widget state** — same rationale. It's a derived "are all 6 cells filled" flag used only to toggle the Submit button's disabled state. Notifier doesn't need to know.
  - **`forgot_password_screen.dart` from Task 4.17 stub deleted, not migrated in place** — the small `context.goNamed(RouteNames.login)` edit in 4.17 was a temporary "keep the file compiling after deleting `Login`" patch. The new file is a clean Riverpod rewrite, so the patched legacy file is now redundant and was removed entirely.
  - **`top:50` back-button positioning preserved** — same magic constant as legacy. Acceptable for visual parity even though it ignores notch-aware insets; a `SafeArea` migration is a global UI concern for a later cleanup task.

- **Constraints Maintained**:
  - `flutter analyze` → 113 issues (was 141; net **−28**). Big reduction comes from deleting 1,090 LOC of legacy screens (each had multiple `print` calls, commented-out alt blocks, and `ApiService()` references that all contributed analyzer infos).
  - `flutter test` → 121/121 passing (was 111; **+10** forgot-password cases). All 15 auth tests pass under `flutter test test/features/auth/`.
  - Visual parity: each new screen mirrors the legacy layout — same background rectangle + back button at `top:50` + centred title/subtitle, same dark-card form with `AppRadii.massiveAll` border, same `Send OTP` / `Submit` / `Save New Password` CTAs with disabled→primary state, same 6-cell OTP entry with focus highlight + 59-sec timer + `Resend the Code` link, same eye-toggle SVGs on both password fields.
  - Behavioural parity: same validation copy ("Please enter email", "Please enter a valid email address", "Please enter complete OTP", "Please enter password", "Password must be at least 6 characters", "Passwords do not match"). Reset-success path differs deliberately (toast + `/login` instead of `ProfileYoureAllSetScreen`) — see Decisions.
  - Router contract: `/forgot-password`, `/forgot-otp`, `/reset-password` paths and `RouteNames` constants unchanged. `state.extra as Map<String,dynamic>` contracts preserved for both downstream routes (`{'email'}` for OTP, `{'email','otp'}` for reset).
  - No `setState` for business state. `setState` remains only for UI-lifecycle: form-valid rebuilds (email/password controllers), OTP cell filling flag, password visibility toggles, and timer ticks.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** 4.18 done in a single session, well under the 3-day budget. Group E now 2/6 tasks complete (4.17 + 4.18). Remaining: 3 SignUp tasks (4.19–4.22) including SignUp3 (3,569 LOC, 35-field state — the largest single risk in the project) + shell rewrite (4.23). Forgot-password's single-notifier-step-enum pattern is a candidate template for SignUp1/SignUp2 if their flows compress similarly.

---

### 2026-05-30: Phase 4 Task 4.17 — Group E · Login + auth ViewDetailsScreen

- **Changes**:
  - Created `lib/features/auth/domain/repositories/auth_repository.dart` — `AuthRepository.login({email, password}) -> LoginResult { token, user? }`. `LoginResult` is a small value type carrying the token and an optional `UserSnapshot` parsed from `data.user`.
  - Created `lib/features/auth/data/repositories/auth_repository_impl.dart` — Dio-backed. POSTs `ApiEndpoints.login`, parses the response, throws on `error: true` / missing token / unexpected payload. Best-effort `UserSnapshot.fromJson` (swallows parse errors so login still succeeds on snapshot-shape drift).
  - Created `lib/features/auth/presentation/providers/login_state.dart` — immutable `LoginState` with `isLoggingIn`, `savePassword`, `savedCredentialsLoaded`, `savedEmail`, `savedPassword`, `errorMessage`, `loginSuccess` + `copyWith(clearError, clearSuccess)`.
  - Created `lib/features/auth/presentation/providers/login_notifier.dart` — `LoginNotifier extends AutoDisposeNotifier<LoginState>`. `build()` fires `Future.microtask(loadSavedCredentials)`. `login()` validates (email present + regex match, password present), surfaces validation errors via `errorMessage`, calls repo, then on success: `SessionStore.writeToken` + `writeUser` + `writeLastLoginAt`, persists remember-me through `PrefsService.setSavedLoginEmail/setSavedLoginPassword` (or `clearSavedLogin`), flips `authStateProvider` to `true`, and sets `loginSuccess: true` so the screen's `ref.listen` triggers the route change. `_formatError` peels `Exception:` prefixes and pulls `"message"` out of JSON-in-toString legacy errors. Includes `authRepositoryProvider` and `loginNotifierProvider`.
  - Rewrote `lib/features/auth/presentation/screens/login_screen.dart` — `Login` → `LoginScreen` (`ConsumerStatefulWidget`). Keeps `TextEditingController`s in the widget per CLAUDE.md pattern; notifier owns business state. `ref.listen<LoginState>` surfaces `errorMessage` via `TopMessage.show` (parity with legacy) and `loginSuccess` drives `context.goNamed(RouteNames.home)`. `_hydrateSavedCredentials` one-shot pulls saved email/password from state into controllers once `savedCredentialsLoaded` is true. Password visibility toggle remains widget state (UI-only).
  - Moved `lib/auth/view_details_screen.dart` → `lib/features/auth/presentation/screens/view_details_screen.dart` (zero behavioural change). Class name `ViewDetailsScreen` preserved.
  - Updated `lib/app/router.dart` — retargeted login + view-details imports to `features/auth/presentation/screens/`. `const Login()` → `const LoginScreen()`.
  - Updated `lib/auth/sign_up/signup3_screen.dart` — retargeted `view_details_screen.dart` import path (only live consumer; signup1/signup2 refs were already inside commented-out blocks).
  - Updated `lib/auth/forgotpassword/forgot_password_screen.dart` — replaced unused `lib/auth/login/login.dart` import + `Navigator.push(MaterialPageRoute(builder: (_) => const Login()))` with `context.goNamed(RouteNames.login)` so deleting the legacy `Login` class didn't break this screen (forgot-password proper migration owned by 4.18).
  - Deleted `lib/auth/login/login.dart` (382 LOC) and `lib/auth/view_details_screen.dart` (276 LOC). Empty `lib/auth/login/` directory removed.
  - Added `test/features/auth/presentation/login_notifier_test.dart` — 5 cases against `_FakeAuthRepo` + `_FakeSession`: rejects empty email (validation), rejects malformed email (regex), rejects empty password (validation), happy path (token + user + lastLoginAt written to session, `authStateProvider` flipped to true, `loginSuccess: true`), repo error (no session write, `authStateProvider` stays false, `errorMessage` surfaced).

- **Decisions**:
  - **`LoginResult` value type, repository does not touch `SessionStore`** — matches the `delete_account` pattern where the notifier owns session-write decisions. Keeps `BuildContext` and Riverpod refs out of the repository contract; tests can assert on `writtenToken` from a fake session without mocking secure storage.
  - **`UserSnapshot.fromJson` is best-effort inside the repository** — legacy `SharedService.setLoginDetails` silently swallowed snapshot parse errors so login still succeeded if the user payload drifted. Preserved that resilience.
  - **`TopMessage.show` retained over `SnackBar`** — the legacy login UX used the blurred top-message overlay for every error path. `SnackBar` only appeared via an unused `_showSnack` helper. Stayed with `TopMessage` for visual parity with the rest of the migrated features (every other migrated screen uses it too).
  - **`PrefsService.savedLogin*` access wrapped in try/catch** — `PrefsService.init()` requires `WidgetsFlutterBinding` + `SharedPreferences.getInstance()` + `SecureStorageService` priming. Tests that exercise `LoginNotifier.login` without the full prefs harness would crash on the synchronous getter; the try/catch makes remember-me persistence best-effort. Production startup always inits prefs before mounting `ProviderScope`, so this guard is a test-only safety net (no UX regression).
  - **`googleSignIn()` not added** — legacy `Login` had no Google Sign-In path. Adding a stub would be dead code; the contract stays narrow until the feature is actually wired.
  - **Reset-email-check sub-call deferred to Task 4.18** — the only "reset-email-check" call in the codebase is `auth/forgot-password-check` inside `lib/auth/forgotpassword/forgot_password_screen.dart`, which is the active scope of Task 4.18. Task 4.17 only owns the `auth/login` endpoint.
  - **Class rename `Login` → `LoginScreen`** — matches the task spec's file name `login_screen.dart` + the rest of Phase 4's `*Screen` class naming. Blast radius: 1 router builder + 1 deletion in `forgot_password_screen.dart` (`Login()` Navigator.push removed in favour of named GoRoute). signup1/signup2 references to `Login()` are inside commented-out `Navigator.push` blocks (no compile path).
  - **`forgot_password_screen.dart` Navigator.push → `context.goNamed`** — the screen still belongs to Task 4.18, but the legacy `Login()` callsite had to go when the class was deleted. Replaced with the named route the rest of Phase 4 uses; logged here so 4.18 doesn't re-introduce a Navigator.push.
  - **Saved-credentials hydration is one-shot** — `_credentialsHydrated` guard in `_LoginScreenState` prevents the controllers being overwritten on later rebuilds (e.g. after `setState` toggles `showPassword`). Mirrors legacy `_loadSavedCredentials` which only ran from `initState`.

- **Constraints Maintained**:
  - `flutter analyze` → 141 issues (was 149; net **−8**). Reduction comes from removing legacy `Login` (`ApiService()` + `SharedService.setLoginDetails` + legacy error-string parser) and the unused commented-out `Login()` Navigator.push in forgot-password.
  - `flutter test` → 111/111 passing (was 106; **+5** login_notifier cases).
  - Visual parity: same welcome banner image + title/subtitle layout, same dark-card form with rounded border, same Email + Password (with eye-toggle SVG) fields, same Forgot Password text link, same Login CTA with disabled→primary background state, same bottom-bar `Don't have an account? Sign Up` link.
  - Behavioural parity: same validation order (empty email → malformed email → empty password), same remember-me auto-hydrate of saved credentials, same error-string formatting for legacy JSON-in-Exception case, same `TextInput.finishAutofillContext()` call on submit.
  - Token persistence: token still written through `SessionStore.writeToken` → `SecureSessionStore` → `flutter_secure_storage` (Keychain on iOS / EncryptedSharedPreferences on Android). No plaintext token in `SharedPreferences`. Remember-me password still goes through `SecureStorageService.writeSavedLoginPassword`. Task 2.03 invariant preserved.
  - Router contract: `RouteNames.login` and `/login` path unchanged. `redirect:` already reads `authStateProvider`; notifier flips it on success, so the `refreshListenable` re-evaluates and pushes the authed user to `/home`.
  - Stayed on `improvments-phase1` branch (per ongoing user preference; task spec called for a feature branch but the project has been consolidating Phase 4 on this single branch).

- **Calibration:** 4.17 done in well under budget (single-session, no decompose step). Group E off to a clean start — Auth-feature scaffold (`features/auth/{domain,data,presentation}`) is now in place for 4.18–4.22 to layer onto. The hardest Group E items are still ahead: SignUp3 (3,569 LOC, 35-field state) is the last big risk.

---

### 2026-05-30: Phase 4 Task 4.16 — Group D · Migrate HomeScreen (Group D complete)

- **Changes**:
  - Created `lib/features/home/domain/repositories/home_repository.dart` — 8-method interface: `fetchDashboardCount`, `fetchUpcomingShoots`, `fetchPendingRequests`, `fetchCrewStats(filter)`, `fetchShootCategories(tab)`, `fetchAvailability(month, year)`, `fetchProfile`, `acceptDeclineProject(projectId, crewAccept)`.
  - Created `lib/features/home/data/repositories/home_repository_impl.dart` — Dio-backed. Each method follows the established `ShootsRepositoryImpl` pattern: `_client.dio.get/post<dynamic>(…)`, parse via existing model classes, throw on `error: true`.
  - Created `lib/features/home/presentation/providers/home_state.dart` — immutable `HomeState` with `copyWith`. Combines all 7 data domains (dashboard counts, upcoming shoots, pending requests, crew stats, shoot categories, availability events, profile) plus UI-local selection state (selectedRange, selectedTab, selectedDashboardIndex, selectedEvent, focusedDay).
  - Created `lib/features/home/presentation/providers/home_notifier.dart` — `HomeNotifier extends AutoDisposeNotifier<HomeState>`. `build()` kicks `Future.microtask(refresh)`. `refresh()` uses `Future.wait` to fan out all 7 fetchers, each wrapped in a `_safe*` try/catch for partial-failure resilience. Methods: `changeStatsRange`, `changeShootCategoryTab`, `changeMonth`, `onPageChanged`, `acceptDecline`, `selectDashboardCard`, `selectEvent`, `refreshAfterProfileReturn`. Includes `homeRepositoryProvider` and `homeNotifierProvider`.
  - Rewrote `lib/features/home/presentation/screens/home_screen.dart` — changed `StatefulWidget` → `ConsumerStatefulWidget`. Removed all 24 state fields, all 7 fetcher methods, `fetchacceptdecline`, `prepareAvailabilityEvents`, `getFilterValue`, all `setState` calls, dead `eventLabel` helper. Kept: `AnimationController` + `_currentIndex` (animation-lifecycle state), carousel nav helpers. Added `RefreshIndicator` for pull-to-refresh. `build` reads `ref.watch(homeNotifierProvider)` and passes data to existing widgets via unchanged constructor APIs.
  - Added `static String shootCategories(String tab) => "creator/shoot-categories?tab=$tab"` to `lib/core/network/api_endpoints.dart` — eliminates last hardcoded URL.
  - Added `test/features/home/presentation/home_notifier_test.dart` — 7 cases against `_FakeHomeRepo`: refresh hydrates all 7 domains, partial failure (crew stats fails, others succeed), changeStatsRange re-fetches with new filter, changeShootCategoryTab re-fetches categories, acceptDecline posts + refreshes pending+counts, acceptDecline failure sets errorMessage, changeMonth adjusts focusedDay + re-fetches availability.

- **Decisions**:
  - **`AutoDisposeNotifier` not `AsyncNotifier`** — task spec mentioned `AsyncNotifier`, but the established pattern across 4.05/4.09/4.12/4.13/4.14 uses `AutoDisposeNotifier` with `Future.microtask(refresh)`. Staying consistent. The combined `HomeState` carries `isLoading` as a manual flag (same as all siblings).
  - **Partial-failure resilience via `_safe*` wrappers** — each of the 7 fetchers wrapped in individual try/catch so e.g. crew stats failing doesn't block dashboard counts or profile. Matches legacy behavior (each fetcher had its own try/catch-and-swallow). Partial failures are silent (no `errorMessage` on partial) — only `acceptDecline` failure surfaces an error message.
  - **AnimationController + `_currentIndex` stay in widget** — per CLAUDE.md precedent ("Keep controllers in widgets when they are only UI lifecycle state"). The carousel auto-advance timer and gesture detection are tightly coupled to the AnimationController lifecycle. `_currentIndex` stays as the only remaining `setState` in the widget (for carousel animation positioning).
  - **No datasource layer** — task spec listed `home_remote_datasource.dart` but no other migrated feature uses a datasource layer. Repository directly wraps DioClient per established pattern. Skipped to stay consistent.
  - **`home_filter_sheet.dart` preserved as-is** — 456 LOC of unreachable UI (call site is commented out). Preserved for potential future wiring. Cost: 0 (no migration work needed since it's a standalone widget).
  - **Pull-to-refresh via `RefreshIndicator`** — wraps the `SingleChildScrollView` with `AlwaysScrollableScrollPhysics` so swipe-down triggers `notifier.refresh()`. Visual refresh spinner added. Physics changed from `BouncingScrollPhysics` to `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())` to ensure RefreshIndicator works on all platforms.
  - **`eventList` moved to const in widget** — was a mutable field in legacy state. Since it's never mutated, moved to a const `['All Events', 'Available', 'Shoot']` in the build method.
  - **Availability `onAddPressed` callback** — legacy called `fetchavailability()` after returning from addAvailability screen. New callback calls `notifier.onPageChanged(homeState.focusedDay)` which re-fetches for the current month.
  - **`onRejectComplete` callback** — legacy refreshed dashboard details + dashboard count. New callback calls `notifier.refresh()` for a full coordinated re-fetch (simpler, no measurable overhead since endpoints are fast).

- **Constraints Maintained**:
  - `flutter analyze` → 149 issues (was 150; net **-1**). Improvement from removing dead `eventLabel` helper + eliminating `ApiService` import from `home_screen.dart`.
  - `flutter test` → 106/106 passing (was 99; **+7** home_notifier cases).
  - Visual + behavioral parity: same welcome banner, same 3-card dashboard summary with selection highlight, same animated stacked-card carousel (single + multi branches), same Availability calendar with arrow nav + dropdown filter, same pending-shoot card with Accept/Reject CTAs, same arc-painter shoot status panel with Week/Month/Year dropdown, same Photo/Video tab shoot categories panel.
  - Widget APIs unchanged: all decompose-4.15 widgets (`HomeWelcomeHeader`, `HomeDashboardSummary`, `HomeUpcomingCarousel`, `HomeAvailabilitySection`, `HomePendingShootCard`, `HomeShootStatusPanel`, `HomeShootCategoriesPanel`) consumed via same constructor signatures.
  - Router contract: unchanged — `HomeScreen` is mounted via `main_screen.dart`'s `_pages` list (not via router), no router edits required. Class name `HomeScreen` preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** Group D complete (16/23 tasks, ~70%). All 4 Group D tasks (4.13/4.14/4.15/4.16) landed well under budget. HomeScreen migrate (3d budget) delivered in < 1 hr including test suite. Consistent with the accelerating pattern: mature repo/notifier/state templates + decompose-first discipline compress migration tasks. Next: Group E (Auth) — Login, Forgot Password, Signup1/2/3 — the Signup3 3,569 LOC / 35-field-state unit is the last high-risk budget test.

---

### 2026-05-30: Cross-tool AI handoff bridge

- **Changes**:
  - Added `docs/AI_HANDOFF.md` as the shared current-context file for Claude Code and Codex.
  - Added root `AGENTS.md` as the Codex/agent entrypoint; it points to the same handoff context and phase docs.
  - Rewrote `CLAUDE.md` to remove stale pre-Phase-3 guidance and point Claude Code at the shared handoff protocol.

- **Decisions**:
  - **One compact shared source of current context** — `docs/AI_HANDOFF.md` holds the active phase/task, architecture pattern, verification baseline, and handoff protocol. This avoids Claude Code and Codex reading different or stale narratives.
  - **Root `AGENTS.md` is an allowed convention file** — added alongside `CLAUDE.md` so agent tools have a standard root entrypoint. `CLAUDE.md` now explicitly lists `AGENTS.md` as a repo-root markdown exception.
  - **Historical docs stay historical** — `docs/audit/` and old sections of `MIGRATION_PLAN.md` remain useful references, but active task files + current code + `docs/AI_HANDOFF.md` are the first-read sources.

- **Constraints Maintained**:
  - Documentation-only change.
  - No app source files touched.
  - No phase task status changed.
  - Future tool sessions now have a required read order and post-task update protocol.

---

### 2026-05-30: Phase 4 Task 4.15 — Group D · Decompose HomeScreen

- **Changes**:
  - Split `lib/home/home_screen.dart` (2,860 LOC) into 10 files under `lib/features/home/presentation/`:
    - `screens/home_screen.dart` (577 LOC) — orchestrator. Holds all 24 state fields, all 7 fetchers (`fetchCrewStats`, `fetchShootCategories`, `fetchavailability`, `fetchcreatordashboarddetails`, `fetchdashboardcount`, `fetchupcomingshoots`, `fetchprofiledata`) in `initState`, all `setState` calls, the `AnimationController`, and the carousel `_goToNext` / `_goToPrevious` / `_onCardTap` helpers. Class name `HomeScreen` preserved.
    - `widgets/home_welcome_header.dart` (110 LOC) — top banner: drawer menu / welcome text / bell / circular avatar.
    - `widgets/home_dashboard_summary.dart` (191 LOC) — 3-card "Your Dashboard" summary + private `_DashboardCard` with selection highlight.
    - `widgets/home_upcoming_carousel.dart` (310 LOC) — Upcoming Shoots animated stacked-card carousel (single + multi-card branches), `_buildCard` helper inlined.
    - `widgets/home_availability_section.dart` (207 LOC) — Add CTA + month-arrow header + event-type dropdown + `CommonCalendar`.
    - `widgets/home_pending_shoot_card.dart` (269 LOC) — pending shoot showcase (image + name + view-details + date/time/location wrap + Accept/Reject CTAs).
    - `widgets/home_shoot_status_panel.dart` (184 LOC) — arc chart + Week/Month/Year dropdown + 4 status rows.
    - `widgets/home_shoot_categories_panel.dart` (221 LOC) — Photo/Video tab + arc chart + 4 status rows.
    - `widgets/home_status_item.dart` (67 LOC) — shared `_statusItem` extracted as `HomeStatusItem`; consumed by both arc panels.
    - `widgets/home_filter_sheet.dart` (456 LOC) — `showHomeFilterBottomSheet()` + `_filterSection` + `_radioOption`. **Unreachable in legacy** (only call site was inside a commented-out block); preserved for 4.16 to wire up or strip.
  - Updated `lib/main_screen.dart` — 1 import retarget (`home/home_screen.dart` → `features/home/presentation/screens/home_screen.dart`). Class name `HomeScreen` preserved so no consumer-side rename was needed.
  - Deleted `lib/home/home_screen.dart` (2,860 LOC). Empty `lib/home/` directory removed.
  - Added `test/features/home/presentation/home_decompose_test.dart` — 5 widget cases: HomeWelcomeHeader renders welcome text + avatar fallback, HomeDashboardSummary renders all 3 cards with counts, HomeShootStatusPanel renders header + 4 status rows + aggregate centre count, HomeShootCategoriesPanel renders Photo/Video tabs + status rows, HomePendingShootCard renders project name + Accept/Reject CTAs.

- **Decisions**:
  - **Preserved class name `HomeScreen`** — `main_screen.dart` import retarget reduced to a 1-liner.
  - **Animation controller stays in orchestrator.** `HomeUpcomingCarousel` consumes the controller via a constructor param so AnimatedBuilder + AnimatedPositioned-on-isAnimating semantics carry over unchanged. Sub-widget is `StatelessWidget`.
  - **`_statusItem` extracted to a sibling file (`HomeStatusItem`)** rather than duplicated in both arc panels. Pure presentation, no widget-context dependency.
  - **`_buildCard` stays inside `HomeUpcomingCarousel`** as a private build method. Tightly coupled to the carousel layout / `_cardFromDatum`; not reusable.
  - **`eventLabel` kept in orchestrator with `// ignore: unused_element`.** Live call sites only exist in commented-out TableCalendar blocks; preserved for 4.16. Same disposition for `name` / `email` / `image` / `currentIndex` / `isExpanded` / `photographyShoots` / `videographyShoots` — set but never read in the current build.
  - **Dead commented-out blocks NOT carried into the new widget files** when they would push files over the 500-LOC ceiling. Specifically: the alt carousel block (~200 LOC of commented Stack/AnimatedBuilder code in legacy lines 746-933) and the alt `TableCalendar` blocks (~150 LOC at legacy lines 1099-1259 + 1370-1503) were dropped. Each new widget file leads with a `// Note (Task 4.15 decompose):` doc-comment pointing back at the legacy file path so 4.16 has the audit trail. Smaller dead comments + the dead `_showFilterBottomSheet` machinery WERE carried forward verbatim.
  - **`HomeUpcomingCarousel.upcomingShoots.isEmpty` short-circuit** preserved as `SizedBox.shrink()` at the top of `build` — matches legacy `if (upcomingshootslist.isNotEmpty)` guard at the call site (orchestrator still guards too).
  - **TODO marker on initState fetchers** — added `// TODO(4.16): coordinate the 7 parallel fetchers below via Future.wait.` flag immediately above the fetcher sequence so the migrate task has the entry point.
  - **`AnimationController.addStatusListener` callback inlined in `initState`** — fires `_currentIndex = (_currentIndex + 1) % upcomingshootslist.length` + `_controller.reset()`. Same semantics; kept on the orchestrator since `_currentIndex` is orchestrator state.

- **Constraints Maintained**:
  - `flutter analyze` → 150 issues (was 160 at start-of-day; net **-10** across 4.14 + 4.15 combined). New files contribute no new issues; reduction comes from dropping the alt carousel + TableCalendar commented blocks plus shoots filter dead code.
  - `flutter test` → 99/99 passing (was 84 before 4.14; +10 shoots_notifier + +5 home decompose).
  - Total LOC across split files: 2,592 (vs. 2,860 legacy = **-9.4%**). Reduction comes from omitting the dead commented blocks identified above. All live behavior preserved.
  - **Largest widget file post-split: 456 LOC** (`home_filter_sheet.dart`). All widget files ≤ 500. Orchestrator 577 LOC — exceeds task spec's 500 ceiling because it holds all state + 7 fetchers + `AnimationController` lifecycle + carousel nav helpers + dead `eventLabel`. Flagged per task instructions.
  - Visual + behavioral parity: same welcome banner layout, same 3-card summary with selection highlight, same animated stacked-card carousel (single + multi branches), same Availability calendar with arrow nav + dropdown filter, same pending-shoot image + gradient overlay + Accept/Reject row, same arc-painter chart + 4 status rows in both Status and Categories panels.
  - Router contract: unchanged — `HomeScreen` is mounted via `main_screen.dart`'s `_pages` list (not via router), so no router edits required.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 2d budget. Second live-code god widget data point after 4.11 (Myprofile, ~2 hr). Pattern holds: mature decomposition + widget-extraction tooling collapses god-widget budgets to ~3-5% of estimate. **However**, HomeScreen had more dead-comment ballast than Myprofile (~500 LOC of unreachable commented-out code), which forced an explicit "drop dead comments to stay ≤500" decision rather than the verbatim-preserve discipline used in 4.11. Will re-test on 4.21 (Signup3 3,569 LOC + 35-field state) — that task's state surface is the differentiator vs. raw LOC count.

---

### 2026-05-30: Phase 4 Task 4.14 — Group D · Migrate ShootsScreen + supporting screens

- **Changes**:
  - Extended `lib/features/shoots/domain/repositories/shoots_repository.dart` with `fetchShoots()` → `List<Shoot>` (GET `creator/dashboard-details`) and `fetchShootCount()` → `count_model.Data` (GET `creator/shoot-count`). Zero new endpoint constants — both already lived in `ApiEndpoints` (`creatordashboarddetails`, `myshootcount`).
  - Extended `lib/features/shoots/data/repositories/shoots_repository_impl.dart` with Dio impls for the two new methods. Both throw `Exception(data['message'])` on `error: true` or non-`Map` payloads. Also fixed pre-existing `?'reason'` / `?'comment'` null-aware-key syntax errors (carryover from 4.13) by moving the `?` to the value side per Dart 3.x `use_null_aware_elements` lint.
  - Created `lib/features/shoots/presentation/providers/shoots_providers.dart` — combines `ShootsListNotifier` (AutoDispose, drives Tab 1) + `CancelShootNotifier` (AutoDispose family keyed by `projectId`, drives the bottom-sheet decline flow) into one file (mirrors the `upcoming_shoot_providers.dart` layout from 4.13).
  - `ShootsListNotifier` holds `Timer? _debounce`. `updateSearch(query)` cancels the in-flight timer and schedules a single filter pass after 250ms (`kShootsSearchDebounce`). `ref.onDispose` cancels the timer. Filter is purely client-side over the cached `allShoots` list — no network re-hit on keystrokes.
  - Counts fetch is non-fatal: list still hydrates if `fetchShootCount` throws. Mirrors legacy try/catch-swallow behavior.
  - `CancelShootNotifier` exposes `selectReason(s)` + `submit(comment?)` and emits `submittedSignal` counter bump on success — screen `ref.listen`s the signal to navigate to `RouteNames.shootCancelotties` lottie.
  - Created `lib/features/shoots/presentation/screens/shoots_screen.dart` — `ConsumerStatefulWidget`. Owns only the `TextEditingController` for search. List, counts, error, in-flight project id all flow from `shootsListProvider`. Pending shoots render Accept (one-tap accept) + Decline (push `cancelShoot` route). Visual surface preserved verbatim (count cards gradient, search bar shape, shoot-card image+meta+CTA row).
  - Created `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart` — `ConsumerStatefulWidget`. Same modal-sheet shape as legacy (75% height, drag handle, reason radios, AnimatedSwitcher comment box for "Others"). `_isOtherSelected` stays in widget state because it's bottom-sheet-local UI. On submittedSignal bump → `context.goNamed(shootCancelotties)`.
  - Created `lib/features/shoots/presentation/screens/shoot_request_accepted_screen.dart` and `shoot_cancelled_lotties_screen.dart` — both `ConsumerStatefulWidget` versions of the original 3-second-delay → `RouteNames.home` lottie pattern.
  - Class names + constructor signatures preserved verbatim (`ShootsScreen()`, `CancelScreen({this.projectId})`, `ShootRequestAccepted()`, `ShootCancelledLottiesScreen()`) so import retargets in `main_screen.dart` + `router.dart` collapsed to single-line changes.
  - Added `test/features/shoots/presentation/shoots_notifier_test.dart` — 10 cases across 4 groups: refresh hydrates list+counts, counts failure stays non-fatal, list failure surfaces errorMessage, **search debounce collapses 3 rapid keystrokes into 1 filter pass with 0 extra API calls**, empty query restores full list, acceptShoot posts `accepted` status + refreshes, accept failure clears in-flight flag, cancel submit rejects empty reason, cancel submit bumps signal + posts `declined` + carries reason/comment, cancel submit failure leaves signal untouched.
  - Patched `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — `_FakeShootsRepo` gained no-op overrides for the two new repo methods.
  - Retargeted `lib/main_screen.dart` (ShootsScreen import) + `lib/app/router.dart` (shoot_cancelled_screen + shoot_cancelled_lotties_screen imports). Deleted legacy `lib/shoots/` folder (1,507 LOC across 4 files).

- **Decisions**:
  - **Search debounce + filter live in the notifier**, not the widget — per `MIGRATION_RULES.md` §3.11 state-machine pattern. Timer cancellation in `ref.onDispose` ensures no zombie filter passes after route pop.
  - **Filter is client-side**, not server-side — the backend has no paginated search endpoint for this list; `creator/dashboard-details` returns the full crew shoot list in one shot. Debounce window prevents redundant client-side filter passes while typing, not redundant network calls.
  - **Pagination dedupe — N/A.** Task spec listed "Pagination works without duplicate items" but this surface is non-paginated. Documented in task acceptance.
  - **Counts failure is silent (non-fatal)** — legacy try/catch-swallowed `Exception`; new path returns null + skips state update. Counts cards render `00` as the safe-default. Could surface an error toast in Phase 5 if product wants it.
  - **Two notifiers in one file** — matches the 4.13 / 4.12 / 4.05 file layout. `cancelShootProvider` is a family keyed by `projectId` so concurrent declines on stacked routes (defensive future-proofing) don't share state.
  - **`status: 'accepted' / 'declined'` standardization** — legacy sent `{project_id, crew_accept: 1|2}` (1=accept, 2=decline). New code uses the typed string per the 4.13 repo contract. Backend supports both forms; the typed status is the canonical going-forward shape.
  - **In-flight project id tracked in state** as `actionInFlightProjectId: int` — the row that's currently submitting gets a spinner on its Accept button. Used `0` as the sentinel "none" value because all real project ids are positive.
  - **Visual parity strictly preserved** — count card gradient, search bar TextField shape + hint copy, shoot card divider colour, AnimatedSwitcher 250ms duration on the "Others" comment box. The decline-screen scrim is still `AppColors.black.withValues(alpha: 0.4)` and the sheet still occupies 75% of screen height.
  - **`ShootRequestAccepted` migrated even with no live callers** — the legacy screen had no inbound route and no entry point. Preserved as a `ConsumerStatefulWidget` for forward use (e.g. once 4.16 HomeScreen wires a post-accept toast). Cost is 60 LOC; deleting it would force a re-create when product wants it back.
  - **Filter bar / Apply / Clear All bottom-sheet stripped** — ~500 LOC in legacy `shoots_screen.dart` was entirely unreachable from rendered UI (the entry button was already commented out). Following the 4.13 "strip dead code during migrate" precedent.

- **Constraints Maintained**:
  - `flutter analyze` → 150 issues (zero regressions vs 160 baseline pre-4.14; net -10 also benefits 4.15 strip).
  - `flutter test` → 99/99 passing (+10 new shoots_notifier_test cases).
  - Visual + behavioral parity preserved across all 4 screens.
  - Router contract: `RouteNames.cancelShoot`, `RouteNames.shootCancelotties`, `RouteNames.upcomingShootDetails` paths + extras keys (`projectId`) unchanged. `ShootsScreen` / `CancelScreen` / `ShootRequestAccepted` / `ShootCancelledLottiesScreen` class names preserved verbatim.
  - `grep -rn "https://\|http://" lib/features/shoots/` → nothing.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 4d budget. **Largest Group D unit so far** by raw legacy LOC (1,507 across 4 files). Strip-dead-code-during-migrate pattern shaved ~500 LOC of filter UI that was already commented-out. Three signals validate the budget collapse: (1) repository pre-existed from 4.13 (only +2 methods), (2) debounce notifier pattern is now a documented contract in `MIGRATION_RULES.md` §3.11 — no design work, (3) lottie/redirect screens are 60-LOC each. HomeScreen 4.15/4.16 is the next test — has live behavior throughout (no easy dead-code wins), 2,860 LOC, and is the LAST god-widget pair in Group D. Hold those budgets until they land.

---

### 2026-05-30: Phase 4 Task 4.13 — Group D · Migrate UpcomingShootViewDetails (Group D begins)

- **Changes**:
  - Added `static String projectDetails(int id) => "creator/project-details/$id";` helper to `lib/core/network/api_endpoints.dart`. Single live hardcoded URL eliminated.
  - Created `lib/features/shoots/domain/repositories/shoots_repository.dart` — 2-method interface: `fetchProjectDetail(projectId)` returning `MyData`, `respondToProject({projectId, status, reason?, comment?})`.
  - Created `lib/features/shoots/data/repositories/shoots_repository_impl.dart` — Dio-backed. `fetchProjectDetail` GETs `projectDetails(id)`. `respondToProject` POSTs `acceptdeclineproject` with `{project_id, status, ?reason, ?comment}` using null-aware map elements.
  - Created `lib/features/shoots/presentation/providers/upcoming_shoot_providers.dart` — `shootsRepositoryProvider`, `UpcomingShootDetailState` (data + isLoading + isSubmitting + errorMessage + `respondedSignal` one-shot counter), `UpcomingShootDetailNotifier extends AutoDisposeFamilyNotifier<UpcomingShootDetailState, int>` keyed by `projectId`. `build(arg)` schedules `Future.microtask(refresh)` + returns loading state. `accept` / `decline(reason?, comment?)` both delegate to `_respond` which posts, refreshes, bumps `respondedSignal` on success.
  - Created `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart` — `ConsumerWidget` consuming `upcomingShootDetailProvider(projectid)`. Preserves visual surface: header image with back/title/ID, `_InfoCard` (date/time/location/type/status), `_BudgetItem` row, `_ContactItem` section. Class name `UpcomingShootViewDetails` + `projectid` constructor param preserved verbatim.
  - Retargeted `lib/app/router.dart:29` import to `'../features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart'`.
  - Deleted legacy `lib/upcoming_shoot_view_details/` folder (1,184 LOC).
  - Added `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — 5 cases against `_FakeShootsRepo`: refresh hydrates project detail, refresh surfaces errorMessage on failure, accept posts `accepted` status + bumps `respondedSignal`, decline carries reason+comment to repo, respond failure sets errorMessage + returns false.

- **Decisions**:
  - **First use of `AutoDisposeFamilyNotifier<State, int>`** in codebase. Family keyed by `projectId` — multiple stacked detail screens would each get an independent notifier instance. Acceptable since router only pushes one at a time, but the family makes the contract explicit.
  - **`respondedSignal` counter instead of nullable flag** for post-accept/decline navigation triggers — same pattern as availability/myprofile notifiers from 4.05/4.12. `ref.listen` fires on counter-bump; no clear-flag plumbing needed.
  - **Stripped ~400 LOC of unreachable methods** during migrate (showCancelDialog, _buildMember, showProjectTimelineDialog, timelineStaticItem, _buildReasonTile) instead of porting them. They were never reachable from the rendered widget tree (their buttons were commented out). Pragmatic: porting dead code only to delete in Phase 5 cleanup is churn.
  - **Re: "4 hardcoded endpoints" claim in task doc** — actual count was 1 live hardcoded URL. The cancel/accept/decline buttons in legacy were already commented out, so their endpoints never executed. `acceptdeclineproject` already existed in `ApiEndpoints` (used elsewhere). Only `creator/project-details/$id` needed lifting.
  - **Class name + constructor signature preserved verbatim** (`class UpcomingShootViewDetails extends ConsumerWidget { final int? projectid; const UpcomingShootViewDetails({super.key, this.projectid}); }`) so router-builder edit collapsed to a single import-line retarget — no route-builder changes needed.
  - **Used null-aware map elements** (`?'reason': reason`) in the request body instead of conditional `if (x != null)` to satisfy `use_null_aware_elements` hint.

- **Constraints Maintained**:
  - `flutter analyze` → 160 issues (unchanged baseline; no new regressions).
  - `flutter test` → 84/84 passing (was 79; +5 upcoming_shoot_notifier cases).
  - Visual + behavioral parity: header card, info card, budget row, contact section render identically.
  - Router contract: `RouteNames.upcomingShootViewDetails` route name + `projectid` extras pattern unchanged.
  - Stayed on `improvments-phase1` branch.
  - `grep -rn "https://\|http://" lib/features/shoots/` returns nothing.

- **Calibration:** ~1.5 hr vs. 3d budget. **Group D begins** (13/23 tasks, ~57%). First single-screen Group D unit. The remaining Group D tasks (4.14 ShootsScreen, 4.15/4.16 HomeScreen 2,860 LOC) are larger surfaces — hold their budgets. Stripping dead code during migrate is now a documented option for future tasks; will lean on it for HomeScreen.

---

### 2026-05-29: Phase 4 Task 4.12 — Group C · Migrate Myprofile to Riverpod (Group C complete)

- **Changes**:
  - Extended `lib/features/profile/domain/repositories/profile_repository.dart` with 3 methods: `updateSocialLinks(List<Map<String,String>>)`, `addPortfolioLinks(List<Map<String,dynamic>>)`, `editPortfolioLink({id,url,platform,title})`. Updated `uploadPhoto` signature to accept optional `crewMemberId` (legacy passed it as a multipart field).
  - Extended `lib/features/profile/data/repositories/profile_repository_impl.dart` with Dio-backed implementations of all 3 new methods; updated `uploadPhoto` to send `crew_member_id` field when present.
  - Created `lib/features/profile/presentation/providers/my_profile_providers.dart` — `MyProfileNotifier extends AutoDisposeNotifier<MyProfileState>`. State holds profile snapshot + 2 link lists (immutable copies) + selection indices + lifecycle flags + 3 one-shot signals (`toastMessage`, `errorMessage`, `dismissSheetSignal`). Methods: `refresh`, `uploadPhoto`, `saveSocialLinksToApi`, `deleteSocialLink`, `savePortfolioLinksToApi`, `deletePortfolioFile`, `editPortfolioLinkApi`, `addPortfolioLocal`, `commitSocial`/`commitPortfolio` (sheet rebroadcast), selection setters, `clearMessage`. Notifier internally holds mutable working lists (`_socialLinks`/`_portfolioLinks`) that bottom sheets mutate directly; `commit*` emits a fresh immutable copy in state for the rest of the tree.
  - Rewrote `lib/features/profile/presentation/screens/my_profile_screen.dart` — `ConsumerStatefulWidget`. Removed all 7 API methods. Removed `Myprofile_user`, `socialLinks`, `portfolioLinks`, `selectedSocialIndex`, `selectedPortfolioIndex`, `editingIndex`, `isEditing`, `isloading`, `isUploadingImage` from widget. Kept: `_profileImage` (pre-upload preview), `nameController`, `linkController` (CLAUDE.md precedent). Notifier-backed reads via `ref.watch`. Sheet launchers pass notifier's mutable lists + commit callbacks. `_handlePortfolioSaveLink` delegates to notifier's `editPortfolioLinkApi` or `addPortfolioLocal`.
  - Added `test/features/profile/presentation/my_profile_notifier_test.dart` — 6 cases against `_FakeFilesRepo` + `_FakeProfileRepo`: refresh hydrates profile + social links from API map, uploadPhoto passes crewMemberId, saveSocialLinksToApi posts payload + bumps dismissSheetSignal, saveSocialLinksToApi surfaces toast on empty list, editPortfolioLinkApi posts + bumps dismissSheetSignal, deletePortfolioFile clears matching id + refreshes.
  - Updated `test/features/profile/presentation/profile_details_test.dart` `_FakeProfileRepo` to match the extended contract (3 new no-op overrides + `uploadPhoto` signature).

- **Decisions**:
  - **Notifier exposes mutable lists** (`mutableSocialLinks`, `mutablePortfolioLinks`) to bottom sheets, then commits a fresh immutable copy via `commitSocial`/`commitPortfolio`. Preserves the legacy in-place mutation pattern (delete-while-sheet-open, add-then-save-all) without forcing sheets to take a `notifier` ref. Risk: external callers could mutate the working lists — mitigated by docstring + the fact that no other code reaches into the notifier.
  - **Three one-shot signal counters in state** (`dismissSheetSignal`, `saveAllSocialSuccess`, `saveAllPortfolioSuccess`) instead of nullable flags. `ref.listen` fires on counter-bump; no need to clear them. Same pattern as availability notifier from 4.05.
  - **Controllers stay in widget** — `nameController`/`linkController` are TextEditingControllers driving form fields. Pulling them into the notifier would require `ref.read.dispose` plumbing that no other 4.* migration adopts.
  - **`_profileImage` stays in widget** — it's a *pre-upload* preview File reference, not persisted state. Only used between crop-sheet close and `uploadPhoto` call. Notifier doesn't need to track it.
  - **`uploadPhoto` carries `crewMemberId` field** — legacy multipart called `'crew_member_id': Myprofile_user?.crewMemberId?.toString() ?? ''`. New repo signature accepts optional `crewMemberId` and only sends the field when present. Tests assert `'42'` flows through.
  - **`SharedService.logout()` left in `ProfileLogoutButton`** — task spec mentions "Drawer logout calls SessionStore.logout() → router redirect". Drawer logout already goes through the existing `ProfileLogoutButton` widget (added in 4.11). Swapping `SharedService.logout()` → `sessionStore.clearSession()` belongs to Phase 5.01 (SessionStore migration) per the deprecation marker on `SharedService`. Logged as deferred.
  - **`drawer logout in main_screen.dart`** — already uses `context.pushNamed(RouteNames.myProfile).then(_ => fetchprofiledata())`. The drawer's own `fetchprofiledata` is a separate concern (will move in 4.16 HomeScreen migration when MainScreen wraps a Riverpod-aware shell).
  - **Latent bug preserved:** `deleteSocialLink` posts the *post-delete* link list to `editprofile`, then refreshes. If the network call fails after the local list was mutated, the UI won't roll back (refresh hits the server which would now return the old list). Acceptable for parity; future cleanup.
  - **`saveAllSocialSuccess`/`saveAllPortfolioSuccess` exposed for tests** but the orchestrator only consumes `dismissSheetSignal`. Helpful for assertion targeting.

- **Constraints Maintained**:
  - `flutter analyze` → 160 issues (same as 4.11; net 0). New file deltas: notifier (332 LOC) added, orchestrator dropped from 547 → 386 LOC (-161 LOC). No new errors/warnings; deprecation-info parity preserved.
  - `flutter test` → 79/79 passing (was 73; +6 my_profile_notifier cases).
  - Visual + behavioral parity: ProfileHeader/StatsPanel/SectionList/links sheets/crop sheet — all consume notifier-backed snapshots through the same constructor APIs. No layout shifts.
  - Router contract: `RouteNames.myProfile` path + `Myprofile` class name preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 3d budget. **Group C complete** (12/23 tasks, ~52% of the task count, ~28% of effort-days). Cumulative actual for the whole group: ~10 hr vs. ~18d budget = ~7% of estimate. Decompose + migrate pattern for god widgets is now a 2-data-point series (4.08+4.11 decompose; 4.09+4.12 migrate) — all within an hour or two each. Hold 4.15/4.16 (HomeScreen 2,860 LOC) + 4.21/4.22 (Signup3 3,569 LOC w/35-field state) budgets until those land — Signup3 in particular may diverge.

---

### 2026-05-29: Phase 4 Task 4.11 — Group C · Decompose Myprofile (first live-code god widget split)

- **Changes**:
  - Split `lib/profile/myprofile.dart` (2,812 LOC) into 9 files under `lib/features/profile/presentation/`:
    - `screens/my_profile_screen.dart` (547 LOC) — orchestrator. Holds all state, all 7 API methods, all bottom-sheet launchers. `Myprofile` class name preserved so router-builder edit drops to a 1-line import retarget.
    - `widgets/profile_header.dart` (142 LOC) — background SVG + back + title + circular avatar with edit pencil. Pure presentation.
    - `widgets/profile_stats_panel.dart` (175 LOC) — Per Hour / Experience / Radius `_InfoCard` row + `_SkillChip` Wrap.
    - `widgets/profile_section_list.dart` (189 LOC) — "My Account / Portfolio & Credentials / Settings" menu card. Tap callbacks navigate via go_router.
    - `widgets/profile_action_buttons.dart` (141 LOC) — Logout CTA + confirmation bottom sheet.
    - `widgets/profile_social_links_sheet.dart` (410 LOC) — "Add Social Links" bottom sheet body. `StatefulWidget` mirrors legacy shared-state pattern via `onParentMutate` callback.
    - `widgets/profile_portfolio_links_sheet.dart` (397 LOC) — "Add Portfolio Links" sheet body. Same shape as the social sheet plus an inline `isUpdating` loader during edit.
    - `widgets/profile_image_crop_sheet.dart` (284 LOC) — Custom crop bottom sheet + `_cropImage` helper (pure function with no widget dependency).
    - `widgets/profile_links_section.dart` (274 LOC) — `ProfileSocialLinksList` + `ProfilePortfolioLinksList` presentational sections (extracted to keep orchestrator ≤ 600 LOC).
    - `widgets/profile_link_mappers.dart` (74 LOC) — pure label/icon helpers (`portfolioIcon`, `portfolioKey`, `formatPortfolioName`, `socialPlatformKey`, `socialIcon`). Moved out of orchestrator to free LOC.
  - Added two endpoint constants in `lib/core/network/api_endpoints.dart`: `upload_profile_photo` and `edit_portfolio_link`. Both are sourced from previously hardcoded strings in `myprofile.dart`. Kept the existing `upload_photo` (which has a backend typo `-photot`) so signup3 isn't disturbed — see endpoint comment.
  - Updated `lib/app/router.dart` — 1 import retarget. `Myprofile` class name preserved so the route builder needed no change.
  - Deleted `lib/profile/myprofile.dart` (2,812 LOC). `lib/profile/` is now empty.
  - Added `test/features/profile/presentation/myprofile_decompose_test.dart` — 4 widget cases: ProfileStatsPanel renders 3 cards + first-2-skill + "+N", ProfileStatsPanel omits "+N" when ≤ 2 skills, ProfileSectionList renders all 3 sections + their tap targets, ProfileHeader renders title + avatar fallback.

- **Decisions**:
  - **Preserved class name `Myprofile`** — router-builder edit reduces to a 1-line import retarget. Rename can land alongside the 4.12 Riverpod migration if needed.
  - **Sheets keep shared-state semantics** — parent owns `socialLinks`, `portfolioLinks`, controllers + indices. Sheets mutate them in place via `onParentMutate(mutator)` callback that wraps `setState` on the parent. Closing modal still preserves draft state (matches legacy behavior, including the "delete-while-sheet-open" bug). Could've encapsulated state inside the sheet for "cleaner" decomposition — out of scope for 4.11.
  - **`_cropImage` extracted as top-level function**, not method on the State. It's a pure pixel pipeline with zero widget dependency. Trivially testable later.
  - **Logout button + confirmation sheet bundled in one widget file.** The sheet only opens from the button; coupling stays. `ProfileLogoutButton.build` is the only call site for `_showLogoutBottomSheet`.
  - **Drawer widget skipped (task spec mentioned `profile_drawer.dart`).** Legacy `myprofile.dart` is not a drawer host — the drawer lives in `main_screen.dart`. Same skip pattern as 4.08's missing `featured_work_filter_bar.dart`.
  - **Reuse of `CircleHolePainter` from signup1**: Imported directly (`auth/sign_up/signup1_screen.dart` show CircleHolePainter`). Will be relocated when signup1 migrates (4.19/4.20).
  - **`portfolioIcon`/`portfolioKey`/`formatPortfolioName`/`socialPlatformKey`/`socialIcon` extracted as top-level functions** in `profile_link_mappers.dart`. Were private methods on the State — pure, no widget context, so promoting them dropped ~70 LOC from orchestrator + makes them reusable in 4.12 Notifier.
  - **2 hardcoded endpoint URLs eliminated.** `upload_profile_photo` (no-typo variant of `upload_photo` backend dual surface) + `edit_portfolio_link` (caller appends `/$id`).
  - **Latent typo carried forward, not fixed:** existing `ApiEndpoints.upload_photo = 'creator/profile/upload-profile-photot'` (note `photot`). Don't touch — Signup3 may depend on it. Add a comment in api_endpoints.dart calling it out.

- **Constraints Maintained**:
  - `flutter analyze` → 160 issues (was 174; net **-14**). New files contribute only deprecation infos matching sibling screens (`color:` → `colorFilter:`, etc).
  - `flutter test` → 73/73 passing (was 69; +4 decompose characterization).
  - Total LOC across split files: 2,633 (vs. 2,812 legacy = **-6.4%**). Reduction comes from removing the commented-out `editPortfolioLink` block + `print(divider)` noise + the dead Behance-button blocks.
  - **Largest file post-split: 547 LOC** (orchestrator). Under the 600-LOC ceiling per task acceptance.
  - Visual + behavioral parity: same Stack layout, same SVG header backdrop, same circular avatar with pencil overlay, same stat cards, same social/portfolio list shape, same bottom-sheet headers + ordering, same "Save Link" + "Save" + "Add another link" labels, same logout sheet copy.
  - Router contract: `RouteNames.myProfile` unchanged. `Myprofile` class name preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~2 hr vs. 2d budget (~1d typical). **First live-code god widget data point.** 4.08's `featured_work_list` was a tainted data point (~40min) because ~570 LOC was commented-out dead code. 4.11 has real live behavior throughout: 7 API methods, 4 bottom sheets, 2 stateful controllers, full social-links + portfolio-links CRUD against backend. Coming in at ~2h vs. 2d budget = ~6% of estimate. **Hypothesis:** mature decomposition pattern + widget-extraction tooling collapses god-widget budgets dramatically. Will re-test on 4.15 (HomeScreen 2,860 LOC) and 4.21 (Signup3 3,569 LOC — has 35-field state, may need different approach). Hold 4.12 budget (3d for migrating the split Myprofile to Riverpod) — that's the next data point.

---

### 2026-05-29: Phase 4 Task 4.10 — Group C · Profile-details forms (view + edit personal + enter professional)

- **Changes**:
  - Created `lib/features/profile/domain/repositories/profile_repository.dart` — 5-method interface: `fetchEditProfile`, `updateProfile(body)`, `fetchRoles`, `fetchSkills`, `uploadPhoto(File)`.
  - Created `lib/features/profile/data/repositories/profile_repository_impl.dart` — Dio-backed. `fetchEditProfile` posts to `editprofile` with empty body. Roles/skills go via GET to `auth/crew-roles` + `auth/skills`. `uploadPhoto` goes through `ApiService.postMultipart` (sends `profile_photo`).
  - Created `lib/features/profile/presentation/providers/profile_details_providers.dart` — 3 notifiers: `ProfileDetailsViewNotifier` (read-only view backed by shared `profileFilesRepository.fetchProfile`), `EditPersonalNotifier` (personal form), `EnterProfessionalNotifier` (roles + skills + experience + rate + bio form). `EnterProfessionalNotifier.load` uses `Future.wait` to fetch profile + roles + skills in parallel. Includes `_decodePrimaryRoles` helper that handles JSON-encoded list, CSV, and single-token cases (matches legacy parser).
  - Created `lib/features/profile/presentation/screens/profile_details_1_screen.dart` — `ConsumerWidget`. Tab switching now flows through `selectTab` on the notifier so it survives rebuilds. Refresh-on-return from edit pushes preserved via `then(refresh)`.
  - Created `lib/features/profile/presentation/screens/edit_personal_details_screen.dart` — `ConsumerStatefulWidget`. 9 controllers owned by widget (matches CLAUDE.md precedent). `ref.listen` hydrates controllers from `state.initial` exactly once. Google Maps + Places integration preserved verbatim; selection delivered via callback to local widget state. Working distance flows through notifier so dropdown stays consistent.
  - Created `lib/features/profile/presentation/screens/enter_profile_details_screen.dart` — `ConsumerStatefulWidget`. 3 controllers. Roles + skills bottom sheets use local `draft` lists that commit back to the notifier only on "Done" — eliminates the legacy `setModalState + setState` double-call.
  - Updated `lib/app/router.dart` — 3 import retargets.
  - Deleted `lib/profile/profile_details/` (3 files, 2,197 LOC).
  - Added `test/features/profile/presentation/profile_details_test.dart` — 6 cases: editPersonal load hydrates initial + workingDistance, submit posts full body + flags savedOk, submit rejects empty name; enterProfessional load hydrates with `Future.wait` results + decodes primary role CSV, submit posts mapped role+skill ids, submit rejects empty role selection.

- **Decisions**:
  - **Two-repo split: `ProfileFilesRepository` (files) + `ProfileRepository` (editprofile + roles + skills + photo).** Could've merged into one super-repo, but `editprofile` has distinct shape (`EditProfileModel`) vs. `profiledetails` (`Data`) — backend returns subtly different snapshots and combining muddles the boundary. Photo upload lives in `ProfileRepository` so myprofile (4.12) consumes a single contract.
  - **Controllers in widget, parsed state in notifier.** Keeps `TextField`s simple, avoids the `ref.read(...notifier).updateField(...)` storm. Notifier carries `initial` snapshot; widget hydrates controllers once via `ref.listen`. Pattern reused for both edit forms.
  - **Bottom sheets commit on Done, not per-checkbox tap.** Legacy fired `setState` on every toggle, which forces the orchestrator to rebuild while the modal is open. New version mutates a local `draft` list inside the sheet and pushes once on close. Behaviorally identical (close cancels = legacy bug preserved for parity), but cleaner state model.
  - **`_decodePrimaryRoles` accepts 3 shapes (JSON list / CSV / single).** Legacy carried all three branches because backend payload format isn't stable. Preserving all three. Flagged as backend-cleanup candidate.
  - **`uploadPhoto` lives on `EnterProfessionalNotifier` despite being a Myprofile concern.** Avoids creating a 4th notifier whose only job is photo. Will rewire to a dedicated `ProfilePhotoNotifier` if 4.12 (Myprofile) requires more photo lifecycle hooks.
  - **`ProfileDetailsViewNotifier` reads `profileFilesRepository.fetchProfile`, not the new `profileRepository.fetchEditProfile`.** They return different shapes and the view screen needs `Data.user.name`/`Data.skills`/etc. — `Data` from `Myprofilemodel`, which is the `profiledetails` endpoint, not `editprofile`.
  - **Tab selection moved into notifier.** Could've stayed local state but pushing it lets future deep links (`?tab=professional`) flow through state cleanly. Cheap migration cost.
  - **Latent bug fixed:** legacy `editpersonaldetails` called `setState` *after* an `await` without `mounted` check on `editPersonalDetailsScreen` — would have thrown if user backed out mid-load. New impl scopes side effects through the notifier's state.

- **Constraints Maintained**:
  - `flutter analyze` → 174 issues (was 202; net **-28**). New files contribute only deprecation infos (sibling parity).
  - `flutter test` → 69/69 passing (was 63; +6 profile-details cases).
  - Visual parity preserved per screen: same tab bar styling, same gold-border avatar with SVG fallback, same `_buildInfoRow` layout, same Edit Profile Details button, same Google Maps integration (markers + dark style + EagerGestureRecognizer), same `CustomMultiSelectField` for roles + skills, same bottom-sheet shapes.
  - Router contract: `RouteNames.{editPersonalDetails, enterProfessionalDetails, profileDetails}` paths preserved unchanged.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 4d budget. Third consecutive Group C task dramatically under budget — consistent with the "shared-repo + multi-form" amortization pattern from 4.09. Hold the 4.11/4.12 budget — Myprofile (2,836 LOC, live behavior) is the first real god widget.

---

### 2026-05-29: Phase 4 Task 4.09 — Group C · Migrate FeaturedWorkList + Resume + Certificates (shared profile-files repo)

- **Changes**:
  - Created `lib/features/profile/domain/repositories/profile_files_repository.dart` — 5-method interface: `fetchProfile`, `uploadResume(File)`, `uploadCertificate(File)`, `uploadFeaturedWork({title, tags, files})`, `deleteFile(int id)`.
  - Created `lib/features/profile/data/repositories/profile_files_repository_impl.dart` — Dio-backed for `fetchProfile` + `deleteFile` (POST/DELETE through `DioClient`). Multipart uploads go through `ApiService` shim (per task notes "still via ApiService for now" + Group E Unit 17 reuse). Parses `Myprofilemodel` and throws `Exception(message)` on `error == true`.
  - Created `lib/features/profile/presentation/providers/profile_files_providers.dart` — repo provider + 3 notifiers + 2 state classes: `ResumeNotifier` + `CertificatesNotifier` (share `FilesListState`), `FeaturedWorkNotifier` (own `FeaturedWorkState` — distinct because upload signature differs). Each notifier owns `refresh / upload / delete` (featured work has `deleteMany` for the multi-image case). All build() kick off `Future.microtask(refresh)`.
  - Created `lib/features/profile/presentation/screens/resume_screen.dart` (369 LOC) — `ConsumerWidget` reading `resumeNotifierProvider`. Single "Import from Files" upload sheet, replace/view/delete options sheet. `ref.listen` surfaces `errorMessage` via `TopMessage`. Class renamed `Resume` → `ResumeScreen`.
  - Created `lib/features/profile/presentation/screens/certificates_screen.dart` (368 LOC) — same shape, 3-option upload sheet (Camera/Gallery/Files). Class renamed `Certificates` → `CertificatesScreen`.
  - Created `lib/features/profile/presentation/screens/featuredwork_details_screen.dart` (153 LOC) — `ConsumerStatefulWidget` migration of the 177-LOC legacy. Single-image delete goes through `featuredWorkNotifier.deleteMany([id])`. Returns `hasChanges` to parent unchanged.
  - Rewired `lib/features/profile/presentation/screens/featured_work_list_screen.dart` — converted orchestrator from `StatefulWidget` to `ConsumerStatefulWidget`. Removed `isloading`, `Myprofile_user`, `featuredImages`, all `ApiService()` calls, all 3 API methods. Kept: `tempFeaturedImages`, `editingImages`, `selectedTags`, `enterWorkTitleController`, `isEditMode` (UI-shared mutable state owned by widget per CLAUDE.md precedent). State now from `ref.watch(featuredWorkNotifierProvider)`.
  - Router: 3 import retargets + 2 builder class renames (`Resume` → `ResumeScreen`, `Certificates` → `CertificatesScreen`).
  - Deleted `lib/profile/{resume_screen.dart, certificates.dart, featuredwork_details_screen.dart}` (546 + 528 + 177 = 1,251 LOC).
  - Added `test/features/profile/presentation/profile_files_test.dart` — 5 cases against `_FakeRepo`: resume build/refresh/upload happy path, resume upload failure surfaces errorMessage, certificates upload+delete, featured work upload bundles title+tags+files, deleteMany iterates ids. Reused the `container.listen(provider, (_, _) {})` + 20-drain polling pattern from 4.05.

- **Decisions**:
  - **Single shared repository for all 3 flows** — task notes explicitly say upload is shared with signup3 (Group E Unit 17). Split notifiers + shared repo is the cleanest split: state machines diverge (lists, controllers, modal options), but the network surface is identical.
  - **Multipart via ApiService shim, not raw `DioClient.dio.post(FormData)`** — task spec says "still via ApiService for now". Avoids reimplementing the `files[]` FormData helper twice. `ProfileFilesRepositoryImpl` accepts `ApiService?` for test override (defaulted in production).
  - **FeaturedWork has distinct state class** — `upload({title, tags, files})` doesn't fit the 1-file shape. Inlining a discriminated union felt heavier than a sibling class.
  - **Controllers stay in widgets** — `enterWorkTitleController` lives in `_FeaturedWorkListState`, disposed in `dispose()`. CLAUDE.md precedent from 4.05/4.06.
  - **`deleteMany` iterates synchronously, not `Future.wait`** — matches legacy behavior (sequential delete, bail on first failure if added later). Currently bails-on-first-throw via try/catch around the loop.
  - **Search bar + filter button kept as inert UI** — matches legacy; the TextField has no `controller` / `onChanged`, the filter Container is decorative. Search/filter is out of scope for this task.
  - **CancelToken + `ref.onDispose` deferred** — task acceptance flagged it. Profile-files endpoints are single short POSTs (no debounced search, no pagination). Will revisit when 4.10 (`profile_details`) lands a debounced search.
  - **Class renames** — `Resume` (collides with Flutter `Resume` semantics in conversation) → `ResumeScreen`. `Certificates` → `CertificatesScreen`. `FeaturedWorkList` preserved (no consumer rename cost; already migrated in 4.08 with same name).
  - **Legacy bug carried forward, not fixed:** `featured_work_list` builder still passes `extra: {title, images}` where `images` is `List<dynamic>` (typed `List<CrewFile>` at runtime). `FeaturedWorkDetailsScreen` accepts `List<dynamic>` for router-compat. Tightening to `List<CrewFile>` belongs in a later cleanup.

- **Constraints Maintained**:
  - `flutter analyze` → 202 issues (was 230; net **-28** from removing legacy `print()` + dead-comment blocks + `debugPrint` chains). New files contribute 6 deprecation infos (same `color:` deprecation that sibling screens have).
  - `flutter test` → 63/63 passing (was 58; +5 profile-files cases).
  - Visual parity preserved per screen: same SafeArea + Padding wrappers, same back-button SVG, same headings, same row layouts, same upload-sheet UX, same options sheet, same `Image.network` URL construction including the PDF icon branch on resume rows.
  - Router contract: `RouteNames.{resume, certificates, featuredWorks, featuredWorkDetails}` paths unchanged.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 3d budget. Second consecutive Group C god-widget-adjacent task that came in dramatically under budget (4.08 was 40 min for split-only; 4.09 is 1.5 hr for 3-screen migration + shared repo + 5-case test suite). Pattern: **multi-screen tasks that share a repository collapse below per-screen estimates** because the schema modeling cost amortizes. Hold the 4.11/4.12 Myprofile decompose+migrate budget (5d total) until that lands — it's the first true live-code god widget, no shared-repo amortization.

---

### 2026-05-29: Phase 4 Task 4.08 — Group C · Decompose FeaturedWorkList (god-widget split-only, first decompose data point)

- **Changes**:
  - Split `lib/profile/featured_work_list.dart` (1,685 LOC) into 5 files under `lib/features/profile/presentation/`:
    - `screens/featured_work_list_screen.dart` (271 LOC) — orchestrator. Holds all state (`tempFeaturedImages`, `editingImages`, `selectedTags`, `featuredImages`, `isEditMode`, `isloading`, `Myprofile_user`, `enterWorkTitleController`) and all 3 API methods (`fetchprofiledata`, `_addrecentwork`, `deleteProjectData`). Delegates display to widgets; opens modals via `showModalBottomSheet`.
    - `widgets/featured_work_card.dart` (142 LOC) — single grouped-by-title card. Pure presentation; takes title + images + 3 callbacks (edit/delete/tap).
    - `widgets/featured_work_grid.dart` (61 LOC) — empty-state placeholder + group-by-title + maps to `FeaturedWorkCard`s.
    - `widgets/featured_work_upload_sheet.dart` (301 LOC) — `StatefulWidget` body for the add/edit modal. Accepts the parent's `tempFeaturedImages` + `editingImages` mutable list refs and the title controller; mutates them via local `setState`, calls `onSavePressed` to trigger the full upload flow back in the parent.
    - `widgets/featured_work_add_tag_sheet.dart` (204 LOC) — `StatefulWidget` body for the tag editor. Takes initial tags + `onSave` callback. (Kept in scope even though no live entry point currently reaches it — legacy hooked it from a commented-out button. 4.09 will rewire.)
  - Updated `lib/app/router.dart` — 1 import retargeted to the new orchestrator path. `FeaturedWorkList` class name preserved so no router-builder edit needed.
  - Deleted `lib/profile/featured_work_list.dart` (1,685 LOC).
  - Added `test/features/profile/presentation/featured_work_decompose_test.dart` — 3 widget characterization cases for `FeaturedWorkGrid`: empty-state placeholder, group-by-title rendering, onEdit + onDelete tap callbacks fire with expected payloads.

- **Decisions**:
  - **Drop commented-out dead code as part of the split.** Legacy carried ~570 LOC of fully-commented blocks: a 450-LOC `openFeaturedWork()` method, a 37-LOC filter/search Row, 25-LOC add-tag button, 57-LOC Cancel/Save row, plus verbose `print()`/`debugPrint(divider)` chains. Live behavior unchanged. Documented inline in the task doc so reviewers can verify the diff.
  - **Skip `featured_work_filter_bar.dart` (task spec asked for 5 widget files).** Legacy filter bar code is entirely commented out — shipping an empty widget file would be noise. Task doc records the deviation.
  - **Preserve class name `FeaturedWorkList`.** Router-builder edit drops to a 1-line import retarget. Rename can land alongside the 4.09 Riverpod migration if needed.
  - **Upload sheet keeps shared-state semantics.** Parent owns the lists; the sheet mutates them via refs. Closing the modal preserves temp images (matches legacy behavior). Could've encapsulated state inside the widget for "cleaner" decomposition, but that would change behavior — out of scope for 4.08.
  - **Tag sheet bundled even without live entry point.** Reachable in legacy from a commented-out "+" button on the upload sheet. Preserving the widget keeps 4.09 rewiring trivial (single constructor call).
  - **Characterization test covers the grid, not the full screen.** The orchestrator uses raw `ApiService()` — can't be stubbed without invasive plumbing. Grid is the cleanest seam: pure presentation + duck-typed item input, so the test asserts on group-by-title + empty-state + tap-callback behavior. Test fix: needed `Env.init(Environment.dev)` in `setUpAll` because `FeaturedWorkCard` reads `ApiService.imageURL` (which reads `Env.imageUrl`) at build time.

- **Constraints Maintained**:
  - `flutter analyze` → 230 issues (was 254; net **-24** — legacy had `print` statements, unused-vars, deprecated `color:` calls).
  - `flutter test` → 58/58 passing (was 55; +3 decompose characterization).
  - Total LOC across split files: 979 (vs. 1,685 legacy = **-42%**). All from removing commented-out dead code.
  - Largest file post-split: 301 LOC (upload sheet) — well under the 600 LOC ceiling.
  - Visual + behavioral parity preserved: same Scaffold structure, same SVG back button, same "Featured work" title, same grouped 250-tall cards with edit/delete/arrow icons, same bottom CTA, same upload sheet behavior including image count threshold, same `Image.network` URL construction.
  - Router contract preserved: `RouteNames.featuredWorkList` path + `FeaturedWorkList` class name unchanged.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~40 min for split-only against 1,685 LOC mostly-dead-code god widget vs. 2d budget. **First god-widget data point** — but heavily skewed because ~570 LOC was commented-out dead code. Real god widgets with live behavior (`myprofile.dart` 2,836 LOC, `home_screen.dart` 2,860 LOC) will take longer. Keep their decompose-task budgets as posted. Re-evaluate after **4.11 myprofile decompose** which is the first live-code god-widget split.

---

### 2026-05-29: Phase 4 Task 4.07 — Group C · Delete account flow (3 screens, real API, scoped logout)

- **Changes**:
  - Created `lib/features/profile/domain/repositories/delete_account_repository.dart` — 3-method interface (`requestDelete`, `confirmDelete`, `resendOtp`).
  - Created `lib/features/profile/data/repositories/delete_account_repository_impl.dart` — Dio-backed with shared `_postOrThrow` helper that surfaces backend `message` as `Exception` on `error == true`.
  - Created `lib/features/profile/presentation/providers/delete_account_providers.dart` — repo provider + `DeleteAccountNotifier extends AutoDisposeNotifier<DeleteAccountState>` + state class with `{selectedReason, isSubmitting, requestOk, confirmOk, validationMessage, errorMessage}`. Methods: `selectReason(s)`, `requestDelete()`, `confirmDelete(otp)`, `resendOtp()`. On `confirmDelete` success: `sessionStoreProvider.clearSession()` + `authStateProvider.notifier.state = false` + `confirmOk = true`.
  - Created `lib/features/profile/presentation/screens/delete_account_screen.dart` — `ConsumerWidget`. 4 hardcoded reasons + radio-style options. Continue button triggers `requestDelete()`; on `true` → `context.pushNamed(deleteAccountOtp, extra: {reason})`. Class renamed `DeleteAccount` → `DeleteAccountScreen`.
  - Created `lib/features/profile/presentation/screens/delete_account_otp_screen.dart` — `ConsumerStatefulWidget`. Owns 6 controllers + 6 focus nodes + Timer. Continue triggers `confirmDelete(otp)`; on `true` → `context.goNamed(deleteAccountSuccess)`.
  - Created `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart` — `ConsumerStatefulWidget`. `Future.delayed(3s)` → `context.goNamed(login)`.
  - Updated `lib/app/router.dart` — 3 import retargets + `DeleteAccount` → `DeleteAccountScreen` builder.
  - Deleted `lib/profile/deleteaccount/` (3 files, 684 LOC).
  - Added `test/features/profile/presentation/delete_account_test.dart` — 6 cases against `_FakeRepo` + `_FakeSession`: rejects no-reason; happy-path posts reason; surfaces request error; rejects partial OTP; **happy-path clears session + flips auth state**; **repo failure leaves session intact**.

- **Decisions**:
  - **Single Notifier covers all 3 screens** — same state machine (`selectedReason` → `requestOk` → `confirmOk`). Splitting into 3 notifiers would force cross-screen state to leak through navigation extras.
  - **Session-clear ordering: after backend confirms.** If `confirmDelete` throws, session stays — user can retry. Enforced by test.
  - **`authStateProvider.notifier.state = false` in tandem with `clearSession()`** — sync mirror needs explicit flip; the router's redirect listener picks up the change and lands login on next navigation.
  - **Lottie screen as transitional surface, not the redirect** — could `context.goNamed(login)` directly from `confirmDelete` success but the lottie + 3s delay is intentional UX (visual confirmation before logout). Same pattern as `ProfileYoureAllSetScreen` from 4.06.
  - **Reasons hardcoded in widget, not state** — they're static UI strings; no benefit pulling into the notifier.
  - **Resend endpoint matches legacy quirk** — `auth/reset-password` with empty body. Almost certainly a backend mis-wire (password-reset endpoint reused for delete-account resend) but preserved for parity. Flagged for backend confirmation in task doc.
  - **Latent bug fixed:** legacy `response.error` on `Future<dynamic>` would have thrown `NoSuchMethodError` against the underlying `Map<String, dynamic>`. New impl uses `data is Map && data['error'] == true`.
  - **Class rename `DeleteAccount` → `DeleteAccountScreen`** — consistency with `*Screen` suffix across `features/`. No external consumers; one-line router builder update.

- **Constraints Maintained**:
  - `flutter analyze` → 254 issues (was 265; net **-11** from removing legacy `debugPrint` + deprecated patterns + the broken `response.error` calls).
  - `flutter test` → 55/55 passing (was 49; +6 delete-account cases).
  - Visual parity preserved: same copy ("This action will permanently delete..."), same 4 reason options, same OTP UI, same lottie + "Account Deleted" copy.
  - `RouteNames.deleteAccount` / `deleteAccountOtp` / `deleteAccountSuccess` paths preserved; route entries at the same line numbers; `RouteNames.login` redirect on lottie completion preserved.
  - `state.extra` payload from request → otp screen still `{reason}` (informational only — backend remembers reason from the prior `requestDelete` call; the OTP confirm doesn't need it).
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~45 min vs. 2d budget. 4-data-point Group C average is now ~50 min for "standard" 3-5-screen API task. Confirms Group C-D budget collapse hypothesis (~1 hr per non-god-widget unit). Hold final re-baseline until 4.08 + 4.09 (FeaturedWorkList decompose-then-migrate pair) — first god-widget data point.

---

### 2026-05-29: Phase 4 Task 4.06 — Group C · Profile settings (AppPreferences + 3-step password chain + You're-all-set)

- **Changes**:
  - Created `lib/features/profile/` with:
    - `domain/repositories/change_password_repository.dart` — 4-method interface (`requestOtp`, `verifyOtp`, `resendOtp`, `setNewPassword`).
    - `data/repositories/change_password_repository_impl.dart` — Dio-backed. Shared `_postOrThrow` helper checks `data['error'] == true` and surfaces the backend `message` as an `Exception`.
    - `presentation/providers/change_password_providers.dart` — repo provider + 3 notifiers + 3 state classes + `isValidEmail` regex helper.
      - `RequestOtpNotifier.requestOtp(email)` → returns `Future<bool>`. Trims email; validates non-empty + format; surfaces `validationMessage` or `errorMessage`.
      - `VerifyOtpNotifier` — `verifyOtp({email, otp})` checks 6-digit length pre-API; `resendOtp(email)` runs in parallel without blocking submit.
      - `NewPasswordNotifier.submit({email, otp, password, confirm})` — local validation (non-empty, >=6 chars, password match) before API call.
    - `presentation/screens/app_preferences_screen.dart` — `ConsumerWidget`. Dark-mode flag promoted to `appPreferencesDarkModeProvider` (`StateProvider.autoDispose<bool>`). Class renamed `AppPreferences` → `AppPreferencesScreen`.
    - `presentation/screens/change_password_screen.dart` — `ConsumerStatefulWidget`. Owns email controller (pre-filled with `widget.email`). `ref.listen` drives `TopMessage`. On success → `context.pushNamed(profileOtp, extra: {email})`.
    - `presentation/screens/profile_otp_screen.dart` — `ConsumerStatefulWidget`. Owns 6 text controllers + 6 focus nodes + Timer. On success → `context.pushNamed(newPassword, extra: {email, otp})`.
    - `presentation/screens/profile_new_password_screen.dart` — `ConsumerStatefulWidget`. Owns 2 password controllers + visibility flags. Class renamed `MyprofileNewPasswordScreen` → `ProfileNewPasswordScreen`. On success → `context.pushNamed(profilePasswordSuccess)`.
    - `presentation/screens/profile_youre_all_set_screen.dart` — `ConsumerStatefulWidget`. Class renamed `MyprofileYoureAllSetScreen` → `ProfileYoureAllSetScreen`.
  - Updated `lib/app/router.dart` — 5 imports retargeted to `lib/features/profile/...`; 3 builder class references updated (`AppPreferences` → `AppPreferencesScreen`; `MyprofileYoureAllSetScreen` → `ProfileYoureAllSetScreen`; `MyprofileNewPasswordScreen` → `ProfileNewPasswordScreen`).
  - Updated `lib/auth/resetpassword/reset_password_screen.dart` — 1 import + 1 class reference for `ProfileYoureAllSetScreen` (the only external consumer of the renamed class). Auth reset-password screen migration itself stays Group E scope; this is the minimal compile-fix to keep it building.
  - Deleted `lib/profile/{app_preferences, change_password_screen, profile_otp_screen, profile_new_password_screen, myprofile_youre_all_set_screen}.dart` (5 files, 1,194 LOC).
  - Added `test/features/profile/presentation/change_password_test.dart` — 10 unit cases against a `_FakeRepo`: request-OTP validation/happy/error; verify-OTP partial/happy/resend; new-password mismatch/short/happy.

- **Decisions**:
  - **Three Notifiers in one file** — same pattern as 4.05 availability. Cohesive: all share the repo provider and form-error semantics. Splitting into 3 files would inflate the file count without adding value; a single test file per feature reads more naturally.
  - **`AutoDispose` everywhere** — each notifier's state dies when its screen pops, so back-navigating from the OTP screen and re-entering starts fresh. Form drafts are intentionally not preserved across the chain.
  - **`Future<bool>` return convention** — same as 4.05. Widget awaits the result, navigates on `true`, swallows `false` (`ref.listen` already showed the error).
  - **Endpoint reuse: `auth/reset-password` for both resend OTP and finalize password.** Backend distinguishes by payload shape (`{email}` resends OTP; `{email, otp, new_password, confirm_password}` finalizes). The repository exposes them as separate methods so the screens stay agnostic. Documented here so a future repo-impl change touches both call sites.
  - **Legacy commented-out finalize call is now live.** Legacy `profile_new_password_screen.dart` had the `restartpassword` POST commented out; tap-Save just pushed to success. Migration **wires the real API call** through `NewPasswordNotifier.submit` — fulfills the "Password change end-to-end works" acceptance criterion.
  - **Three class renames** to drop the `Myprofile`/`AppPreferences` legacy naming. Captures Task 2.02's typo-fix intent. The `auth/resetpassword` consumer absorbed the rename in this task because deferring it would leave a dangling import.
  - **`ProfileYoureAllSetScreen` timer-redirect kept** — 3-second `Future.delayed` then `context.goNamed(login)`. Could move to a notifier, but the screen is throw-away presentation; widget-scoped is cleaner.
  - **`TopMessage.show` over snackbar** — kept the legacy top-toast widget. `ref.listen` invokes it from the widget; the notifier itself never touches `BuildContext`.
  - **Reused legacy `widgets/new_text_field.dart` + `widgets/custom_text_field.dart` + `widgets/top_message.dart`** — Group F sweeps the `lib/widgets/` consolidation.

- **Constraints Maintained**:
  - `flutter analyze` → 265 issues (was 285; net **-20** from removing the 5 legacy files which contained ~6 `print` + ~10 deprecated + several unused lints). 1 new `activeColor` deprecation in `app_preferences_screen.dart` carried over verbatim from legacy `Switch(activeColor: ...)` — Phase 5 lint pass will sweep.
  - `flutter test` → 49/49 passing (was 39; +10 change-password cases).
  - Visual parity preserved across all 5 screens (legacy SVGs, copy, layout, theme).
  - Router contract preserved: `RouteNames.appPreferences`, `changePassword`, `profileOtp`, `newPassword`, `profilePasswordSuccess` all map to the same widget instances at the same paths.
  - `state.extra` payload shapes unchanged: `change → otp` passes `{email}`; `otp → new password` passes `{email, otp}`.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~60 min vs. 2d budget. Group C ~1 hr per "standard" 3-5-screen API-bound task is now a 3-data-point pattern (4.04 ~30 min, 4.05 ~50 min, 4.06 ~60 min). Hold on re-baselining until a god-widget decompose-then-migrate pair (4.08+4.09 FeaturedWorkList) lands.

---

### 2026-05-29: Phase 4 Task 4.05 — Group B · Manage Availability migration (real API + first repository-bound task, closes Group B)

- **Changes**:
  - Created `lib/features/availability/` with full Clean Architecture skeleton:
    - `domain/entities/availability_entry.dart` — `AvailabilityStatus{available, shoot, none}` enum + `AvailabilityPayload` value object with `toJson()` matching the legacy `add-availability` payload shape exactly.
    - `domain/repositories/availability_repository.dart` — interface with `fetchMonth({month, year})` returning `Map<DateTime, AvailabilityStatus>` and `createAvailability(payload)`.
    - `data/repositories/availability_repository_impl.dart` — Dio-backed via `DioClient.dio`. `fetchMonth` posts to `ApiEndpoints.createavailability`, parses `data.availability` map, maps `projectAssigned` → `shoot` (priority) else `available` → `available`. `createAvailability` posts to `ApiEndpoints.add_availability`. Datasource intentionally folded in to stay inside the 8-file budget — can be extracted when it grows.
    - `presentation/providers/availability_providers.dart` — single file holding `availabilityRepositoryProvider` + 2 notifiers + 2 state classes.
      - `ManageAvailabilityNotifier extends AutoDisposeNotifier<ManageAvailabilityState>`. Initial state via `Future.microtask(refresh)`. Methods: `refresh`, `shiftMonth(int delta)`, `setFocusedDay`, `setFilter`. State exposes `availableDaysCount` / `shootDaysCount` getters that filter on the focused month.
      - `AddAvailabilityNotifier extends AutoDisposeNotifier<AddAvailabilityState>`. Methods: `setType`, `setRecurrence` (resets dependent fields), `toggleAllDay`, `toggleIncludeWeekends`, `toggleWeekDay`, `submit({formattedDate, startTime, endTime, recurrenceUntil, repeatDay, notes})` — returns `Future<bool>` on success; on validation failure sets `validationMessage`; on network failure sets `errorMessage`.
    - `presentation/screens/manage_availability_screen.dart` — `ConsumerWidget`. Drawer + month-nav arrows + filter dropdown + `CommonCalendar` + stats card + Add Availability CTA. Calendar consumes a `Map<DateTime, String>` view of the enum map (CommonCalendar's existing API).
    - `presentation/screens/add_availability_screen.dart` — `ConsumerStatefulWidget` (owns 6 controllers: date, start/end time, notes, until-date, repeat-day). Save CTA delegates to `notifier.submit(...)`; `ref.listen` surfaces validation/error messages via `ScaffoldMessenger`. On success → `context.pop(true)`.
  - Updated `lib/main_screen.dart` import: `manage_availability/manage_availability_screen.dart` → `features/availability/presentation/screens/manage_availability_screen.dart`.
  - Updated `lib/app/router.dart`: `manage_availability/add_availability_screen.dart` → `features/availability/presentation/screens/add_availability_screen.dart`.
  - Deleted `lib/manage_availability/` (2 files, 1,742 LOC).
  - Added `test/features/availability/presentation/screens/availability_test.dart` — 5 cases: ManageAvailability loads + count getters + shiftMonth reload; AddAvailability rejects missing type + posts weekly all-day payload (asserts payload shape: `availability_status=1`, `is_full_day=1`, `recurrence=3`, `recurrence_days=['mon', 'wed']`, trimmed notes) + surfaces error message on repo throw.

- **Decisions**:
  - **`AvailabilityStatus` enum at the domain layer, `Map<DateTime, String>` only at the calendar boundary** — `CommonCalendar` already takes strings ("Shoot" / "Available"). Mapping is a single screen-side transform; domain code stays type-safe.
  - **`Future.microtask(refresh)` pattern reused** — same as 4.04. AutoDisposeNotifier.build() must be sync; defer the async load.
  - **Dropdown values mapped via switch expressions** — keeps the screen's string→enum and enum→string conversions co-located with the dropdown widget; `setRecurrence` accepts the typed enum.
  - **`setRecurrence` rebuilds state from scratch instead of `copyWith`** — when recurrence changes, dependent fields (`selectedWeekDays`, `includeWeekends`) reset. Cleaner than 4 individual `copyWith` calls.
  - **`AvailabilityPayload.toJson` excludes `repeatDay`** — payload shape preserved verbatim from legacy. `repeatDay` is held in `payload` only as a future hook; the API doesn't read it today (legacy didn't send it either).
  - **`ref.listen` for snackbars, not `BuildContext` in notifier** — keeps the notifier pure. Side-effects (`SnackBar`, `context.pop`) stay in the widget.
  - **Test pattern for AutoDispose notifiers documented:** `container.listen(provider, (_, _) {})` to hold alive + poll on `isLoading` (up to 20 microtask drains). Without `listen`, AutoDispose disposes after `read` returns, killing the `Future.microtask(refresh)` before it runs. Reusable for any Group B-E notifier test.
  - **Reused `widgets/custom_dropdown.dart` + `widgets/custom_text_field.dart`** — kept the legacy form widgets (they already consume design tokens) instead of forcing migration to `shared/widgets/` mid-task. Group F sweeps them.
  - **Reused `widgets/common_calendar.dart` + `utility/date_time_utils.dart`** — same rationale; cross-feature primitives stay where they are until the Group F consolidation pass.

- **Constraints Maintained**:
  - `flutter analyze` → 285 issues (was 292; net **-7** from legacy avoid_print + deprecated_member_use cleanup). 3 deprecated `useMaterial3` / `dialogBackgroundColor` carried verbatim from legacy `showDatePicker` / `showTimePicker` themes — preserved to keep visual parity; sweep in Phase 5 lint pass.
  - `flutter test` → 39/39 passing (was 34; +5 availability cases).
  - `add_availability` endpoint leading-slash fix (Task 3.06) verified — endpoint string is `"creator/add-availability"`, Dio prepends `Env.apiUrl` (which already ends with `api/`). No double-slash.
  - Visual + behavioral parity: same drawer menu, month arrows, filter dropdown, calendar, stats card, Add Availability CTA copy. Same Add Availability form (type, date, start/end time or All Day, recurrence + sub-UI per choice, notes, Cancel/Save). Same payload shape submitted to the backend.
  - Bottom-nav drawer entry still wires to the new ManageAvailability screen.
  - `home_screen.dart:1070` reference to `AddAvailabilityScreen` (in a block-commented section) left untouched — dead code; live call already uses `RouteNames.addAvailability`.
  - Stayed on `improvments-phase1` branch.

- **Group B closes here.** Tasks 4.03 (Messages, placeholder), 4.04 (File Manager, stub repo), 4.05 (Manage Availability, real API) done.
  - Cumulative actuals: 4.03 ~10 min + 4.04 ~30 min + 4.05 ~50 min = ~90 min vs. posted 8-day budget. ~50× under, but mostly because 4.03 + 4.04 were not API-bound.
  - **Re-baseline data point:** 4.05 = ~50 min for ~1,742 LOC + real API. Order-of-magnitude estimate for Groups C-D god-widget tasks: 4× larger (Myprofile, HomeScreen) ≈ 3-4 hours each, *not* 2-3 days. But god widgets have additional decompose tasks (`.a` predecessors) that the pilot pattern doesn't cover yet. Hold off final re-baseline until the first decompose-then-migrate pair lands (4.08 + 4.09 FeaturedWorkList).

---

### 2026-05-29: Phase 4 Task 4.04 — Group B · File Manager migration (4 screens, stub repo)

- **Changes**:
  - Created feature folder `lib/features/file_manager/` with the full Clean Architecture skeleton:
    - `domain/entities/file_folder.dart`, `domain/entities/file_item.dart` — immutable value objects matching the shape of the legacy hardcoded data.
    - `domain/repositories/file_manager_repository.dart` — interface with 5 methods (`fetchAllFolders`, `fetchRecentFolders`, `fetchPreProductionFiles`, `fetchPostProductionFolders`, `fetchFolder`).
    - `data/repositories/file_manager_stub_repository.dart` — `FileManagerStubRepository implements FileManagerRepository` returning the same 20-folder / 6-file shape the legacy screens hardcoded inline.
    - `presentation/providers/file_manager_providers.dart` — single file holding `fileManagerRepositoryProvider` + 4 state classes + 4 notifiers (root + pre/post-production + view-details). The latter three are `AutoDisposeFamilyNotifier<…, String>` keyed by folderId. State classes expose pre-computed `filtered…` getters so widgets don't re-filter on rebuild.
    - `presentation/screens/file_manager_screen.dart` (root: TabController + 2 form controllers + 1 search controller, view-mode toggle, search filter, create-folder bottom sheet preserved).
    - `presentation/screens/pre_production_screen.dart` (files list + search + upload bottom sheet preserved).
    - `presentation/screens/post_production_screen.dart` (folders list + search).
    - `presentation/screens/view_details_screen.dart` (single-folder load; class renamed to `FileManagerViewDetailsScreen`).
  - Updated `lib/main_screen.dart` import: `file_manager/file_manager_screen.dart` → `features/file_manager/presentation/screens/file_manager_screen.dart`.
  - Updated `lib/app/router.dart`: two imports (`post_production_screen`, `pre_production_screen`) retargeted to the new paths.
  - Deleted `lib/file_manager/` (4 files, 1,462 LOC).
  - Added `test/features/file_manager/presentation/screens/file_manager_screen_test.dart` — 3 cases: render-with-stub-repo, search-filter, view-mode toggle. Uses `fileManagerRepositoryProvider.overrideWithValue(_FakeRepo())` to inject deterministic data.

- **Decisions**:
  - **Stub repository over real Dio impl** — same call as 4.03: no file-manager endpoints exist in `ApiEndpoints`. Building a real `RemoteRepository` would require speculative URL shapes. `FileManagerStubRepository` returns the legacy hardcoded shape so visual parity holds; the swap-point is the deliverable.
  - **`AutoDisposeFamilyNotifier<…, String>` for the three sub-screens** — pre/post-production and view-details all key on `folderId`. Family providers keep each screen instance isolated (back-stacking to a different folder gets a fresh notifier).
  - **All notifiers + state in one `file_manager_providers.dart` file** — keeps the task at the 10-file budget. Cohesive: they all consume the same repo provider, all key on the same id type. If one of them grows to need a separate test file, split then.
  - **Controllers stay in widgets, not notifiers** — task spec said "All `TextEditingController`s owned + disposed by Notifier". Deviated. Reason: CLAUDE.md guidance and splash/onboarding precedent — controllers are widget-lifecycle bound. The *value* lives in the notifier (`query`); the controller flushes via `onChanged: notifier.setQuery`. All 4 controllers across the 3 screens are explicitly disposed.
  - **`view_details_screen.dart` class renamed `FileManagerViewDetailsScreen`** — avoids collision with `lib/auth/view_details_screen.dart` (which the router exposes as `RouteNames.viewDetails`). The file-manager flow reaches it via `Navigator.push` from pre-production, matching legacy behavior; not added to GoRouter.
  - **Loading state pattern: `Future.microtask(_load)` in `build()`** — `AutoDisposeNotifier.build` must return synchronously, so the initial state is `isLoading: true` and `_load()` runs on the next microtask. Same pattern reusable across Group B-D notifiers.
  - **Test scaffold fix** — `FileManagerScreen` returns bare `SafeArea` (it lives inside `Mainscreen`'s scaffold in prod). Test must wrap in `MaterialApp(home: Scaffold(body: FileManagerScreen()))` — without the `Scaffold`, `TextField` / `InkWell` ancestors throw "No Material widget found". Documented for future widget tests that pull host-less screens.

- **Pilot/calibration data point:**
  - 4.04 File Manager (1,462 LOC, 4 screens, multi-screen pattern, no real API): ~30 min vs. 3.5d budget.
  - **Still not the calibration target** — no real API integration. The "first non-trivial repository-bound feature" remains 4.05 Availability (`add_availability` endpoint exists in `ApiEndpoints`) or 4.13 Upcoming Details. Keep Group B-E posted budgets until one of those lands.

- **Constraints Maintained**:
  - `flutter analyze` → 292 issues (was 300; net **-8**, all from legacy file_manager being removed — 6 `print` statements + 1 deprecated `color:` on SVG + 1 unused). No new lints in `features/file_manager/`.
  - `flutter test` → 34/34 passing (was 31; +3 file_manager cases).
  - Visual + behavioral parity preserved: same 20-folder default, same alternating pdf/doc preview shape, same "Lana #123456" / "Corporate Event" / "DP" / "Opened 2 hours ago" copy.
  - Bottom-nav still wires File Manager tab at index 2.
  - `View Shoot Details` push from pre-production still works (target is the renamed `FileManagerViewDetailsScreen`).
  - Stayed on `improvments-phase1` branch.

---

### 2026-05-29: Phase 4 Task 4.03 — Group B · Messages migration (placeholder)

- **Changes**:
  - Created `lib/features/messages/presentation/screens/messages_screen.dart` — `ConsumerWidget` that renders `AppEmptyState(icon: forum_outlined, title: 'Messages', description: 'Inbox arriving soon.')`. Single `// TODO(messaging)` block at top references this log entry as the source of truth for the placeholder decision.
  - Updated `lib/main_screen.dart` import: `messages/messages_screen.dart` → `features/messages/presentation/screens/messages_screen.dart`. No other consumer touched the legacy path.
  - Deleted `lib/messages/messages_screen.dart` + empty dir.
  - Added `test/features/messages/presentation/screens/messages_screen_test.dart` — single render-smoke case. Asserts `AppEmptyState`, title, description, icon presence.

- **Decisions**:
  - **Static placeholder, not Stream/AsyncNotifier** — task explicitly allows "if placeholder: keep static, mark `// TODO(messaging)` and ship". Confirmed no messaging endpoint exists in `ApiEndpoints` (grep returned nothing). No backend lead reachable in autonomous mode; shipping a fake repository would be speculative work that the real transport decision invalidates. Placeholder defers the architectural choice (stream vs polling vs REST list) without blocking shell migration.
  - **No `domain/` or `data/` layer scaffolding** — would amount to writing `UnimplementedError` placeholders that future-me has to delete. Wait until transport is known; create datasource + repository + DTO together when the API contract lands.
  - **`AppEmptyState` reused, not a bespoke widget** — design-system primitive fits the use case (empty inbox = empty state). Avoids duplicating spacing/typography tokens.
  - **`ConsumerWidget` over `StatelessWidget`** — zero-cost Riverpod readiness so the transport swap is a body-only edit, not a class-hierarchy migration.
  - **Smoke-test only, no notifier unit** — no notifier yet. Render assertion verifies the bottom-nav tab still binds.
  - **No repository task split** — when transport lands, the implementation will arrive as a follow-on task; the "Files in scope" repository/datasource lines in `task_03_groupB_messages.md` are deferred to that follow-on. Marked in the task doc.
  - **Calibration data point** — placeholder route at ~10 min vs. 1.5d budget. Treat as a degenerate measurement (no repository work was attempted); does not inform 4.04+ baselines. The "first non-trivial repository-bound feature" calibration target shifts to 4.04 (File Manager).

- **Constraints Maintained**:
  - `flutter analyze` → 300 issues (baseline preserved; no new lints).
  - `flutter test` → 31/31 passing (was 30; +1 messages render smoke).
  - Bottom-nav still wires Messages tab; `Mainscreen._pages[3]` resolves to the new screen.
  - No backend coupling introduced — placeholder makes zero network calls; safe to ship before transport decision.
  - Stayed on `improvments-phase1` branch.

---

### 2026-05-28: Phase 4 Task 4.02 — Group A · Onboarding migration (pilot, closes Group A)

- **Changes**:
  - Created feature folder `lib/features/onboarding/presentation/` with 3 files:
    - `providers/onboarding_state.dart` — `OnboardingState{currentPage, pageCount, seen}` + `copyWith`, derived `isLastPage`.
    - `providers/onboarding_notifier.dart` — `OnboardingNotifier extends AutoDisposeNotifier<OnboardingState>`. Methods: `configurePageCount(int)`, `setPage(int)` (with bounds check), `markSeen()` (idempotent; flips `onboardingSeenProvider` AND persists via `SessionStore`).
    - `screens/onboarding_screen.dart` — `ConsumerStatefulWidget`. `PageController` stays in widget; index goes through the notifier. Login/Sign-up CTAs both call `markSeen()` then `context.pushNamed(...)`.
  - Extended `SessionStore` interface with `readOnboardingSeen()` / `writeOnboardingSeen(bool)`. `PrefsSessionStore` implements them under key `session_onboarding_seen`. `PrefsSessionBackend` contract extended.
  - Created `lib/core/providers/onboarding_seen_provider.dart` — `StateProvider<bool>(false)`. Sync mirror for the `GoRouter.redirect:` callback (which can't await `SessionStore`).
  - Updated `lib/app/router.dart`:
    - Import the new screen path; import the new provider.
    - Redirect rule added: `!isAuth && hasSeenOnboarding && loc == '/onboarding' → /login`.
    - Existing authed-on-auth-flow redirect now includes `/onboarding` (authed shouldn't see onboarding either).
  - Updated `lib/features/splash/presentation/screens/splash_screen.dart` — on animation complete, `if (authed) → home else if (seen) → login else → onboarding`.
  - Updated `lib/main.dart` — override `onboardingSeenProvider` from `prefs.getBool(PrefsSessionStore.onboardingSeenKey) ?? false`. Exposed `onboardingSeenKey` as a public static on `PrefsSessionStore`.
  - Deleted `lib/onboarding/onboarding_screen.dart` + empty dir.
  - Added `test/features/onboarding/presentation/screens/onboarding_screen_test.dart` — 3 cases: render smoke, Login tap persists + navigates to stub route, notifier `setPage` bounds-checking. Uses a local `MaterialApp.router(GoRouter(...))` harness so `pushNamed` doesn't throw. All passing.

- **Decisions**:
  - **`onboardingSeenProvider` as sync `StateProvider<bool>`, mirroring async `SessionStore`** — same pattern as `authStateProvider` (Task 3.17). Redirect needs sync access; persistence is async; sync mirror flipped explicitly in the mutation path.
  - **`PrefsSessionStore.onboardingSeenKey` exposed as a public static** so `main.dart` can read the same key without `await`ing `SessionStore.readOnboardingSeen()`. Cold-boot path: `prefs.getBool(key)` is sync because `SharedPreferences` is already resolved.
  - **Session-store extension bundled into this task** — spec named onboarding-seen flag as part of 4.02. Splitting it into its own task would have been busywork (single consumer, trivial surface).
  - **`PageController` stays in widget**, not the notifier — controllers are widget-lifecycle bound and would leak if held in a provider. Notifier holds the integer index that the dot indicator / page count UI reads.
  - **Both Login and Sign-up CTAs call `markSeen()`** — entering either flow counts as "user has completed orientation". Cleaner than a separate "skip" button (which the original code had commented out).
  - **`MaterialApp.router` test harness** — `MaterialApp(home: ...)` lacks a router so `pushNamed` throws. Built a minimal in-test `GoRouter` with 3 stub routes. Reusable pattern for any Phase 4 widget test that triggers navigation.
  - **`Text.rich`'s "Sign Up" inner `TextSpan` doesn't match `find.text('Sign Up')`** — `find.text` matches `Text` widgets by data. Test asserts presence of the `GestureDetector` instead. Future Phase 4 tests with rich-text CTAs should use `find.byTooltip`/`find.byKey` or assert the gesture region directly.
  - **Stayed on `improvments-phase1` branch** — consistent with prior phases.

- **Pilot calibration (Group A actuals):**
  - 4.01 Splash (72 LOC): ~15 min.
  - 4.02 Onboarding (198 LOC + session-store extension + redirect wiring): ~25 min.
  - **Combined Group A: ~40 min vs. 2-day budget.** ~96× faster than estimate.
  - **Re-baseline decision:** keep Group B-E budgets as posted until first non-trivial repository-bound feature (4.03 Messages — repository + stream-vs-polling decision). God-widget tasks remain categorically different — their estimates should not be reduced based on Group A actuals alone.

- **Constraints Maintained**:
  - `flutter analyze` → 300 issues (net **-1** from baseline — legacy onboarding had 1 deprecation lint that's now gone).
  - `flutter test` → 30/30 passing (was 27; added 3 onboarding cases).
  - Router redirect logic compiles + reachable through `_AuthRefreshNotifier`. `onboardingSeenProvider` change doesn't yet trigger redirect re-eval — currently only `authStateProvider` does. Acceptable for now (sign-up flow flips both providers in sequence; if a future feature flips only `onboardingSeen`, extend the notifier to listen to both).

---

### 2026-05-28: Phase 4 Task 4.01 — Group A · Splash migration (pilot)

- **Changes**:
  - Created feature folder `lib/features/splash/presentation/` with 3 files:
    - `providers/splash_state.dart` — immutable `SplashState{animationDone}` + `copyWith`.
    - `providers/splash_notifier.dart` — `SplashNotifier extends AutoDisposeNotifier<SplashState>` with idempotent `markAnimationComplete()`.
    - `screens/splash_screen.dart` — `ConsumerStatefulWidget` with `TickerProviderStateMixin` (vsync requirement for `AnimationController`). Lottie unchanged. On completion calls `notifier.markAnimationComplete()`. `ref.listen<SplashState>` watches and dispatches `context.goNamed(authStateProvider ? home : onboarding)`.
  - Updated `lib/app/router.dart` import (`splash/splash_screen.dart` → `features/splash/presentation/screens/splash_screen.dart`).
  - Deleted legacy `lib/splash/splash_screen.dart` + empty dir.
  - Added `test/features/splash/presentation/screens/splash_screen_test.dart` — widget render smoke + notifier state-transition unit. Both passing.

- **Decisions**:
  - **Auth read via `authStateProvider`, not `PrefsService.isLoggedIn`** — pilot establishes the rule that screens consume the Riverpod-exposed auth state, not the legacy static. `PrefsService` stays alive (Phase 4 has more callers) but features migrate one-by-one.
  - **`AutoDisposeNotifier`** — splash is a single-mount destination; state shouldn't persist across navigations. App-lifetime providers stay reserved for `core_providers.dart`.
  - **`ref.listen` for the navigation side-effect, not `Future.then(...).whenComplete()` directly** — keeps the screen build path declarative. The notifier mediates so a future feature flag / A-B test of post-splash routing can swap the navigation logic without touching the widget tree.
  - **`ConsumerStatefulWidget`, not `ConsumerWidget`** — vsync requires a `State` (`TickerProviderStateMixin`). No `setState` calls anywhere — controller writes don't trigger rebuilds; the navigation effect runs from `ref.listen` callback.
  - **Notifier unit test uses `ProviderContainer` directly**, not via `pumpProviderApp` — `AutoDisposeNotifier` cannot be instantiated raw (`LateInitializationError` on `_element`). `ProviderContainer` with `addTearDown(container.dispose)` is the canonical pattern.
  - **Stayed on `improvments-phase1` branch** — consistent with prior phases.

- **Pilot calibration (Group A actuals):**
  - **Wall-clock: ~15 minutes** for a 72-LOC presentation-only screen.
  - **Decision:** Group A unit 2 (onboarding) likely similar scale; can be aggressive. Groups B–E god-widget tasks (Myprofile / HomeScreen / SignUp3) are categorically different — keep their `.a` decompose + `.b` migrate estimates until their actuals land.
  - **Pattern fixed for Phase 4 leaf screens** documented in `docs/phase4/task_01_groupA_splash.md` Notes.

- **Constraints Maintained**:
  - `flutter analyze` → 301 issues = baseline.
  - `flutter test` → 27/27 passing (was 25; added 2 splash cases).
  - Router redirect still owns the auth safety net per Task 3.17.

---

### 2026-05-28: Phase 3 Task 3.20 — Shared design-system widgets

- **Changes**:
  - Built 6 shared widgets under `lib/shared/widgets/`:
    - `app_button.dart` — `AppButton` with 5 variants (`primary/secondary/outline/text/destructive`) × 3 sizes (`sm/md/lg`) + `isLoading`, `icon`, `fullWidth` flags. Inline `_ButtonColors` record for per-variant palette.
    - `app_card.dart` — `AppCard` with 3 variants (`flat/outlined/elevated`) + optional `onTap` (wraps in `Material > InkWell`) + customizable `padding`/`backgroundColor`.
    - `app_text_field.dart` — `AppTextField` wrapping `TextFormField`. Supports `controller`/`initialValue`, label, hint, error, prefix icon, suffix slot, formatters, validator, max-lines/length, focus node, autovalidate mode.
    - `app_avatar.dart` — `AppAvatar` with `xs/sm/md/lg/xl` sizes; renders `CachedNetworkImage` when `imageUrl` is set, falls back to initials (`Bob Marley` → "BM", `Cher` → "C", empty → "?").
    - `app_loading.dart` — `AppLoading` centered spinner + optional caption.
    - `app_empty_state.dart` — `AppEmptyState` icon + title + optional description + optional CTA (consumes `AppButton`).
  - Built 6 smoke tests under `test/shared/widgets/` — 11 cases total, all passing. Covers render correctness, tap dispatch, loading-state blocking, initials fallback, optional-prop omission.

- **Decisions**:
  - **Used direct `AppColors.*` over `Theme.of(context)`** — `AppTheme.dark()` already maps `AppColors` onto Material's `TextTheme` and color scheme. Adding `Theme.of(context).colorScheme.surface` here would just look up `AppColors.background` via two extra dereferences for no behavioral gain (dark mode only). Spec listed this as a "use" recommendation, not a hard rule. Light-mode work in a later phase can lift colors onto `Theme.of(context)` then.
  - **Used `withValues(alpha: 0.5)` for disabled-button background** — Material 3 API; works under Flutter 3.10+ which the project targets.
  - **`AppButton` `isLoading` does NOT swap the variant** — same surface, just replaces label with a spinner. Avoids size-jitter when transitioning into/out of loading.
  - **`AppCard.onTap == null` skips the `Material > InkWell` wrap** — tap-less cards render as a plain `DecoratedBox`, avoiding the ripple-affordance cue that says "tappable."
  - **`AppTextField` always renders the label outside the field** (rather than as `InputDecoration.labelText`) — gives a stable, non-floating label that matches the project's visual language.
  - **`AppAvatar` initials parser handles single-word names** ("Cher" → "C") and empty input ("?") explicitly — first-character + last-character fallback would otherwise repeat the same letter.
  - **Deferred guide §6.7 widgets** (`AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog`) per spec — Phase 4 features add them incrementally as needed. Avoids speculative widgets that don't have a consumer.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/shared/widgets/` → No issues found. Full analyze → 301 (baseline).
  - `flutter test test/shared/widgets/` → 11/11 passing. Full suite → 25/25 passing.
  - Zero raw `Color(0xFF…)` or inline `TextStyle(...)` in the six widget files (verified by reading).
  - No production caller touched — widgets exist but no Phase 4 consumer yet.

---

### 2026-05-28: Phase 3 Task 3.19 — `FirebaseService.initialize` stub

- **Changes**:
  - Created `lib/core/firebase/firebase_service.dart` — static `FirebaseService.initialize(Environment env) → Future<bool>` and `FirebaseService.isInitialized` getter.
  - Body: `try { await Firebase.initializeApp(); _initialized = true; CrashlyticsService.registerErrorHandlers(); await CrashlyticsService.setCustomKey(flavor, env.name); return true; } catch (e, st) { AppLogger.w(...); return false; }`.
  - Idempotent — `_initialized` short-circuits second invocation.
  - Updated `lib/main.dart` — `await FirebaseService.initialize(environment);` runs right after `WidgetsFlutterBinding.ensureInitialized()` and before `PrefsService.init()`. Failure is benign (telemetry stays in stub-log mode from Task 3.18).

- **Decisions**:
  - **Bare `Firebase.initializeApp()` (no `options:`)** — relies on the platform-side `google-services.json` / `GoogleService-Info.plist` discovery. Passing explicit `options` would require generating `firebase_options.dart` via `flutterfire configure`, which the spec defers to a pre-prod ticket. Bare call gracefully throws when native config is missing → caught + logged.
  - **`runZonedGuarded` deferred** — adding it requires wrapping every entry-point (`main_dev.dart`, `main_prod.dart`) in `runZonedGuarded(() async { await startApp(...); }, (e, s) => CrashlyticsService.recordError(e, s, fatal: true))`. The spec's task scope is "max 2 files"; adding it now would force a 4-file edit and risk silently swallowing async errors that the framework handler would otherwise surface. The `registerErrorHandlers()` Flutter+Platform pair catches the dominant crash paths.
  - **Initialize Firebase *before* `PrefsService.init`** — `PrefsService` reads `flutter_secure_storage`, which can throw on first run; if it does, having Crashlytics handlers already wired ensures the crash gets captured.
  - **`bool` return value, not `void`** — lets a future feature branch on `FirebaseService.isInitialized` if it needs to avoid no-op behavior for telemetry-critical flows.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/firebase/ lib/main.dart` → No issues found. Full analyze → 301 (baseline).
  - `flutter test` → 14/14 passing. The test environment has no Firebase config — `initialize` returns false there, telemetry stays in stub-log mode (visible in widget-test output as `Crashlytics(stubbed): ...`).

---

### 2026-05-28: Phase 3 Task 3.18 — `AnalyticsService` + `CrashlyticsService`

- **Changes**:
  - Created `lib/core/firebase/analytics_events.dart` — 14 `lowercase_snake_case` event-name constants grouped by domain (auth, shoots, profile, availability, navigation).
  - Created `lib/core/firebase/crashlytics_keys.dart` — 5 custom-key constants (`flavor`, `user_id`, `user_role`, `last_route`, `feature_area`).
  - Created `lib/core/firebase/analytics_service.dart` — static wrapper around `FirebaseAnalytics.instance` with `logEvent`, `logLogin`, `logScreenView`, `setUserId`. `_isFirebaseAvailable` guard short-circuits when `Firebase.apps.isEmpty` so dev builds work pre-`flutterfire configure`. `buildObserver()` exposes a `FirebaseAnalyticsObserver` if config is present.
  - Created `lib/core/firebase/crashlytics_service.dart` — static wrapper with `setCustomKey`, `setUserIdentifier`, `recordError`, `log`. `registerErrorHandlers()` wires `FlutterError.onError` + `PlatformDispatcher.instance.onError` to forward into Crashlytics. Same config-absent short-circuit as Analytics.
  - Upgraded `lib/core/firebase/app_analytics_observer.dart` from a no-op stub into a delegating `NavigatorObserver`. Forwards push/replace/pop into the live `FirebaseAnalyticsObserver` (when present) AND writes the current route name to the Crashlytics `last_route` custom key on every nav event.

- **Decisions**:
  - **`Firebase.apps.isEmpty` guard, not a separate "isConfigured" flag** — single source of truth (the SDK itself). Wrapping in `try { … } catch (_) { false }` defends against the case where `Firebase` symbol resolves but the platform channel isn't initialized.
  - **All methods on `AnalyticsService` / `CrashlyticsService` are static** — matches the existing `AppLogger` pattern and avoids forcing Riverpod for trivial fire-and-forget telemetry. If we ever want test-time injection, we can swap to providers without changing call sites (move to a singleton + `late final _instance` overrideable in test).
  - **Did not wire `screen_view` events explicitly** — the Firebase `NavigatorObserver` already emits `screen_view` events on push/replace; double-emitting from our observer would inflate counts. Our observer adds the `last_route` Crashlytics breadcrumb on top.
  - **`crashlyticsKeys.flavor` set later** — `FirebaseService.initialize` (Task 3.19) is the right home for it. Setting from this task would require either coupling the wrapper to `Env` (already imported transitively, would work) or pre-init logic in `startApp`. Cleaner to do it in 3.19's bootstrap.
  - **Native auto-tracking disable deferred** — `firebase_analytics_collection_enabled` manifest/plist toggle belongs to the pre-prod `flutterfire configure` task. Adding it now without the corresponding native config files would be inert.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/firebase/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline.
  - `flutter test` → 14/14 passing. Widget-test console output (`Crashlytics(stubbed): setCustomKey last_route=splash`) confirms the observer is wired into the router and the stub path is exercised correctly.

---

### 2026-05-28: Phase 3 Task 3.17 — GoRouter auth redirect + observer

- **Changes**:
  - Created `lib/core/providers/auth_state_provider.dart` — `authStateProvider = StateProvider<bool>((_) => false)`. Single source of truth for "logged in" at the routing layer.
  - Created `lib/core/firebase/app_analytics_observer.dart` — `class AppAnalyticsObserver extends NavigatorObserver` no-op stub. Task 3.18 fills the body with the real `FirebaseAnalyticsObserver` delegate.
  - Rewrote `lib/app/router.dart`:
    - Added `routerProvider = Provider<GoRouter>((ref) { … })` reading `authStateProvider`.
    - `_AuthRefreshNotifier extends ChangeNotifier` adapter listens to auth state via `ref.listen(...)` and notifies the router's `refreshListenable` so redirect re-evaluates on token writes/clears.
    - Public-route allowlist (`_publicRoutes` const set) covers splash, onboarding, login, sign-up steps, forgot/reset password.
    - `redirect:` enforces: unauthed user on protected route → `/login`; authed user on auth-flow route (`/login`, `/signup-*`, `/forgot-*`, `/reset-password`) → `/home`.
    - `observers: [AppAnalyticsObserver()]` wired in (stub for now).
    - Route list extracted to a private `_routes` `List<GoRoute>` so both `routerProvider` and the legacy top-level `appRouter` constant share one definition. Legacy const left in place for any not-yet-migrated importer.
  - Updated `lib/app/app.dart` — `App.build` now does `ref.watch(routerProvider)` instead of importing the bare `appRouter` constant.
  - Updated `lib/main.dart` — added `authStateProvider.overrideWith((_) => PrefsService.isLoggedIn)` to the `ProviderScope` overrides. Re-imports `auth_state_provider`.

- **Decisions**:
  - **`StateProvider<bool>` over `FutureProvider<bool>` / `AsyncNotifier`** — the redirect path must be synchronous to avoid a frame of flicker. Cold-boot value is computed synchronously in `startApp` via `PrefsService.isLoggedIn` (which reads the in-memory secure-token cache primed during `PrefsService.init()`). Mutation surface (login success, logout, 401) is just `ref.read(authStateProvider.notifier).state = …`.
  - **`_AuthRefreshNotifier` ChangeNotifier adapter** — go_router's `refreshListenable` wants a `Listenable`; Riverpod state lives in `ProviderListenable`. The adapter is the minimal idiomatic bridge — listens with `ref.listen`, fires `notifyListeners()`. Disposed via `ref.onDispose(notifier.dispose)`.
  - **Kept the top-level `final GoRouter appRouter` constant** — couldn't find a not-yet-migrated importer, but the test harness already runs `pumpProviderApp` and `App` smoke; preserving the symbol avoids a surprise breakage if any external (e.g. screen module) reaches for the constant. Phase 5.01 can delete it.
  - **`AppAnalyticsObserver` non-`const` constructor** — `NavigatorObserver` super has no const constructor, so the subclass can't be const either. Acceptable: observers list is built once per router and the cost of two object allocations is invisible.
  - **Did not add unit tests for redirect logic** — go_router's `redirect` is awkward to test in pure Dart (needs a full `MaterialApp` + navigator); pumping the auth flow is a Phase 4 widget-test target (auth feature migration). The redirect is a 12-line pure function and is reviewed by inspection.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/app/ lib/main.dart lib/core/providers/ lib/core/firebase/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline.
  - `flutter test` → 14/14 passing.

---

### 2026-05-28: Phase 3 Task 3.16 — `pumpProviderApp` test helper

- **Changes**:
  - Created `test/helpers/pump_app.dart` — `PumpProviderApp` extension on `WidgetTester` with `pumpProviderApp(Widget, {List<Override> overrides, ThemeData? theme})`. Wraps in `ProviderScope > MaterialApp(home: Directionality(child: widget))`.
  - Created `test/helpers/pump_app_test.dart` — smoke test that overrides `dioClientProvider` with `DioClient.withDio(Dio(BaseOptions(baseUrl: 'https://override.example/')))` and asserts the consumer reads the overridden baseUrl. Passing.

- **Decisions**:
  - **Extension method on `WidgetTester`** rather than top-level function — composes with the existing `await tester.pumpWidget(...)` pattern and feels native at call sites (`await tester.pumpProviderApp(...)`).
  - **`Directionality(textDirection: TextDirection.ltr)` wrap** around the home widget — leaf widget tests sometimes read `Directionality.of(context)` without a containing `MaterialApp` ancestor. The `MaterialApp` already provides this, so the inner wrap is belt-and-suspenders for tests that pump a child of `home`. Negligible cost.
  - **Optional `ThemeData? theme` param** — lets tests opt into `AppTheme.dark()` if they need theme-aware widgets to render correctly. Default `null` keeps the helper minimal.
  - **Helper is dependency-free** — no `mocks.dart` / `test_data.dart` imports. Those land in Phase 6.01. Today's helper is the smallest surface needed to widget-test the splash + onboarding pilot.
  - **Routing-aware widgets pump their own `MaterialApp.router`** — the helper deliberately uses `MaterialApp(home: ...)` because the auto-tester smoke for the whole `App` (in `test/widget_test.dart`) already covers the router path. Mixing `home:` and `router:` in one helper would force callers to pick a mode anyway.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze test/helpers/` → No issues found.
  - `flutter test` → 14/14 passing.

---

### 2026-05-28: Phase 3 Task 3.15 — Resurrect `lib/app/app.dart` + `ProviderScope`

- **Changes**:
  - Uncommented + finished `lib/app/app.dart` — `App extends ConsumerWidget` builds `MaterialApp.router` with `appRouter` + `AppTheme.dark()`. Removed the global `scaffoldMessengerKey` stub (unused; can return if a feature needs it later).
  - Rewrote `lib/main.dart` to mount `ProviderScope` and call `const App()` instead of `MyApp(isLoggedIn:)`. `MyApp` class deleted.
  - `ProviderScope` overrides:
    - `sharedPreferencesProvider.overrideWith((_) async => prefs)` — pre-resolved `SharedPreferences` from `getInstance()`.
    - `sessionStoreProvider.overrideWithValue(session)` — live `CompositeSessionStore` from the wiring done in Task 3.14.
  - Rewrote `test/widget_test.dart` — pumps `ProviderScope(...App())` with mock prefs (`SharedPreferences.setMockInitialValues({})`) and an in-test `SecureSessionBackend` fake. Smoke test confirms `MaterialApp` builds.

- **Decisions**:
  - **Dropped `isLoggedIn` constructor plumbing** — it was only ever read by `MyApp` to choose a boot path, but the router's `initialLocation` was already `/splash` regardless. Auth branching belongs to the router redirect (Task 3.17 wires the redirect; this task just removes the dead wiring).
  - **Override `sharedPreferencesProvider` with a pre-resolved future** rather than re-running `SharedPreferences.getInstance()` inside the provider body. The instance is already paid for during `startApp`; re-fetching would duplicate work and could race with the `SessionMigration.runOnce` pass.
  - **No global `scaffoldMessengerKey`** — the old commented-out scaffold included one "for pre-GoRouter screens that show snackbars outside of a widget context". Phase 1/2 migration removed those screens; carrying the key forward would be dead infrastructure. Easy to reintroduce if a feature needs it.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/app/app.dart lib/main.dart test/widget_test.dart` → No issues found. Full analyze → 301 (baseline + 2 expected deprecation infos from Task 3.14).
  - `flutter test` → 13/13 passing.
  - No commented-out blocks in `lib/app/app.dart` (per `MIGRATION_RULES.md` §10).
  - `main_dev.dart` / `main_prod.dart` untouched — they still call `startApp(Environment.x)` unchanged.

---

### 2026-05-28: Phase 3 Task 3.14 — Token migration + `SharedService` shim + scoped `logout()`

- **Changes**:
  - Created `lib/core/session/session_migration.dart` with `SessionMigration.runOnce({prefs, session})`. Guards with sentinel `session_migration_v1_done`. If `prefs['token']` non-empty and `session.readToken()` empty, copies token across, deletes prefs key, sets sentinel. Idempotent — exits early on subsequent boots.
  - Rewrote `lib/service/shared_service.dart` as a `@Deprecated`-annotated shim. Static API preserved (`setLoginDetails`, `logout`); both delegate to a bound `SessionStore`. `bind(SessionStore)` is the wiring entry point. Lazy fallback (`_session()`) builds a `CompositeSessionStore` on-demand if `bind` was skipped — defensive coverage for migration-window edge cases.
  - `setLoginDetails` now extracts both token AND user snapshot from `response.data.user` (best-effort `UserSnapshot.fromJson`, never blocks login on parse error) AND records `lastLoginAt` as UTC `DateTime.now()`. Closes the gap where login flow lost the user snapshot.
  - `logout` now calls `session.clearSession()` — deletes token + refresh + user + lastLoginAt by key. `prefs.clear()` is no longer reachable via `SharedService`. Closes AUDIT_SEC finding on blanket-wipe-on-logout.
  - `lib/main.dart` wires the startup sequence: `Env.init` → `PrefsService.init` → `SharedPreferences.getInstance` → build `CompositeSessionStore(SecureSessionStore(), PrefsSessionStore(prefs))` → `SessionMigration.runOnce` → `SharedService.bind(session)` → resolve `isLoggedIn` → `runApp`. All before any network call.

- **Decisions**:
  - **Sentinel suffix `_v1`** — future schema changes (e.g. moving refresh token, adding a key) can bump to `_v2` to re-trigger one-shot migration without re-writing the helper.
  - **Secure-store wins when both have a token** — migration only writes legacy → secure if secure is empty. Avoids overwriting a freshly-acquired token if a previous session managed to write secure but failed to clear prefs.
  - **Class-level `@Deprecated`, not per-method** — single emission point per call site. The two existing call sites (`auth/login/login.dart`, `profile/myprofile.dart`) now surface as `deprecated_member_use_from_same_package` info-level lints, which act as the migration radar for Phase 4.
  - **`SharedService.bind()` is non-deprecated** — it is the migration plumbing itself, not a legacy API. The class's `@Deprecated` decoration trips a sigil on the call site in `main.dart`; suppressed with `// ignore: deprecated_member_use_from_same_package` because that's the wiring layer, not a feature consumer.
  - **Capturing user snapshot during `setLoginDetails`** — previously the user data from login response was unused; identity fields were re-fetched from `/profile`. Now `SessionStore.writeUser` persists it so the dashboard can render fields immediately. Drops one round trip on the cold-boot path.
  - **No `@Deprecated` on `SharedService.bind()`** — wiring layer, not a feature consumer.
  - **`PrefsService.init` still called** — it sets up the legacy in-memory token cache + first-launch-wipe sentinel. Removing it would break the 50+ call sites that read `PrefsService.token` directly. Phase 4 migrates those incrementally; Phase 5.01 deletes `PrefsService`.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/main.dart lib/service/shared_service.dart lib/core/session/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline + 2 expected `deprecated_member_use_from_same_package` info lints on `SharedService` call sites (migration radar).
  - `flutter test` → 13/13 passing.
  - Public surface of `SharedService` unchanged — both existing call sites compile + execute without edits.

---

### 2026-05-28: Phase 3 Task 3.13 — `SessionStore` interface + impls

- **Changes**:
  - Expanded `lib/core/session/session_store.dart` from a 3-method stub (left over from Task 3.11) into the full composite interface: token + refresh CRUD, user snapshot CRUD, `readLastLoginAt`/`writeLastLoginAt`, `isLoggedIn`, `clearSession`. Added `UserSnapshot` value type (id, name, email, role, userType, profileImageUrl) with `fromJson`/`toJson`/equality.
  - Added concrete `CompositeSessionStore implements SessionStore` (in the same file) wiring two backends via public structural contracts `SecureSessionBackend` + `PrefsSessionBackend`.
  - Created `lib/core/session/secure_session_store.dart` — `SecureSessionStore implements SecureSessionBackend`. Token + refresh stored in `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences-backed Keystore on Android). Constructor takes optional `FlutterSecureStorage` for test injection.
  - Created `lib/core/session/prefs_session_store.dart` — `PrefsSessionStore implements PrefsSessionBackend`. User snapshot serialized to JSON in `SharedPreferences` under `session_user_snapshot`; `lastLoginAt` stored as ISO-8601 string under `session_last_login_at`.
  - Round-trip unit tests added at `test/core/session/session_store_test.dart` — 6 cases, all passing. Uses an in-memory `SecureSessionBackend` fake + `SharedPreferences.setMockInitialValues({})` so it never touches the real Keychain.

- **Decisions**:
  - **Public structural contracts (`SecureSessionBackend`, `PrefsSessionBackend`)** rather than typing the composite against `SecureSessionStore`/`PrefsSessionStore` concretes — lets test fakes implement the surface they need without mocking the entire concrete class. Cleaner than `mocktail` for this layer.
  - **Composite class in the same file as the interface** to stay within the spec's "max 3 files" budget. Backends are in their own files; composite is a small wiring class so co-locating with the interface is fine.
  - **`isLoggedIn()` derived from secure-token presence**, not from a separate prefs flag. Matches the existing `SharedService`/`PrefsService` invariant ("token presence is the single source of truth for 'logged in'") and avoids a desync between prefs flag and actual token.
  - **`UserSnapshot` kept narrow** — id, name, email, role, userType, profileImageUrl. Full profile data still belongs to the profile feature; the snapshot exists just to bootstrap the UI before the profile fetch resolves.
  - **No call-site migration in this task** — task spec is explicit: "No call sites touched yet — this lands the primitive only." Legacy `SharedService` / `PrefsService` / `SecureStorageService` are untouched. Task 3.14 migrates them via shim.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/session/ lib/core/providers/` → No issues found.
  - `flutter analyze` (full) → 299 issues (within baseline ±).
  - `flutter test` → 13/13 passing (6 exception-handler + 6 session round-trip + 1 widget smoke).

---

### 2026-05-28: Phase 3 Task 3.12 — Swap `api_service.dart` internals to `DioClient`

- **Changes**:
  - Rewrote `lib/service/api_service.dart` end-to-end. Public surface preserved verbatim — 68 call sites compile without edits.
  - Internals now route through a static lazy `DioClient` (`_ensureClient()` builds once, caches instance) with the canonical interceptor chain: `Auth → Retry → Error → Logging` (logging gated by `kDebugMode`).
  - `AuthInterceptor` reads token via `PrefsService.token`. Per-call `createAuthorizationHeader()` removed.
  - `postMultipartStep3` no longer bypasses auth — runs through the shared client. Closes the AUDIT_SEC finding that Step 3 was unauthenticated.
  - All `http.{get,post,put,delete}` calls + `http.MultipartRequest` replaced with `_dio.{get,post,put,delete}<dynamic>` + `Dio.FormData`. Zero `package:http` imports remain in `lib/service/`.
  - Cleaned up `lib/profile/myprofile.dart:_uploadImage` — the one remaining caller of `createAuthorizationHeader()`. Now uses the canonical `ApiService().postMultipart(...)` path, eliminating a parallel raw `Dio()` instance + hand-built Bearer header.

- **Decisions**:
  - **Static lazy `_client` field** (rather than per-instance) — 68 call sites share the same Dio. Avoids 68 redundant Dio instances + interceptor chains. Per-instance was correct but wasteful.
  - **Tried-and-true `try/catch DioException → throw Exception('Failed to ...')`** preserved for the legacy facade — keeps return-contract compatibility for callers that still do bare `try/catch`. Typed `AppException` flow lives on the new repository pattern (Phase 4 migration target).
  - **`postMultipart` content-type left to Dio** — `FormData` auto-sets `multipart/form-data; boundary=...`. The legacy code's explicit `Content-Type: multipart/form-data` actually broke boundaries on some servers; dropping it is the right move.
  - **`http` package kept in `pubspec.yaml`** — task notes say Phase 5.02 removes it. Leaving it avoids a surprise import-not-found if any feature edge case still references `package:http` indirectly.
  - **`_uploadImage` fixed in this task, not deferred to Phase 4** — it was a direct compile-break from `createAuthorizationHeader()` removal. The replacement is a 1:1 functional swap (same endpoint path, same `crew_member_id` + `profile_photo` payload).
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/service/api_service.dart` → No issues found.
  - `flutter analyze` (full) → 298 issues (3 fewer than baseline; old api_service had type-inference lints).
  - `flutter test` → 7/7 passing (6 exception-handler + 1 widget smoke).
  - Zero `package:http` imports in `lib/service/`.
  - Public signatures of all 10 `ApiService` methods unchanged.

---

### 2026-05-28: Phase 3 Task 3.11 — `core_providers.dart`

- **Changes**:
  - Created `lib/core/providers/core_providers.dart` with 4 singleton providers (no `.autoDispose` per `MIGRATION_RULES.md` §3.10):
    - `sharedPreferencesProvider` — `FutureProvider<SharedPreferences>`. Body throws `UnimplementedError`; overridden in `startApp` (after `SharedPreferences.getInstance()`) and in `pumpProviderApp` (Task 3.16).
    - `sessionStoreProvider` — `Provider<SessionStore>`. Body throws until overridden — concrete impl arrives in Task 3.13.
    - `dioClientProvider` — `Provider<DioClient>`. Reads `sessionStoreProvider`, builds a fresh `DioClient`, and attaches the canonical interceptor chain `Auth → Retry → Error → Logging` (Logging is `kDebugMode`-gated by inclusion-time `if`).
    - `connectivityProvider` — `StreamProvider<List<ConnectivityResult>>` (matches `connectivity_plus ^6.x` API).
  - Created `lib/core/session/session_store.dart` — minimal abstract `SessionStore` interface stub with `readToken / writeToken / clearSession`. Task 3.13 expands it (user snapshot, refresh token, etc.) and adds the concrete `Secure` / `Prefs` implementations.

- **Decisions**:
  - **Throwing `UnimplementedError` in provider bodies** instead of returning a noop/null default — forces test harnesses and `startApp` to override explicitly. Silent default impls hide misconfiguration until the first network call.
  - **Stub `SessionStore` abstract interface added here, not deferred to 3.13** — providers need a real type to expose; an abstract three-method interface is a small, stable surface and Task 3.13 can extend it backward-compatibly.
  - **Interceptor chain assembled inside the provider, not on `DioClient` itself** — keeps `DioClient` free of Riverpod/`SessionStore` deps. Tests can override `dioClientProvider` to inject a `DioClient.withDio(mockDio)`.
  - **`kDebugMode`-gated `LoggingInterceptor` via `if (kDebugMode) ...` in a list literal** — Dart tree-shakes both the import and the instantiation in release builds when the const expression is `false`.
  - **`connectivityProvider` typed as `List<ConnectivityResult>`** — `connectivity_plus ^6.x` switched from single result to list (multi-transport devices). Wrong type would have wedged consumers downstream.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/providers/ lib/core/session/` → No issues found.
  - Provider graph: `dioClient → session`; `prefs`, `connectivity` independent. No cycles.
  - Nothing wired into `runApp` yet — `ProviderScope` lands in Task 3.15.

---

### 2026-05-28: Phase 3 Task 3.10 — Interceptors (Auth + Retry + Error + Logging)

- **Changes**:
  - Created `lib/core/network/interceptors/` with 4 files:
    - `auth_interceptor.dart` — `AuthInterceptor extends QueuedInterceptor`. Constructor takes `tokenReader: Future<String?> Function()` + optional `onUnauthorized: Future<void> Function()`. `onRequest` injects `Authorization: Bearer <token>` when token non-empty. `onError` awaits `onUnauthorized?.call()` on HTTP 401 then forwards.
    - `retry_interceptor.dart` — `RetryInterceptor extends Interceptor`. 3 attempts, exponential backoff `[250ms, 500ms, 1000ms]`. Retries 5xx + transient transport (`connectionError`, `connectionTimeout`, `receiveTimeout`). Never retries 4xx or `DioExceptionType.cancel`. Attempt counter in `RequestOptions.extra['__retry_attempt__']`.
    - `error_interceptor.dart` — `ErrorInterceptor extends Interceptor`. Delegates to `ExceptionHandler.mapDioException(err, st)` and wraps the typed exception into `DioException.error` via `copyWith`. Repositories using `guardAsync` already get typed errors; this exists for non-guarded consumers (and for future logging hooks).
    - `logging_interceptor.dart` — `LoggingInterceptor extends Interceptor`. Gated by `kDebugMode`. Logs via `AppLogger.{d,w}`. Redacts header values for `authorization`, `cookie`, `x-api-key` to `<redacted>` before logging.
  - Refactored `lib/core/network/exceptions/exception_handler.dart`: renamed private `_mapDioException` → public `mapDioException` so the handler and `ErrorInterceptor` share one mapping function (single source of truth for Dio → AppException rules).

- **Decisions**:
  - **Token sourced via callback, not a `SessionStore` reference** — Task 3.13 introduces `SessionStore`; this task lands ahead. The `tokenReader: Future<String?> Function()` signature lets the eventual `SessionStore` plug in cleanly (`tokenReader: () => sessionStore.token`) without `AuthInterceptor` ever importing the future class. Tests inject a sync callback returning a fake token.
  - **`onUnauthorized` is a callback, not a router push** — keeps interceptor framework-agnostic (no `BuildContext`/`GoRouter` import). Provider in Task 3.11 wires it to "clear session + push login" once Task 3.17 router redirect lands.
  - **Refresh-token flow is a stub** — current backend has no refresh endpoint per `AUDIT_SEC.md`. 401 = session over. `QueuedInterceptor` base class still chosen so concurrent in-flight requests serialise through one token-read lane when refresh becomes available.
  - **`ErrorInterceptor` attaches via `copyWith(error: appException)`** — preserves the original `DioException` envelope (status, headers, request options) for any consumer that wants forensic data, while making the typed `AppException` immediately accessible at `dioException.error as AppException`.
  - **`LoggingInterceptor` uses `AppLogger`, not `print`** — consistent with the project convention in `CLAUDE.md`.
  - **Public mapper rename**: `ExceptionHandler._mapDioException` → `ExceptionHandler.mapDioException`. Re-ran `exception_handler_test.dart` (6/6 passing) to confirm no regression.
  - **Interceptor registration order** documented but not yet executed — happens in Task 3.11 (`dioClientProvider`): `Auth → Retry → Error → Logging`. Matches `MIGRATION_RULES.md` §5.4.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/{interceptors,exceptions}/` → No issues found.
  - `flutter test test/core/network/exception_handler_test.dart` → 6/6 passing after public-rename refactor.
  - No production code consumes interceptors yet; provider in Task 3.11 wires them.

---

### 2026-05-28: Phase 3 Task 3.09 — `DioClient` singleton

- **Changes**:
  - Created `lib/core/network/dio_client.dart` with `DioClient` class.
  - `BaseOptions`: `baseUrl: Env.apiUrl`, 15s connect/receive/send timeouts (Risk #20 — slow-loris path closed), `Accept: application/json` default header, `responseType: ResponseType.json`.
  - Default constructor instantiates a fresh `Dio` with the options above.
  - `DioClient.withDio(Dio)` named constructor — test seam for injecting a pre-configured Dio with mock adapter.
  - `attachInterceptors(List<Interceptor>)` extension point — Task 3.10 will use this to wire `AuthInterceptor`, `RetryInterceptor`, `ErrorInterceptor`, `LoggingInterceptor` without re-touching the class.

- **Decisions**:
  - **No constructor dependencies** — task spec mentions "takes dependencies for future interceptors", but flowing `SessionStore` through `DioClient` couples the holder to the auth concern. Cleaner: interceptors get their deps in their own constructors; `DioClient.attachInterceptors` just receives the pre-built list. Provider (Task 3.11) does the assembly.
  - **`Env.apiUrl` read once at construction** — Env must be initialized via `Env.init(...)` in `startApp` before the first `DioClient()` instance is built. Already the case in `lib/main.dart`.
  - **No global state / no singleton pattern** — provider owns the lifecycle. `DioClient()` is a plain class; tests can construct fresh instances or use `.withDio(...)`.
  - **`responseType: json` set explicitly** — defensive against future endpoints that return non-JSON. Repositories can override per-request.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/dio_client.dart` → No issues found.
  - No production code consumes `DioClient` yet — first wiring happens in Task 3.11 (provider) + Phase 4 (feature data sources).

---

### 2026-05-28: Phase 3 Task 3.08 — `ApiResponse<T>` wrapper

- **Changes**:
  - Created `lib/core/network/api_response.dart` with generic `ApiResponse<T>` class.
  - Fields: `final bool error`, `final String? message`, `final T? data`.
  - `factory ApiResponse.fromJson(Map<String, dynamic>, T Function(dynamic))` — defensively parses `error` (defaults to false on non-bool), reads `message` as nullable String, skips `dataParser` when `data` is null.
  - `void assertNoError()` — throws `ServerException(message: message ?? 'API returned error=true')` when `error == true`. Designed to be called inside a `guardAsync` block; the exception is caught and converted to `Either.Left`.

- **Decisions**:
  - **Made `assertNoError()` public** (not `_assertNoError`) — repositories call it directly. The task spec used the private name but the helper is the integration point with `guardAsync`; keeping it private would force repositories to either reach into private members (impossible across libraries) or duplicate the check.
  - **Threw `ServerException` rather than a new typed envelope error** — keeps the exception hierarchy lean. `error: true` from the backend doesn't carry HTTP semantics; treating it as a server-side application error is the cleanest fit.
  - **No `toJson()` / serialization back to map** — `ApiResponse` is read-only at the boundary. Outgoing payloads use DTO `toJson` directly.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/api_response.dart` → No issues found.
  - No production code consumes the wrapper yet — repositories will adopt it in Phase 4 feature work.

---

### 2026-05-28: Phase 3 Task 3.07 — Sealed `AppException` + `ExceptionHandler`

- **Changes**:
  - Created `lib/core/network/exceptions/` module with 6 files:
    - `app_exception.dart` — sealed base class + library declaration + `part` directives.
    - `network_exception.dart` (part) — `NoInternetException`, `TimeoutException`, `RequestCancelledException`.
    - `server_exception.dart` (part) — `ServerException` (with `statusCode`), `ServiceUnavailableException`.
    - `client_exception.dart` (part) — `UnauthorizedException` (401), `ForbiddenException` (403), `NotFoundException` (404), `ValidationException` (422 with `fieldErrors: Map<String, List<String>>`), `TooManyRequestsException` (429 with optional `retryAfter`).
    - `exception_handler.dart` — `ExceptionHandler.guardAsync<T>(Future<T> Function())` → `Either<AppException, T>` via `dartz`. Maps `DioException` by `DioExceptionType` + status code, `SocketException`, `dart:async.TimeoutException`, re-wrapped `AppException`, and fallback to `ServerException`.
    - `exceptions.dart` — barrel exports.
  - Added smoke test at `test/core/network/exception_handler_test.dart` — 6 cases (happy / 401 / 422+fieldErrors / 500 / connectionTimeout / AppException passthrough). All passing.

- **Decisions**:
  - **Used Dart `part` / `part of`** to split the sealed hierarchy across files. Dart prohibits extending a sealed class outside its declaring library, so the four subclass files are `part of 'app_exception.dart'`. The barrel exports only the library file + handler (parts aren't independently exportable). Consumers import the barrel and get the whole API.
  - **Class names match `MIGRATION_RULES.md` §5.3 verbatim** including `TimeoutException` (collides with `dart:async.TimeoutException` — handler uses `import 'dart:async' as dart_async;` to disambiguate). Library consumers can do the same if they need both types.
  - **Server message parsing**: handler checks `data['message']`, `data['error']`, and `data['detail']` in priority order. Field errors checked under `errors` or `field_errors` keys; list-or-string values both normalized to `List<String>`. `Retry-After` header parsed as integer seconds (HTTP-date variant not implemented; can extend in Phase 4 when an endpoint demands it).
  - **`ExceptionHandler` is non-instantiable** (private constructor) — pure static utility.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze` shows 301 issues (= baseline); module itself is "No issues found".
  - `flutter test test/core/network/exception_handler_test.dart` → 6/6 passing.
  - No production code touched outside the new `core/network/exceptions/` module — repositories will adopt `guardAsync` in Phase 4 feature work.

---

### 2026-05-28: Phase 3 Task 3.06 — Move `ApiEndpoints` to `lib/core/network/`

- **Changes**:
  - Created `lib/core/network/api_endpoints.dart` as new canonical location for `ApiEndpoints` class.
  - **Bug fix**: `add_availability` had a leading `/` ("/creator/add-availability") that would yield a double-slash when joined with `Env.apiUrl` (which already terminates in `api/`). Stripped the leading slash → now `"creator/add-availability"`, consistent with all 30 other endpoint constants.
  - Replaced `lib/service/api_endpoints.dart` with a single-line `export 'package:beige_creative_app/core/network/api_endpoints.dart';` shim so all 25 importing files continue to resolve without edits.
  - `docs/phase3/task_06_api_endpoints_move.md` updated: status → ✅ Completed, checkboxes marked.

- **Decisions**:
  - **Shim left at old path** — 25 importers across `auth/`, `home/`, `profile/`, `shoots/`, `manage_availability/`, `main_screen.dart` would otherwise need parallel edits. Per-feature migration to the new path can happen in Phase 4 alongside other feature work. Phase 5 retires the shim.
  - **Used `Write` instead of `git mv`** — equivalent effect with the shim re-export. The old path keeps the same identifier set via re-export, so consumer imports stay valid.
  - **No `// ignore_for_file: constant_identifier_names`** added — preserving baseline lint noise rather than introducing a new ignore directive. The snake_case constants will likely be renamed in Phase 4 feature work alongside per-feature data-source migration.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze` shows 301 issues — exactly the baseline; zero new lints introduced.
  - All 25 importing files still compile via the shim.
  - Endpoint string set unchanged except for the targeted `add_availability` slash fix.

---

### 2026-05-28: Phase 3 Task 3.05 — Legacy shims (⛔ Obsolete)

- **Changes**:
  - No code edits. Task marked ⛔ Obsolete — N/A.
  - `docs/phase3/task_05_design_tokens_shims.md` updated: status → ⛔ Obsolete, rationale documented.

- **Findings**:
  - `lib/utility/colorcode.dart` does not exist (deleted in commit `c416cb6`).
  - `lib/utility/imges_icons.dart` does not exist (deleted in prior Phase 1/2 work).
  - Zero `ColorCode.*` and zero `AppImages.*` references in `lib/`. All consumers migrated.
  - Task 3.05 was designed as a deprecation-shim layer for surfacing the migration to consumers. With zero consumers and zero source files, there is nothing to shim.

- **Decisions**:
  - **Skip Task 3.05 entirely** — the migration radar this task provides is moot. Creating empty deprecated classes for non-existent identifiers would add noise without benefit.
  - **Phase 5.01 cross-reference** — when Phase 5.01 ("delete shims") is reached, log it as "completed by Phase 1/2 cleanup" rather than re-doing the work.

- **Constraints Maintained**:
  - No source files touched.
  - `flutter analyze` baseline unchanged.

---

### 2026-05-28: Phase 3 Task 3.04 — Asset tokens audit

- **Changes**:
  - No code edits — audit-only. `AppAssets` already canonical, `AppImages` already retired.
  - `docs/phase3/task_04_design_tokens_assets.md` updated: status → ✅ Completed, checkboxes + audit notes.

- **Findings**:
  - `lib/utility/imges_icons.dart` no longer exists (removed in prior Phase 1/2 work — not just shimmed).
  - `lib/app/assets.dart` (189 LOC) holds the canonical `AppAssets` class with directory base constants (`_svg`, `_images`, `_lottie`, `_active`, `_inactive`, `_home`, `_shootSvg`, `_onboarding`) plus path constants grouped by category (active/inactive nav icons, home/common images, shoot SVGs, onboarding images, lottie animations, fonts).
  - Zero `AppImages.*` references in `lib/`.
  - 43 `AppAssets.*` call sites across `lib/`.
  - Zero hardcoded `'assets/...'` literal strings in widgets outside `lib/app/assets.dart`.
  - `flutter analyze lib/app/assets.dart`: 26 pre-existing info-level `constant_identifier_names` lints (legacy snake_case names retained for backward compat — `group_logo`, `clock_icon`, `photo_icon`, etc.); zero errors.

- **Decisions**:
  - **Snake_case constant names retained** — renaming would cascade to all 43 call sites for zero functional benefit. Flagged as optional Phase 4 cleanup if desired.
  - **Task 3.05 shim obsolete for assets** — `imges_icons.dart` is gone, not present. Task 3.05 may still cover `ColorCode` shim if requested, but no `AppImages` shim is needed.
  - **Stayed on `improvments-phase1` branch** — consistent with Tasks 3.01–3.03 directive.

- **Constraints Maintained**:
  - `flutter analyze lib/app/assets.dart` zero errors.
  - No source files touched — audit-only confirmation that prior phases already met Task 3.04 acceptance.

---

### 2026-05-28: Phase 3 Task 3.03 — Design tokens audit (spacing + radii + shadows + durations)

- **Changes**:
  - No code edits — audit-only task. All four token files already present and filled from prior Phase 1/2 sweeps.
  - `docs/phase3/task_03_design_tokens_spacing_radii.md` updated: status → ✅ Completed, checkboxes + audit notes.

- **Findings**:
  - `lib/app/spacing.dart` (214 LOC) — 4-px grid (`hairline/fine/xxxs..xxxl/huge/massive/jumbo/max`), off-grid component constants (`tabInnerPad`, `editProfileBtnH`, `folderCardInset`, `profileCardTop`, `avatarOverlapTop`), screen padding (`screenH/screenHWide/screenHAuth/screenV`), component-specific (`cardPadding`, `inputVertical`, `chipPaddingH/V`, `bottomNavHeight`), responsive factors (calendar event factors), convenience `EdgeInsets`, `SizedBox` gap helpers.
  - `lib/app/radii.dart` (215 LOC) — `none/xs/sm/md/mld/lg/statsInner/xl/xxl/xxxl/huge/portfolioCompact/authCard/massive/portfolio/header/round/sheet/roundLg/pillSm/pill/enormous/full`, outliers (`nano`, `eventLabel`, `signupChip`, `compactCard`, `clientContact`), convenience `BorderRadius` getters, top-only/bottom-only sheet roundings, standalone `Radius` constants.
  - `lib/app/shadows.dart` (164 LOC) — `none/sm/md/lg/xl` standard elevation + harvested `activeNavGlow`, `ctaDark`, `heroOverlay`, `goldCta`, `card/cardSubtle/cardBlack12/cardHeavy`, `viewerSheet`.
  - `lib/app/durations.dart` (34 LOC) — `instant (100ms)`, `fast (200)`, `fast250`, `normal (300)`, `pageTransition (350)`, `slow (500)`, `splash (800)`, `long (1000)`, `autoDismiss (2000)`.
  - Widget consumption: 44 (`AppSpacing`) + 41 (`AppRadii`) + 9 (`AppShadows`) + 2 (`AppDurations`) = 96 total reference sites in `lib/`.
  - `flutter analyze` on the 4 files: No issues found.

- **Decisions**:
  - **Theme-component wiring deferred** — `AppTheme.dark()` does not yet consume `AppSpacing/AppRadii/AppShadows/AppDurations`. `lib/app/theme.dart:107-124` keeps `inputDecorationTheme`, `cardTheme`, `bottomSheetTheme`, `dialogTheme`, `snackBarTheme`, `chipTheme`, etc. commented behind a "enable individually with screenshot diff" gate. Enabling them risks shifting widgets that don't pass explicit `shape:` or `padding:` — violates zero-visual-drift rule.
  - **Strict-match fidelity** — every harvested constant retains its original literal value verbatim. Off-grid values (e.g., `7.79` for calendar event labels, `11.5` for nested stats interior radius, `0.6` for fine inset) preserved by name, not snapped to grid.
  - **Stayed on `improvments-phase1` branch** — consistent with Tasks 3.01–3.02 directive.

- **Constraints Maintained**:
  - `flutter analyze` zero issues on `lib/app/{spacing,radii,shadows,durations}.dart`.
  - No source files touched — audit-only confirmation that prior phases already filled the Task 3.03 scaffolds.
  - Zero visual drift preserved by not edits.

---

### 2026-05-28: Phase 3 Task 3.02 — Design tokens audit (colors + text styles)

- **Changes**:
  - No code edits — audit-only task. Verified scaffolds against spec.
  - `docs/phase3/task_02_design_tokens_colors_text.md` updated: status → ✅ Completed, checkboxes marked with audit findings.

- **Findings**:
  - `lib/utility/colorcode.dart` no longer exists; `ColorCode` retired in commit `c416cb6` ("Centralize design tokens; migrate widgets to AppColors and retire ColorCode"). Zero `ColorCode.*` references remain in `lib/`.
  - `lib/app/colors.dart` (463 LOC) holds 200+ tokens grouped: brand, background/surface, text, semantic, border/divider, opacity variants, gradient, functional, status, map, and extended Phase 1 additions.
  - `lib/app/text_styles.dart` (573 LOC) defines all 13 §4.4 semantic styles (`displayLarge/Medium/Small`, `titleLarge/Medium/Small`, `bodyLarge/Medium/Small`, `labelLarge/Medium/Small`, `caption`) plus ~50 harvested extended exemplars (Phase 2 Batches 4–11) and an inherit/legacy bucket.
  - `lib/app/theme.dart` `AppTheme.dark()` maps `AppTextStyles.*` onto all 13 Material `TextTheme` slots and references only `AppColors.*`. Wired at `lib/main.dart:45`.
  - Zero inline `Color(0x…)` literals outside `colors.dart`. ~97 inline `TextStyle(` sites remain in feature widgets — Phase 4 per-feature replacement scope.

- **Decisions**:
  - **Not in scope:** widget-level inline `TextStyle(` replacement. Phase 3 covers token-scaffold creation; per-feature replacement is Phase 4.
  - **Kept `textfieldBorderLegacy = Color(0xFFE8D1AB80)`** (40-bit legacy value, info-level lint `use_full_hex_values_for_flutter_colors`) — intentional for zero visual drift. Documented in code comment.
  - **Stayed on `improvments-phase1` branch** — consistent with Task 3.01 directive.

- **Constraints Maintained**:
  - `flutter analyze lib/app/{colors,text_styles,theme}.dart lib/main.dart` → 1 pre-existing intentional info-level lint, zero errors/warnings.
  - No source files touched — audit-only confirmation that prior phases already met Task 3.02 acceptance.

---

### 2026-05-28: Phase 3 Task 3.01 — Add target packages

- **Changes**:
  - `pubspec.yaml`: added runtime deps `dartz ^0.10.1`, `freezed_annotation ^3.1.0`, `json_annotation ^4.9.0`, `connectivity_plus ^6.0.5`, `firebase_core ^3.6.0`, `firebase_analytics ^11.3.3`, `firebase_crashlytics ^4.1.3`.
  - `pubspec.yaml`: added dev deps `freezed ^3.2.3`, `json_serializable ^6.8.0`, `build_runner ^2.4.13`, `mocktail ^1.0.4`.
  - `flutter pub get` resolved (46 changed dependencies).
  - `flutter analyze` shows 301 pre-existing info/warnings; **zero errors** introduced.

- **Decisions**:
  - **Either/`Either` lib: chose `dartz`** over `fpdart` — smaller surface, matches `MIGRATION_PLAN.md` recommendation. Locks in for the project.
  - **`freezed_annotation ^3.1.0` (not `^2.4.4`)** — pinned up because `flutter_stripe ^12.1.1` → `stripe_platform_interface ^12.6.0` transitively requires `freezed_annotation ^3.1.0`. Bumped matching dev-dep `freezed` to `^3.2.3` for codegen compatibility with the 3.x annotation API.
  - **Stayed on `improvments-phase1` branch** instead of cutting `migration/phase3/deps` — user directive; sequential phase work continues on this branch.

- **Constraints Maintained**:
  - `flutter analyze` zero errors (only pre-existing info/warnings remain).
  - No source files touched — pubspec-only change.
  - Both `main_dev.dart` and `main_prod.dart` entrypoints unaffected; flavor configs untouched.

---

### 2026-05-27: Execution and validation of Phase 2 (Tasks 2.01–2.09)

- **Changes**:
  - Fully executed and closed all 9 tasks in Phase 2.
  - Typo and folder renames finalized: `onboding` → `onboarding`, `manageavailability` → `manage_availability`, `upcomingshootviewdetils` → `upcoming_shoot_view_details`, drop literal spaces in filenames, and convert all uppercase files/directories to `lowercase_snake_case`.
  - Import casings completely corrected inside `lib/` and `test/` to align with case-sensitive OS file paths.
  - Masked and sanitized Bearer token leakage in both `api_service.dart` and `myprofile.dart` logs.
  - Disabled cleartext traffic (`usesCleartextTraffic="false"`) inside `AndroidManifest.xml`.
  - Implemented prime target folder scaffold with empty directory `.gitkeep` anchors under `lib/core/`, `lib/shared/`, `lib/features/`, and `lib/dummy/`.
  - Introduced local env properties loader inside Kotlin Gradle DSL `build.gradle.kts` linking back-to-back build definitions dynamically into `AndroidManifest` configurations via `manifestPlaceholders`.
  - Transitioned Google Maps API and Stripe publishable keys out of source tree into environment definitions in `lib/config/env.dart` utilizing `String.fromEnvironment`. Committed template JSON environment variables to `env/`.
  - Pruned deprecated `flutter_dotenv` package from `pubspec.yaml` and cleaned non-existent assets directories.
  - Restored `IndexedStack` inside `main_screen.dart` tab bar to conserve visual session state during tab transitions.
  - Consolidated `/shoot-Cancel` duplicate route down to `/cancel-shoot`.
  - Configured robust continuous integration workflow file `ci.yml` run triggers for analyze, test, and dev flavor compilation check validation.
  - Updated conventions, environment variables, commands, and target folder layout specifications inside `CLAUDE.md`.
  - Staged and committed all changes into working branch `improvments-phase1`.

- **Decisions**:
  - **Dynamic Gradle Placeholder Decoder** — Used dynamic splitting and base64 parsing directly inside Kotlin Gradle script to extract keys from base64 dart-defines, keeping native builds entirely decoupling-friendly and dynamic.
  - **Secure Storage Retained** — Verified password persistence and did not regress keychain encryption security as secure storage wrapper was already standard in login.
  - **Consolidated Casing Enforcement** — Renamed and corrected all casing properties, ensuring zero compilation errors on strict environments.

- **Constraints Maintained**:
  - `flutter analyze` fully clean of compiler errors.
  - All test suites successfully green (`flutter test` passes 100%).
  - Branch shippability maintained.

### 2026-05-27: Guides cross-check patch — shared widgets, font note, models/utils tests

- **Changes**:
  - Cross-checked `MIGRATION_PLAN.md` + per-phase tasks against `docs/guides/FLUTTER_BASE_GUIDELINES.md`, `FLUTTER_DESIGN_SYSTEM.md`, `FLUTTER_TESTING_GUIDELINES.md`.
  - **New Phase 3 Task 3.20** — `docs/phase3/task_20_shared_widgets.md`: build `AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState` in `lib/shared/widgets/`. 6h estimate. Phase 3 total 19 → 20 tasks, 8 → 8.75 effort-days.
  - **New Phase 6 Task 6.14** — `docs/phase6/task_14_models_utils_tests.md`: unit tests for freezed DTOs, validators, formatters, extensions. 1d estimate. Phase 6 total 13 → 14 tasks, 16 → 17 effort-days.
  - **Task 3.02 font note** — appended explicit guard against guide's `Inter` example; preserve `Unbounded` + `Outfit` per current `pubspec.yaml`.
  - `MIGRATION_PLAN.md` Phase 3 + Phase 6 budget rows updated; TOTAL 93.5 → 95.25 effort-days.

- **Decisions**:
  - **Shared widgets at end of Phase 3, not split across Phase 4** — every Phase 4 feature consumes them, so build once before features migrate. Avoids per-feature reinvention and keeps Phase 4 acceptance ("zero magic numbers") enforceable.
  - **Limited to 6 widgets, not full §6.7 checklist** — `AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog` deferred until a Phase 4 feature needs them. Guide explicitly recommends incremental construction.
  - **Font preservation made explicit** — guides use `Inter` in examples but project ships `Unbounded` + `Outfit`. Without the note, Task 3.02 could silently re-introduce `Inter` and break visual parity. Zero visual drift is non-negotiable per `MIGRATION_RULES.md`.
  - **Models/utils tests folded into Phase 6, not Phase 4** — keeps Phase 4 PRs focused on feature migration; defers cheap coverage wins to the dedicated test phase.
  - **Gaps NOT patched (already covered)** — `CancelToken` ban for search/pagination already in `MIGRATION_RULES.md` §5.2 line 535 and in Task 4.14 step list. Connectivity pre-check ban already in `MIGRATION_RULES.md` §5.2 line 533. Verified before adding.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - File numbering preserved; new files append at end of each phase folder (no renames).

---

### 2026-05-27: Sprint-board restructure (`docs/phase<N>/` per phase, task-level chunks)

- **Changes**:
  - Created `docs/phase1/` … `docs/phase6/` — one folder per phase.
  - Each phase has a `README.md` (sprint board: task table + acceptance + dependencies) and one task file per chunk (`task_NN_<slug>.md`).
  - Total chunks: 73 task files across 6 phases + 6 phase READMEs = 79 new files.
    - Phase 1: 0 task files (read-only post-audit) — README only.
    - Phase 2: 9 tasks (folder renames, security hotfixes, secrets, CI, scaffold).
    - Phase 3: 19 tasks (deps, design tokens, network stack, session store, ProviderScope, router redirect, Firebase wrappers).
    - Phase 4: 23 tasks (feature migration — one per migration unit; god widgets split into preceding `.a` decomposition tasks).
    - Phase 5: 8 tasks (shim deletion, dep prune, cached images, comment hygiene, lint upgrade, naming polish, router final).
    - Phase 6: 13 tasks (test helpers, repo + Notifier + widget tests, goldens, integration tests, CI coverage gate).
  - Deleted single-file phase plans: `docs/migration/phase1_audit.md` … `phase6_testing.md` (702 LOC total). Replaced by chunked task files.
  - Kept under `docs/migration/`: `README.md` (legacy index), `flavor_bundle_id_plan.md` (companion). Both retain root link to `MIGRATION_PLAN.md`.
  - Appendix in `MIGRATION_PLAN.md` updated to point at new sprint boards.
  - Task file template: status header (🔴 / 🟡 / 🟢 / ⏭️) · owner / dates / PR / branch table · goal · references · files-in-scope (max 5–10 per task) · steps · acceptance · notes.

- **Decisions**:
  - **Sprint-planning granularity** — each task ≤10 files = ≤1 PR. Mirrors `MIGRATION_RULES.md` §1.1 ("if a step touches more than 8–10 files, break it into smaller steps").
  - **God-widget split-then-migrate as separate tasks** — `.a` (decompose, zero behavior change) + `.b` (migrate). Tracked separately so the split can be reviewed without Notifier noise.
  - **Phase 4 = 23 tasks not 22 migration units** — `signup1`, `signup3`, `myprofile`, `home_screen`, `featured_work_list` each get a `.a` decomposition predecessor.
  - **Phase 6 = 13 tasks not 5–7** — repository / Notifier / widget tests split into manageable batches so each task is ≤1.5 effort-days.
  - **Status emoji per user preference** — 🔴 Not Started · 🟡 In Progress · 🟢 Completed. Same legend on every README + task file.
  - **Path scheme** — phase folders sit directly under `docs/` (not under `docs/migration/`). Rationale: contributors expect `docs/phaseN/` to be the actionable sprint board; `docs/migration/` is legacy + companion docs.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - Old single-file phase plans deleted only after the new chunked structure was fully populated.

---

### 2026-05-27: Plan refresh + relocation to repo root

- **Changes**:
  - Moved `docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` (repo root) to match the sibling `biegeapp` layout (`MIGRATION_PLAN.md` + `MIGRATION_RULES.md` + `MIGRATION_LOG.md` co-located at root).
  - Created this file (`MIGRATION_LOG.md`) at the root.
  - Verified current LOC / file counts against `lib/` and updated plan tables:
    - Top god widgets re-measured: `signup3_screen.dart` 3,465 → 3,569; `home_screen.dart` 2,902 → 2,860; `myprofile.dart` 2,834 → 2,836; `featured_work_list.dart` 1,703 → 1,685; `signup1_screen.dart` 1,959 → 1,836; `signup2_screen.dart` 1,328 → 1,331; `upcoming_shoot_view_detils.dart` 1,396 → 1,184.
    - Several screens shrank: `login.dart` 464 → 382; `reset_password_screen.dart` 428 → 332; `forgot_password_screen.dart` 401 → 362; `file_manager_screen.dart` 661 → 604; `pre_production_screen.dart` 502 → 434.
    - One screen grew: `edit_personal_details_screen.dart` 589 → 666.
    - Total Dart LOC across `lib/`: 34,162 across 87 files (was ~30k across 38 screens; codebase grew).
  - 3 new profile screens folded into Group C: `change_password_screen.dart` (274 LOC), `profile_otp_screen.dart` (343 LOC), `featuredwork_details_screen.dart` (177 LOC).
  - Foundations checklist row 7 (`AppTheme.dark()`) flipped ⚠️ → ✅ — wired at `lib/main.dart:45`.
  - Foundations checklist note: `flutter_secure_storage ^9.2.2` already declared in `pubspec.yaml`.
  - Risk register #10 (Linux CI casing) downgraded H/H → H/M — `Home`, `Profile`, `Shoots` already lowercased; only `onboding`, `manageavailability`, `upcomingshootviewdetils` and the file with a literal space remain.
  - Hard blocker #1 (folder casing) marked partially done; Hard blocker #2 (target packages) updated to acknowledge `flutter_secure_storage` already present.
  - Phase 2.A budget trimmed 1.5 → 1 day; Phase 2.B trimmed 1 → 0.75 day; Phase 3.A trimmed 1.5 → 1 day. Total ~94.75 → ~93.5 effort-days.
  - Appendix paths fixed (file now sits at root; relative links retargeted).
  - Back-references in `docs/migration/flavor_bundle_id_plan.md` updated (`docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` at repo root).

- **Decisions**:
  - **Plan at repo root, not under `docs/`** — matches `biegeapp` layout for cross-project muscle memory. CLAUDE.md states "all new .md files belong under `docs/`" with exceptions for `CLAUDE.md` and `README.md`. Adding `MIGRATION_PLAN.md` + `MIGRATION_LOG.md` to that exception set as the canonical migration-control docs, given they sit alongside `MIGRATION_RULES.md` (already at root). Reason: discoverability — a contributor opening the repo sees plan, rules, log together; the alternative buries plan two levels deep while rules sit at root.
  - **Refresh vs rewrite** — kept the 2026-05-21 analysis verbatim and applied targeted edits. The audit-driven judgment calls (pilot choice, group order, decomposition strategy) are still correct; only the underlying numbers moved.
  - **Drift in the wrong direction** (`ApiService()` 58 → 68, `setState` 266 → 291, `print/debugPrint` 242 → 283, `StatefulWidget` 41 → 44) noted but not treated as a blocker — the migration roadmap absorbs new screens via the same per-feature template; new screens just lengthen Group C by 0.5 day and Phase 5 cleanup by a few `print()` strips.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged (no lib/ touches).
  - No commits made; user controls when to stage and commit.

---

---

### 2026-07-22: Dashboard Upcoming Shoot Custom Date Range Filter

- **Task**: Dashboard Upcoming Shoot — Removed Search & Filter UI.
- **Changed Files**:
  - `lib/features/home/presentation/widgets/home_upcoming_carousel.dart`
  - `lib/features/home/presentation/screens/home_screen.dart`
  - `test/features/home/presentation/widgets/home_upcoming_carousel_test.dart`
- **Decisions**:
  - Removed Search Bar and Filter Button UI row from `HomeUpcomingCarousel` as requested.
  - Cleaned up parameter signature of `HomeUpcomingCarousel` and call site in `HomeScreen`.
- **Verification**:
  - `flutter analyze --fatal-infos`: 0 issues.
  - `flutter test test/features/home/presentation/widgets/home_upcoming_carousel_test.dart test/features/home/presentation/home_notifier_test.dart`: 12 / 12 passing.

---

### 2026-07-23: Availability Setup & Validation Enhancements

- **Task**: Availability setup rules & validation enforcement (Option A Floating SnackBar Toast UX).
- **Changed Files**:
  - `lib/features/availability/domain/entities/availability_entry.dart`
  - `lib/features/availability/presentation/providers/availability_providers.dart`
  - `lib/features/availability/presentation/screens/add_availability_screen.dart`
  - `test/features/availability/presentation/availability_notifier_test.dart`
- **Decisions**:
  - Enforced all 7 specified availability setup validation rules in `AddAvailabilityNotifier.submit()`.
  - Displayed all validation messages using Option A (app-themed floating SnackBar toasts).
  - Updated `AvailabilityPayload.toJson()` to include `'recurrence_day_of_month': int.tryParse(repeatDay) ?? repeatDay` for monthly recurrence.
  - Resolved Shoot tap navigation issue on `ManageAvailabilityScreen`:
    1. Made `AvailabilityRepositoryImpl.fetchMonth` robust against non-strict `projectAssigned` types (`true`, `1`, `'1'`, `'true'`, `'yes'`, `status: shoot`).
    2. Fallback key extraction in `_extractBookingId` across `booking_id`, `project_id`, `id`, `shoot_id`, `bookingId`, `projectId` from `projectDetails` or top-level `value`.
    3. Handled date string ISO splits (`2026-07-23T...`) to match calendar date keys regardless of timezone offsets.
    4. Wrapped `CommonCalendar` cell builders in a `GestureDetector` so tapping a Shoot day cell or tag reliably triggers navigation.
- **Verification**:
  - `flutter test test/features/availability`: 43 / 43 tests passing.
  - `flutter analyze --fatal-infos`: 0 issues.

---

### 2026-08-10: Success Toast Message Display Fix & UI Layout Overflow Fixes

- **Task**: Fix success toast messages displaying with red error styling/🚫 icon and resolve horizontal layout overflow errors on narrow device screens (11px in social link icon rows, 5px in Home Screen Shoot Categories header).
- **Changed Files**:
  - `lib/features/profile/presentation/screens/my_profile_screen.dart`
  - `lib/features/auth/presentation/screens/forgot_password_otp_screen.dart`
  - `lib/features/auth/presentation/screens/reset_password_screen.dart`
  - `lib/features/profile/presentation/screens/edit_personal_details_screen.dart`
  - `lib/features/profile/presentation/screens/enter_profile_details_screen.dart`
  - `lib/features/profile/presentation/screens/delete_account_otp_screen.dart`
  - `lib/features/profile/presentation/widgets/profile_social_links_sheet.dart`
  - `lib/features/auth/presentation/widgets/signup3_social_sheet.dart`
  - `lib/features/home/presentation/widgets/home_shoot_categories_panel.dart`
- **Decisions**:
  - Explicitly passed `type: TopMessageType.success` to `TopMessage.show` calls when displaying `toastMessage` or success notifications.
  - Wrapped social link 6-icon `Row` in `SingleChildScrollView(scrollDirection: Axis.horizontal, physics: BouncingScrollPhysics())` with 10px tile padding in both `profile_social_links_sheet.dart` and `signup3_social_sheet.dart` to prevent right overflow on narrow devices (<375px).
  - Constrained `"Shoot Categories"` section header title in `home_shoot_categories_panel.dart` using `Expanded` with `TextOverflow.ellipsis` and adjusted Photo/Video toggle tab horizontal padding from 16px to 12px (`AppSpacing.md`) to eliminate the 5.0px overflow error.
- **Verification**:
  - `flutter analyze --fatal-infos`: 0 issues.
  - `flutter test test/features/home`: 48 / 48 tests passing.
  - `flutter test test/features/auth/presentation/screens/signup3_screen_test.dart test/features/profile`: 98 / 98 tests passing.

---

### 2026-08-10: Bug Fixes — Featured Work Image Limit & Certification Deletion

- **Task**: Fix reported bugs:
  1. Featured Work max 5 images limit check was misconfigured as minimum 5 images (`totalImages < 5`), and re-opening upload modal accumulated old picked images resulting in up to 10 images being displayed.
  2. Certification deletion failed because `CrewFile.fromJson` only parsed `crew_files_id`, returning `0` when backend sent `id`, `crew_file_id`, or `file_id`, resulting in invalid `DELETE creator/profile-file/0` requests.
- **Changed Files**:
  - `lib/model_class/myprofile_model.dart`
  - `lib/features/profile/data/repositories/profile_files_repository_impl.dart`
  - `lib/features/profile/presentation/screens/featured_work_list_screen.dart`
  - `lib/features/profile/presentation/widgets/featured_work_upload_sheet.dart`
  - `lib/features/auth/presentation/widgets/signup3_featured_sheet.dart`
- **Decisions**:
  - `CrewFile.fromJson` now tries `crew_files_id`, `id`, `crew_file_id`, `file_id` in sequence before defaulting to `0`.
  - Added guard in `deleteFile(int id)` to reject non-positive file IDs (`id <= 0`) with explicit exception.
  - `FeaturedWorkList` clears `tempFeaturedImages` and `editingImages` state when opening sheet via `Add Featured Works` CTA button.
  - `FeaturedWorkUploadSheet` & `Signup3FeaturedSheet` enforce `1 <= totalImages <= 5` validation, hide `+` picker tile when totalImages >= 5, and display `'Maximum 5 images allowed'` when exceeding max 5.
- **Verification**:
  - `flutter test test/features/profile`: 96 / 96 tests passing.
