import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meetings_tab.dart';
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
      final all = await _repo.list(tab: state.tab);
      final user = await ref.read(sessionStoreProvider).readUser();
      // ignore: avoid_print
      print('[MEETINGS_NOTIFIER_DEBUG] user.id = ${user?.id}');
      state = state.copyWith(
        currentUserId: user?.id,
        allItems: all,
        items: applyLocalMeetingFilters(
          all,
          tab: null,
          filter: state.filter,
        ),
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

  /// Tab drives a server-side `meeting_time_status` filter. Switching tab
  /// kicks off a fresh fetch — clear the current list so the previous tab's
  /// items don't flash while the new fetch is in flight.
  void selectTab(MeetingsTab tab) {
    if (tab == state.tab) return;
    state = state.copyWith(
      tab: tab,
      allItems: const [],
      items: const [],
      status: MeetingsListStatus.loading,
      clearError: true,
    );
    _load();
  }

  void applyFilter(MeetingFilter filter) {
    final items = applyLocalMeetingFilters(
      state.allItems,
      tab: null,
      filter: filter,
    );
    state = state.copyWith(filter: filter, items: items);
  }

  void clearFilter() {
    final items = applyLocalMeetingFilters(
      state.allItems,
      tab: null,
      filter: MeetingFilter.empty,
    );
    state = state.copyWith(filter: MeetingFilter.empty, items: items);
  }

  Future<void> refresh() => _load();

  /// RSVP — call server, mark id pending while in-flight, patch the item
  /// in `allItems` + `items` on success, surface error via `rsvpError`
  /// otherwise.
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
      final nextAll = _replaceItem(state.allItems, updated);
      state = state.copyWith(
        allItems: nextAll,
        items: applyLocalMeetingFilters(
          nextAll,
          tab: null,
          filter: state.filter,
        ),
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
