import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/notification_settings_dto.dart';
import '../../data/repositories/notification_settings_repository_impl.dart';
import '../../data/sources/notification_settings_remote_source.dart';
import '../../domain/repositories/notification_settings_repository.dart';

// --- Dependency Injection Providers ---

final notificationSettingsRemoteSourceProvider = Provider<NotificationSettingsRemoteSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final sessionStore = ref.read(sessionStoreProvider);
  return NotificationSettingsRemoteSource(dioClient, sessionStore);
});

final notificationSettingsRepositoryProvider = Provider<NotificationSettingsRepository>((ref) {
  final remoteSource = ref.watch(notificationSettingsRemoteSourceProvider);
  return NotificationSettingsRepositoryImpl(remoteSource);
});

// --- State & Notifier ---

@immutable
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
    );
  }

  /// IMPORTANT: When you uncomment a category in the UI (e.g. categoryPayouts),
  /// you must ALSO uncomment it here so the main Push/Email Notification 
  /// switch automatically toggles ON/OFF based on active categories!
  bool get isAnyActiveCategoryEnabled {
    return categoryShoots ||
        // categoryPayouts ||
        categoryMessages ||
        categoryMeetings ||
        // categoryProposals ||
        // categoryFiles ||
        // categorySystem ||
        false;
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettingsState> {
  @override
  NotificationSettingsState build() {
    return const NotificationSettingsState();
  }

  Future<void> loadSettings() async {
    try {
      final repo = ref.read(notificationSettingsRepositoryProvider);
      final data = await repo.getNotificationSettingsFlags();
      if (data.isNotEmpty) {
        state = state.copyWith(
          pushNotifications: data['push_enabled'] as bool? ?? state.pushNotifications,
          emailNotifications: data['email_enabled'] as bool? ?? state.emailNotifications,
        );
      }
    } catch (e, st) {
      AppLogger.e('NotificationSettingsNotifier.loadSettings failed', e, st);
    }
  }

  Future<void> loadPushPreferences() async {
    try {
      final repo = ref.read(notificationSettingsRepositoryProvider);
      final data = await repo.getPushNotificationsPreferences();
      if (data.isNotEmpty) {
        final prefs = data['notification_preferences'] as Map<String, dynamic>? ?? data;
        final topics = prefs['topics'] as Map<String, dynamic>?;

        if (topics != null) {
          state = state.copyWith(
            pushNotifications: prefs['push_enabled'] as bool? ?? state.pushNotifications,
            categoryShoots: topics['shoots'] as bool? ?? state.categoryShoots,
            categoryPayouts: topics['payments'] as bool? ?? state.categoryPayouts,
            categoryMessages: topics['messages'] as bool? ?? state.categoryMessages,
            categoryMeetings: topics['meetings'] as bool? ?? state.categoryMeetings,
            categoryProposals: topics['proposals'] as bool? ?? state.categoryProposals,
            categoryFiles: topics['files'] as bool? ?? state.categoryFiles,
            categorySystem: topics['system'] as bool? ?? state.categorySystem,
          );
        }
      }
    } catch (e, st) {
      AppLogger.e('NotificationSettingsNotifier.loadPushPreferences failed', e, st);
    }
  }

  Future<void> savePushPreferences() async {
    try {
      final repo = ref.read(notificationSettingsRepositoryProvider);
      
      final allFalse = !state.isAnyActiveCategoryEnabled;

      if (allFalse && state.pushNotifications) {
        state = state.copyWith(pushNotifications: false);
      } else if (!allFalse && !state.pushNotifications) {
        state = state.copyWith(pushNotifications: true);
      }

      final sessionStore = ref.read(sessionStoreProvider);
      final sessionId = await sessionStore.getAppSessionId();

      final dto = NotificationSettingsRequestDto(
        sessionId: sessionId,
        notificationPreferences: NotificationPreferencesDto(
          pushEnabled: state.pushNotifications,
          topics: NotificationTopicsDto(
            shoots: state.categoryShoots,
            // payments: state.categoryPayouts,
            messages: state.categoryMessages,
            meetings: state.categoryMeetings,
            // proposals: state.categoryProposals,
            files: state.categoryFiles,
            // system: state.categorySystem,
          ),
        ),
      );

      await repo.updateNotificationPreferences(dto);
    } catch (e, st) {
      AppLogger.e('NotificationSettingsNotifier.savePushPreferences failed', e, st);
    }
  }

  Future<void> loadEmailPreferences() async {
    try {
      final repo = ref.read(notificationSettingsRepositoryProvider);
      final data = await repo.getEmailNotificationsPreferences();
      if (data.isNotEmpty && data['email_topics'] != null) {
        final topics = data['email_topics'];
        state = state.copyWith(
          emailNotifications: data['email_enabled'] as bool? ?? state.emailNotifications,
          categoryShoots: topics['shoots'] as bool? ?? state.categoryShoots,
          categoryPayouts: topics['payments'] as bool? ?? state.categoryPayouts,
          categoryMessages: topics['messages'] as bool? ?? state.categoryMessages,
          categoryMeetings: topics['meetings'] as bool? ?? state.categoryMeetings,
          categoryProposals: topics['proposals'] as bool? ?? state.categoryProposals,
          categoryFiles: topics['files'] as bool? ?? state.categoryFiles,
          categorySystem: topics['system'] as bool? ?? state.categorySystem,
        );
      }
    } catch (e, st) {
      AppLogger.e('NotificationSettingsNotifier.loadEmailPreferences failed', e, st);
    }
  }

  Future<void> saveEmailPreferences() async {
    try {
      final repo = ref.read(notificationSettingsRepositoryProvider);
      
      final allFalse = !state.isAnyActiveCategoryEnabled;

      if (allFalse && state.emailNotifications) {
        state = state.copyWith(emailNotifications: false);
      } else if (!allFalse && !state.emailNotifications) {
        state = state.copyWith(emailNotifications: true);
      }
      
      final payload = {
        "email_enabled": state.emailNotifications,
        "email_topics": {
          "shoots": state.categoryShoots,
          // "payments": state.categoryPayouts,
          "messages": state.categoryMessages,
          "meetings": state.categoryMeetings,
          // "proposals": state.categoryProposals,
          "files": state.categoryFiles,
          // "system": state.categorySystem,
        }
      };

      await repo.updateEmailNotificationPreferences(payload);
    } catch (e, st) {
      AppLogger.e('NotificationSettingsNotifier.saveEmailPreferences failed', e, st);
    }
  }

  void updateState(NotificationSettingsState newState) {
    state = newState;
  }

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
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
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  NotificationSettingsNotifier.new,
);
