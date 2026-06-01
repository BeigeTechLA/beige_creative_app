import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/model_class/myprofile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';
import 'pump_app.dart';
import 'test_data.dart';

void main() {
  group('pumpRouterApp', () {
    testWidgets('mounts MaterialApp.router against passed-in routes',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/probe',
        routes: [
          GoRoute(
            path: '/probe',
            builder: (context, state) => const Scaffold(
              body: Text('probe-rendered'),
            ),
          ),
        ],
      );

      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('probe-rendered'), findsOneWidget);
    });
  });

  group('MockSessionStore', () {
    test('stubs SessionStore methods via mocktail', () async {
      final store = MockSessionStore();
      when(() => store.readToken()).thenAnswer((_) async => 'stubbed-token');
      when(() => store.isLoggedIn()).thenAnswer((_) async => true);

      expect(await store.readToken(), 'stubbed-token');
      expect(await store.isLoggedIn(), isTrue);
      verify(() => store.readToken()).called(1);
    });
  });

  group('FakeSessionBackends + CompositeSessionStore', () {
    test('round-trips token + user without touching real storage', () async {
      final store = CompositeSessionStore(
        secure: FakeSecureSessionBackend(),
        prefs: FakePrefsSessionBackend(),
      );

      expect(await store.isLoggedIn(), isFalse);

      await store.writeToken('abc');
      await store.writeUser(const UserSnapshot(id: '42', email: 'a@b.c'));

      expect(await store.readToken(), 'abc');
      expect(await store.isLoggedIn(), isTrue);
      expect((await store.readUser())?.email, 'a@b.c');

      await store.clearSession();
      expect(await store.readToken(), isNull);
      expect(await store.readUser(), isNull);
    });
  });

  group('test_data fixtures', () {
    test('profileResponse round-trips through MyProfileModel.fromJson', () {
      final json = profileResponse(firstName: 'Bob', email: 'bob@x.com');
      final model = MyProfileModel.fromJson(json);
      expect(model.error, isFalse);
      expect(model.data.firstName, 'Bob');
      expect(model.data.user.email, 'bob@x.com');
    });

    test('loginResponse exposes nested token + crew_member', () {
      final json = loginResponse(token: 'jwt', crewMemberId: 7);
      expect((json['data'] as Map)['token'], 'jwt');
      expect(((json['data'] as Map)['crew_member'] as Map)['id'], 7);
    });

    test('errorResponse always has error=true', () {
      final json = errorResponse(message: 'boom');
      expect(json['error'], isTrue);
      expect(json['message'], 'boom');
    });
  });
}
