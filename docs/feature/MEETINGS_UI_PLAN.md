# Meetings Module — UI Plan

**Status:** MT1–MT7 complete (MT8 deferred to API phase)
**Owner:** Mobile (crew app)
**Scope:** UI only. Dummy in-memory data; real API wires in a later phase.
**Reference design:** `testing/Meetings_UI.png` (5 surfaces — list, filter sheet, create form, success, details sheet)

---

## 0. Status Tracking

| Phase | Status | Notes |
|---|---|---|
| MT1 — Foundation | ✅ Complete (2026-06-09) | Domain enums + entities + filter + input, repo contract, dummy source + impl, provider, routes wired, placeholder screens, router test green. |
| MT2 — Meetings list | ✅ Complete (2026-06-09) | Tab bar + cards + platform chip + list notifier + screen w/ pull-to-refresh, empty / loading / error branches, filter sheet wired (stub body until MT3), bottom Create CTA. `AppMainToolbar` extended additively w/ optional `trailing`. Analyze + router tests green. |
| MT3 — Filter bottom sheet | ✅ Complete (2026-06-09) | Category chips (7) + status chips (3) + date-range field via themed `showDateRangePicker` + Clear All / Apply w/ disabled states. Analyze clean. |
| MT4 — Create Meeting form | ✅ Complete (2026-06-09) | Full form (title, description, date, start/end time, platform picker, link + Add, reminder). Themed date/time pickers. Submit drives notifier → `ref.invalidate(meetingsListNotifierProvider)` + `pushReplacementNamed(meetingScheduled)`. Errors snackbar. Analyze clean. |
| MT5 — Meeting Scheduled success | ✅ Complete (2026-06-09) | Lottie success + heading + subtext + 2s timer → `goNamed(meetings)`. `PopScope` redirects hardware back to list. Analyze clean. |
| MT6 — Meeting Details bottom sheet | ✅ Complete (2026-06-09) | Family `FutureProvider`, `DraggableScrollableSheet` (0.85/0.95), summary + date/time chips + project + agenda + participants + sticky Join CTA, loading/error branches, wired from `MeetingCard` tap. Analyze clean. |
| MT7 — Polish + tests | ✅ Complete (2026-06-09) | Motion / a11y already shipped in MT2–MT6; 5 new tests (list render, tab swap, notifier filter shrink, create-form valid/invalid). Golden skipped per plan. Analyze + meetings test suite green. |
| MT8 — API integration | ⏳ Pending (out of UI scope) | Swap dummy repo for Dio impl. |

---

## MT1 — Foundation

| Task | Status | Output |
|---|---|---|
| MT1.01 Domain enums | ✅ | `domain/models/meeting_platform.dart`, `meeting_status.dart`, `meeting_category.dart` w/ `label` extensions. |
| MT1.02 Domain entities | ✅ | `domain/models/meeting.dart`, `meeting_participant.dart`, `meeting_filter.dart` (custom `DateTimeRange` to keep domain Flutter-material-free), `create_meeting_input.dart`. |
| MT1.03 Repository contract | ✅ | `domain/repositories/meetings_repository.dart` — `list({tab, filter})`, `getById(id)`, `create(input)`. |
| MT1.04 Dummy source + impl | ✅ | `data/dummy/dummy_meetings.dart` (8 seed records — 4 upcoming + 4 completed, 3 platforms, 7 categories covered, agenda + participants populated), `data/repositories/meetings_repository_dummy.dart` w/ 300ms `Future.delayed`. `list` applies tab + filter + sorts by `startAt`; `create` appends in-memory. |
| MT1.05 Riverpod skeleton | ✅ | `presentation/providers/meetings_repository_provider.dart` — `meetingsRepositoryProvider` + `useDummyMeetingsProvider` flag (default `true`, kept stable for MT8 swap-in). |
| MT1.06 Routes + router wiring | ✅ | `Routes.meetingCreate` + `Routes.meetingScheduled` added (`trackScreenView: false` on the latter); included in `Routes.all`. `presentation/routes/meetings_routes.dart` spreads into `appRoutes`. Tab branch swapped from `MenuPlaceholderScreen` to `MeetingsScreen()`. Placeholder shells for create + scheduled screens stub MT4/MT5. Router test still green (9/9). |

### MT1 deviations

