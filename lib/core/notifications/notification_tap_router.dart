import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../features/messages/presentation/routes/messages_args.dart';
import '../../features/shoots/presentation/routes/shoots_args.dart';
import 'notification_payload.dart';

class _NotificationDestination {
  const _NotificationDestination(
    this.location, {
    this.push = true,
    this.extra,
    this.name,
    this.pathParameters = const {},
  });

  final String location;
  final bool push;
  final Object? extra;
  final String? name;
  final Map<String, String> pathParameters;

  bool matches(GoRouterState state) {
    if (state.error != null) return false;
    final uri = Uri.parse(location);
    if (name != null) {
      if (state.name != name ||
          !pathParameters.entries.every(
            (entry) => state.pathParameters[entry.key] == entry.value,
          )) {
        return false;
      }
    } else if (state.uri.path != uri.path) {
      return false;
    }
    // Identity-bearing parameters must survive redirects. Unrelated added
    // parameters, encoding differences, and query ordering do not change it.
    return uri.queryParametersAll.entries.every(
      (entry) =>
          listEquals(state.uri.queryParametersAll[entry.key], entry.value),
    );
  }
}

/// Holds taps until the authenticated router can accept them. A redirect must
/// not consume a tap, and repeated lifecycle/frame callbacks must not push twice.
///
/// Mirrors the sibling client app (`biegeapp`) router so both apps route push
/// taps identically across foreground / background / terminated states.
class NotificationTapRouter {
  NotificationTapRouter({this.onError, this.onEvent});

  final void Function(Object error, StackTrace stack)? onError;
  final void Function(String event)? onEvent;
  GoRouter? _router;
  bool Function()? _canNavigate;
  String? Function()? _blockedReason;
  NotificationPayload? _pending;
  NotificationPayload? _attempted;
  _NotificationDestination? _attemptDestination;
  bool _scheduled = false;
  bool _inFlight = false;
  bool _retryRequested = false;

  NotificationPayload? get pending => _pending;

  void attach(
    GoRouter router, {
    required bool Function() canNavigate,
    String? Function()? blockedReason,
  }) {
    detach();
    _router = router;
    _canNavigate = canNavigate;
    _blockedReason = blockedReason;
    router.routerDelegate.addListener(_routeChanged);
    retry();
  }

  void detach() {
    _router?.routerDelegate.removeListener(_routeChanged);
    _router = null;
    _canNavigate = null;
    _blockedReason = null;
    _attempted = null;
    _attemptDestination = null;
    _inFlight = false;
    _retryRequested = false;
  }

  void enqueue(NotificationPayload payload) {
    _pending = payload;
    _log('queued');
    process();
  }

  /// Called when auth/account/connectivity changes, or the app resumes.
  void retry() {
    if (_inFlight) {
      _retryRequested = true;
      return;
    }
    _attempted = null;
    process();
  }

