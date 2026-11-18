import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Explicit SDK page: GoRouter 18 detects material_ui.MaterialApp, whereas
/// this app uses Flutter's MaterialApp. Its automatic fallback has no swipe back.
MaterialPage<void> appRoutePage(GoRouterState state, Widget child) {
  return MaterialPage<void>(
    key: state.pageKey,
    name: state.name ?? state.path,
    arguments: <String, String>{
      ...state.pathParameters,
      ...state.uri.queryParameters,
    },
    restorationId: state.pageKey.value,
    child: child,
  );
}

/// Keep screen construction below the route's inherited state, just as
/// GoRouter does for its default widget builder. Extras stay on [GoRouterState].
GoRouterPageBuilder appPageBuilder(GoRouterWidgetBuilder builder) {
  return (context, state) => appRoutePage(
    state,
    Builder(builder: (context) => builder(context, state)),
  );
}
