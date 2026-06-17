import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_status.dart';

/// Partial patch for an existing meeting. Every field nullable — `null` means
/// "leave unchanged" (matches PATCH semantics per `MEETINGS_API.md` §5).
///
/// `duration` deliberately absent — server recomputes from start/end
/// (`MEETINGS_API.md` §5 ✅ note). `participants`/`cp_ids`/`order_id`
/// mutability via PATCH is unverified (Q12); kept out of the patch type until
/// backend confirms.
@immutable
class UpdateMeetingInput {
  final String? title;
  final String? description;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? link;
  final int? reminderMinutes;
  final MeetingStatus? status;
  final MeetingCategory? category;

  const UpdateMeetingInput({
    this.title,
    this.description,
    this.startAt,
    this.endAt,
    this.link,
    this.reminderMinutes,
    this.status,
    this.category,
  });

  bool get isEmpty =>
      title == null &&
      description == null &&
      startAt == null &&
      endAt == null &&
      link == null &&
      reminderMinutes == null &&
      status == null &&
      category == null;
}
