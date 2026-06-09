# Messages Module — UI Plan

**Status:** UI complete (M1 + M2 + M3 + M4 + M5 complete)
**Owner:** Mobile (crew app)
**Scope:** UI only. Dummy JSON for data; real API + socket.io land in Phase M6.
**Reference design:** `testing/messages_UI.png` (3 screens — list, thread, details)
**Backend reference:** `docs/feature/web-chat-socket-reference.md`

---

## 0. Status Tracking

| Phase | Status | Notes |
|---|---|---|
| M1 — Foundation | ✅ Complete (2026-06-09) | Domain, repo contract, dummy source, providers, routes wired. Router tests green. |
| M2 — Conversations list | ✅ Complete (2026-06-09) | Tab bar + search + tiles + states + pull-to-refresh shipped. Analyze clean. |
| M3 — Chat thread | ✅ Complete (2026-06-09) | AppBar + bubbles (text/audio/system) + day separator + composer + attach sheet + thread notifier w/ optimistic send + auto-scroll. Analyze clean. |
| M4 — Details | ✅ Complete (2026-06-09) | Hero header + section card + shared file row + notes + details provider + search-in-conversation. Analyze clean. |
| M5 — Polish + tests | ✅ Complete (2026-06-09) | Motion polish, a11y labels/touch targets, message goldens, and widget tests shipped. Analyze + full test suite green. |
| M6 — API + socket.io | ⏳ Pending (out of UI scope) | |

### M1 task ledger

| Task | Status | Output |
|---|---|---|
| M1.01 dummy JSON fixtures | ✅ | `assets/dummy/messages/{conversations,messages_conv_001,details_conv_001}.json` + pubspec asset entry |
| M1.02 domain entities + sealed event | ✅ | `lib/features/messages/domain/entities/*` + `domain/events/chat_socket_event.dart` |
| M1.03 repo contract + sources | ✅ | `domain/repositories/messages_repository.dart`, `data/sources/{dummy,remote,socket}.dart`, `data/repositories/messages_repository_impl.dart`, DTOs |
| M1.04 Riverpod skeleton | ✅ | `presentation/providers/messages_repository_provider.dart` (+ `useDummyMessagesProvider` flag, default `true`) |
| M1.05 routes + router wiring | ✅ | `Routes.chat` + `Routes.chatDetails` added, `messages_routes.dart` + `messages_args.dart` + placeholder screens, router test green |

### M2 task ledger

| Task | Status | Output |
|---|---|---|
| M2.01 MessagesTabBar | ✅ | `screens/widgets/messages_tab_bar.dart` — pill segmented bar (All/Shoots/Admin), `AppDurations.fast250` swap |
| M2.02 ConversationTile | ✅ | `screens/widgets/conversation_tile.dart` — avatar + presence dot + name + preview + relative timestamp + unread dot |
| M2.03 conversationListProvider | ✅ | `presentation/providers/conversation_list_providers.dart` — `ConversationListState`, 250ms debounce search, `selectTab` + `refresh` |
| M2.04 Rebuild messages_screen.dart | ✅ | `screens/messages_screen.dart` — toolbar + tab bar + search row + new-chat `+` button (stub) + list |
| M2.05 Empty / loading / error states | ✅ | Inline `_ListBody` switches via `AppEmptyState` + retry CTA |
| M2.06 Pull-to-refresh + analyze | ✅ | `RefreshIndicator` wired to `notifier.refresh`; analyze clean |

### M3 task ledger

