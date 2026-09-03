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
      case 'new_message':
      case 'direct_message':
        type = NotificationType.chat;
        break;
      case 'booking':
      case 'shoot':
      case 'order':
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
        // Infer from data fields if type is missing or unknown
        if (data.containsKey('chat_id') || data.containsKey('chatId') || data.containsKey('room_id') || data.containsKey('conversationId') || data.containsKey('chat_room_id')) {
          type = NotificationType.chat;
        } else if (data.containsKey('booking_id') || data.containsKey('bookingId') || data.containsKey('shoot_id')) {
          type = NotificationType.booking;
        } else if (data.containsKey('meeting_id') || data.containsKey('meetingId')) {
          type = NotificationType.meeting;
        } else {
          type = NotificationType.unknown;
        }
    }

    return NotificationPayload(
      type: type,
      title: title ?? data['title']?.toString() ?? data['name']?.toString(),
      body: body ?? data['body']?.toString() ?? data['message']?.toString() ?? data['content']?.toString() ?? data['text']?.toString(),
      chatId: data['chatId']?.toString() ?? data['chat_id']?.toString() ?? data['room_id']?.toString() ?? data['chat_room_id']?.toString(),
      bookingId: data['bookingId']?.toString() ?? data['booking_id']?.toString() ?? data['shoot_id']?.toString() ?? data['order_id']?.toString(),
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
