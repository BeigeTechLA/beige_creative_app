import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/colors.dart';
import '../firebase/crashlytics_service.dart';
import 'notification_payload.dart';
import 'notification_tap_router.dart';

/// Background-isolate tap handler for local notifications shown while the app
/// is backgrounded or terminated.
///
/// Runs in a separate isolate with no UI, so it cannot navigate. It persists
/// the tapped payload so the main isolate can drain it on next launch/resume
/// (see `PushNotificationService._drainPersistedTap`). Belt-and-suspenders for
/// the `getNotificationAppLaunchDetails` capture, and the only path that
/// receives notification taps delivered to the background isolate.
@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PushNotificationService.pendingTapPrefsKey, payload);
  } catch (_) {
    // Best-effort — the foreground launch-details path is the primary capture.
  }
}

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
      
      const androidInitSettings = AndroidInitializationSettings('@drawable/ic_notification');
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(android: androidInitSettings, iOS: darwinInitSettings);
      
      await flutterLocalNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveBackgroundNotificationResponse:
            _onDidReceiveBackgroundNotificationResponse,
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
        priority: importance == Importance.max ? Priority.max : (importance == Importance.high ? Priority.high : Priority.defaultPriority),
        color: AppColors.primary,
        icon: '@drawable/ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(AndroidNotificationChannel(
          channelId,
          channelName,
          importance: importance,
        ));
      }
      
      const darwinDetails = DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(android: androidDetails, iOS: darwinDetails);

      await flutterLocalNotificationsPlugin.show(
        id: message.hashCode & 0x7FFFFFFF,
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

  /// SharedPreferences key under which the background isolate persists a tapped
  /// local-notification payload for the main isolate to drain on next launch.
  static const String pendingTapPrefsKey = 'pending_notification_tap_payload';

  /// Routes push taps once the authenticated router can accept them. Holds the
  /// tap across cold start / auth redirects and retries on readiness change so
  /// a terminated-state tap is never dropped. Mirrors `biegeapp`.
  final tapRouter = NotificationTapRouter(
    onError: (error, stack) {
      unawaited(CrashlyticsService.recordError(error, stack));
    },
  );

  /// Whether there is a pending notification payload waiting to be dispatched.
  bool get hasPendingNotification => tapRouter.pending != null;

  /// Current pending notification payload, if any.
  NotificationPayload? get pendingPayload => tapRouter.pending;

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

    // NOTE: the OS permission prompt is intentionally NOT requested here (cold
    // start, pre-login). It is requested from `pushTokenSyncProvider` once the
    // user is authenticated, so the ask lands in a context the user understands.
    // See requestPermissions().

    // Fetch initial FCM token & listen for refreshes
    _setupTokenManagement();

    // TERMINATED STATE capture. An FCM notification-type tap is delivered via
    // getInitialMessage(). A data-only push shows a LOCAL notification from the
    // background isolate, whose tap launches the app WITHOUT an FCM message —
    // getInitialMessage() returns null, so it must be recovered from the
    // local-notification launch details (and, belt-and-suspenders, from the
    // payload the background isolate persisted to prefs).
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('[PushNotificationService] App launched from terminated state via notification: ${initialMessage.data}');
      }
      tapRouter.enqueue(NotificationPayload.fromRemoteMessage(initialMessage));
    } else {
      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      final responsePayload = launchDetails?.notificationResponse?.payload;
      if ((launchDetails?.didNotificationLaunchApp ?? false) &&
          responsePayload != null &&
          responsePayload.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(responsePayload);
          tapRouter.enqueue(NotificationPayload.fromMap(data));
          if (kDebugMode) {
            print('[PushNotificationService] Captured terminated local notification launch.');
          }
        } catch (e) {
          if (kDebugMode) {
            print('[PushNotificationService] Failed to parse launch local notification payload: $e');
          }
        }
      }
    }

    // Drain any tap the background isolate persisted (data-only taps whose
    // launch details the OS did not surface). Only adopts it when the launch
    // capture above did not already set a pending payload, so a tap is never
    // routed twice.
    await _drainPersistedTap();

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
      alert: false,
      badge: false,
      sound: false,
    );

    if (kDebugMode) {
      print('[PushNotificationService] Permission authorization status: ${settings.authorizationStatus}');
    }

    return settings;
  }

  /// Setup flutter_local_notifications plugin and create dedicated Android channels.
  Future<void> _setupLocalNotifications() async {
    const androidInitSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
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
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
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
      case NotificationType.files:
      case NotificationType.profile:
      case NotificationType.deeplink:
      case NotificationType.unknown:
        return _generalChannel;
    }
  }

  Priority _getPriorityForImportance(Importance importance) {
    if (importance == Importance.max) {
      return Priority.max;
    }
    if (importance == Importance.high) {
      return Priority.high;
    }
    return Priority.defaultPriority;
  }

  Future<String?> fetchToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken = await _fcm.getAPNSToken();
      int attempts = 0;
      while (apnsToken == null && attempts < 5) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await _fcm.getAPNSToken();
        attempts++;
      }
      if (apnsToken == null) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] APNS token not set yet. Skipping FCM token fetch.');
        }
        return null;
      }
    }
    // register()/onRegistered emit the FID, not the legacy FCM token the
    // backend stores. Keep getToken() until the backend confirms FID/direct-send
    // support.
    // ignore: deprecated_member_use
    return await _fcm.getToken();
  }

  Future<String?> ensureToken() async {
    if (_fcmToken != null) return _fcmToken;
    final token = await fetchToken();
    if (token != null) _fcmToken = token;
    return token;
  }

  /// Clears cached token state on session end. When [deleteFromFirebase] is true
  /// (explicit logout) the device token is also invalidated with Firebase so the
  /// device identity rotates and the old token can never be reused. For a
  /// transient session expiry it is left intact (cheaper re-login, no churn).
  /// Always clears the in-memory token and remembered session id.
  Future<void> resetToken({required bool deleteFromFirebase}) async {
    if (deleteFromFirebase) {
      try {
        // ignore: deprecated_member_use
        await _fcm.deleteToken();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] Error deleting FCM token: $e');
        }
      }
    }
    _fcmToken = null;
    clearSession();
  }

  /// Fetch and listen for FCM Token updates.
  void _setupTokenManagement() {
    fetchToken().then((token) {
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

    // see fetchToken(); onRegistered emits the FID, not the FCM token. Keep
    // onTokenRefresh until the backend migrates.
    // ignore: deprecated_member_use
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
    final title = notification?.title ?? message.data['title'] ?? message.data['name'] ?? 'Notification';
    final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? message.data['content'] ?? message.data['text'] ?? '';

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: _getPriorityForImportance(channel.importance),
      color: AppColors.primary,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
      id: message.hashCode & 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Reads (and clears) any tapped payload the background isolate persisted via
  /// `_onDidReceiveBackgroundNotificationResponse`. Only adopts it when the FCM
  /// `getInitialMessage` / launch-details capture didn't already set a pending
  /// payload, so a single tap never routes twice.
  Future<void> _drainPersistedTap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final stored = prefs.getString(pendingTapPrefsKey);
      if (stored == null || stored.isEmpty) return;
      await prefs.remove(pendingTapPrefsKey);
      if (tapRouter.pending != null) return;
      final Map<String, dynamic> data = jsonDecode(stored);
      tapRouter.enqueue(NotificationPayload.fromMap(data));
      if (kDebugMode) {
        print('[PushNotificationService] Captured persisted background tap.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PushNotificationService] Failed to drain persisted background tap: $e');
      }
    }
  }

  /// Re-attempts a pending tap. Wired to app resume + auth/router readiness
  /// changes so a tap captured before the authenticated router was ready is
  /// routed as soon as it becomes ready.
  void processPendingNotification() => tapRouter.retry();

  /// Enqueues a tap into the readiness-gated router. All tap sources (FCM
  /// background open, local-notification tap, launch capture) funnel here.
  void handleNotificationClick(NotificationPayload payload) {
    tapRouter.enqueue(payload);
  }
}
