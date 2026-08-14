import '../../domain/repositories/notification_settings_repository.dart';
import '../models/notification_settings_dto.dart';
import '../sources/notification_settings_remote_source.dart';

class NotificationSettingsRepositoryImpl implements NotificationSettingsRepository {
  NotificationSettingsRepositoryImpl(this._remoteSource);

  final NotificationSettingsRemoteSource _remoteSource;

  @override
  Future<Map<String, dynamic>> getNotificationSettingsFlags() async {
    return await _remoteSource.getNotificationSettingsFlags();
  }

  @override
  Future<Map<String, dynamic>> getPushNotificationsPreferences() async {
    return await _remoteSource.getPushNotificationsPreferences();
  }

  @override
  Future<void> updateNotificationPreferences(
    NotificationSettingsRequestDto dto,
  ) async {
    await _remoteSource.updateNotificationPreferences(dto.toJson());
  }

  @override
  Future<Map<String, dynamic>> getEmailNotificationsPreferences() async {
    return await _remoteSource.getEmailNotificationsPreferences();
  }

  @override
  Future<void> updateEmailNotificationPreferences(
    Map<String, dynamic> payload,
  ) async {
    await _remoteSource.updateEmailNotificationPreferences(payload);
  }
}
