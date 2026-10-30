import 'package:firebase_messaging/firebase_messaging.dart';

enum NotificationType {
  chat,
  booking,
  meeting,
  files,
  profile,
  deeplink,
  unknown,
}

class NotificationPayload {
  final NotificationType type;
  final String? title;
  final String? body;
  final String? chatId;
  final String? bookingId;
  final String? meetingId;
  final String? folderId;
  final String? filePath;
  final String? targetRoute;
  final Map<String, dynamic> rawMap;

  const NotificationPayload({
    required this.type,
    this.title,
    this.body,
    this.chatId,
    this.bookingId,
    this.meetingId,
    this.folderId,
    this.filePath,
    this.targetRoute,
    required this.rawMap,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> data, {String? title, String? body}) {
    final payloadMap = data['payload'] is Map<String, dynamic>
        ? data['payload'] as Map<String, dynamic>
        : (data['payload'] is Map ? Map<String, dynamic>.from(data['payload'] as Map) : null);

    Object? resolveKey(List<String> keys) {
      for (final k in keys) {
        if (data[k] != null && data[k].toString().isNotEmpty) return data[k];
      }
      if (payloadMap != null) {
        for (final k in keys) {
          if (payloadMap[k] != null && payloadMap[k].toString().isNotEmpty) return payloadMap[k];
        }
      }
      return null;
    }

    final topic = (resolveKey(['topic', 'category']) ?? '').toString().toLowerCase().trim();
    final typeString = (resolveKey(['type', 'notification_type', 'event']) ?? '').toString().toLowerCase().trim();

    NotificationType type;

    // 1. Check Topic match first
    if (topic == 'shoots' || topic == 'shoot' || topic == 'booking' || topic == 'bookings') {
      type = NotificationType.booking;
    } else if (topic == 'messages' || topic == 'message' || topic == 'chat') {
      type = NotificationType.chat;
    } else if (topic == 'meetings' || topic == 'meeting') {
      type = NotificationType.meeting;
    } else if (topic == 'files' || topic == 'file') {
      type = NotificationType.files;
    } else if (topic == 'profile' || topic == 'account') {
      type = NotificationType.profile;
    }
    // 2. Check Event / Type match
    else if (typeString.startsWith('booking') ||
        typeString.startsWith('shoot') ||
        typeString == 'order' ||
        typeString.contains('shoot') ||
        typeString.contains('reschedule')) {
      type = NotificationType.booking;
    } else if (typeString.contains('message') || typeString.contains('chat') || typeString == 'mention') {
      type = NotificationType.chat;
    } else if (typeString.contains('meeting')) {
      type = NotificationType.meeting;
    } else if (typeString.contains('file') || typeString.contains('revision') || typeString.contains('version')) {
      type = NotificationType.files;
    } else if (typeString.contains('profile') || typeString.contains('account')) {
      type = NotificationType.profile;
    } else if (typeString == 'deeplink' || typeString == 'route') {
      type = NotificationType.deeplink;
    }
    // 3. Fallback to key heuristics
    else if (resolveKey(['chat_room_id', 'chatRoomId', 'room_id', 'roomId', 'chat_id', 'chatId', 'conversation_id', 'conversationId']) != null) {
      type = NotificationType.chat;
    } else if (resolveKey(['file_id', 'fileId', 'folder_id', 'folderId', 'filepath', 'filePath']) != null) {
      type = NotificationType.files;
    } else if (resolveKey(['meeting_id', 'meetingId']) != null) {
      type = NotificationType.meeting;
    } else if (resolveKey(['booking_id', 'bookingId', 'shoot_id', 'order_id']) != null) {
      type = NotificationType.booking;
    } else if (resolveKey(['targetRoute', 'route', 'path']) != null) {
      type = NotificationType.deeplink;
    } else {
      type = NotificationType.unknown;
    }

    final chatId = resolveKey([
      'chat_room_id',
      'chatRoomId',
      'room_id',
      'roomId',
      'chat_id',
      'chatId',
      'conversation_id',
      'conversationId',
      if (type == NotificationType.chat) 'id',
    ])?.toString();

    final bookingId = resolveKey([
      'booking_id',
      'bookingId',
      'shoot_id',
      'order_id',
      'project_id',
      'projectId',
      if (type == NotificationType.booking) 'id',
    ])?.toString();

    final meetingId = resolveKey([
      'meeting_id',
      'meetingId',
      if (type == NotificationType.meeting) 'id',
    ])?.toString();

    final folderId = resolveKey([
      'folder_id',
      'folderId',
      'booking_id',
      'bookingId',
      'project_id',
      'projectId',
    ])?.toString();

    final filePath = resolveKey([
      'filepath',
      'filePath',
      'file_path',
      'fileUrl',
      'file_url',
    ])?.toString();

    final targetRoute = resolveKey([
      'targetRoute',
      'route',
      'path',
    ])?.toString();

    final resolvedTitle = title ??
        resolveKey(['title', 'name', 'subject'])?.toString();

    final resolvedBody = body ??
        resolveKey(['body', 'message', 'content', 'text'])?.toString();

    return NotificationPayload(
      type: type,
      title: resolvedTitle,
      body: resolvedBody,
      chatId: chatId,
      bookingId: bookingId,
      meetingId: meetingId,
      folderId: folderId,
      filePath: filePath,
      targetRoute: targetRoute,
      rawMap: Map<String, dynamic>.from(data),
    );
  }

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload.fromMap(
      message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }
}
