import 'package:beige_creative_app/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:beige_creative_app/features/meetings/data/sources/meetings_remote_source.dart';
import 'package:beige_creative_app/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_category.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_participant.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_status.dart';
import 'package:flutter_test/flutter_test.dart';

Meeting _m({
  required String id,
  MeetingStatus status = MeetingStatus.upcoming,
  MeetingCategory category = MeetingCategory.commercial,
  DateTime? startAt,
}) => Meeting(
  id: id,
  title: 'T-$id',
  description: '',
  project: '',
  platform: MeetingPlatform.meet,
  startAt: startAt ?? DateTime(2026, 6, 11, 13),
  endAt: (startAt ?? DateTime(2026, 6, 11, 13)).add(const Duration(hours: 1)),
  link: 'https://meet.google.com/x',
  reminderMinutes: 15,
  status: status,
  category: category,
  agenda: const [],
  participants: const [],
);

/// Hand-rolled fake source — mocktail mocks of `MeetingsRemoteSource` would
/// drag in DioClient/SessionStore setup the repo doesn't need.
class _FakeRemote implements MeetingsRemoteSource {
  _FakeRemote({List<Meeting>? seed}) : items = List<Meeting>.from(seed ?? const []);

  final List<Meeting> items;
  int createCalls = 0;
  int addParticipantsCalls = 0;
  List<String>? lastAddedUserIds;
  String? lastAddedMeetingId;

  @override
  Future<MeetingsPage> list({
    int page = 1,
    int limit = 100,
    String sortBy = 'meeting_date_time:desc',
  }) async => MeetingsPage(items: items, hasMore: false);

  @override
  Future<Meeting> getById(String id) async =>
      items.firstWhere((m) => m.id == id);

  @override
  Future<Meeting> create(CreateMeetingInput input) async {
    createCalls += 1;
    final m = _m(id: 'created');
    items.add(m);
    return m;
  }

  @override
  Future<Meeting> addParticipants(
    String meetingId,
    List<String> userIds,
  ) async {
    addParticipantsCalls += 1;
    lastAddedMeetingId = meetingId;
    lastAddedUserIds = userIds;
    final base = items.firstWhere((m) => m.id == meetingId);
    return base.copyWith(
      participants: [
        for (final id in userIds) MeetingParticipant(id: id, name: 'P-$id'),
      ],
    );
  }

  @override
  Future<Meeting> update(String id, Map<String, dynamic> patch) async {
    final base = items.firstWhere((m) => m.id == id);
    return base.copyWith(title: (patch['meeting_title'] as String?) ?? base.title);
  }

  @override
  Future<void> delete(String id) async {
    items.removeWhere((m) => m.id == id);
  }
}

CreateMeetingInput _input({List<MeetingParticipant> participants = const []}) =>
    CreateMeetingInput(
      title: 'New',
      description: 'd',
      project: 'p',
      startAt: DateTime(2026, 6, 11, 13),
      endAt: DateTime(2026, 6, 11, 14),
      platform: MeetingPlatform.meet,
      link: 'https://meet.google.com/x',
      reminderMinutes: 15,
      category: MeetingCategory.commercial,
      participants: participants,
    );

void main() {
  group('list — client-side filtering', () {
    test('tab=upcoming excludes completed', () async {
      final remote = _FakeRemote(
        seed: [
          _m(id: 'a', status: MeetingStatus.upcoming),
          _m(id: 'b', status: MeetingStatus.completed),
          _m(id: 'c', status: MeetingStatus.upcoming),
        ],
      );
      final repo = MeetingsRepositoryImpl(remote);

      final result = await repo.list(tab: MeetingStatus.upcoming);

      expect(result.map((m) => m.id).toSet(), {'a', 'c'});
    });

    test('tab=completed keeps only completed', () async {
      final remote = _FakeRemote(
        seed: [
          _m(id: 'a', status: MeetingStatus.upcoming),
          _m(id: 'b', status: MeetingStatus.completed),
        ],
      );
      final repo = MeetingsRepositoryImpl(remote);

      final result = await repo.list(tab: MeetingStatus.completed);

      expect(result.map((m) => m.id).toList(), ['b']);
    });

    test('MeetingFilter category shrinks result + sorts by startAt asc', () async {
      final remote = _FakeRemote(
        seed: [
          _m(
            id: 'a',
            category: MeetingCategory.commercial,
            startAt: DateTime(2026, 6, 11, 13),
          ),
          _m(
            id: 'b',
            category: MeetingCategory.editorial,
            startAt: DateTime(2026, 6, 10, 13),
          ),
          _m(
            id: 'c',
            category: MeetingCategory.commercial,
            startAt: DateTime(2026, 6, 9, 13),
          ),
        ],
      );
      final repo = MeetingsRepositoryImpl(remote);

      final result = await repo.list(
        filter: const MeetingFilter(
          categories: {MeetingCategory.commercial},
        ),
      );

      expect(result.map((m) => m.id).toList(), ['c', 'a']); // asc by startAt
    });
  });

  group('create — two-step chain', () {
    test('input without participants → single POST only', () async {
      final remote = _FakeRemote();
      final repo = MeetingsRepositoryImpl(remote);

      await repo.create(_input(participants: const []));

      expect(remote.createCalls, 1);
      expect(remote.addParticipantsCalls, 0);
    });

    test('input with participants → POST then addParticipants', () async {
      final remote = _FakeRemote();
      final repo = MeetingsRepositoryImpl(remote);

      final result = await repo.create(
        _input(
          participants: const [
            MeetingParticipant(id: '4', name: 'A'),
            MeetingParticipant(id: '7', name: 'B'),
          ],
        ),
      );

      expect(remote.createCalls, 1);
      expect(remote.addParticipantsCalls, 1);
      expect(remote.lastAddedMeetingId, 'created');
      expect(remote.lastAddedUserIds, ['4', '7']);
      expect(result.participants.map((p) => p.id).toList(), ['4', '7']);
    });

    test('input with only empty-id participants → no add-participants call', () async {
      final remote = _FakeRemote();
      final repo = MeetingsRepositoryImpl(remote);

      await repo.create(
        _input(
          participants: const [MeetingParticipant(id: '', name: 'Blank')],
        ),
      );

      expect(remote.createCalls, 1);
      expect(remote.addParticipantsCalls, 0);
    });
  });
}
