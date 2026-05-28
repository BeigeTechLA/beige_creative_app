import 'package:beige_creative_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/prefs_session_store.dart';
import 'package:beige_creative_app/core/session/session_store.dart';

class _FakeSecureBackend implements SecureSessionBackend {
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> writeToken(String token) async {}
  @override
  Future<void> clearToken() async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clearRefreshToken() async {}
}

void main() {
  testWidgets('App smoke test - MaterialApp.router builds inside ProviderScope',
      (WidgetTester tester) async {
    Env.init(Environment.dev);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final session = CompositeSessionStore(
      secure: _FakeSecureBackend(),
      prefs: PrefsSessionStore(prefs),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((_) async => prefs),
          sessionStoreProvider.overrideWithValue(session),
        ],
        child: const App(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
