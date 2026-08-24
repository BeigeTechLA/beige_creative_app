
import '../../domain/repositories/notification_repository.dart';
import '../../domain/models/notification_item.dart';
import '../models/notification_dto.dart';
import '../sources/notification_remote_source.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteSource);

  final NotificationRemoteSource _remoteSource;

  @override
  Future<void> removeFcmToken({
    required String sessionId,
  }) async {
    await _remoteSource.removeFcmToken(
      sessionId: sessionId,
    );
  }

  @override
  Future<void> saveFcmToken({required String fcmToken, required String sessionId, String? deviceType}) async {
    await _remoteSource.saveFcmToken(
      fcmToken: fcmToken,
      sessionId: sessionId,
    );
  }

  @override
  Future<List<NotificationItem>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await _remoteSource.getNotifications(page: page, limit: limit);
    final dto = NotificationListResponseDto.fromJson(response);
    return dto.data;
  }
}
