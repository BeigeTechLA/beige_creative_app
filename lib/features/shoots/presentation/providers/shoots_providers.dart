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
  final ShootsData shootsData;

  /// Filtered view of `shootsData` or `topCardShoots` after applying [searchQuery], [selectedTabIndex], and [selectedStatusFilter].
  final List<Shoot> visibleShoots;

  final String searchQuery;
  final int selectedTabIndex; // 0 = Request, 1 = Shoots
  final String selectedStatusFilter; // 'All Status', 'Pending', 'Confirmed'
  final String? selectedTopCard;
  final List<Shoot>? topCardShoots;
  final count_model.ShootCountData? counts;
  final bool isLoading;
  final String? errorMessage;
  final int actionInFlightProjectId;

  List<Shoot> get allShoots => shootsData.all;

  ShootsListState({
    ShootsData? shootsData,
    this.visibleShoots = const [],
    this.searchQuery = '',
    this.selectedTabIndex = 0,
    this.selectedStatusFilter = 'All Status',
    this.selectedTopCard,
    this.topCardShoots,
    this.counts,
    this.isLoading = false,
    this.errorMessage,
    this.actionInFlightProjectId = 0,
  }) : shootsData = shootsData ?? ShootsData();

  ShootsListState copyWith({
    ShootsData? shootsData,
    List<Shoot>? allShoots,
    List<Shoot>? visibleShoots,
    String? searchQuery,
    int? selectedTabIndex,
    String? selectedStatusFilter,
    String? selectedTopCard,
    bool clearSelectedTopCard = false,
    List<Shoot>? topCardShoots,
    bool clearTopCardShoots = false,
    count_model.ShootCountData? counts,
    bool? isLoading,
    String? errorMessage,
    int? actionInFlightProjectId,
    bool clearError = false,
  }) {
    final effectiveShootsData = shootsData ??
        (allShoots != null ? ShootsData(shoots: allShoots) : this.shootsData);
    return ShootsListState(
      shootsData: effectiveShootsData,
      visibleShoots: visibleShoots ?? this.visibleShoots,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedStatusFilter:
          selectedStatusFilter ?? this.selectedStatusFilter,
      selectedTopCard:
          clearSelectedTopCard ? null : (selectedTopCard ?? this.selectedTopCard),
      topCardShoots:
          clearTopCardShoots ? null : (topCardShoots ?? this.topCardShoots),
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
    return ShootsListState(isLoading: true);
  }

  String? _getCardStatus(String cardTitle) {
    switch (cardTitle) {
      case 'Pending Shoots':
        return 'pending';
      case 'Confirmed Shoots':
        return 'confirmed';
      case 'Completed Shoots':
        return 'completed';
      case 'Declined':
        return 'rejected';
      default:
        return null;
    }
  }

  /// Re-fetch dashboard + count in parallel. Re-applies the current search and tab filter.
  /// Counts failure is non-fatal — the list still hydrates.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(shootsRepositoryProvider);

    final countsFuture = _safeFetchCounts(repo);

    try {
      final shootsData = await repo.fetchShoots(
        requestStatus: 'all',
        shootStatus: 'completed',
      );
      final counts = await countsFuture;

      List<Shoot>? topCardShoots = state.topCardShoots;
      if (state.selectedTopCard != null) {
        final statusParam = _getCardStatus(state.selectedTopCard!);
        if (statusParam != null) {
          try {
            topCardShoots = await repo.fetchShootCardDetails(statusParam);
          } catch (e, st) {
            AppLogger.e('Shoots fetchShootCardDetails refresh failed', e, st);
          }
        }
      }

      final filtered = _filter(
        shootsData,
        state.searchQuery,
        state.selectedTabIndex,
        state.selectedStatusFilter,
        topCardShoots: topCardShoots,
      );
      state = state.copyWith(
        shootsData: shootsData,
        topCardShoots: topCardShoots,
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

  /// Switch active tab segment (0 = Request, 1 = Shoots).
  void selectTab(int index) {
    if (state.selectedTabIndex == index) return;
    final filtered = _filter(
      state.shootsData,
      state.searchQuery,
      index,
      state.selectedStatusFilter,
      topCardShoots: state.topCardShoots,
    );
    state = state.copyWith(
      selectedTabIndex: index,
      visibleShoots: filtered,
    );
  }

  String? _mapStatusToCardTitle(String status) {
    switch (status) {
      case 'Pending':
        return 'Pending Shoots';
      case 'Confirmed':
        return 'Confirmed Shoots';
      case 'Completed':
        return 'Completed Shoots';
      case 'Declined':
      case 'Cancelled':
        return 'Declined';
      default:
        return null;
    }
  }

  String _mapCardTitleToStatus(String cardTitle) {
    switch (cardTitle) {
      case 'Pending Shoots':
        return 'Pending';
      case 'Confirmed Shoots':
        return 'Confirmed';
      case 'Completed Shoots':
        return 'Completed';
      case 'Declined':
        return 'Declined';
      default:
        return 'All Status';
    }
  }

  /// Set status filter ('All Status', 'Pending', 'Confirmed', 'Completed', 'Declined').
  /// Synchronizes [selectedTopCard] and fetches card details for the matching status card.
  Future<void> setStatusFilter(String status) async {
    final cardTitle = _mapStatusToCardTitle(status);
    if (status == 'All Status' || cardTitle == null) {
      clearTopCardSelection();
      return;
    }

    final statusParam = _getCardStatus(cardTitle);

    state = state.copyWith(
      selectedStatusFilter: status,
      selectedTopCard: cardTitle,
      isLoading: true,
      clearError: true,
    );

    List<Shoot>? cardShoots;
    if (statusParam != null) {
      try {
        final repo = ref.read(shootsRepositoryProvider);
        cardShoots = await repo.fetchShootCardDetails(statusParam);
      } catch (e, st) {
        AppLogger.e('Shoots fetchShootCardDetails failed', e, st);
      }
    }

    final filtered = _filter(
      state.shootsData,
      state.searchQuery,
      state.selectedTabIndex,
      status,
      topCardShoots: cardShoots ?? state.topCardShoots,
    );

    state = state.copyWith(
      selectedStatusFilter: status,
      selectedTopCard: cardTitle,
      topCardShoots: cardShoots ?? state.topCardShoots,
      visibleShoots: filtered,
      isLoading: false,
    );
  }

  /// Select a top rectangle count card option.
  /// Synchronizes [selectedStatusFilter] and toggles selection off if tapped again.
  Future<void> selectTopCard(String cardTitle) async {
    if (state.selectedTopCard == cardTitle) {
      clearTopCardSelection();
      return;
    }
    final status = _mapCardTitleToStatus(cardTitle);
    await setStatusFilter(status);
  }

  /// Clear top count card selection and status filter, restoring segment control.
  void clearTopCardSelection() {
    final filtered = _filter(
      state.shootsData,
      state.searchQuery,
      state.selectedTabIndex,
      'All Status',
      topCardShoots: null,
    );
    state = state.copyWith(
      selectedStatusFilter: 'All Status',
      clearSelectedTopCard: true,
      clearTopCardShoots: true,
      visibleShoots: filtered,
    );
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
    final filtered = _filter(
      state.shootsData,
      query,
      state.selectedTabIndex,
      state.selectedStatusFilter,
      topCardShoots: state.topCardShoots,
    );
    state = state.copyWith(visibleShoots: filtered);
  }

  @visibleForTesting
  List<Shoot> filterForTesting(
    ShootsData data, {
    required String query,
    required int tabIndex,
    required String statusFilter,
    List<Shoot>? topCardShoots,
  }) =>
      _filter(
        data,
        query,
        tabIndex,
        statusFilter,
        topCardShoots: topCardShoots,
      );

  List<Shoot> _filter(
    ShootsData data,
    String query,
    int tabIndex,
    String statusFilter, {
    List<Shoot>? topCardShoots,
  }) {
    final q = query.trim().toLowerCase();
    final List<Shoot> source = topCardShoots ??
        (tabIndex == 0 ? data.requests : data.shoots);

    return source.where((s) {
      if (statusFilter != 'All Status') {
        final statusLower = s.status.trim().toLowerCase();
        final isCompleted = statusLower == 'completed';
        final isDeclinedOrCancelled = statusLower == 'declined' ||
            statusLower == 'cancelled' ||
            statusLower == 'rejected';
        final isConfirmed = statusLower == 'confirmed' ||
            statusLower == 'accepted' ||
            s.crewAccept == 1;
        final isPending = (statusLower == 'pending' ||
                statusLower.contains('pending') ||
                s.crewAccept == 0) &&
            !isConfirmed &&
            !isCompleted &&
            !isDeclinedOrCancelled;

        if (statusFilter == 'Pending' && !isPending) return false;
        if (statusFilter == 'Confirmed' && !isConfirmed) return false;
        if (statusFilter == 'Completed' && !isCompleted) return false;
        if ((statusFilter == 'Declined' || statusFilter == 'Cancelled') &&
            !isDeclinedOrCancelled) {
          return false;
        }
      }

      if (q.isEmpty) return true;
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