| Task | Status | Output |
|---|---|---|
| M3.01 ChatAppBar | ✅ | `screens/widgets/chat_app_bar.dart` — back + avatar + name + presence/typing subtitle + video + 3-dot menu |
| M3.02 MessageBubble | ✅ | `screens/widgets/message_bubble.dart` — in/out, asymmetric tail radius, sender header, edited/deleted markers, delivery status icons, system notice |
| M3.03 AudioBubble | ✅ | `screens/widgets/audio_bubble.dart` — play/pause toggle + static waveform `CustomPainter` + mm:ss |
| M3.04 DaySeparator | ✅ | `screens/widgets/day_separator.dart` — Today / Yesterday / weekday / dd MMM yyyy chip |
| M3.05 ChatComposer | ✅ | `screens/widgets/chat_composer.dart` — attach + textfield + emoji + camera + mic; mic swap to send button when non-empty; record bar state |
| M3.06 chatThreadProvider | ✅ | `presentation/providers/chat_thread_providers.dart` — `AutoDisposeFamilyNotifier<ChatThreadState,String>` owns stream sub via `ref.onDispose`, optimistic send w/ failure rollback, switch on sealed `ChatSocketEvent` |
| M3.07 chat_thread_screen.dart | ✅ | `presentation/screens/chat_thread_screen.dart` — chronological ListView, day-separator grouping, sender-header grouping (>5min gap), post-frame bottom auto-scroll, snackbar on error via `ref.listen` |
| M3.08 AttachActionSheet | ✅ | `screens/widgets/attach_action_sheet.dart` — modal sheet w/ `AttachKind { camera, gallery, file, linkShoot }` enum result |

### M4 task ledger

| Task | Status | Output |
|---|---|---|
| M4.01 DetailsHeroHeader | ✅ | `screens/widgets/details_hero_header.dart` — `surfaceWarm` rounded-bottom hero, back/title/menu row, XL avatar, name, email · phone meta |
| M4.02 DetailsSectionCard | ✅ | `screens/widgets/details_section_card.dart` — icon + title + `(count)` + chevron, `AnimatedRotation` + `AnimatedCrossFade` body reveal |
| M4.03 SharedFileRow | ✅ | `screens/widgets/shared_file_row.dart` — mime-aware icon, name, `dd MMM yyyy · size` meta, download icon |
| M4.04 Notes + chatDetailsProvider | ✅ | `presentation/providers/chat_details_providers.dart` — `AutoDisposeFutureProviderFamily<ChatDetails,String>`; notes editor in `_NotesCard` inside screen |
| M4.05 chat_details_screen.dart | ✅ | `presentation/screens/chat_details_screen.dart` — `CustomScrollView` w/ hero + search + Participants / Linked Shoot / Shared Files (initially expanded) / Notes; AsyncValue branches |
| M4.06 Navigation from M3 | ✅ | Already wired in M3.07 — 3-dot menu on chat AppBar pushes `Routes.chatDetails` via `pushNamed` |

### M5 task ledger

| Task | Status | Output |
|---|---|---|
| M5.01 Motion polish | ✅ | `MessagesTabBar` keeps `fast250` tab animation; `ChatThreadScreen` wraps message/audio bubbles in fade+slide entrance; `ChatComposer` animates focused border + vertical expansion. |
| M5.02 A11y + touch targets | ✅ | Semantics labels added for tabs, conversation rows, message bubbles, custom new-chat/send/attach rows, section cards, and shared-file rows; custom send/play controls now meet 44dp targets. |
| M5.03 Golden tests | ✅ | `test/golden/messages_test.dart` covers `ConversationTile`, `MessageBubble` incoming/outgoing/audio, and expanded `DetailsSectionCard`; baselines added under `test/golden/goldens/`. |
| M5.04 Widget tests | ✅ | `test/features/messages/presentation/screens/messages_screen_test.dart` covers list tab switching, optimistic send path, and details section expand/collapse. |

### Deviations from original plan