- **`MeetingFilter.dateRange` uses a custom `DateTimeRange` class** (`domain/models/meeting_filter.dart`), not `material.DateTimeRange`, to keep `domain/` free of Flutter `material` imports. Filter-sheet code in MT3 will convert from `material.DateTimeRange` (returned by `showDateRangePicker`) to the domain type at the boundary.
- **`useDummyMeetingsProvider` flag exists but provider has only one arm today.** Provider still `ref.watch`es the flag so the future MT8 swap is a one-line change.

---

## MT2 — Meetings list

| Task | Status | Output |
|---|---|---|
| MT2.01 MeetingsTabBar | ✅ | `presentation/widgets/meetings_tab_bar.dart` — pill bar, `goldHorizontalGradient` active state, `fast250` swap. |
| MT2.02 MeetingCard | ✅ | `presentation/widgets/meeting_card.dart` — title, platform chip, calendar/time/timezone meta rows, full-width gold "Join Meeting" `AppButton`. Tap opens details (currently snackbar stub until MT6). |
| MT2.03 MeetingPlatformChip | ✅ | `presentation/widgets/meeting_platform_chip.dart` — material icon fallback + label; switches to brand SVGs when assets land. |
| MT2.04 meetingsListNotifier | ✅ | `presentation/providers/meetings_list_state.dart` (`MeetingsListStatus` enum + immutable state) + `meetings_list_notifier.dart` (`AutoDisposeNotifier` w/ `selectTab`, `applyFilter`, `clearFilter`, `refresh`). |
| MT2.05 MeetingsScreen | ✅ | `presentation/screens/meetings_screen.dart` — toolbar w/ trailing filter button (dot indicator when filtered), tab bar, pull-to-refresh `ListView.separated`, bottom Create CTA. |
| MT2.06 Empty / loading / error | ✅ | Inline `_ListBody` switches between loading spinner, error column + Retry button, `AppEmptyState` (filter-aware copy). |
| MT2.07 Filter entry point | ✅ | `widgets/meeting_filter_sheet.dart` shell + `showMeetingFilterSheet(...)`; toolbar icon opens it, result piped through `notifier.applyFilter`. Body is stub copy + Clear / Apply until MT3. |
| MT2.08 Analyze pass | ✅ | `flutter analyze --fatal-infos` clean for `lib/features/meetings/**` + extended toolbar; only pre-existing `app_shell.dart` warning remains repo-wide. Router tests still 9/9. |

### MT2 deviations

- **`AppLoader` not used in list body.** It's `Positioned.fill`-only and requires a `Stack` ancestor; the column layout would crash. Used a centered `CircularProgressIndicator(color: AppColors.primary)` instead.
- **`AppMainToolbar` extended additively** w/ optional `trailing` widget. Existing call sites (8) keep current centered-title layout because the new param defaults to `null`.
- **Card tap + Join button** show snackbars today. Details sheet ships in MT6; Join requires `url_launcher` (verified absent in pubspec — added to MT8 open questions).

---

## MT3 — Filter bottom sheet

| Task | Status | Output |
|---|---|---|
| MT3.01 MeetingFilterSheet shell | ✅ | `widgets/meeting_filter_sheet.dart` — drag handle, "Filter" + X header, divider, scrollable body, footer divider + Clear / Apply. Local `StatefulWidget` holds draft; capped to `0.85 * screen height`. |
| MT3.02 Category chips | ✅ | `_SelectableChip` x 7 in a `Wrap`. Gold fill when selected, surface + dark divider border when not. |
| MT3.03 Date range field | ✅ | `_DateRangeField` opens `showDateRangePicker` themed via `ThemeData.dark` + `primary: AppColors.primary` (mirrors availability picker). Range rendered as `dd MMM yyyy – dd MMM yyyy`; inline `×` clears. Material `DateTimeRange` converted to domain `DateTimeRange` at picker boundary (the planned MT1 bridge). |
| MT3.04 Status chips | ✅ | Wrap of chips for `initiated` / `reviewer` / `completed` (the 3 filter-only statuses; tab statuses excluded). |
| MT3.05 Clear All / Apply | ✅ | Clear disabled when draft already empty; Apply disabled when draft equals current. Apply pops `MeetingFilter`; sheet caller (`MeetingsScreen`) pipes through `notifier.applyFilter`. |

---

## MT4 — Create Meeting form

