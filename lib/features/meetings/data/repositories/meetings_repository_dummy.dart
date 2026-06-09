import '../../domain/models/create_meeting_input.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_status.dart';
import '../../domain/repositories/meetings_repository.dart';
import '../dummy/dummy_meetings.dart';

class MeetingsRepositoryDummy implements MeetingsRepository {
  MeetingsRepositoryDummy() : _items = buildDummyMeetings();

  final List<Meeting> _items;
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
  }) async {
    await Future<void>.delayed(_latency);
    Iterable<Meeting> result = _items;

    if (tab != null) {
      // Tab "upcoming" matches anything in the future / not completed;
      // "completed" matches completed only. Other statuses fall through.
      if (tab == MeetingStatus.upcoming) {
        result = result.where((m) => m.status != MeetingStatus.completed);
      } else if (tab == MeetingStatus.completed) {
        result = result.where((m) => m.status == MeetingStatus.completed);
      }
    }

    if (filter != null && !filter.isEmpty) {
      if (filter.categories.isNotEmpty) {
        result = result.where((m) => filter.categories.contains(m.category));
      }
      if (filter.statuses.isNotEmpty) {
        result = result.where((m) => filter.statuses.contains(m.status));
      }
      if (filter.dateRange != null) {
        final s = filter.dateRange!.start;
        final e = filter.dateRange!.end;
        result = result.where(
          (m) => !m.startAt.isBefore(s) && !m.startAt.isAfter(e),
        );
      }
    }

    final list = result.toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    return list;
  }

  @override
  Future<Meeting> getById(String id) async {
    await Future<void>.delayed(_latency);
    return _items.firstWhere(
      (m) => m.id == id,
      orElse: () => throw StateError('Meeting $id not found'),
    );
  }

  @override
  Future<Meeting> create(CreateMeetingInput input) async {
    await Future<void>.delayed(_latency);
    final created = Meeting(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
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
    _items.add(created);
    return created;
  }
}