- **Dummy fixtures live under `assets/dummy/messages/`, not `lib/.../data/dummy/`** — Flutter requires runtime-loadable assets to sit under a `pubspec.yaml` `assets:` entry. Files inside `lib/` are not bundle-loadable. Pubspec updated; dummy source reads via `rootBundle.loadString`.
- **Repository contract widened** — added `editMessage` + `deleteMessage` (backend supports them per web reference doc). Audio is not a first-class `MessageType`; backend uses `file` + `audio/*` mime. `Message.type` enum is `text | image | file | system` to match backend.
- **`ChatSocketEvent` sealed type expanded** — includes `MessageEdited`, `MessageDeleted`, `RoomPreviewUpdated`, `ParticipantsChanged`, `RoomStatusChanged`, `NotificationReceived`, `SocketErrored` from web reference.
- **Placeholder `ChatThreadScreen` + `ChatDetailsScreen` shipped in M1** — needed to satisfy `router_test.dart`'s "every `Routes.x` is registered as a `GoRoute`" assertion. Replaced fully in M3 / M4.
- **Search row built inline, not via `AppTextField`** — `AppTextField` wraps `TextFormField` with a label column; conversation search needs a compact pill (icon + input on one line). Inline `Container` + `TextField` matches the screenshot. If we add a third search-pill site later, promote to `AppSearchField` shared widget.
- **`+` new-chat button is a stub** — directory + room-create REST endpoints (`POST external-chat/room`, `GET external-chat/directory`) ship in M6.
- **Unread dot uses `AppColors.primary` (cream)** — matches the outgoing-bubble accent so the list and thread feel unified. Screenshot is ambiguous between cream and white; cream reads as more on-brand.
- **Audio waveform is purely decorative** — `CustomPainter` with seeded random bars. Real waveform data + playback wires later (needs `just_audio` or similar). Mic record state is a bool toggle; no `record`/`flutter_sound` integration yet.
- **Day + sender-header grouping rules baked into the screen** — separator on calendar-day change, sender header on speaker change OR >5-min gap from previous message in the same chat. Tweakable in `_ThreadBody`.
- **Attach sheet returns `AttachKind` enum, not direct send** — screen handles the enum → SnackBar stub. Real attach pipelines (`image_picker`, `file_picker`, shoot link sheet) land in a later phase.
- **`_StatusIcon` uses `Icons.done_all` for both delivered + read** — read state tints with `AppColors.info` (blue) to differentiate. Matches WhatsApp/Telegram convention.
- **`chatDetailsProvider` is `FutureProviderFamily`, not a notifier** — details payload is read-only client-side in this phase; notes editing wires to a future `saveNotes` repo method but the local TextField is sufficient for M4. Promote to `AsyncNotifierFamily` when notes need server-sync.
- **Search-in-conversation is local-only state** — `_searchQuery` lives in the screen `State`. Wiring to actual thread filtering / scroll-to-match needs cross-screen state and lands later. Field renders + accepts input now.
- **Hero header uses `AppRadii.bottomHeader` (28px)** — matches the screenshot's curved-bottom container shape. No new radius token needed.
- **Bubble entrance fade is screen-scoped** — the animation wraps built thread items in `ChatThreadScreen`, leaving `MessageBubble` / `AudioBubble` deterministic for component goldens and direct reuse.
- **Audio waveform generation is deterministic per paint** — `AudioBubble` now seeds the placeholder waveform inside `paint()` so M5 goldens do not drift across repaint order.
- **Thread auto-scroll controller is now attached** — M3 created `_scrollCtrl`, but M5 found it was not passed to the thread `ListView`; the controller is wired so new-message auto-scroll can actually run.
- **Chat thread renders oldest-to-newest with new messages at the bottom** — the thread now uses a normal chronological `ListView` and scrolls to `maxScrollExtent` on message-count changes, instead of relying on `reverse: true` / reversed item order.
- **Analyzer cleanup touched `core_providers.dart`** — `flutter analyze` was blocked by two unused imports left behind while `LoggingInterceptor` is commented out. Removed only those imports; no runtime behavior changed.

---

---

## 1. Goal

Build crew-side messaging module against existing design tokens. Land all three screens (conversation list, chat thread, chat details) wired to a dummy data source that implements the same repository contract the future API + socket.io implementation will satisfy. Swap implementation, not call sites, when backend is ready.

---

## 2. Design Token Mapping

All values map to existing tokens in `lib/app/`. **No new colors needed.**

### Surfaces