| Task | Status | Output |
|---|---|---|
| MT4.01 createMeetingNotifier | ✅ | `providers/create_meeting_state.dart` (`CreateMeetingState` w/ `copyWith`, `TimeOfDayValue` value type, `isValid` aggregate, scheme-aware URL check, `CreateMeetingSubmitStatus` enum). `create_meeting_notifier.dart` `AutoDisposeNotifier` w/ field setters + `submit()`. |
| MT4.02 CreateMeetingScreen shell | ✅ | `screens/create_meeting_screen.dart` `ConsumerStatefulWidget` w/ bespoke header (X close on left, centered title), scroll body, sticky bottom "Create & Send Invite" `AppButton` (disabled until `state.isValid`). |
| MT4.03 Title + Description fields | ✅ | `AppTextField` for title; 3–4 line multi-line `AppTextField` for description. Both wired to notifier on change. |
| MT4.04 Date + time pickers | ✅ | Bespoke `_ReadonlyField` opens themed `showDatePicker` / `showTimePicker`. Start + End side-by-side; inline error when end ≤ start. |
| MT4.05 SelectMeetLinkPicker | ✅ | `widgets/select_meet_link_picker.dart` — 3-column radio cards (icon + label), gold tint when active. |
| MT4.06 Link input + Add | ✅ | URL `AppTextField` w/ inline scheme check + adjacent outline "Add" button (enabled when link is valid). Add is a UI accent only — the link commits via `setLink`; backend will store via `submit`. |
| MT4.07 Reminder dropdown | ✅ | Bespoke `_ReminderDropdown` over `DropdownButton<int>` (`CustomDropdownField` only accepts `String` items). Options: 5/10/15/30/60 min. |
| MT4.08 Submit flow | ✅ | `submit()` builds `CreateMeetingInput` → `repo.create()`. `ref.listen` on status: `success` → invalidate list + `pushReplacementNamed(meetingScheduled)`; `error` → snackbar w/ message; button shows spinner via `isLoading`. |
| MT4.09 List refresh hook | ✅ | `ref.invalidate(meetingsListNotifierProvider)` fires before navigation so the list re-builds w/ the new row when the user returns from MT5. |

### MT4 deviations

- **`project` and `category` not exposed in form.** Mock has neither; both default in the notifier (`project: 'General'`, `category: MeetingCategory.commercial`). Logged for later when backend confirms picker scope.
- **Reminder dropdown is bespoke, not `CustomDropdownField`.** The shared dropdown is typed to `String`; reminder is an `int`. Rebuilt minimal `DropdownButton<int>` w/ the same surface treatment.
- **"Add" button is decorative.** Mock shows it adjacent to URL field; nothing in the spec says to support multiple links. Treated as visual affordance — link still commits via `setLink` + included in `submit`.
- **Header is bespoke**, not `AppMainToolbar` — needed an X-close on the left, not the drawer button.

---

## MT5 — Meeting Scheduled success

| Task | Status | Output |
|---|---|---|
| MT5.01 MeetingScheduledScreen | ✅ | `screens/meeting_scheduled_screen.dart` — `Lottie.asset(AppAssets.lottieSuccess, repeat: false)`, "Meeting Scheduled" title, supporting subtext (mirrors `ShootCancelledLottiesScreen`). |
| MT5.02 Auto-redirect | ✅ | `initState` schedules `Timer(2s, _goToList)`; `_goToList` guards `mounted`; `dispose` cancels timer. Navigates via `context.goNamed(Routes.meetings.name)` so the stack resets to the tab. |
| MT5.03 Hardware back guard | ✅ | `PopScope(canPop: false, onPopInvokedWithResult:)` routes hardware back to the meetings tab so the user never lands back on the create form. |

---

## MT6 — Meeting Details bottom sheet

| Task | Status | Output |
|---|---|---|
| MT6.01 meetingDetailsProvider | ✅ | `providers/meeting_details_providers.dart` — `AutoDisposeFutureProviderFamily<Meeting, String>` over `repo.getById`. |
| MT6.02 MeetingDetailsSheet shell | ✅ | `widgets/meeting_details_sheet.dart` — `showMeetingDetailsSheet(...)` opens `DraggableScrollableSheet` (initial 0.85, max 0.95, min 0.5) inside `showModalBottomSheet(isScrollControlled, transparent)`; drag handle + header + close. |
| MT6.03 Meeting summary block | ✅ | Title + edit icon (snackbar stub), `_MetaChip` date + time, `_LabeledRow` for project. |
| MT6.04 Agenda section | ✅ | `widgets/meeting_agenda_tile.dart` — numbered circle badge + agenda line. |
| MT6.05 Participants section | ✅ | `widgets/meeting_participant_tile.dart` — `AppAvatar.sm` + name; count rendered via `_SectionHeader('Participants', count)`. |
| MT6.06 Join CTA | ✅ | Sticky `Positioned` bottom bar w/ "Join Meeting" `AppButton`. `url_launcher` absent — fallback snackbar surfaces the link (logged for MT8). |
| MT6.07 Async branches | ✅ | `AsyncValue.when` → loading: inline spinner inside sheet shell; error: icon + message + Retry that invalidates the family provider; data: full body. |

