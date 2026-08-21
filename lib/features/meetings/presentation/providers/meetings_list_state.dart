import 'package:flutter/foundation.dart';

import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_status.dart';
import '../../domain/models/meetings_tab.dart';

enum MeetingsListStatus { idle, loading, ready, error }

@immutable
class MeetingsListState {
  final MeetingsTab tab;
  final MeetingFilter filter;
  final MeetingsListStatus status;

  /// Full unfiltered page from the API. Stored once on load so filter
  /// changes can recompute locally without refetching. Notifier derives the
  /// visible [items] list from this.
  final List<Meeting> allItems;

  /// View-model list — already filtered by [filter].
  final List<Meeting> items;
  final String? error;

  /// Meeting ids with an in-flight Accept/Reject call. Card uses
  /// [isRsvpPending] to render the spinner + disable both buttons.
  final Set<String> pendingRsvpIds;

  /// One-shot error from the last RSVP submit. Screen consumes via
  /// `ref.listen` and calls [MeetingsListNotifier.clearRsvpError] after
  /// surfacing the toast.
  final String? rsvpError;

  /// Logged-in user's ID. Used to check if a meeting is self-created.
  final String? currentUserId;

  const MeetingsListState({
    this.tab = MeetingsTab.upcoming,
    this.filter = MeetingFilter.empty,
    this.status = MeetingsListStatus.idle,
    this.allItems = const [],
    this.items = const [],
    this.error,
    this.pendingRsvpIds = const <String>{},
    this.rsvpError,
    this.currentUserId,
  });

  bool get isFiltered => !filter.isEmpty;

  bool isRsvpPending(String meetingId) => pendingRsvpIds.contains(meetingId);

  MeetingsListState copyWith({
    MeetingsTab? tab,
    MeetingFilter? filter,
    MeetingsListStatus? status,
    List<Meeting>? allItems,
    List<Meeting>? items,
    String? error,
    bool clearError = false,
    Set<String>? pendingRsvpIds,
    String? rsvpError,
    bool clearRsvpError = false,
    String? currentUserId,
  }) {
    return MeetingsListState(
      tab: tab ?? this.tab,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      pendingRsvpIds: pendingRsvpIds ?? this.pendingRsvpIds,
      rsvpError: clearRsvpError ? null : (rsvpError ?? this.rsvpError),
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

/// Local filter applied to `allItems` to produce the visible list. Tab is
/// server-driven (`meeting_time_status`), so it is optional here — only
/// the client-side [MeetingFilter] runs by default.
List<Meeting> applyLocalMeetingFilters(
  List<Meeting> items, {
  MeetingsTab? tab,
  required MeetingFilter filter,
}) {
  Iterable<Meeting> result = items;

  if (tab != null) {
    switch (tab) {
      case MeetingsTab.upcoming:
        result = result.where((m) => m.status != MeetingStatus.completed);
      case MeetingsTab.completed:
        result = result.where((m) => m.status == MeetingStatus.completed);
    }
  }

  if (!filter.isEmpty) {
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

  final list = result.toList()..sort((a, b) => b.startAt.compareTo(a.startAt));
  return list;
}
