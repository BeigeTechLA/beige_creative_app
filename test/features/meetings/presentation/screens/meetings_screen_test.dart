import 'package:beige_creative_app/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_category.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_status.dart';
import 'package:beige_creative_app/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/create_meeting_notifier.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/create_meeting_state.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/meetings_list_notifier.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:beige_creative_app/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:beige_creative_app/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

class _FakeMeetingsRepository implements MeetingsRepository {
  _FakeMeetingsRepository({List<Meeting>? seed})
    : _items = List<Meeting>.from(seed ?? _defaultSeed);

  final List<Meeting> _items;

  @override
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
  }) async {
    Iterable<Meeting> r = _items;
    if (tab == MeetingStatus.upcoming) {
      r = r.where((m) => m.status != MeetingStatus.completed);
    } else if (tab == MeetingStatus.completed) {
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
  Future<Meeting> create(CreateMeetingInput input) async {
    final m = Meeting(
      id: 'new',
      title: input.title,
      description: input.description,
      project: input.project,
      platform: input.platform,
      startAt: input.startAt,
      endAt: input.endAt,
      link: input.link,
      reminderMinutes: input.reminderMinutes,
      status: MeetingStatus.upcoming,
      category: input.category,
      agenda: input.agenda,
      participants: input.participants,
    );
    _items.add(m);
    return m;
  }
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
    category: MeetingCategory.editorial,
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
      await tester.pumpProviderApp(
        const Scaffold(body: MeetingsScreen()),
        overrides: [meetingsRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming One'), findsOneWidget);
      expect(find.text('Upcoming Editorial'), findsOneWidget);
      expect(find.text('Completed One'), findsNothing);
      expect(find.byType(MeetingCard), findsNWidgets(2));
    });

    testWidgets('tab switch shows completed list', (tester) async {
      final repo = _FakeMeetingsRepository();
      await tester.pumpProviderApp(
        const Scaffold(body: MeetingsScreen()),
        overrides: [meetingsRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(GestureDetector, 'Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Upcoming One'), findsNothing);
      expect(find.text('Completed One'), findsOneWidget);
      expect(find.byType(MeetingCard), findsOneWidget);
    });
  });

  group('MeetingsListNotifier', () {
    test('applyFilter shrinks list by category', () async {
      final repo = _FakeMeetingsRepository();
      final container = ProviderContainer(
        overrides: [meetingsRepositoryProvider.overrideWithValue(repo)],
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
        const MeetingFilter(categories: {MeetingCategory.editorial}),
      );
      // applyFilter triggers _load(); await its completion via refresh().
      await notifier.refresh();
      final state = container.read(meetingsListNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items.single.id, 'u2');
    });
  });

  group('CreateMeetingNotifier', () {
    test('isValid flips when all fields are populated', () {
      final container = ProviderContainer(
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(_FakeMeetingsRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(createMeetingNotifierProvider.notifier);
      expect(container.read(createMeetingNotifierProvider).isValid, isFalse);

      notifier.setTitle('Title');
      notifier.setDescription('Desc');
      notifier.setProject('Project');
      notifier.setDate(DateTime(2026, 6, 10));
      notifier.setStartTime(const TimeOfDayValue(10, 0));
      notifier.setEndTime(const TimeOfDayValue(11, 0));
      notifier.setLink('https://meet.google.com/abc');
      notifier.addParticipant('Participant');

      expect(container.read(createMeetingNotifierProvider).isValid, isTrue);
    });

    test('end time before start time blocks isValid', () {
      final container = ProviderContainer(
        overrides: [
          meetingsRepositoryProvider.overrideWithValue(_FakeMeetingsRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(createMeetingNotifierProvider.notifier);
      notifier.setTitle('Title');
      notifier.setDescription('Desc');
      notifier.setProject('Project');
      notifier.setDate(DateTime(2026, 6, 10));
      notifier.setStartTime(const TimeOfDayValue(11, 0));
      notifier.setEndTime(const TimeOfDayValue(10, 0));
      notifier.setLink('https://meet.google.com/abc');
      notifier.addParticipant('Participant');

      expect(container.read(createMeetingNotifierProvider).isValid, isFalse);
    });
  });
}