### MT6 deviations

- **Join opens snackbar, not browser.** `url_launcher` is not in `pubspec.yaml`; MT8 will add the dep and replace the snackbar with `launchUrl`.
- **Edit icon is a snackbar stub.** Mock shows it but spec defers the edit flow.

---

## MT7 — Polish + tests

| Task | Status | Output |
|---|---|---|
| MT7.01 Motion polish | ✅ | `AnimatedContainer` on tab pills (`fast250`), filter chips (150ms), and platform picker. Sheet uses default Material modal slide-in. Card press uses InkWell ripple — no bespoke scale (kept it simple). |
| MT7.02 A11y + touch targets | ✅ | `Semantics(button, selected, label)` on tab pills, filter chips, platform picker cards, meeting cards. Toolbar icon buttons inherit 48dp default. Sheet drag handle + close use stock `IconButton` (48dp). |
| MT7.03 Widget tests | ✅ | `test/features/meetings/presentation/screens/meetings_screen_test.dart` — 5 tests: list renders, tab swap, `MeetingsListNotifier.applyFilter` shrinks, `CreateMeetingNotifier.isValid` flips, end-before-start blocks `isValid`. |
| MT7.04 Golden (optional) | ⏭ Skipped | Per plan ("Skip if budget tight"). |
| MT7.05 Analyze + full test | ✅ | `flutter analyze --fatal-infos` clean for meetings; only pre-existing `app_shell.dart` unused-import warning repo-wide. Full `flutter test`: 489 / 490 (1 **pre-existing failure** unrelated to MT — `messages_screen_test.dart` "switches conversation tabs" looks for `'Shoots'`, but tab bar label was renamed to `'Messages'` in commit `b9b561c`). |

### MT7 deviations

- **One pre-existing test failure tolerated.** `MessagesScreen switches conversation tabs` fails because the messages tab label changed from `Shoots` → `Messages` in commit `b9b561c` without updating the test. Fixing it is outside the meetings plan; flagged here so the next messages-area pass can address it.
- **Routes analytics allowlist updated.** `meeting_scheduled` opts out of `screen_view` (momentary success route, mirrors `shoot_cancelotties`); added to the `routes_analytics_test.dart` opt-out set.
- **No bespoke card press scale.** InkWell ripple is enough on a card with full-width Join CTA; the spec didn't call for press scaling.

---

## MT8 — API integration (out of UI scope)

| Task | Output |
|---|---|
| MT8.01 Repository impl | `data/repositories/meetings_repository_impl.dart` Dio-backed; reuse `dioClientProvider`. |
| MT8.02 DTOs + mappers | `data/dto/meeting_dto.dart` + `toDomain()` extensions. |
| MT8.03 Flip flag | `useDummyMeetingsProvider` default → `false`; keep dummy path for tests. |
| MT8.04 Error envelope handling | Match Phase 4 pattern — throw `Exception` on envelope-error, let notifier catch + surface via `ref.listen`. |

---

## Decisions / open questions

- **`url_launcher` dep:** confirm presence in `pubspec.yaml` before MT2.02 + MT6.06; if absent, stub Join CTA w/ snackbar and add dep in MT8.
- **Edit icon on details sheet:** present in mock, no spec — stub for now, log follow-up.
- **Reminder options:** 5 / 10 / 15 / 30 / 60 min — confirm w/ backend later.
- **Timezone display:** show device timezone abbreviation under time row for now; revisit when API ships timezone field.
- **Localization:** hardcoded English strings, mirror current features. No `intl` keys until app-wide i18n lands.

---

## Out of scope

- Real API + WebSocket.
- Push reminders / calendar export.
- Edit meeting flow.
- Cancel / decline meeting.
- Participant invite picker (current spec shows static list only).
