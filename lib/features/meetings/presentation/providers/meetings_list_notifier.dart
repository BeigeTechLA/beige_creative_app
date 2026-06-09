import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/meeting_filter.dart';
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
        error: e.toString(),
      );
    }
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
}

final meetingsListNotifierProvider =
    AutoDisposeNotifierProvider<MeetingsListNotifier, MeetingsListState>(
      MeetingsListNotifier.new,
    );
