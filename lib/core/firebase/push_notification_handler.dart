import 'package:flutter/widgets.dart';

import '../../app/navigator_key.dart';
import '../../app/routes.dart';
import '../utils/app_logger.dart';

/// Central router for incoming Push Notification payloads.
///
/// Implements routing based on topic and type as defined in Section 11:
/// - shoots (booking_confirmed) ➔ open booking details summary using booking_id
/// - messages (direct_message, messaging_initiated, mention) ➔ open chat room using chat_room_id or room_id
/// - meetings (meeting_*) ➔ open meeting details or booking details
/// - files (*files*) ➔ open file manager for booking_id
/// - default ➔ open Notification Center
class PushNotificationHandler {
  PushNotificationHandler._();

  static void handlePushTap(Map<String, dynamic> data) {
    AppLogger.i('🚀 [PUSH TAP RECEIVED]: Data payload = $data');

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      AppLogger.w('[PUSH TAP] Root navigator context is null; cannot route notification tap.');
      return;
    }

    final topic = data['topic']?.toString().toLowerCase() ??
        data['category']?.toString().toLowerCase() ??
        '';
    final type = data['type']?.toString().toLowerCase() ?? '';

    final bookingId = data['booking_id']?.toString() ?? data['project_id']?.toString();
    final roomId = data['chat_room_id']?.toString() ?? data['room_id']?.toString();
    final meetingId = data['meeting_id']?.toString();

    AppLogger.i('[PUSH ROUTER] Processing topic: "$topic", type: "$type"');

    try {
      switch (topic) {
        case 'shoots':
          if (bookingId != null && bookingId.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to shoot details for booking_id: $bookingId');
            Navigator.of(context).pushNamed(
              Routes.upcomingShootDetails.name,
              arguments: {'booking_id': bookingId},
            );
          } else {
            _navigateToNotifications(context);
          }
          break;

        case 'messages':
          if (roomId != null && roomId.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to chat room for room_id: $roomId');
            Navigator.of(context).pushNamed(
              Routes.chatDetails.name,
              arguments: {
                'chat_room_id': roomId,
                'booking_id': bookingId,
                'sender_id': data['sender_id']?.toString(),
              },
            );
          } else {
            _navigateToNotifications(context);
          }
          break;

        case 'meetings':
          if (meetingId != null && meetingId.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to meeting details for meeting_id: $meetingId');
            Navigator.of(context).pushNamed(
              Routes.meetings.name,
              arguments: {'meeting_id': meetingId, 'booking_id': bookingId},
            );
          } else if (bookingId != null && bookingId.isNotEmpty) {
            Navigator.of(context).pushNamed(
              Routes.upcomingShootDetails.name,
              arguments: {'booking_id': bookingId},
            );
          } else {
            _navigateToNotifications(context);
          }
          break;

        case 'files':
          if (bookingId != null && bookingId.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to file manager for booking_id: $bookingId');
            Navigator.of(context).pushNamed(
              Routes.files.name,
              arguments: {
                'booking_id': bookingId,
                'filepath': data['filepath']?.toString(),
              },
            );
          } else {
            _navigateToNotifications(context);
          }
          break;

        default:
          _navigateToNotifications(context);
          break;
      }
    } catch (e, st) {
      AppLogger.e('[PUSH ROUTER] Routing failed on notification tap: $e', e, st);
    }
  }

  static void _navigateToNotifications(BuildContext context) {
    AppLogger.i('[PUSH ROUTER] Fallback routing to Notifications Center');
    try {
      Navigator.of(context).pushNamed(Routes.notificationList.name);
    } catch (e) {
      AppLogger.w('[PUSH ROUTER] Fallback navigation failed: $e');
    }
  }
}
