import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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
class NotificationPayloadInfo {
  final String topic;
  final String type;
  final String resolvedTopic;
  final String? roomId;
  final String? bookingId;
  final String? meetingId;
  
  bool get isEmpty => topic.isEmpty && type.isEmpty && bookingId == null && roomId == null && meetingId == null;

  NotificationPayloadInfo({
    required this.topic,
    required this.type,
    required this.resolvedTopic,
    this.roomId,
    this.bookingId,
    this.meetingId,
  });
}

class PushNotificationHandler {
  PushNotificationHandler._();

  static String? _lastProcessedMessageId;

  static NotificationPayloadInfo parsePayload(Map<String, dynamic> data) {
    final topic = data['topic']?.toString().toLowerCase() ??
        data['category']?.toString().toLowerCase() ??
        '';
    final type = data['type']?.toString().toLowerCase() ?? '';

    final bookingId = data['booking_id']?.toString() ?? 
                      data['project_id']?.toString() ??
                      data['bookingId']?.toString() ??
                      data['projectId']?.toString();
                      
    final roomId = data['chat_room_id']?.toString() ?? 
                   data['room_id']?.toString() ??
                   data['conversation_id']?.toString() ??
                   data['conversationId']?.toString() ??
                   data['id']?.toString();
                   
    final meetingId = data['meeting_id']?.toString() ??
                      data['meetingId']?.toString();

    // Normalize topic to match our switch cases
    String resolvedTopic = 'default';
    if (topic.contains('message') || type.contains('message') || 
        topic.contains('chat') || type.contains('chat') || 
        data.containsKey('chat_room_id') || data.containsKey('room_id') || data.containsKey('conversation_id')) {
      resolvedTopic = 'messages';
    } else if (topic.contains('meeting') || type.contains('meeting') || data.containsKey('meeting_id')) {
      resolvedTopic = 'meetings';
    } else if (topic.contains('shoot') || topic.contains('booking') || 
               type.contains('shoot') || type.contains('booking') || data.containsKey('booking_id') || data.containsKey('project_id')) {
      resolvedTopic = 'shoots';
    } else if (topic.contains('file') || type.contains('file')) {
      resolvedTopic = 'files';
    }
    
    // If we still don't know the topic, use the type or topic directly if it matches something
    if (resolvedTopic == 'default') {
      if (roomId != null) resolvedTopic = 'messages';
      else if (bookingId != null) resolvedTopic = 'shoots';
      else if (meetingId != null) resolvedTopic = 'meetings';
    }

    return NotificationPayloadInfo(
      topic: topic,
      type: type,
      resolvedTopic: resolvedTopic,
      roomId: roomId,
      bookingId: bookingId,
      meetingId: meetingId,
    );
  }

  static void handlePushTap(Map<String, dynamic> data, {String? messageId}) async {
    AppLogger.i('🚀 [PUSH TAP RECEIVED]: Data payload = $data, MessageID = $messageId');

    // Prevent duplicate navigation
    if (messageId != null && messageId.isNotEmpty) {
      if (_lastProcessedMessageId == messageId) {
        AppLogger.i('[PUSH TAP] Duplicate tap detected for messageId: $messageId. Ignoring.');
        return;
      }
      _lastProcessedMessageId = messageId;
    }

    final info = parsePayload(data);

    // Early exit if missing critical routing data for specific topics
    if (info.isEmpty) {
      AppLogger.w('[PUSH TAP] Insufficient data payload to route. Ignoring tap.');
      return;
    }

    AppLogger.i('[PUSH ROUTER] Processing resolved topic: "${info.resolvedTopic}", type: "${info.type}", roomId: "${info.roomId}", bookingId: "${info.bookingId}"');

    // Retry loop to wait for context readiness during cold-start
    BuildContext? context = rootNavigatorKey.currentContext;
    int retries = 0;
    while (context == null && retries < 15) {
      AppLogger.w('[PUSH TAP] Context not ready, waiting 100ms (retry $retries/15)...');
      await Future.delayed(const Duration(milliseconds: 100));
      context = rootNavigatorKey.currentContext;
      retries++;
    }

    if (context == null) {
      AppLogger.w('[PUSH TAP] Root navigator context is still null after retries; cannot route notification tap.');
      return;
    }

    // Wait for the splash screen to finish its hard redirect on cold start
    int splashRetries = 0;
    while (splashRetries < 50) { // wait up to 5 seconds
      try {
        final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
        if (currentPath != Routes.splash.path) {
          break; // We are no longer on the splash screen, safe to push!
        }
      } catch (_) {
        // Fallback if currentConfiguration throws during router initialization
      }
      await Future.delayed(const Duration(milliseconds: 100));
      splashRetries++;
    }

    try {
      switch (info.resolvedTopic) {
        case 'shoots':
          if (info.bookingId != null && info.bookingId!.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to shoot details for booking_id: ${info.bookingId}');
            GoRouter.of(context).pushNamed(
              Routes.upcomingShootDetails.name,
              extra: {'projectId': int.tryParse(info.bookingId!)},
            );
          } else {
            AppLogger.i('[PUSH ROUTER] Fallback to shoots list (missing bookingId)');
            GoRouter.of(context).goNamed(Routes.shoots.name);
          }
          break;

        case 'messages':
          if (info.roomId != null && info.roomId!.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to chat room for room_id: ${info.roomId}, booking_id: ${info.bookingId}');
            GoRouter.of(context).pushNamed(
              Routes.chat.name,
              extra: {
                'conversationId': info.roomId,
                if (info.bookingId != null && info.bookingId!.isNotEmpty) 'bookingId': info.bookingId,
              },
            );
          } else {
            AppLogger.i('[PUSH ROUTER] Fallback to messages list (missing roomId)');
            GoRouter.of(context).goNamed(Routes.messages.name);
          }
          break;

        case 'meetings':
          if (info.meetingId != null && info.meetingId!.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to meeting details for meeting_id: ${info.meetingId}');
            GoRouter.of(context).pushNamed(
              Routes.meetings.name,
              extra: {'meeting_id': info.meetingId, 'booking_id': info.bookingId},
            );
          } else if (info.bookingId != null && info.bookingId!.isNotEmpty) {
            GoRouter.of(context).pushNamed(
              Routes.upcomingShootDetails.name,
              extra: {'projectId': int.tryParse(info.bookingId!)},
            );
          } else {
            AppLogger.i('[PUSH ROUTER] Fallback to meetings list (missing meetingId)');
            GoRouter.of(context).goNamed(Routes.meetings.name);
          }
          break;

        case 'files':
          if (info.bookingId != null && info.bookingId!.isNotEmpty) {
            AppLogger.i('[PUSH ROUTER] Navigating to file manager for booking_id: ${info.bookingId}');
            GoRouter.of(context).pushNamed(
              Routes.files.name,
              extra: {
                'booking_id': info.bookingId,
                'filepath': data['filepath']?.toString(),
              },
            );
          } else {
            AppLogger.i('[PUSH ROUTER] Fallback to files list (missing bookingId)');
            GoRouter.of(context).goNamed(Routes.files.name);
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
      GoRouter.of(context).pushNamed(Routes.notificationList.name);
    } catch (e) {
      AppLogger.w('[PUSH ROUTER] Fallback navigation failed: $e');
    }
  }
}