  void process() {
    if (_scheduled || _pending == null || _router == null) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _dispatch();
    });
    // A late platform callback may arrive while the UI is idle.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _routeChanged() {
    final router = _router;
    if (router == null) return;
    _inFlight = false;
    if (_pending != null &&
        identical(_attempted, _pending) &&
        (_attemptDestination?.matches(router.state) ?? false)) {
      _log('destination_reached');
      _pending = null;
      _attempted = null;
      _attemptDestination = null;
    } else if (_attempted != null) {
      _log('redirected_pending');
    }
    if (_retryRequested) _attempted = null;
    _retryRequested = false;
    process();
  }

  void _dispatch() {
    final router = _router;
    final payload = _pending;
    if (router == null ||
        payload == null ||
        _inFlight ||
        identical(_attempted, payload)) {
      return;
    }
    if (router.routerDelegate.currentConfiguration.isEmpty ||
        !(_canNavigate?.call() ?? false) ||
        router.state.uri.path == Routes.splash.path) {
      _log(_blockedReason?.call() ?? 'waiting_for_router');
      return;
    }
    _attempted = payload;
    try {
      final destination = _destination(router, payload);
      _attemptDestination = destination;
      // An already open destination also counts as successful delivery.
      if (destination.matches(router.state)) {
        _routeChanged();
        return;
      }
      _log('dispatching');
      _inFlight = true;
      if (destination.push) {
        // push() completes when the page is POPPED, not when it is accepted.
        // Acknowledge through the router delegate instead.
        unawaited(
          router
              .push<void>(destination.location, extra: destination.extra)
              .catchError((Object error, StackTrace stack) {
                _navigationFailed(error, stack);
              }),
        );
      } else {
        router.go(destination.location, extra: destination.extra);
      }
    } catch (error, stack) {
      // Preserve the pending tap. Retry only on a readiness change, avoiding a
      // frame loop for an invalid server-supplied route.
      _navigationFailed(error, stack);
    }
  }

  void _navigationFailed(Object error, StackTrace stack) {
    _inFlight = false;
    _log('navigation_failed');
    onError?.call(error, stack);
  }

  void _log(String event) {
    onEvent?.call(event);
    if (kDebugMode) {
      debugPrint('[NotificationTapRouter] $event type=${_pending?.type.name}');
    }
  }

  _NotificationDestination _destination(
    GoRouter router,
    NotificationPayload payload,
  ) {
    _NotificationDestination named(
      String name, {
      bool push = true,
      Map<String, String> pathParameters = const {},
      Map<String, dynamic> queryParameters = const {},
      Object? extra,
    }) => _NotificationDestination(
      router.namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
      push: push,
      extra: extra,
      name: name,
      pathParameters: pathParameters,
    );

    switch (payload.type) {
      case NotificationType.chat:
        if (payload.chatId != null && payload.chatId!.isNotEmpty) {
          return named(
            Routes.chat.name,
            extra: ChatArgs(
              conversationId: payload.chatId!,
              contactName: payload.title,
            ).toExtra(),
            queryParameters: {'conversationId': payload.chatId!},
          );
        } else {
          return named(Routes.messages.name, push: false);
        }

      case NotificationType.booking:
        if (payload.bookingId != null && payload.bookingId!.isNotEmpty) {
          final bookingId = int.tryParse(payload.bookingId!);
          if (bookingId != null) {
            return named(
              Routes.upcomingShootDetails.name,
              extra: UpcomingShootDetailsArgs(projectId: bookingId).toExtra(),
              queryParameters: {'bookingId': bookingId.toString()},
            );
          } else {
            return named(Routes.shoots.name, push: false);
          }
        } else {
          return named(Routes.shoots.name, push: false);
        }

      case NotificationType.meeting:
        if (payload.meetingId != null && payload.meetingId!.isNotEmpty) {
          return named(
            Routes.meetings.name,
            push: false,
            queryParameters: {'meetingId': payload.meetingId!},
          );
        } else if (payload.bookingId != null &&
            int.tryParse(payload.bookingId!) != null) {
          return named(
            Routes.upcomingShootDetails.name,
            extra: UpcomingShootDetailsArgs(
              projectId: int.parse(payload.bookingId!),
            ).toExtra(),
            queryParameters: {'bookingId': payload.bookingId!},
          );
        } else {
          return named(Routes.meetings.name, push: false);
        }

      case NotificationType.files:
        final folderId = payload.folderId ?? payload.bookingId;
        if (folderId != null && folderId.isNotEmpty) {
          return named(
            Routes.filesFolder.name,
            pathParameters: {'id': folderId},
          );
        } else {
          return named(Routes.files.name, push: false);
        }

      case NotificationType.profile:
        return named(Routes.myProfile.name, push: false);

      case NotificationType.deeplink:
      case NotificationType.unknown:
        final route = payload.targetRoute;
        if (route != null && route.startsWith('/') && !route.startsWith('//')) {
          return _NotificationDestination(route);
        }
        return named(Routes.notificationList.name);
    }
  }
}