| Screenshot element | Token |
|---|---|
| Page background (`#1D1D1B`) | `AppColors.background` |
| Card / sheet surface | `AppColors.surface` (`#262624`) |
| Search field background | `AppColors.surfaceInput` (`#1A1A1A`) |
| Composer background | `AppColors.surfaceInput` |
| Detail hero (warm beige top) | `AppColors.surfaceWarm` (`#322F2A`) over `background` |
| Section row background | `AppColors.surface` |
| Day separator chip | `AppColors.surfaceVariant` |
| Incoming bubble | `AppColors.surfaceCharcoal` (`#1B1B1B`) |
| Outgoing bubble (cream) | `AppColors.primary` (`#E8D1AB`) |

### Accents / State

| Element | Token |
|---|---|
| Tab pill active background | `AppColors.primary` |
| Tab pill active text | `AppColors.onPrimary` |
| Tab pill inactive text | `AppColors.textSecondary` |
| Outgoing bubble text | `AppColors.onPrimary` / `AppColors.textDark` |
| Incoming bubble text | `AppColors.textPrimary` |
| Online presence dot | `AppColors.online` (`#2ED47A`) |
| Divider | `AppColors.dividerDark` |
| Section chevron / placeholder | `AppColors.textTertiary` |
| Composer placeholder | `AppColors.textTertiary` |

### Typography

| Element | Token |
|---|---|
| "Message" / "Details" title | `AppTextStyles.titleLarge` |
| Chat AppBar contact name | `AppTextStyles.headingOutfitLg` |
| "Active now" subtitle | `AppTextStyles.body12` + `textSecondary` |
| Tab labels | `AppTextStyles.labelLarge` |
| Conversation row name | `AppTextStyles.bodyLargeStrong` |
| Conversation preview | `AppTextStyles.bodyMedium` + `textSecondary` |
| Timestamp | `AppTextStyles.body11` + `textTertiary` |
| Bubble text | `AppTextStyles.body14` |
| Bubble sender label (incoming) | `AppTextStyles.bodySmallMedium` + `textSecondary` |
| Section header | `AppTextStyles.body15Medium` |
| Notes placeholder | `AppTextStyles.body13` + `textTertiary` |

### Spacing

| Use | Token |
|---|---|
| Screen horizontal padding | `AppSpacing.screenH` (16) |
| Row gap | `AppSpacing.md` (12) |
| Bubble inner pad | `AppSpacing.md` horizontal, `AppSpacing.smd` vertical |

### Radii

| Element | Token |
|---|---|
| Bubble | `AppRadii.huge` (20) — asymmetric tail via `BorderRadius.only` |
| Search field | `AppRadii.lg` (12) |
| Section card | `AppRadii.xl` (14) |
| Tab pill | `AppRadii.full` |

### Shadows + Motion

| Element | Token |
|---|---|
| Bubble | `AppShadows.none` (flat) |
| Section card | `AppShadows.cardSubtle` |
| Active-state transitions | `AppDurations.fast` |
| Tab swap | `AppDurations.fast250` |

**New tokens:** none required. Asymmetric bubble corners composed inline via `BorderRadius.only` — only promote to a const if reused 3+ times.

---

## 3. Feature Structure

Follows established Phase 4 pattern (domain → data → presentation).

