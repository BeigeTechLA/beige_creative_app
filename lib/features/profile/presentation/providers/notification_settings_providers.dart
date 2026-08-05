import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/fcm_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../notification/data/models/notification_settings_dto.dart';
import '../../../notification/presentation/providers/notification_list_providers.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.smartDelivery = true,
    this.categoryShoots = true,
    this.categoryPayouts = true,
    this.categoryMessages = true,
    this.categoryMeetings = true,
    this.categoryProposals = true,
    this.categoryFiles = true,
    this.categorySystem = true,
    this.isSaving = false,
  });

  final bool pushNotifications;
  final bool emailNotifications;
  final bool smartDelivery;

  final bool categoryShoots;
  final bool categoryPayouts;
  final bool categoryMessages;
  final bool categoryMeetings;
  final bool categoryProposals;
  final bool categoryFiles;
  final bool categorySystem;

  final bool isSaving;

  NotificationSettingsState copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smartDelivery,
    bool? categoryShoots,
    bool? categoryPayouts,
    bool? categoryMessages,
    bool? categoryMeetings,
    bool? categoryProposals,
    bool? categoryFiles,
    bool? categorySystem,
    bool? isSaving,
  }) {
    return NotificationSettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smartDelivery: smartDelivery ?? this.smartDelivery,
      categoryShoots: categoryShoots ?? this.categoryShoots,
      categoryPayouts: categoryPayouts ?? this.categoryPayouts,
      categoryMessages: categoryMessages ?? this.categoryMessages,
      categoryMeetings: categoryMeetings ?? this.categoryMeetings,
      categoryProposals: categoryProposals ?? this.categoryProposals,
      categoryFiles: categoryFiles ?? this.categoryFiles,
      categorySystem: categorySystem ?? this.categorySystem,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class NotificationSettingsNotifier
    extends AutoDisposeNotifier<NotificationSettingsState> {
  @override
  NotificationSettingsState build() {
    return const NotificationSettingsState();
  }

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
    savePreferences();
  }

  void toggleEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
  }

  void toggleSmartDelivery(bool value) {
    state = state.copyWith(smartDelivery: value);
  }

  void toggleCategoryShoots(bool value) {
    state = state.copyWith(categoryShoots: value);
  }

  void toggleCategoryPayouts(bool value) {
    state = state.copyWith(categoryPayouts: value);
  }

  void toggleCategoryMessages(bool value) {
    state = state.copyWith(categoryMessages: value);
  }

  void toggleCategoryMeetings(bool value) {
    state = state.copyWith(categoryMeetings: value);
  }

  void toggleCategoryProposals(bool value) {
    state = state.copyWith(categoryProposals: value);
  }

  void toggleCategoryFiles(bool value) {
    state = state.copyWith(categoryFiles: value);
  }

  void toggleCategorySystem(bool value) {
    state = state.copyWith(categorySystem: value);
  }

  Future<void> savePreferences() async {
    state = state.copyWith(isSaving: true);
    try {
      // Ensure FCM Token session is registered on backend first
      await ref.read(fcmServiceProvider).ensureFcmTokenRegistered();

      final session = ref.read(sessionStoreProvider);
      final token = await session.readToken();
      final repo = ref.read(notificationRepositoryProvider);
      final dto = NotificationSettingsRequestDto(
        sessionId: token ?? '',
        notificationPreferences: NotificationPreferencesDto(
          pushEnabled: state.pushNotifications,
          topics: NotificationTopicsDto(
            shoots: state.categoryShoots,
            payments: state.categoryPayouts,
            messages: state.categoryMessages,
            meetings: state.categoryMeetings,
            proposals: state.categoryProposals,
            files: state.categoryFiles,
            system: state.categorySystem,
          ),
        ),
      );
      await repo.updateNotificationPreferences(dto);
      AppLogger.i('Notification preferences successfully updated on backend');
    } catch (e, st) {
      AppLogger.e('Failed to update notification preferences on backend', e, st);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final notificationSettingsProvider = AutoDisposeNotifierProvider<
    NotificationSettingsNotifier, NotificationSettingsState>(
  NotificationSettingsNotifier.new,
);
