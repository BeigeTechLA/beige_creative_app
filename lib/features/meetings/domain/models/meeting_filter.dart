import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_status.dart';

@immutable
class MeetingFilter {
  final Set<MeetingCategory> categories;
  final DateTimeRange? dateRange;
  final Set<MeetingStatus> statuses;

  const MeetingFilter({
    this.categories = const {},
    this.dateRange,
    this.statuses = const {},
  });

  bool get isEmpty =>
      categories.isEmpty && dateRange == null && statuses.isEmpty;

  MeetingFilter copyWith({
    Set<MeetingCategory>? categories,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    Set<MeetingStatus>? statuses,
  }) {
    return MeetingFilter(
      categories: categories ?? this.categories,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      statuses: statuses ?? this.statuses,
    );
  }

  static const MeetingFilter empty = MeetingFilter();
}

@immutable
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}
