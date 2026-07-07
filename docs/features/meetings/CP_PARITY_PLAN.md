# Meetings — CP App Parity Plan

Comparison of `biegeCPapp/lib/features/meetings` vs `biegeapp/lib/features/meetings`, listing UI section changes and fixes shipped in beigeApp after the MT8 baseline that still need to be ported to the CP app.

Owner-side flows (create / edit / cancel meeting, participant picker, shoot picker, generate Meet link) are intentionally excluded — CP hides these per commit `add7a5e feat(meetings): hide create/edit actions for CP`. That policy is preserved in this plan.

Rollout order at the bottom.

---

## 1. Design Tokens

### 1.1 `lib/app/colors.dart` — add meeting status + RSVP palette

Card status pill, details status pill, and RSVP buttons currently rely on raw hex literals. Introduce tokens (values from beigeApp):

| Token | Value |
| --- | --- |
| `meetingPendingBg` | `0xFFFFF4C9` |
| `meetingPendingFg` | `0xFFBA6605` |
| `meetingOngoingBg` | `0xFFC3E7FD` |
| `meetingOngoingFg` | `0xFF0575BA` |
| `meetingCompletedBg` | `0xFFD4FFE4` |
| `meetingCompletedFg` | `0xFF16A34A` |
| `meetingRescheduledBg` | `0xFFFFDDAD` |
| `meetingRescheduledFg` | (match beige) |
| `meetingCancelledBg` | `0xFFFFD3D3` |
| `meetingRejected` | `0xFFD33732` |
| `meetingRejectSoftBg` | `0xFFEECCC9` |

`softMint` + `greenBright` already exist — reuse for Accept button surface.

Then swap hex literals in `meeting_card.dart` (`_statusBg`, `_statusFg`, Accept / Reject palette) and `meeting_details_sheet.dart` (`_StatusPill._bg` / `_fg`, response line color) to tokens.

### 1.2 `lib/app/assets.dart` + `assets/svg/meeting/` — add brand SVGs

Add the four meeting SVG assets from beigeApp and register them:

- `ic_meeting_link.svg` → `AppAssets.icMeetingLink`
- `ic_meeting_datetime.svg` → `AppAssets.icMeetingDatetime`
- `ic_related_shoot.svg` → `AppAssets.icRelatedShoot`
- `ic_google_meet.svg` → `AppAssets.icGoogleMeet`

Register the folder in `pubspec.yaml` assets manifest.

Replace Material glyphs at these call sites:

- `meeting_card.dart` title-row `Icons.videocam_outlined` → `icMeetingLink`
- `meeting_card.dart` `_PlatformBadge` `_GoogleMeetLogo` custom painter → `icGoogleMeet` SVG (drop the painter class + `_GoogleMeetLogoPainter` entirely)
- `meeting_details_sheet.dart` `_InfoRow` — swap `IconData` param for `String iconAsset`, render `SvgPicture.asset(iconAsset, 18×18)`; call sites use `icMeetingDatetime`, `icMeetingLink`, `icRelatedShoot`
- `meeting_platform_chip.dart` — replace `IconData get _icon` with `Widget _iconWidget()`; Meet returns `SvgPicture.asset(icGoogleMeet, 14×14)`, others fall back to `Icon(...)`

---

## 2. Domain Layer

### 2.1 `MeetingStatus` enum expansion — `domain/models/meeting_status.dart`

Add `pending`, `cancelled`, `rescheduled`, `scheduled` to the enum. Extend `label` getter:

- `pending` → "Pending"
- `cancelled` → "Cancelled"
- `rescheduled` → "Rescheduled"
- `scheduled` → "Scheduled"

Update `meeting_enum_mapper.dart` `fromServer`:

- Lowercase raw input before switch
- `initiated` → `pending`
- `scheduled` → `scheduled`
- `rescheduled` → `rescheduled`
- `cancelled` / `canceled` → `cancelled`
- `revision` → `revision`
- Default → `pending` (was `upcoming`)

`toServer` maps `pending` / `scheduled` → `pending`, `rescheduled` → `rescheduled`, `cancelled` → `cancelled`.

### 2.2 New model — `domain/models/meetings_tab.dart`

```dart
enum MeetingsTab { upcoming, completed }

extension MeetingsTabLabel on MeetingsTab {
  String get label => switch (this) {
    MeetingsTab.upcoming => 'Upcoming',
    MeetingsTab.completed => 'Completed',
  };
}
```

Used by the tab bar and drives the server-side `meeting_time_status` query.

### 2.3 New model — `domain/models/meeting_type.dart`

