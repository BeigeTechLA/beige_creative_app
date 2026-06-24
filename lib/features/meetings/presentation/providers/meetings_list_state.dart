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
  final Set<String> pendingRsvpIds;
  final String? rsvpError;

  const MeetingsListState({
    this.tab = MeetingStatus.upcoming,
    this.filter = MeetingFilter.empty,
    this.status = MeetingsListStatus.idle,
    this.items = const [],
    this.error,
    this.pendingRsvpIds = const <String>{},
    this.rsvpError,
  });

  bool get isFiltered => !filter.isEmpty;

  bool isRsvpPending(String meetingId) => pendingRsvpIds.contains(meetingId);

  MeetingsListState copyWith({
    MeetingStatus? tab,
    MeetingFilter? filter,
    MeetingsListStatus? status,
    List<Meeting>? items,
    String? error,
    bool clearError = false,
    Set<String>? pendingRsvpIds,
    String? rsvpError,
    bool clearRsvpError = false,
  }) {
    return MeetingsListState(
      tab: tab ?? this.tab,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      pendingRsvpIds: pendingRsvpIds ?? this.pendingRsvpIds,
      rsvpError: clearRsvpError ? null : (rsvpError ?? this.rsvpError),
    );
  }
}
