import 'package:beige_creative_app/app/router.dart';
import 'package:beige_creative_app/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _State extends Mock implements GoRouterState {}

class _Context extends Mock implements BuildContext {}

Iterable<GoRoute> _routes(List<RouteBase> routes) sync* {
  for (final route in routes) {
    if (route is GoRoute) yield route;
    yield* _routes(route.routes);
  }
}

void main() {
  test(
    'all production routes explicitly choose SDK pages or the cancellation modal',
    () {
      final routes = _routes(appRoutes).toList();
      expect(routes.length, Routes.all.length);
      for (final route in routes) {
        expect(route.pageBuilder, isNotNull, reason: route.name);
        final state = _State();
        when(() => state.pageKey).thenReturn(ValueKey(route.path));
        when(() => state.name).thenReturn(route.name);
        when(() => state.path).thenReturn(route.path);
        when(() => state.pathParameters).thenReturn({'id': '42'});
        when(
          () => state.uri,
        ).thenReturn(Uri.parse('${route.path}?from=drawer'));
        when(() => state.extra).thenReturn({'projectId': 42});
        final page = route.pageBuilder!(_Context(), state);
        if (route.name == Routes.cancelShoot.name) {
          expect(page, isA<CustomTransitionPage<bool>>());
          final modal = page as CustomTransitionPage<bool>;
          expect(modal.opaque, isFalse);
          expect(modal.barrierDismissible, isTrue);
          expect(modal.barrierColor, isNotNull);
        } else {
          expect(page, isA<MaterialPage<void>>(), reason: route.name);
          expect(page.name, route.name);
          expect(page.key, state.pageKey);
          expect(page.arguments, {'id': '42', 'from': 'drawer'});
          expect(page.restorationId, state.pageKey.value);
        }
      }
      expect(
        appRoutes.whereType<StatefulShellRoute>().single.pageBuilder,
        isNotNull,
      );
    },
  );
}