```
lib/features/messages/
├── data/
│   ├── sources/
│   │   ├── messages_remote_source.dart       // REST contract (stubbed UnimplementedError until M6)
│   │   ├── messages_socket_source.dart       // socket.io contract (stubbed)
│   │   └── messages_dummy_source.dart        // assets/dummy/messages JSON + Stream.periodic
│   ├── dto/
│   │   ├── conversation_dto.dart
│   │   ├── message_dto.dart
│   │   ├── participant_dto.dart
│   │   └── shared_file_dto.dart
│   └── repositories/
│       └── messages_repository_impl.dart     // composes remote + socket; routes to dummy in UI phase
├── domain/
│   ├── entities/
│   │   ├── conversation.dart                 // ConversationTab { all, shoots, admin }
│   │   ├── message.dart                      // type: text | audio | image | file; deliveryStatus
│   │   ├── chat_thread.dart
│   │   ├── participant.dart
│   │   ├── chat_details.dart
│   │   └── shared_file.dart
│   ├── repositories/
│   │   └── messages_repository.dart          // listConversations, fetchThread, events, send*, markRead, fetchDetails
│   └── events/
│       └── chat_socket_event.dart            // sealed: msgReceived | typing | presence | readReceipt | deleted
├── presentation/
│   ├── providers/
│   │   ├── messages_repository_provider.dart
│   │   ├── conversation_list_providers.dart  // tab + search + list state, 250ms debounce
│   │   ├── chat_thread_providers.dart        // family by convId; owns Stream subscription
│   │   ├── chat_composer_providers.dart      // draft, attach, voice-record state
│   │   ├── chat_details_providers.dart       // family by convId
│   │   └── chat_socket_provider.dart         // connection lifecycle (placeholder until M6)
│   ├── routes/
│   │   ├── messages_routes.dart              // chat, chatDetails
│   │   └── messages_args.dart
│   └── screens/
│       ├── messages_screen.dart              // replaces current placeholder
│       ├── chat_thread_screen.dart
│       ├── chat_details_screen.dart
│       └── widgets/
│           ├── conversation_tile.dart
│           ├── messages_tab_bar.dart
│           ├── chat_app_bar.dart
│           ├── message_bubble.dart
│           ├── audio_bubble.dart
│           ├── day_separator.dart
│           ├── chat_composer.dart
│           ├── attach_action_sheet.dart
│           ├── details_hero_header.dart
│           ├── details_section_card.dart
│           └── shared_file_row.dart
```

---

## 4. Repository Contract

Stable from day 1 — UI codes against this; dummy + real implementations both satisfy it.

```dart
abstract class MessagesRepository {
  Future<List<Conversation>> listConversations({
    required ConversationTab tab,
    String? query,
  });

  Future<ChatThread> fetchThread(String conversationId, {String? cursor});

  /// socket.io-backed event stream. UI never imports socket_io_client.
  Stream<ChatSocketEvent> events(String conversationId);

  Future<Message> sendText(String conversationId, String body);
  Future<Message> sendAudio(String conversationId, String localPath, Duration duration);
  Future<Message> sendAttachment(String conversationId, Attachment a);

  Future<void> markRead(String conversationId, String upToMessageId);

  Future<ChatDetails> fetchDetails(String conversationId);
}
```

### Implementation strategy

- `MessagesDummySource` — reads bundled JSON via `rootBundle.loadString`. `events()` returns `Stream.periodic` emitting fake typing / incoming-message events on a fixed cadence.
- `MessagesRemoteSource` — scaffolded only. Methods throw `UnimplementedError` until M6.
- `MessagesSocketSource` — scaffolded only. Owns `socket_io_client` connection, auth handshake via `SessionStore`. Throws until M6.
- `MessagesRepositoryImpl` composes both. A `useDummyMessagesProvider` flag (default `true` during UI phases) routes calls to dummy. Flip to `false` in M6.

### Why this shape

- `Stream<ChatSocketEvent>` keeps `socket_io_client` out of widget/notifier code.
- Connection lifecycle owned by `chatSocketProvider`, scoped to chat-thread route via `ref.onDispose`.
- Optimistic-send pattern lives in the notifier — UI never knows whether send is real or dummy.

---

## 5. Phase Plan (UI scope)

### Phase M1 — Foundation
- **M1.01** Add dummy JSON fixtures under `assets/dummy/messages/` — 3 conversations, 1 thread (12 messages incl. text + audio), 1 details payload.
- **M1.02** Domain entities + sealed `ChatSocketEvent`.
- **M1.03** `MessagesRepository` contract + `MessagesDummySource` (Future reads + `Stream.periodic` fake events).
- **M1.04** Riverpod skeleton — `messagesRepositoryProvider`, `useDummyMessagesProvider` flag (default `true`).
- **M1.05** Routes `chat`, `chatDetails` added to `Routes` enum + `router.dart` wiring (`extra: { conversationId, contactName }`).

