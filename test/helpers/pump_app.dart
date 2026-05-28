import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimum-viable widget-test harness for the Riverpod tree.
///
/// Wraps the widget under test in a `ProviderScope` (with caller-supplied
/// `overrides`) followed by a bare `MaterialApp(home: ...)`. Routing-specific
/// widgets that need `MaterialApp.router` should pump that themselves; this
/// helper covers leaf-widget tests where `MaterialApp` is just localization +
/// Directionality scaffolding.
///
/// Phase 6.01 layers in `mocks.dart` + `test_data.dart`; this helper stays
/// dependency-free so it can ship today.
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
}
