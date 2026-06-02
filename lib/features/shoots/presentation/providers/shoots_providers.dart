import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/crashlytics_breadcrumbs.dart';
import '../../../../core/firebase/telemetry_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/shoot_count_model.dart' as count_model;
import '../../../../model_class/shoots_model.dart';
import '../../domain/repositories/shoots_repository.dart';
import 'upcoming_shoot_providers.dart' show shootsRepositoryProvider;

/// Debounce window for search-as-you-type. Per `MIGRATION_RULES.md` §3.11 the
/// timer lives in the notifier (state-machine pattern), not the widget.
const Duration kShootsSearchDebounce = Duration(milliseconds: 250);

@immutable
class ShootsListState {
  /// Server-side hydrated list — never mutated by search.
  final List<Shoot> allShoots;

  /// Filtered view of `allShoots` after applying [searchQuery]. Equals
  /// `allShoots` when the query is empty.
  final List<Shoot> visibleShoots;

  final String searchQuery;
  final count_model.ShootCountData? counts;
  final bool isLoading;
  final String? errorMessage;
  final int actionInFlightProjectId;

  const ShootsListState({
    this.allShoots = const [],
    this.visibleShoots = const [],
    this.searchQuery = '',
    this.counts,
    this.isLoading = false,
    this.errorMessage,
    this.actionInFlightProjectId = 0,
  });

  ShootsListState copyWith({
    List<Shoot>? allShoots,
    List<Shoot>? visibleShoots,
    String? searchQuery,
    count_model.ShootCountData? counts,
    bool? isLoading,
    String? errorMessage,
    int? actionInFlightProjectId,
    bool clearError = false,
  }) {
    return ShootsListState(
      allShoots: allShoots ?? this.allShoots,
      visibleShoots: visibleShoots ?? this.visibleShoots,
      searchQuery: searchQuery ?? this.searchQuery,
      counts: counts ?? this.counts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionInFlightProjectId:
          actionInFlightProjectId ?? this.actionInFlightProjectId,
    );
  }
}

class ShootsListNotifier extends AutoDisposeNotifier<ShootsListState> {
  Timer? _debounce;

