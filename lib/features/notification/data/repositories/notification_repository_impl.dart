import '../models/notification_settings_dto.dart';
import '../../domain/repositories/notification_repository.dart';
import '../sources/notification_remote_source.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteSource);

  final NotificationRemoteSource _remoteSource;

  @override
  Future<void> saveFcmToken({
    required String fcmToken,
    required String sessionId,
    String? deviceType,
  }) async {
    await _remoteSource.saveFcmToken(
      fcmToken: fcmToken,
      sessionId: sessionId,
      deviceType: deviceType,
    );
  }

  @override
  Future<void> removeFcmToken({
    required String sessionId,
  }) async {
    await _remoteSource.removeFcmToken(
      sessionId: sessionId,
    );
  }

  @override
  Future<void> updateNotificationPreferences(
    NotificationSettingsRequestDto dto,
  ) async {
    await _remoteSource.updateNotificationPreferences(dto.toJson());
  }
}
