import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../app/navigator_key.dart';
import '../../app/routes.dart';
import '../../features/messages/presentation/routes/messages_args.dart';
import '../../features/shoots/presentation/routes/shoots_args.dart';
import 'notification_payload.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Ignore initialization errors in background
  }
  
  if (kDebugMode) {
    print('[PushNotificationService] Background message received: ${message.messageId}');
  }

  // If the message has no notification payload, it's a data-only message.
  if (message.notification == null) {
    try {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      
      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(android: androidInitSettings, iOS: darwinInitSettings);
      
      await flutterLocalNotificationsPlugin.initialize(
        settings: initSettings,
      );

      final title = message.data['title'] ?? 'New Notification';
      final body = message.data['body'] ?? '';
      
      final payload = NotificationPayload.fromMap(message.data);
      
      String channelId = 'beige_general_channel';
      String channelName = 'General Updates';
      Importance importance = Importance.defaultImportance;
      
      switch (payload.type) {
        case NotificationType.chat:
          channelId = 'beige_chat_channel';
          channelName = 'Chat Messages';
          importance = Importance.max;
          break;
        case NotificationType.booking:
          channelId = 'beige_booking_channel';
          channelName = 'Booking Updates';
          importance = Importance.high;
          break;
        case NotificationType.meeting:
          channelId = 'beige_meeting_channel';
          channelName = 'Meeting Reminders';
          importance = Importance.high;
          break;
        default:
          break;
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: importance == Importance.max || importance == Importance.high ? Priority.high : Priority.defaultPriority,
        color: AppColors.primary,
        icon: '@mipmap/ic_launcher',
      );
      
      const darwinDetails = DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(android: androidDetails, iOS: darwinDetails);

      await flutterLocalNotificationsPlugin.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[PushNotificationService] Error showing background local notification: $e');
      }
    }
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // ── Dedicated Android Notification Channels ──────────────────────────────
  static const AndroidNotificationChannel _chatChannel = AndroidNotificationChannel(
    'beige_chat_channel',
    'Chat Messages',
    description: 'Instant messages and chat activity alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _bookingChannel = AndroidNotificationChannel(
    'beige_booking_channel',
    'Booking Updates',
    description: 'Updates regarding your shoot bookings and status',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _meetingChannel = AndroidNotificationChannel(
    'beige_meeting_channel',
    'Meeting Reminders',
    description: 'Reminders and notifications for scheduled meetings',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _generalChannel = AndroidNotificationChannel(
    'beige_general_channel',
    'General Updates',
    description: 'General announcements and app notifications',
    importance: Importance.defaultImportance,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Invoked with the current FCM token on initial fetch and on every refresh.
  /// Wired by `pushTokenSyncProvider` while authenticated so the token reaches
  /// the backend; left null while logged out.
  Future<void> Function(String token)? onTokenRefreshed;

  /// Last session id a token was registered under. Kept in memory so logout can
  /// deregister the token even after `SharedService.logout` clears prefs.
  String? _lastSessionId;
  String? get lastSessionId => _lastSessionId;
  void rememberSession(String sessionId) => _lastSessionId = sessionId;
  void clearSession() => _lastSessionId = null;

  NotificationPayload? _pendingPayload;
  bool _isInitialized = false;

  /// Initializes FCM listeners, multi-channel setup, permission prompts,
  /// and notification tap callbacks on app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup multi-channel local notifications for Android & iOS
    await _setupLocalNotifications();

    // Fetch initial FCM token & listen for refreshes
    // Permissions will be requested explicitly after login
    _setupTokenManagement();

    // Handle initial notification tap if launched from terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('[PushNotificationService] App launched from terminated state via notification: ${initialMessage.data}');
      }
      _pendingPayload = NotificationPayload.fromRemoteMessage(initialMessage);
    }

    // Handle background notification taps when app is resumed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[PushNotificationService] Notification opened from background: ${message.data}');
      }
      final payload = NotificationPayload.fromRemoteMessage(message);
      handleNotificationClick(payload);
    });

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[PushNotificationService] Foreground notification received: ${message.notification?.title}');
      }
      _showForegroundNotification(message);
    });
  }

  /// Best Practice Push Notification Permission Request for iOS & Android (13+).
  Future<NotificationSettings> requestPermissions() async {
    // 1. Request iOS & FCM system permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
    );

    // 2. Request Android 13+ (API 33+) POST_NOTIFICATIONS runtime permission
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // 3. Configure iOS foreground notification presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('[PushNotificationService] Permission authorization status: ${settings.authorizationStatus}');
    }

    return settings;
  }

  /// Setup flutter_local_notifications plugin and create dedicated Android channels.
  Future<void> _setupLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            final payload = NotificationPayload.fromMap(data);
            handleNotificationClick(payload);
          } catch (e) {
            if (kDebugMode) {
              print('[PushNotificationService] Error parsing local notification payload: $e');
            }
          }
        }
      },
    );

    // Create all 4 dedicated Android Notification Channels
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_chatChannel);
      await androidImplementation.createNotificationChannel(_bookingChannel);
      await androidImplementation.createNotificationChannel(_meetingChannel);
      await androidImplementation.createNotificationChannel(_generalChannel);
    }
  }

  /// Map payload type to the appropriate Android notification channel.
  AndroidNotificationChannel _getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.chat:
        return _chatChannel;
      case NotificationType.booking:
        return _bookingChannel;
      case NotificationType.meeting:
        return _meetingChannel;
      case NotificationType.profile:
      case NotificationType.deeplink:
      case NotificationType.unknown:
        return _generalChannel;
    }
  }

  Priority _getPriorityForImportance(Importance importance) {
    if (importance == Importance.max || importance == Importance.high) {
      return Priority.high;
    }
    return Priority.defaultPriority;
  }

  /// Fetch and listen for FCM Token updates.
  void _setupTokenManagement() {
    _fcm.getToken().then((token) {
      _fcmToken = token;
      if (kDebugMode) {
        debugPrint('[PushNotificationService] FCM Token: $_fcmToken');
      }
      if (token != null && token.isNotEmpty) {
        onTokenRefreshed?.call(token);
      }
    }).catchError((err) {
      if (kDebugMode) {
        debugPrint('[PushNotificationService] Error fetching FCM token: $err');
      }
    });

    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        debugPrint('[PushNotificationService] FCM Token refreshed: $_fcmToken');
      }
      if (newToken.isNotEmpty) {
        onTokenRefreshed?.call(newToken);
      }
    });
  }

  /// Displays local notification banner using the channel corresponding to message type.
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(message);
    final channel = _getChannelForType(payload.type);

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Notification';
    final body = notification?.body ?? message.data['body'] ?? '';

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: _getPriorityForImportance(channel.importance),
      color: AppColors.primary,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Processes any pending notification payload captured during app startup.
  void processPendingNotification(BuildContext context) {
    if (_pendingPayload != null) {
      final payload = _pendingPayload!;
      _pendingPayload = null;
      _executeRouting(context, payload);
    }
  }

  /// Main handler to execute redirection based on notification payload type.
  void handleNotificationClick(NotificationPayload payload) {
    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      if (kDebugMode) {
        print('[PushNotificationService] Context not ready yet, queuing notification tap.');
      }
      _pendingPayload = payload;
      return;
    }
    
    try {
      final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      if (currentPath == Routes.splash.path) {
        _pendingPayload = payload;
        return;
      }
    } catch (_) {
      _pendingPayload = payload;
      return;
    }

    _executeRouting(context, payload);
  }

  void _executeRouting(BuildContext context, NotificationPayload payload) {
    if (kDebugMode) {
      print('[PushNotificationService] Redirecting for notification type: ${payload.type}');
    }

    final router = GoRouter.of(context);

    switch (payload.type) {
      case NotificationType.chat:
        if (payload.chatId != null && payload.chatId!.isNotEmpty) {
          router.pushNamed(
            Routes.chat.name,
            extra: ChatArgs(conversationId: payload.chatId!).toExtra(),
          );
        } else {
          router.goNamed(Routes.messages.name);
        }
        break;

      case NotificationType.booking:
        if (payload.bookingId != null && payload.bookingId!.isNotEmpty) {
          router.pushNamed(
            Routes.upcomingShootDetails.name,
            extra: UpcomingShootDetailsArgs(projectId: int.tryParse(payload.bookingId!)).toExtra(),
          );
        } else {
          router.goNamed(Routes.shoots.name);
        }
        break;

      case NotificationType.meeting:
        if (payload.meetingId != null && payload.meetingId!.isNotEmpty) {
          router.goNamed(
            Routes.meetings.name,
            queryParameters: {'meetingId': payload.meetingId!},
          );
        } else {
          router.goNamed(Routes.meetings.name);
        }
        break;

      case NotificationType.profile:
        router.goNamed(Routes.myProfile.name);
        break;

      case NotificationType.deeplink:
        if (payload.targetRoute != null && payload.targetRoute!.isNotEmpty) {
          router.push(payload.targetRoute!);
        } else {
          router.goNamed(Routes.home.name);
        }
        break;

      case NotificationType.unknown:
        if (payload.targetRoute != null && payload.targetRoute!.isNotEmpty) {
          router.push(payload.targetRoute!);
        } else {
          router.goNamed(Routes.home.name);
        }
        break;
    }
  }
}