  @override
  ShootsListState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
    });
    Future.microtask(refresh);
    return const ShootsListState(isLoading: true);
  }

  /// Re-fetch dashboard + count in parallel. Re-applies the current search.
  /// Counts failure is non-fatal — the list still hydrates.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(shootsRepositoryProvider);

    final countsFuture = _safeFetchCounts(repo);

    try {
      final shoots = await repo.fetchShoots();
      final counts = await countsFuture;
      final filtered = _filter(shoots, state.searchQuery);
      state = state.copyWith(
        allShoots: shoots,
        visibleShoots: filtered,
        counts: counts,
        isLoading: false,
      );
    } catch (e, st) {
      AppLogger.e('Shoots refresh failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load shoots',
      );
    }
  }

  Future<count_model.ShootCountData?> _safeFetchCounts(
    ShootsRepository repo,
  ) async {
    try {
      return await repo.fetchShootCount();
    } catch (e, st) {
      AppLogger.e('Shoots fetchShootCount failed', e, st);
      return null;
    }
  }

  /// Public entry for the search field. Cancels the in-flight timer and
  /// schedules a single filter pass after [kShootsSearchDebounce]. The
  /// filter pass is purely client-side so we never hit the network here.
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _debounce?.cancel();
    _debounce = Timer(kShootsSearchDebounce, () {
      _applySearch(query);
    });
  }

  void _applySearch(String query) {
    final filtered = _filter(state.allShoots, query);
    state = state.copyWith(visibleShoots: filtered);
  }

  List<Shoot> _filter(List<Shoot> source, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<Shoot>.from(source);
    return source.where((s) {
      return s.projectName.toLowerCase().contains(q) ||
          s.contentType.toLowerCase().contains(q);
    }).toList();
  }

  /// One-tap accept from the list row. Tracks the in-flight project id so the
  /// row can render a loading state. Refreshes on success.
  Future<bool> acceptShoot(int projectId) async {
    final shootId = projectId.toString();
    CrashlyticsBreadcrumbs.start(
      featureArea: 'shoots.accept',
      message: 'shoot.accept.start id=$shootId',
    );
    state = state.copyWith(
      actionInFlightProjectId: projectId,
      clearError: true,
    );
    try {
      await ref
          .read(shootsRepositoryProvider)
          .respondToProject(projectId: projectId, status: 'accepted');
      unawaited(ref.read(telemetryClientProvider).shootAccepted(shootId));
      CrashlyticsBreadcrumbs.success('shoot.accept.success id=$shootId');
      await refresh();
      state = state.copyWith(actionInFlightProjectId: 0);
      return true;
    } catch (e, st) {
      CrashlyticsBreadcrumbs.failure('shoot.accept.failure id=$shootId');
      AppLogger.e('Shoots acceptShoot failed', e, st);
      state = state.copyWith(
        actionInFlightProjectId: 0,
        errorMessage: 'Failed to accept shoot',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final shootsListProvider =
    AutoDisposeNotifierProvider<ShootsListNotifier, ShootsListState>(
      ShootsListNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Cancel-shoot flow (modal bottom sheet — `ShootCancelledScreen` / `Routes.cancelShoot.name`).
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class CancelShootState {
  final String selectedReason;
  final bool isSubmitting;
  final String? errorMessage;
  final int submittedSignal;

  const CancelShootState({
    this.selectedReason = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.submittedSignal = 0,
  });

  CancelShootState copyWith({
    String? selectedReason,
    bool? isSubmitting,
    String? errorMessage,
    int? submittedSignal,
    bool clearError = false,
  }) {
    return CancelShootState(
      selectedReason: selectedReason ?? this.selectedReason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submittedSignal: submittedSignal ?? this.submittedSignal,
    );
  }
}

class CancelShootNotifier
    extends AutoDisposeFamilyNotifier<CancelShootState, int> {
  @override
  CancelShootState build(int arg) {
    return const CancelShootState();
  }

  void selectReason(String reason) {
    state = state.copyWith(selectedReason: reason, clearError: true);
  }

  /// Posts `accept-project` with `status: declined` and the chosen reason +
  /// optional free-form comment (used when "Others" is selected). Bumps
  /// [submittedSignal] on success so the widget can `ref.listen` and navigate
  /// to the cancelled-lotties screen.
  Future<bool> submit({String? comment}) async {
    if (state.selectedReason.isEmpty) {
      state = state.copyWith(errorMessage: 'Please choose a reason');
      return false;
    }
    final shootId = arg.toString();
    CrashlyticsBreadcrumbs.start(
      featureArea: 'shoots.cancel',
      message: 'shoot.cancel.start id=$shootId',
    );
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(shootsRepositoryProvider)
          .respondToProject(
            projectId: arg,
            status: 'declined',
            reason: state.selectedReason,
            comment: comment,
          );
      // UX-wise this is the "Cancel Shoot" flow even though the backend
      // status posted is `declined` — funnel separation lets us distinguish
      // cancel-screen-initiated rejections from in-detail declines.
      unawaited(ref.read(telemetryClientProvider).shootCancelled(shootId));
      CrashlyticsBreadcrumbs.success('shoot.cancel.success id=$shootId');
      state = state.copyWith(
        isSubmitting: false,
        submittedSignal: state.submittedSignal + 1,
      );
      return true;
    } catch (e, st) {
      CrashlyticsBreadcrumbs.failure('shoot.cancel.failure id=$shootId');
      AppLogger.e('Cancel shoot submit failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong',
      );
      return false;
    }
  }
}

final cancelShootProvider =
    AutoDisposeNotifierProviderFamily<
      CancelShootNotifier,
      CancelShootState,
      int
    >(CancelShootNotifier.new);
