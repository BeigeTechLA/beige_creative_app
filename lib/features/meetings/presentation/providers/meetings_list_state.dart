import 'package:flutter/foundation.dart';

import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_status.dart';

enum MeetingsListStatus { idle, loading, ready, error }

@immutable
class MeetingsListState {
  final MeetingStatus tab;
  final MeetingFilter filter;
  final MeetingsListStatus status;
  final List<Meeting> items;
  final String? error;

  const MeetingsListState({
    this.tab = MeetingStatus.upcoming,
    this.filter = MeetingFilter.empty,
    this.status = MeetingsListStatus.idle,
    this.items = const [],
    this.error,
  });

  bool get isFiltered => !filter.isEmpty;

  MeetingsListState copyWith({
    MeetingStatus? tab,
    MeetingFilter? filter,
    MeetingsListStatus? status,
    List<Meeting>? items,
    String? error,
    bool clearError = false,
  }) {
    return MeetingsListState(
      tab: tab ?? this.tab,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
