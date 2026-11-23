import 'dart:async';

import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/core/notifications/notification_payload.dart';
import 'package:beige_creative_app/core/notifications/notification_tap_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Mirrors `biegeapp`'s router test — same readiness-gating, retry and dedup
/// behaviour, adapted to this app's `Routes` and typed `extra` args.
void main() {
  late NotificationTapRouter taps;
  late GoRouter router;
  late bool authenticated;
  late bool online;
  late bool blockDestination;
  late int destinationAttempts;
  Completer<void>? redirectDelay;
  late List<Object> navigationErrors;

  final chat = NotificationPayload.fromMap({
    'type': 'chat',
    'chat_room_id': 'room-42',
    'name': 'Alex',
  });
  final booking = NotificationPayload.fromMap({
    'type': 'booking',
    'booking_id': '123',
  });

  bool isDestinationPath(String path) =>
      path == Routes.chat.path || path == Routes.upcomingShootDetails.path;

  setUp(() {
    navigationErrors = [];
    taps = NotificationTapRouter(
      onError: (error, stack) => navigationErrors.add(error),
    );
    authenticated = true;
    online = true;
    blockDestination = false;
    destinationAttempts = 0;
    redirectDelay = null;
  });

  Future<void> mount(
    WidgetTester tester, {
    String initial = '/home',
    bool includeFiles = true,
  }) async {
    final routeDefs = <String, String>{
      Routes.home.path: Routes.home.name,
      Routes.splash.path: Routes.splash.name,
      Routes.login.path: Routes.login.name,
      Routes.chat.path: Routes.chat.name,
      Routes.upcomingShootDetails.path: Routes.upcomingShootDetails.name,
      Routes.messages.path: Routes.messages.name,
      Routes.shoots.path: Routes.shoots.name,
      Routes.meetings.path: Routes.meetings.name,
      Routes.myProfile.path: Routes.myProfile.name,
      Routes.notificationList.path: Routes.notificationList.name,
      if (includeFiles) ...{
        Routes.files.path: Routes.files.name,
        Routes.filesFolder.path: Routes.filesFolder.name,
      },
    };

    router = GoRouter(
      initialLocation: initial,
      redirect: (context, state) async {
        if (isDestinationPath(state.uri.path)) {
          destinationAttempts++;
          await redirectDelay?.future;
          if (!authenticated) return Routes.login.path;
          if (blockDestination) return Routes.home.path;
        }
        return null;
      },
      routes: [
        for (final entry in routeDefs.entries)
          GoRoute(
            path: entry.key,
            name: entry.value,
            builder: (context, state) => Scaffold(
              body: Text('${state.uri.path}:${state.uri.queryParameters}'),
            ),
          ),
      ],
    );
    taps.attach(router, canNavigate: () => authenticated && online);
    addTearDown(() {
      taps.detach();
      router.dispose();
    });
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('cold-start tap waits for router and splash to finish', (
    tester,
  ) async {
    taps.enqueue(chat);
    await mount(tester, initial: Routes.splash.path);
    expect(taps.pending, same(chat));
    expect(destinationAttempts, 0);

    router.go(Routes.home.path);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.chat.path);
    expect(router.state.uri.queryParameters['conversationId'], 'room-42');
    expect((router.state.extra as Map)['conversationId'], 'room-42');
    expect((router.state.extra as Map)['contactName'], 'Alex');
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
  });

  testWidgets('tap survives login and opens after authentication', (
    tester,
  ) async {
    authenticated = false;
    taps.enqueue(booking);
    await mount(tester, initial: Routes.login.path);
    expect(taps.pending, same(booking));
    expect(destinationAttempts, 0);

    authenticated = true;
    router.go(Routes.home.path);
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.upcomingShootDetails.path);
    expect((router.state.extra as Map)['projectId'], 123);
    expect(router.state.uri.queryParameters['bookingId'], '123');
    expect(taps.pending, isNull);
  });

  testWidgets('duplicate drains do not create duplicate routes', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(chat);
    taps.process();
    taps.retry();
    taps.process();
    await tester.pumpAndSettle();
    taps.retry();
    await tester.pumpAndSettle();
    expect(destinationAttempts, 1);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.home.path);
    expect(router.canPop(), isFalse);
  });

  testWidgets('router rejection retains tap without a retry loop', (
    tester,
  ) async {
    await mount(tester);
    blockDestination = true;
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.home.path);
    expect(taps.pending, same(chat));
    expect(destinationAttempts, 1);

    blockDestination = false;
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.chat.path);
    expect(taps.pending, isNull);
    expect(destinationAttempts, 2);
  });

  testWidgets('offline launch waits until connectivity returns', (
    tester,
  ) async {
    online = false;
    taps.enqueue(booking);
    await mount(tester);
    expect(taps.pending, same(booking));
    expect(destinationAttempts, 0);
    online = true;
    taps.retry();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.upcomingShootDetails.path);
    expect(taps.pending, isNull);
  });

  testWidgets('meeting go destination acknowledges query parameters', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(
      NotificationPayload.fromMap({'type': 'meeting', 'meeting_id': '77'}),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '${Routes.meetings.path}?meetingId=77');
    expect(taps.pending, isNull);
  });

  testWidgets('files tap opens the folder via path parameter', (tester) async {
    await mount(tester);
    taps.enqueue(
      NotificationPayload.fromMap({'type': 'files', 'folder_id': '9'}),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/files/folder/9');
    expect(router.canPop(), isTrue);
    expect(taps.pending, isNull);
  });

  testWidgets('profile tap switches tab without a pushable page', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(NotificationPayload(type: NotificationType.profile, rawMap: const {}));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.myProfile.path);
    expect(router.canPop(), isFalse);
    expect(taps.pending, isNull);
  });

  testWidgets('internal deeplink is pushed; external is dropped to list', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(
      NotificationPayload(
        type: NotificationType.deeplink,
        targetRoute: Routes.messages.path,
        rawMap: const {},
      ),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.messages.path);
    expect(taps.pending, isNull);

    taps.enqueue(
      NotificationPayload(
        type: NotificationType.deeplink,
        targetRoute: '//external.test',
        rawMap: const {},
      ),
    );
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.notificationList.path);
    expect(taps.pending, isNull);
  });

  testWidgets('already open target is acknowledged without pushing again', (
    tester,
  ) async {
    await mount(tester);
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.home.path);
  });

  testWidgets('destination failure calls onError and retains the tap', (
    tester,
  ) async {
    await mount(tester, includeFiles: false);
    final payload = NotificationPayload.fromMap({'type': 'files'});
    taps.enqueue(payload);
    await tester.pumpAndSettle();
    expect(navigationErrors, hasLength(1));
    expect(taps.pending, same(payload));
    expect(router.state.uri.path, Routes.home.path);
    taps.process();
    await tester.pumpAndSettle();
    expect(navigationErrors, hasLength(1));
  });

  testWidgets('inactive account logs why tap is retained until reactivation', (
    tester,
  ) async {
    await mount(tester);
    var active = false;
    final events = <String>[];
    taps.detach();
    taps = NotificationTapRouter(onEvent: events.add);
    taps.attach(
      router,
      canNavigate: () => active,
      blockedReason: () => active ? null : 'waiting_for_active_account',
    );
    taps.enqueue(chat);
    await tester.pumpAndSettle();
    expect(events, contains('waiting_for_active_account'));
    expect(taps.pending, same(chat));
    expect(destinationAttempts, 0);
    active = true;
    taps.retry();
    await tester.pumpAndSettle();
    expect(taps.pending, isNull);
    expect(destinationAttempts, 1);
  });
}