Production-stage enum with `label` getter and `fromServer(String?)` factory. Observed server values: `planning`, `pre_production`, `production`, `post_production`, `review`, `delivery`. Unknown values keep `null` — card falls back to the raw string via `Meeting.meetingTypeDisplay`.

### 2.4 `Meeting` model — additive fields

Add to `domain/models/meeting.dart`:

- `final MeetingType? meetingType`
- `final String? meetingTypeRaw`
- `String? get meetingTypeDisplay => meetingType?.label ?? (meetingTypeRaw?.isEmpty ?? true ? null : meetingTypeRaw);`
- `final String? createdById` — sourced from `created_by.id` on REST payload; used by owner-gated affordances (no-op for CP, keep for parity)

Propagate through constructor + `copyWith`.

### 2.5 `MeetingParticipant` — add `role`

`final String? role`, plumbed through constructor and `copyWith`. Used by participant tile subtext.

### 2.6 `MeetingResponse` — add `pending`

Change enum to `{ pending, accepted, declined }`. Extend `serverValue` for pending. Add module-level parser:

```dart
MeetingResponse? rsvpFromServer(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'accepted' || 'accept': return MeetingResponse.accepted;
    case 'declined' || 'decline' || 'rejected': return MeetingResponse.declined;
    case 'pending' || 'invited': return MeetingResponse.pending;
  }
  return null;
}
```

`participantResponses` map at the DTO boundary drops the `pending` entry so `myResponse == null` still means "not responded" for existing UI checks.

---

## 3. Data Layer

### 3.1 `meeting_dto.dart`

- Use `rsvpFromServer` inside `_readResponses`; skip entries that resolve to `pending`
- Parse `meeting_type` → `MeetingType.fromServer(...)` + preserve raw string in `meetingTypeRaw`
- Add `_readCreatedById(Object? raw)` — handles map (`{id,...}`) or bare scalar; returns `String?`
- Continue consuming `currentUserId` for `myResponse` derivation

### 3.2 `meeting_user_dto.dart`

Parse `role` string from user JSON and forward to `MeetingParticipant`.

### 3.3 `meetings_repository.dart` (interface)

- `list` signature: `Future<List<Meeting>> list({ MeetingsTab? tab, MeetingFilter filter, String? currentUserId })`
- Drop tab from client-side filter surface — server drives it now

### 3.4 `meetings_repository_impl.dart`

- Map `MeetingsTab` → server `meeting_time_status` (`upcoming` / `completed`) via helper `_tabToServer`
- Pass to remote `list(meetingTimeStatus: ...)`
- `_applyClientFilters` — drop the tab branch, keep category / status / date-range + sort

### 3.5 `meetings_remote_source.dart`

- `list({ String? meetingTimeStatus })` — inject `meeting_time_status` into the query map when non-null
- Verify error helper naming: beige uses `ExceptionHandler.mapDioError`, CP uses `mapDioException`. Keep whichever CP already has — do not rename gratuitously.

---

## 4. Presentation — State + Notifier

`presentation/providers/meetings_list_state.dart`:

- `MeetingsTab tab` (default `MeetingsTab.upcoming`) — replaces `MeetingStatus`
- Add `List<Meeting> allItems` — unfiltered page from API; `items` is derived
- Add `String? currentUserId`
- Keep `pendingRsvpIds`, `rsvpError`
- Add free function:

```dart
List<Meeting> applyLocalMeetingFilters(
  List<Meeting> items, {
  MeetingsTab? tab,
  required MeetingFilter filter,
});
```

Local tab branch remains as a defensive filter but is skipped (`tab: null`) when the server has already filtered.

`presentation/providers/meetings_list_notifier.dart`:

- Read `currentUserIdProvider` into state on build
- `_load()` sets `allItems` from repo, derives `items` via helper
- `selectTab(MeetingsTab)` clears `allItems` + `items`, sets `loading`, refetches — prevents stale flash
- `updateFilter` / `clearFilter` recompute locally from `allItems`, no refetch
- RSVP success path updates both `allItems` and derived `items`
- Auth-failed branch: keep `logout()` if that is the current CP API (beige recently switched to `updateState(false)` — do not port unless the CP auth notifier exposes it)

---

## 5. Presentation — Widgets

### 5.1 `meeting_card.dart`

- **Drop** the "Sync Meeting" toggle row + `_syncMeeting` state + the section divider above it (dropped feature)
- Title column: add meeting-type subtext under the title
  - style: `AppTextStyles.bodyMedium.copyWith(color: textSecondary, fontFamily: 'Outfit', fontWeight: w300, fontSize: 11)`
  - shown only when `meeting.meetingTypeDisplay != null`
