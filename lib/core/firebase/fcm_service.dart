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

    // Add listener to verify incoming notifications in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i('FcmService: 🚨 RECEIVED FOREGROUND MESSAGE 🚨');
      AppLogger.i('Message data: ${message.data}');
      if (message.notification != null) {
        AppLogger.i('Message notification title: ${message.notification?.title}');
        AppLogger.i('Message notification body: ${message.notification?.body}');

        final notification = message.notification!;
        final androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
        final iosDetails = const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        final platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: platformDetails,
          payload: jsonEncode(message.data),
        );
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
        AppLogger.d('FcmService: No active session token, skipping FCM token registration.');
        return;
      }

      String? fcmToken;
      if (FirebaseService.isInitialized) {
        final messaging = FirebaseMessaging.instance;
        try {
          final settings = await messaging.requestPermission().timeout(const Duration(seconds: 5));
          
          if (settings.authorizationStatus == AuthorizationStatus.authorized || 
              settings.authorizationStatus == AuthorizationStatus.provisional) {
            
            if (Platform.isIOS) {
              final apnsToken = await _waitForApnsToken(messaging);
              if (apnsToken == null) {
                AppLogger.w('FcmService: APNS token unavailable, cannot fetch FCM token yet.');
                return;
              }
            }

            fcmToken = await messaging.getToken().timeout(const Duration(seconds: 10));
          } else {
            AppLogger.w('FcmService: Push notification permissions not granted by user.');
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