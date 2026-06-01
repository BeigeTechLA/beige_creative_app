import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Minimum-viable widget-test harness for the Riverpod tree.
///
/// Wraps the widget under test in a `ProviderScope` (with caller-supplied
/// `overrides`) followed by a bare `MaterialApp(home: ...)`. Routing-specific
/// widgets that need `MaterialApp.router` should use [pumpRouterApp] instead.
///
/// Companion helpers ([pumpRouterApp], `mocks.dart`, `test_data.dart`) layered
/// in via Task 6.01.
extension PumpProviderApp on WidgetTester {
  Future<void> pumpProviderApp(
    Widget widget, {
    List<Override> overrides = const [],
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: theme,
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      ),
    );
  }

  /// GoRouter-aware variant. Pass a fully-built [GoRouter] (typically scoped
  /// to the route(s) under test) plus any Riverpod overrides. The harness
  /// mounts `MaterialApp.router` so navigation, redirect, and `state.extra`
  /// all behave as in the real app.
  ///
  /// Tests that need to assert on redirect logic should build their own
  /// router with the auth / onboarding providers overridden first, then
  /// pass that router in here.
  Future<void> pumpRouterApp(
    GoRouter router, {
    List<Override> overrides = const [],
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
          theme: theme,
          routerConfig: router,
        ),
      ),
    );
  }
}
