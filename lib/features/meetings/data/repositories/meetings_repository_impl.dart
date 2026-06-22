import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_status.dart';
import '../../domain/models/update_meeting_input.dart';
import '../../domain/repositories/meetings_repository.dart';
import '../mappers/meeting_enum_mapper.dart';
import '../sources/meetings_remote_source.dart';

/// Dio-backed implementation of [MeetingsRepository].
///
/// Server only exposes `limit`/`page`/`sortBy` query params today
/// (`MEETINGS_API.md` §1) — `tab` and [MeetingFilter] are applied client-side
/// on the fetched page. Volumes today (≤30 records observed) make in-memory
/// filtering acceptable; re-evaluate when pagination ships.
class MeetingsRepositoryImpl implements MeetingsRepository {
  MeetingsRepositoryImpl(this._remote);

  final MeetingsRemoteSource _remote;

  @override
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
  }) async {
    final page = await _remote.list();
    return _applyClientFilters(page.items, tab: tab, filter: filter);
  }

  @override
  Future<Meeting> getById(String id) => _remote.getById(id);

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) {
    final body = _buildUpdateBody(patch);
    return _remote.update(id, body);
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);

  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) =>
      _remote.addParticipants(id, userIds);

  /// Serializes [UpdateMeetingInput] to the server's snake_case patch body.
  /// Skips `null` fields so PATCH stays truly partial (`MEETINGS_API.md` §5).
  /// `duration` never included — server recomputes from times.
  Map<String, dynamic> _buildUpdateBody(UpdateMeetingInput p) {
    final body = <String, dynamic>{};
    if (p.title != null) body['meeting_title'] = p.title;
    if (p.description != null) body['description'] = p.description;
    if (p.startAt != null) {
      body['meeting_date_time'] = p.startAt!.toUtc().toIso8601String();
    }
    if (p.endAt != null) {
      body['meeting_end_time'] = p.endAt!.toUtc().toIso8601String();
    }
    if (p.link != null) body['meetLink'] = p.link;
    if (p.reminderMinutes != null) body['reminder_minutes'] = p.reminderMinutes;
    if (p.status != null) {
      body['meeting_status'] = MeetingEnumMapper.statusToServer(p.status!);
    }
    if (p.category != null) {
      body['meeting_type'] = MeetingEnumMapper.categoryToServer(p.category!);
    }
    return body;
  }

  /// Server only exposes `limit/page/sortBy` query params today, so `tab` +
  /// [MeetingFilter] are applied client-side. `tab=upcoming` includes anything
  /// that isn't `completed`; `tab=completed` includes completed only. Other
  /// tabs fall through (no filter applied — defensive, no UI surface today).
  List<Meeting> _applyClientFilters(
    List<Meeting> items, {
    MeetingStatus? tab,
    MeetingFilter? filter,
  }) {
    Iterable<Meeting> result = items;

    if (tab != null) {
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
}
