import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/session/session_store.dart';
import '../../domain/models/meeting.dart';
import '../dto/meeting_dto.dart';

/// One page of meetings + a cursor-style `hasMore` flag.
///
/// `MeetingsRepository.list` collapses pagination today (single shot
/// `limit=100`), but the source exposes the envelope so future infinite scroll
/// can wire through without re-touching this layer.
class MeetingsPage {
  const MeetingsPage({required this.items, required this.hasMore});
  final List<Meeting> items;
  final bool hasMore;
}

/// REST source for the `external-meetings` endpoints.
///
/// All methods translate `DioException` → typed `AppException` via
/// [ExceptionHandler.mapDioException] so the notifier layer sees the same
/// error taxonomy as the rest of the app.
class MeetingsRemoteSource {
  MeetingsRemoteSource(this._client, this._session);

  final DioClient _client;
  final SessionStore _session;

  Dio get _dio => _client.dio;

  /// Single funnel for `DioException` → `AppException`.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<MeetingsPage> list({
    int page = 1,
    int limit = 100,
    String sortBy = 'meeting_date_time:desc',
  }) {
    return _guard(() async {
      final user = await _session.readUser();
      final userId = user?.id ?? '';
      if (userId.isEmpty) {
        throw const UnauthorizedException(
          message: 'Cannot list meetings without an authenticated user',
        );
      }
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.meetingsByUser(userId),
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
        },
      );
      final raw = resp.data;
      final rawList = _unwrapResults(raw);
      final items = rawList.map(MeetingDto.fromRestJson).toList(growable: false);
      return MeetingsPage(
        items: items,
        hasMore: _hasMoreFromEnvelope(raw, page: page, limit: limit),
      );
    });
  }

  Future<Meeting> getById(String id) {
    return _guard(() async {
      final resp = await _dio.get<dynamic>(ApiEndpoints.meetingById(id));
      return MeetingDto.fromRestJson(_unwrapItem(resp.data));
    });
  }

  /// Attaches participants to an existing meeting. Returns the full updated
  /// meeting (server response shape per MEETINGS_API.md §4).
  ///
  /// `role` field on the request body has no observable effect — server
  /// always tags added users as `role: "participant"`. We send the same value
  /// so we don't depend on backend ignoring an unknown role.
  Future<Meeting> addParticipants(String meetingId, List<String> userIds) {
    return _guard(() async {
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.meetingParticipants(meetingId),
        data: {
          'role': 'participant',
          'user_ids': userIds, // strings, per §4 quirk note
        },
      );
      return MeetingDto.fromRestJson(_unwrapItem(resp.data));
    });
  }

  /// Partial update. Caller supplies only the keys to change.
  ///
  /// `duration` is stripped defensively — server recomputes from start/end
  /// (MEETINGS_API.md §5); sending it risks a 400 if the backend ever
  /// enforces immutability.
  Future<Meeting> update(String id, Map<String, dynamic> patch) {
    return _guard(() async {
      final body = Map<String, dynamic>.of(patch)..remove('duration');
      final resp = await _dio.patch<dynamic>(
        ApiEndpoints.meetingById(id),
        data: body,
      );
      return MeetingDto.fromRestJson(_unwrapItem(resp.data));
    });
  }

  Future<void> delete(String id) {
    return _guard(() async {
      await _dio.delete<dynamic>(ApiEndpoints.meetingById(id));
    });
  }

  // ───── envelope helpers ────────────────────────────────────────────────

  /// List envelope is `{results, page, limit, totalPages, totalResults}`
  /// (MEETINGS_API.md §1). Falls back to bare-list / generic envelope shapes
  /// in case backend ever pivots.
  static List<Map<String, dynamic>> _unwrapResults(dynamic raw) {
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    if (raw is Map<String, dynamic>) {
      for (final key in const ['results', 'data', 'items']) {
        final v = raw[key];
        if (v is List) return v.cast<Map<String, dynamic>>();
      }
    }
    throw const FormatException('Unrecognized meetings list envelope');
  }

  /// Single-object endpoints (`GET :id`, `POST`, `POST /participants`, PATCH)
  /// return the Meeting directly per MEETINGS_API.md. Stay tolerant in case
  /// backend wraps in `{data: ...}` later.
  static Map<String, dynamic> _unwrapItem(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      for (final key in const ['data', 'result']) {
        final v = raw[key];
        if (v is Map<String, dynamic>) return v;
      }
      return raw;
    }
    throw const FormatException('Unrecognized meeting envelope');
  }

  /// `hasMore = page < totalPages` per documented envelope. Falls back to
  /// `data.length >= limit` if `totalPages` absent.
  static bool _hasMoreFromEnvelope(
    dynamic raw, {
    required int page,
    required int limit,
  }) {
    if (raw is Map<String, dynamic>) {
      final total = raw['totalPages'];
      if (total is num) return page < total;
    }
    try {
      return _unwrapResults(raw).length >= limit;
    } catch (_) {
      return false;
    }
  }
}
