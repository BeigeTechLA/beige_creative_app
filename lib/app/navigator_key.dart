import 'package:flutter/widgets.dart';

/// Global key for the root `Navigator`.
///
/// Passed to `GoRouter(navigatorKey:)` so non-widget code (auth interceptor,
/// background notification handlers, etc.) can navigate without holding a
/// `BuildContext`.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