- Status pill: `_statusBg` / `_statusFg` return new palette tokens; extend switch to cover `pending`, `scheduled`, `rescheduled`, `cancelled`
- Accept button: `softMint` bg / `greenBright` fg
- Reject button: `meetingRejectSoftBg` bg / `meetingRejected` fg
- Loader: `AppCircularLoader(size: 14, strokeWidth: 2, valueColor: ...)` instead of raw `CircularProgressIndicator`
- MyRsvp: hide `_ResponseStatusLine` unless `_myRsvp == accepted || _myRsvp == declined`
- Date: `DateTimeUtils.formatMeetingDate(startAt)` (see §7)
- Text style tokens: audit occurrences of `body14` / `body11` — keep CP names unless the app is migrating, then swap to `bodyMedium` / `labelSmall` / `labelLarge`

### 5.2 `meeting_details_sheet.dart`

- `_InfoRow` — replace `IconData icon` param with `String iconAsset`; render `SvgPicture.asset(iconAsset, 18×18, fit: contain)`
- Call sites use `icMeetingDatetime`, `icMeetingLink`, `icRelatedShoot`; shoot row passes `valueColor: AppColors.primary`
- Loader in `_LoadingState`: `AppScreenLoader` in place of raw `CircularProgressIndicator`
- Retry: `AppButton(label: 'Retry', variant: outline)` in place of `TextButton`
- Copy-link toast: `TopMessage.show(context, 'Link copied', type: TopMessageType.success)` — not `ScaffoldMessenger.showSnackBar`
- MyRsvp status text: only render when `myResponse == accepted || declined`
- Join button: full-width `AppButton(label: 'Join Meeting', icon: Icons.videocam_outlined)` — drop the custom underlined `_JoinButton` widget + `_GoogleMeetLogoPainter`
- Status pill palette tokens (extended to cover new statuses)
- Date format: `DateTimeUtils.formatMeetingDate(startAt)` in `_dateLabel`
- **Skip** the owner-gated Edit icon and Cancel button + confirmation dialog — CP is never the owner; do not import `cancel_meeting_notifier`

### 5.3 `meeting_participant_tile.dart`

- Drop `role` and `onMessage` params — role is read from `participant.role` via a `roleLabel(String?)` helper
- Drop the trailing "Message" `InkWell` (chat bubble icon)
- Drop the card container background + `AppRadii.xlAll` — flat `Padding(vertical: AppSpacing.xs)`
- Avatar size `AppAvatarSize.sm` (was `md`)
- Add `shared/util/role_label.dart` if not already present:

```dart
String roleLabel(String? raw) {
  final r = raw?.trim().toLowerCase();
  return switch (r) {
    'cp' || 'creative_partner' || 'creativepartner' => 'Creative Partner',
    'admin' => 'Admin',
    'client' => 'Client',
    null || '' => '',
    _ => raw!,
  };
}
```

### 5.4 `meeting_platform_chip.dart`

- Replace `IconData get _icon` with `Widget _iconWidget()`; Meet returns SVG asset, Zoom / Teams / default return `Icon(...)`
- Label style token — align with card (`labelSmall` if migrating, else keep `body11`)

### 5.5 `meeting_filter_sheet.dart`

- Minor: swap `body14` → `bodyMedium` in the two style copies (rows 355, 436 in beige diff)
- Formatting-only close-icon change is not worth porting

### 5.6 `meetings_tab_bar.dart`

- Consume `MeetingsTab` (not `MeetingStatus`); drop the local `_items` tuple list — iterate `MeetingsTab.values` and read `.label`
- Padding `AppSpacing.xxs`
- Text style `labelLarge` when active
- Animation duration `AppDurations.fast` (rename `fast250 → fast` in `durations.dart` if not already renamed)

### 5.7 `meetings_screen.dart`

- Tab state typed as `MeetingsTab`
- Wrap body in `AppScaffold(hasAppBar: false)`; content becomes a `Stack` with:
  - `SafeArea > Column` (toolbar → tab bar → `Expanded(RefreshIndicator(_ListBody))`)
  - `if (state.pendingRsvpIds.isNotEmpty) AppLoadingOverlay(dimOpacity: 0.4)` on top
- `_ListBody` loader: `AppScreenLoader` inside a `SingleChildScrollView` with constrained-height `SizedBox` so pull-to-refresh works while loading
- Empty state: text style `bodyMedium`
- Retry: `AppButton(label: 'Retry', fullWidth: false, onPressed: onRetry)`
- Toast copy on RSVP success: "You have Accepted Meeting" / "You Have Rejected Meeting"
- Filter icon: CP already has `AppAssets.iconFilter` — keep current SVG usage
- **Skip** the bottom "Create Meeting" `AppButton` — CP hides create
- RSVP callback shape: card `onRsvp(meeting, accept)` (beige) vs `onRsvp(context, meetingId:, accept:)` (CP). Pick one and keep consistent; beige's compact form is preferred if adopting the RSVP-in-flight overlay

