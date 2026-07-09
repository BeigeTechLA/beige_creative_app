import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_category.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_response.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_status.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige_creative_app/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige_creative_app/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/meetings_list_notifier.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:beige_creative_app/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:beige_creative_app/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _FakeSessionStore extends Mock implements SessionStore {
  _FakeSessionStore({this.userId});
  final String? userId;

  @override
  Future<UserSnapshot?> readUser() async {
    if (userId == null) return null;
    return UserSnapshot(id: userId!);
  }
}

class _FakeMeetingsRepository implements MeetingsRepository {
  _FakeMeetingsRepository({List<Meeting>? seed})
    : _items = List<Meeting>.from(seed ?? _defaultSeed);

  final List<Meeting> _items;

  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async {
    Iterable<Meeting> r = _items;
    if (tab == MeetingsTab.upcoming) {
      r = r.where((m) => m.status != MeetingStatus.completed);
    } else if (tab == MeetingsTab.completed) {
      r = r.where((m) => m.status == MeetingStatus.completed);
    }
    if (filter != null && filter.categories.isNotEmpty) {
      r = r.where((m) => filter.categories.contains(m.category));
    }
    return r.toList();
  }

  @override
  Future<Meeting> getById(String id) async =>
      _items.firstWhere((m) => m.id == id);

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) =>
      throw UnimplementedError();

  @override
  Future<Meeting> respond(String id, MeetingResponse response) async =>
      _items.firstWhere((m) => m.id == id);
}

final _now = DateTime(2026, 1, 1, 10);

final _defaultSeed = <Meeting>[
  Meeting(
    id: 'u1',
    title: 'Upcoming One',
    description: 'd',
    project: 'p',
    platform: MeetingPlatform.meet,
    startAt: _now,
    endAt: _now.add(const Duration(hours: 1)),
    link: 'https://example.com/u1',
    reminderMinutes: 15,
    status: MeetingStatus.upcoming,
    category: MeetingCategory.commercial,
    agenda: const ['a1'],
    participants: const [],
  ),
  Meeting(
    id: 'u2',
    title: 'Upcoming Editorial',
    description: 'd',
    project: 'p',
    platform: MeetingPlatform.zoom,
    startAt: _now.add(const Duration(days: 1)),
    endAt: _now.add(const Duration(days: 1, hours: 1)),
    link: 'https://example.com/u2',
    reminderMinutes: 15,
    status: MeetingStatus.upcoming,
    category: MeetingCategory.wedding,
    agenda: const ['a1'],
    participants: const [],
  ),
  Meeting(
    id: 'c1',
    title: 'Completed One',
    description: 'd',
    project: 'p',
    platform: MeetingPlatform.teams,
    startAt: _now.subtract(const Duration(days: 1)),
    endAt: _now.subtract(const Duration(hours: 23)),
    link: 'https://example.com/c1',
    reminderMinutes: 15,
    status: MeetingStatus.completed,
    category: MeetingCategory.commercial,
    agenda: const ['a1'],
    participants: const [],
  ),
];

void main() {
  group('MeetingsScreen', () {
    testWidgets('renders upcoming meetings from repo', (tester) async {
      final repo = _FakeMeetingsRepository();
      final sessionStore = _FakeSessionStore();
      await tester.pumpProviderApp(
        const Scaffold(body: MeetingsScreen()),
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(repo),
          sessionStoreProvider.overrideWithValue(sessionStore),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming One'), findsOneWidget);
      expect(find.text('Upcoming Editorial'), findsOneWidget);
      expect(find.text('Completed One'), findsNothing);
      expect(find.byType(MeetingCard), findsNWidgets(2));
    });

    testWidgets('tab switch shows completed list', (tester) async {
      final repo = _FakeMeetingsRepository();
      final sessionStore = _FakeSessionStore();
      await tester.pumpProviderApp(
        const Scaffold(body: MeetingsScreen()),
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(repo),
          sessionStoreProvider.overrideWithValue(sessionStore),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(GestureDetector, 'Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Upcoming One'), findsNothing);
      expect(find.text('Completed One'), findsOneWidget);
      expect(find.byType(MeetingCard), findsOneWidget);
    });

    testWidgets('hides RSVP buttons for self-created meetings', (tester) async {
      final myUserId = 'user_123';
      final futureTime = DateTime.now().add(const Duration(days: 1));

      // Meeting created by current user
      final selfCreatedMeeting = Meeting(
        id: 'self',
        title: 'Self Created',
        description: 'd',
        project: 'p',
        platform: MeetingPlatform.meet,
        startAt: futureTime,
        endAt: futureTime.add(const Duration(hours: 1)),
        link: 'https://example.com/self',
        reminderMinutes: 15,
        status: MeetingStatus.upcoming,
        category: MeetingCategory.commercial,
        agenda: const ['agenda'],
        participants: const [],
        createdById: myUserId,
      );

      final repo = _FakeMeetingsRepository(seed: [selfCreatedMeeting]);
      final sessionStore = _FakeSessionStore(userId: myUserId);

      await tester.pumpProviderApp(
        const Scaffold(body: MeetingsScreen()),
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(repo),
          sessionStoreProvider.overrideWithValue(sessionStore),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Self Created'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('shows RSVP buttons for meetings created by others', (tester) async {
      final myUserId = 'user_123';
      final otherUserId = 'user_456';
      final futureTime = DateTime.now().add(const Duration(days: 1));

      // Meeting created by another user
      final otherCreatedMeeting = Meeting(
        id: 'other',
        title: 'Other Created',
        description: 'd',
        project: 'p',
        platform: MeetingPlatform.meet,
        startAt: futureTime,
        endAt: futureTime.add(const Duration(hours: 1)),
        link: 'https://example.com/other',
        reminderMinutes: 15,
        status: MeetingStatus.upcoming,
        category: MeetingCategory.commercial,
        agenda: const ['agenda'],
        participants: const [],
        createdById: otherUserId,
      );

      final repo = _FakeMeetingsRepository(seed: [otherCreatedMeeting]);
      final sessionStore = _FakeSessionStore(userId: myUserId);

      await tester.pumpProviderApp(
        const Scaffold(body: MeetingsScreen()),
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(repo),
          sessionStoreProvider.overrideWithValue(sessionStore),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Other Created'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });
  });

  group('MeetingsListNotifier', () {
    test('applyFilter shrinks list by category', () async {
      final repo = _FakeMeetingsRepository();
      final sessionStore = _FakeSessionStore();
      final container = ProviderContainer(
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(repo),
          sessionStoreProvider.overrideWithValue(sessionStore),
        ],
      );
      addTearDown(container.dispose);

      // Keep the AutoDispose notifier alive across calls.
      final sub = container.listen(
        meetingsListNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final notifier = container.read(meetingsListNotifierProvider.notifier);
      await notifier.refresh();
      expect(container.read(meetingsListNotifierProvider).items.length, 2);

      notifier.applyFilter(
        const MeetingFilter(categories: {MeetingCategory.wedding}),
      );
      // applyFilter triggers _load(); await its completion via refresh().
      await notifier.refresh();
      final state = container.read(meetingsListNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items.single.id, 'u2');
    });
  });
}
