import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/upcoming_shootview_model.dart';
import '../../data/repositories/shoots_repository_impl.dart';
import '../../domain/repositories/shoots_repository.dart';

final shootsRepositoryProvider = Provider<ShootsRepository>(
  (ref) => ShootsRepositoryImpl(ref.read(dioClientProvider)),
);

@immutable
class UpcomingShootDetailState {
  final MyData? data;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final int respondedSignal;

  const UpcomingShootDetailState({
    this.data,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.respondedSignal = 0,
  });

  UpcomingShootDetailState copyWith({
    MyData? data,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    int? respondedSignal,
    bool clearError = false,
  }) {
    return UpcomingShootDetailState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      respondedSignal: respondedSignal ?? this.respondedSignal,
    );
  }
}

class UpcomingShootDetailNotifier
    extends AutoDisposeFamilyNotifier<UpcomingShootDetailState, int> {
  @override
  UpcomingShootDetailState build(int arg) {
    Future.microtask(refresh);
    return const UpcomingShootDetailState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data =
          await ref.read(shootsRepositoryProvider).fetchProjectDetail(arg);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Upcoming shoot detail fetch failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load project',
      );
    }
  }

  Future<bool> accept() => _respond(status: 'accepted');

  Future<bool> decline({String? reason, String? comment}) => _respond(
        status: 'declined',
        reason: reason,
        comment: comment,
      );

  Future<bool> _respond({
    required String status,
    String? reason,
    String? comment,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref.read(shootsRepositoryProvider).respondToProject(
            projectId: arg,
            status: status,
            reason: reason,
            comment: comment,
          );
      await refresh();
      state = state.copyWith(
        isSubmitting: false,
        respondedSignal: state.respondedSignal + 1,
      );
      return true;
    } catch (e, st) {
      AppLogger.e('Upcoming shoot respond failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong',
      );
      return false;
    }
  }
}

final upcomingShootDetailProvider = AutoDisposeNotifierProviderFamily<
    UpcomingShootDetailNotifier, UpcomingShootDetailState, int>(
  UpcomingShootDetailNotifier.new,
);