---

## 6. Utilities to Add

- `lib/core/utils/date_time_utils.dart` — `static String formatMeetingDate(DateTime dt)` (unifies formatting across card + details; picks up the pattern used across beige)
- `lib/shared/util/role_label.dart` — `roleLabel(String? raw)` (see §5.3)

---

## 7. Explicit Non-Goals for CP

Do NOT port — CP intentionally hides owner-side flows (`add7a5e`):

Screens:
- `create_meeting_screen.dart`
- `edit_meeting_screen.dart`
- `meeting_scheduled_screen.dart`

Providers / notifiers:
- `create_meeting_notifier.dart` + `create_meeting_state.dart`
- `edit_meeting_notifier.dart` + `edit_meeting_state.dart`
- `cancel_meeting_notifier.dart`
- `client_shoots_provider.dart`
- `shoot_participants_provider.dart`

Models:
- `create_meeting_input.dart`
- `generate_meet_link_input.dart`
- `directory_participant.dart`
- `shoot_option.dart`
- `shoot_participant_option.dart`

Widgets:
- `default_invited_members_section.dart`
- `invite_additional_members_bottom_sheet.dart`
- `invited_member_card.dart`
- `meeting_agenda_tile.dart`
- `meeting_participant_picker_sheet.dart`
- `member_selection_tile.dart`
- `select_meet_link_picker.dart`
- `selected_participant_chip.dart`

Repo methods:
- `create`, `generateMeetLink`, `listProjects`, `addParticipants` (skip unless picker UI ever ships on CP)

Details-sheet owner affordances: Edit icon, Cancel button, cancel confirmation dialog.

---

## 8. Rollout Order

1. **Tokens** — colors, assets, register SVGs in `pubspec.yaml`, text-style audit
2. **Domain** — extend `MeetingStatus`, add `MeetingsTab`, add `MeetingType`, extend `MeetingResponse` + `rsvpFromServer`, extend `Meeting` (`meetingType`, `meetingTypeRaw`, `createdById`), extend `MeetingParticipant.role`
3. **Data** — `meeting_dto` (createdById, meetingType, rsvpFromServer), `meeting_user_dto` (role), `meeting_enum_mapper` (expanded fromServer / toServer)
4. **Repo + remote** — server-driven tab filter (`meeting_time_status`), drop client-side tab branch
5. **State + notifier** — `MeetingsTab`, `allItems`, `applyLocalMeetingFilters`, tab-switch clears list, local filter recompute
6. **Widgets** — card → details sheet → participant tile → platform chip → tab bar → filter sheet
7. **Screen** — `AppScaffold` shell, `AppLoadingOverlay` while RSVP in-flight, `MeetingsTab` wiring, revised RSVP toast copy — skip Create Meeting button
8. **Utils** — `date_time_utils.dart`, `role_label.dart`

## 9. Reference Commits in `biegeapp` for Each Section

Cherry-pick source references (message-only commits omitted):

- Section 1 tokens: `3269e69 refactor(meetings): tokenized colors, brand SVG, consistent back icon, tile polish`
- Section 1.2 SVG icons: `3269e69`, `e2ba499 feat(meetings): meeting stage subtext, status palette, SVG icons, tab-switch loader`
- Section 2.1 status enum + section 5 status pills: `e2ba499`, `c8ffe33 feat(meetings): brand toggle, redesigned filter, status taxonomy` (CP-side baseline — same taxonomy, different scope)
- Section 2.4 stage subtext: `e2ba499`
- Section 4 + 6 server tab filter + loader: `83f6a76 feat(meetings): server-driven tab filter, cupertino time picker, sheet polish`
- Section 5.7 RSVP polish + toast copy: `54fa34a feat(meetings): unify date format, refine RSVP toasts, surface bottom-sheet feedback`, `02be2a6 fix(meetings,messages): UI polish + RSVP cutoff + avatar fallbacks`, `0db86a5 refactor(meetings): consolidate RSVP enum + use PATCH for respond endpoint`
- Section 6 unified date util: `54fa34a`
- Section 5 loader / AppScreenLoader: `16b64c9 refactor(shared): adopt AppScreenLoader across screens`, `be77735 refactor(shared): consolidate loaders + success/image Lottie usage`
