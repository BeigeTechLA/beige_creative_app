import '../../domain/models/meeting_category.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_status.dart';

/// Translates server enum strings to client enums.
///
/// Server `meeting_status` (observed): `pending`, `rescheduled`, `cancelled`.
/// `completed` plausible but never observed (`MEETINGS_API.md` §Enums).
/// Server `meeting_type` (observed): `post_production` only — open enum.
///
/// Unknown values fall back to a sentinel rather than throwing — backend may
/// add values without coordinated client release.
class MeetingEnumMapper {
  MeetingEnumMapper._();

  static MeetingStatus statusFromServer(String? raw) {
    switch (raw) {
      case 'pending':
      case 'rescheduled':
        return MeetingStatus.upcoming;
      case 'completed':
      case 'cancelled':
        return MeetingStatus.completed;
      default:
        return MeetingStatus.upcoming;
    }
  }

  /// Client → server for create/update bodies. Client only ever submits
  /// `upcoming` on create (status defaults to `pending` server-side).
  static String statusToServer(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.upcoming:
      case MeetingStatus.initiated:
      case MeetingStatus.revision:
        return 'pending';
      case MeetingStatus.completed:
        return 'completed';
    }
  }

  /// Backend has not published the full `meeting_type` set. All 30 read
  /// records carry `post_production`. Map everything to `commercial` as a
  /// placeholder until backend pins the taxonomy.
  static MeetingCategory categoryFromServer(String? raw) {
    // ignore: unused_local_variable
    final _ = raw;
    return MeetingCategory.commercial;
  }

  static String categoryToServer(MeetingCategory category) {
    // Until backend confirms category vocabulary, all client categories
    // serialize as `post_production` (only observed value).
    return 'post_production';
  }

  /// Server has no `platform` field — derive from `meetLink` host.
  static MeetingPlatform platformFromLink(String? link) {
    if (link == null || link.isEmpty) return MeetingPlatform.meet;
    final lower = link.toLowerCase();
    if (lower.contains('zoom.us') || lower.contains('zoom.com')) {
      return MeetingPlatform.zoom;
    }
    if (lower.contains('teams.microsoft.com') ||
        lower.contains('teams.live.com')) {
      return MeetingPlatform.teams;
    }
    return MeetingPlatform.meet;
  }
}
