import 'package:firebase_messaging/firebase_messaging.dart';

enum NotificationType {
  chat,
  booking,
  meeting,
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
  final String? targetRoute;
  final Map<String, dynamic> rawMap;

  const NotificationPayload({
    required this.type,
    this.title,
    this.body,
    this.chatId,
    this.bookingId,
    this.meetingId,
    this.targetRoute,
    required this.rawMap,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> data, {String? title, String? body}) {
    final typeString = (data['type'] ?? data['notification_type'] ?? '').toString().toLowerCase();

    NotificationType type;
    switch (typeString) {
      case 'chat':
      case 'message':
        type = NotificationType.chat;
        break;
      case 'booking':
      case 'shoot':
        type = NotificationType.booking;
        break;
      case 'meeting':
        type = NotificationType.meeting;
        break;
      case 'profile':
      case 'account':
        type = NotificationType.profile;
        break;
      case 'deeplink':
      case 'route':
        type = NotificationType.deeplink;
        break;
      default:
        type = NotificationType.unknown;
    }

    return NotificationPayload(
      type: type,
      title: title ?? data['title']?.toString(),
      body: body ?? data['body']?.toString(),
      chatId: data['chatId']?.toString() ?? data['chat_id']?.toString(),
      bookingId: data['bookingId']?.toString() ?? data['booking_id']?.toString(),
      meetingId: data['meetingId']?.toString() ?? data['meeting_id']?.toString(),
      targetRoute: data['targetRoute']?.toString() ?? data['route']?.toString(),
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
