import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'push_notification_handler.dart';

import '../../features/notification/presentation/providers/notification_list_providers.dart';
import '../providers/auth_state_provider.dart';
import '../providers/core_providers.dart';
import '../utils/app_logger.dart';
import 'firebase_service.dart';

/// Service responsible for FCM Token registration & lifecycle management.
class FcmService {
  FcmService(this._ref) {
    _initListeners();
  }

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSub;
  String? _lastRegisteredToken;


  int _notificationIdCounter = 0;
  int _nextNotificationId() =>
      (_notificationIdCounter = (_notificationIdCounter + 1) % 100000);

  void _initListeners() {
    if (!FirebaseService.isInitialized) return;

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );


    _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            PushNotificationHandler.handlePushTap(data);
          } catch (e) {
            AppLogger.e('Failed to parse notification payload: $e');
          }
        }
      },
    );

    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
          (newToken) async {
        AppLogger.i('FcmService: FCM Token refreshed.');
        await _registerToken(newToken);
      },
      onError: (Object err) {
        AppLogger.e('FcmService: Error in onTokenRefresh stream: $err');
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i('FcmService: 🚨 RECEIVED FOREGROUND MESSAGE 🚨');
      AppLogger.i('Message data: ${message.data}');
      if (message.notification != null) {
        AppLogger.i('Message notification title: ${message.notification?.title}');
        AppLogger.i('Message notification body: ${message.notification?.body}');

        final notification = message.notification!;
        final info = PushNotificationHandler.parsePayload(message.data);
        
        // 1. Generate Group Key dynamically
        String groupKey = info.resolvedTopic;
        if (info.resolvedTopic == 'messages' && info.roomId != null) {
          groupKey = 'messages_${info.roomId}';
        } else if (info.resolvedTopic == 'shoots' && info.bookingId != null) {
          groupKey = 'shoots_${info.bookingId}';
        } else if (info.resolvedTopic == 'meetings' && info.meetingId != null) {
          groupKey = 'meetings_${info.meetingId}';
        }
        
        final int summaryId = groupKey.hashCode;

        // 2. Setup Notification Details (Badges & Sounds Enabled)
        final androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          channelShowBadge: true, // Enabled badge count
          groupKey: groupKey,     // Grouping key
        );
        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,     // Enabled badge count
          presentSound: true,
        );
        final platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        // 3. Show the actual individual notification
        _localNotificationsPlugin.show(
          id: _nextNotificationId(),
          title: notification.title,
          body: notification.body,
          notificationDetails: platformDetails,
          payload: jsonEncode(message.data),
        );
        
        // 4. Show the Group Summary notification (Required by Android to stack them)
        final summaryAndroidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          channelShowBadge: true,
          groupKey: groupKey,
          setAsGroupSummary: true, // Mark as group summary
        );
        
        String summaryTitle = 'New Notifications';
        if (info.resolvedTopic == 'messages') summaryTitle = 'New Messages';
        else if (info.resolvedTopic == 'shoots') summaryTitle = 'Shoot Updates';
        else if (info.resolvedTopic == 'meetings') summaryTitle = 'Meeting Updates';
        
        _localNotificationsPlugin.show(
          id: summaryId,
          title: summaryTitle,
          body: 'You have new notifications', // Displayed when expanded if the OS chooses
          notificationDetails: NotificationDetails(android: summaryAndroidDetails, iOS: iosDetails),
        );
      }
    });

    // Handle tap from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.i('FcmService: 🚨 RECEIVED BACKGROUND MESSAGE TAP 🚨');
      PushNotificationHandler.handlePushTap(message.data, messageId: message.messageId);
    });

    // Handle tap from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.i('FcmService: 🚨 RECEIVED TERMINATED MESSAGE TAP (Cold Start) 🚨');
        PushNotificationHandler.handlePushTap(message.data, messageId: message.messageId);
      }
    });
  }

  /// Ensures device FCM token is registered with backend `POST /push-notifications/tokens`
  /// when a valid session token exists.
  Future<void> ensureFcmTokenRegistered() async {
    try {
      final sessionStore = _ref.read(sessionStoreProvider);
      final authToken = await sessionStore.readToken();
      if (authToken == null || authToken.isEmpty) {
        AppLogger.d(
            'FcmService: No active session token, skipping FCM token registration.');
        return;
      }

      String? fcmToken;
      if (FirebaseService.isInitialized) {
        final messaging = FirebaseMessaging.instance;
        try {
          final settings = await messaging
              .requestPermission()
              .timeout(const Duration(seconds: 5));

          if (settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus ==
                  AuthorizationStatus.provisional) {
            if (Platform.isIOS) {
              final apnsToken = await _waitForApnsToken(messaging);
              if (apnsToken == null) {
                AppLogger.w(
                    'FcmService: APNS token unavailable, cannot fetch FCM token yet.');
                return;
              }
            }

            fcmToken =
            await messaging.getToken().timeout(const Duration(seconds: 10));
          } else {
            AppLogger.w(
                'FcmService: Push notification permissions not granted by user.');
          }
        } catch (e) {
          AppLogger.e('FcmService: Timeout or error requesting FCM token: $e');
        }
      }

      if (fcmToken == null || fcmToken.isEmpty) {
        AppLogger.w('FcmService: No FCM token available, skipping backend registration.');
        return;
      }

      await _registerToken(fcmToken);
    } catch (e, st) {
      AppLogger.e('FcmService: FCM token registration failed: $e', e, st);
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final sessionStore = _ref.read(sessionStoreProvider);
      final authToken = await sessionStore.readToken();
      if (authToken == null || authToken.isEmpty) {
        AppLogger.d('FcmService: No active session token, skipping FCM token sync.');
        return;
      }

      final sessionId = await sessionStore.getAppSessionId();

      final cacheKey = '${sessionId}_${authToken.hashCode}_$token';
      if (cacheKey == _lastRegisteredToken) {
        AppLogger.d('FcmService: Token unchanged for this session and user, skipping redundant registration.');
        return;
      }

      final repo = _ref.read(notificationRepositoryProvider);
      await repo.saveFcmToken(
        fcmToken: token,
        sessionId: sessionId,
      );
      _lastRegisteredToken = cacheKey;
      AppLogger.i('FcmService: FCM token registered successfully.');
    } catch (e, st) {
      AppLogger.e('FcmService: Failed to sync FCM token: $e', e, st);
    }
  }

  /// Polls briefly for the APNS token to become available on iOS.
  Future<String?> _waitForApnsToken(FirebaseMessaging messaging) async {
    var apnsToken = await messaging.getAPNSToken();
    var attempts = 0;
    while (apnsToken == null && attempts < 5) {
      await Future.delayed(const Duration(seconds: 1));
      apnsToken = await messaging.getAPNSToken();
      attempts++;
    }
    return apnsToken;
  }

  /// Call this when the provider is disposed to avoid leaking the subscription.
  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}

/// Provider for [FcmService].
final fcmServiceProvider = Provider<FcmService>((ref) {
  final service = FcmService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Lifecycle provider that triggers FCM token sync on auth changes.
/// Add this once in your widget tree (e.g. inside your root App widget's
/// build method) as:
///
///   ref.watch(fcmLifecycleProvider);
///
/// Using `ref.listen` here (instead of calling the service directly inside
/// build) avoids re-triggering registration on every rebuild and correctly
/// reacts only to actual auth state *changes*.
final fcmLifecycleProvider = Provider<void>((ref) {
  ref.listen<bool>(authStateProvider, (previous, next) {
    if (next && previous != next) {
      ref.read(fcmServiceProvider).ensureFcmTokenRegistered();
    }
  }, fireImmediately: true);
});