### Phase M2 — Conversations list (Screen 1)
- **M2.01** `MessagesTabBar` widget — All / Shoots / Admin pill, `AppDurations.fast250` swap.
- **M2.02** `ConversationTile` widget — avatar + name + preview + timestamp + unread dot.
- **M2.03** `conversationListProvider` — `ConversationListState { tab, query, items, isLoading, error }`, 250ms debounced search (follow `kShootsSearchDebounce` precedent).
- **M2.04** Rebuild `messages_screen.dart` — `AppMainToolbar` + search field + tab bar + sliver list + `+` new-chat button (no-op).
- **M2.05** Empty / loading / error states via `AppEmptyState` + `AppLoader`.
- **M2.06** Pull-to-refresh.

### Phase M3 — Chat thread (Screen 2)
- **M3.01** `ChatAppBar` — back, avatar + name + presence subtitle, video / menu icons.
- **M3.02** `MessageBubble` — incoming / outgoing variants, asymmetric radius, sender label for incoming, timestamp tail.
- **M3.03** `AudioBubble` — play / pause, waveform (`CustomPainter` placeholder), duration.
- **M3.04** `DaySeparator` chip.
- **M3.05** `ChatComposer` — attach / `AppTextField` / emoji / camera / mic. Mic toggles dummy record state (no real capture).
- **M3.06** `chatThreadProvider` family by `conversationId` — owns Stream subscription, appends on event, optimistic send.
- **M3.07** `chat_thread_screen.dart` — chronological `ListView`, day-separator grouping selector, bottom auto-scroll on new, keyboard-aware.
- **M3.08** `AttachActionSheet` bottom sheet — camera / gallery / file / link-shoot (UI only).

### Phase M4 — Details (Screen 3)
- **M4.01** `DetailsHeroHeader` — warm beige curved header, large avatar, name, email, phone.
- **M4.02** `DetailsSectionCard` — collapsible row (chevron right, expand on tap). Used for Participants / Linked Shoot / Shared Files.
- **M4.03** `SharedFileRow` — file-type icon, name, meta (date · size), download icon (no-op).
- **M4.04** Notes section card with multiline `AppTextField` (admin-only copy).
- **M4.05** `chatDetailsProvider` family loads from dummy JSON.
- **M4.06** `chat_details_screen.dart` assemble + "Search in conversation" field (filters thread, dummy).
- **M4.07** Navigation — 3-dot menu on chat AppBar → `pushNamed` details.

### Phase M5 — Polish + tests
- **M5.01** Tab swap animation, bubble entrance fade, composer focus expand.
- **M5.02** A11y — semantics labels on icons, min 44pt touch targets.
- **M5.03** Golden tests — `ConversationTile`, `MessageBubble` (in / out / audio), `DetailsSectionCard`.
- **M5.04** Widget tests — list tab switch, send-message optimistic path, details section expand.

### Phase M6 — API + socket.io integration (out of UI scope)
- **M6.01** Implement `MessagesRemoteSource` against real REST contract.
- **M6.02** Implement `MessagesSocketSource` with `socket_io_client`, auth handshake via `SessionStore`.
- **M6.03** Flip `useDummyMessagesProvider` to `false`. Delete dummy bindings from prod build.
- **M6.04** Wire delivery + read receipts, presence, typing indicators end-to-end.
- **M6.05** Reconnect + offline send queue.

---

## 6. Conventions Locked In

- Async UI side-effects (toast, navigation on send-success) live in widget via `ref.listen`. Never in repo / notifier. (Phase 4 rule.)
- Composer controller stays in `ConsumerStatefulWidget`. Notifier owns parsed draft + attachments.
- Stream subscription lifetime = thread screen lifetime via `ref.onDispose`.
- Bubble cream surface = `AppColors.primary`. Matches Beige brand identity; no new palette.
- Dummy fixtures under `assets/dummy/messages/` with a `pubspec.yaml` asset entry. M6 can delete the asset entry and dummy source binding once real transport is active.
- All UI codes against `MessagesRepository` interface, never against a source directly.

---

## 7. Out of Scope

- Real REST endpoints (M6).
- socket.io connection management (M6).
- Push notifications.
- Group-chat creation flow.
- Media capture (camera / mic) — dummy state only in UI phases.
- Encryption / E2EE.
- Message search server-side (Details search is client-side filter in M4).
