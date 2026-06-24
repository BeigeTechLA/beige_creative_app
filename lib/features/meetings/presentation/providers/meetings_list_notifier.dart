import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meeting_status.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'meetings_list_state.dart';
import 'meetings_repository_provider.dart';

class MeetingsListNotifier extends AutoDisposeNotifier<MeetingsListState> {
  late final MeetingsRepository _repo;

  @override
  MeetingsListState build() {
    _repo = ref.watch(meetingsRepositoryProvider);
    Future.microtask(_load);
    return const MeetingsListState(status: MeetingsListStatus.loading);
  }

  Future<void> _load() async {
    state = state.copyWith(
      status: MeetingsListStatus.loading,
      clearError: true,
    );
    try {
      final items = await _repo.list(tab: state.tab, filter: state.filter);
      state = state.copyWith(
        items: items,
        status: MeetingsListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: MeetingsListStatus.error,
        error: _messageFor(e),
      );
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
    }
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Failed to load meetings';
  }

  void selectTab(MeetingStatus tab) {
    if (tab == state.tab) return;
    state = state.copyWith(tab: tab);
    _load();
  }

  void applyFilter(MeetingFilter filter) {
    state = state.copyWith(filter: filter);
    _load();
  }

  void clearFilter() {
    state = state.copyWith(filter: MeetingFilter.empty);
    _load();
  }

  Future<void> refresh() => _load();

  /// CP RSVP — call server, mark id pending while in-flight, patch the item
  /// in [items] on success, surface error via [rsvpError] otherwise.
  ///
  /// Re-entrancy guarded: ignores a second call for the same meeting while
  /// the first is in flight.
  Future<bool> respond(String meetingId, MeetingResponse response) async {
    if (state.pendingRsvpIds.contains(meetingId)) return false;

    state = state.copyWith(
      pendingRsvpIds: {...state.pendingRsvpIds, meetingId},
      clearRsvpError: true,
    );

    try {
      final updated = await _repo.respond(meetingId, response);
      final next = _replaceItem(state.items, updated);
      state = state.copyWith(
        items: next,
        pendingRsvpIds: state.pendingRsvpIds.difference({meetingId}),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        pendingRsvpIds: state.pendingRsvpIds.difference({meetingId}),
        rsvpError: _messageFor(e),
      );
      if (e is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
      return false;
    }
  }

  void clearRsvpError() {
    if (state.rsvpError == null) return;
    state = state.copyWith(clearRsvpError: true);
  }

  List<Meeting> _replaceItem(List<Meeting> items, Meeting updated) {
    final idx = items.indexWhere((m) => m.id == updated.id);
    if (idx < 0) return items;
    final next = List<Meeting>.of(items);
    next[idx] = updated;
    return next;
  }
}

final meetingsListNotifierProvider =
    AutoDisposeNotifierProvider<MeetingsListNotifier, MeetingsListState>(
      MeetingsListNotifier.new,
    );
