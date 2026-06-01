import 'package:beige_creative_app/app/router.dart';
import 'package:beige_creative_app/app/routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Routes (single source of truth)', () {
    test('every Routes.x.name is non-empty', () {
      for (final r in Routes.all) {
        expect(r.name, isNotEmpty, reason: 'Route ${r.path} has empty name');
      }
    });

    test('every Routes.x.name is snake_case', () {
      // Firebase screen_name allows letters/digits/underscore, max 40 chars.
      final snakeCase = RegExp(r'^[a-z][a-z0-9_]{0,39}$');
      for (final r in Routes.all) {
        expect(
          snakeCase.hasMatch(r.name),
          isTrue,
          reason:
              'Route ${r.path} name "${r.name}" is not snake_case ≤40 chars',
        );
      }
    });

    test('Routes.x.name values are unique', () {
      final seen = <String>{};
      for (final r in Routes.all) {
        expect(
          seen.add(r.name),
          isTrue,
          reason: 'Duplicate Routes.name: ${r.name}',
        );
      }
    });

    test('Routes.x.path values are unique', () {
      final seen = <String>{};
      for (final r in Routes.all) {
        expect(
          seen.add(r.path),
          isTrue,
          reason: 'Duplicate Routes.path: ${r.path}',
        );
      }
    });

    test('Routes.publicPaths matches isPublic flags', () {
      final expected = {
        for (final r in Routes.all)
          if (r.isPublic) r.path,
      };
      expect(Routes.publicPaths, equals(expected));
    });

    test('Routes.byName covers all of Routes.all', () {
      expect(Routes.byName.length, Routes.all.length);
      for (final r in Routes.all) {
        expect(Routes.byName[r.name], same(r));
      }
    });
  });

  group('GoRouter tree consistency', () {
    final goRoutes = _flattenGoRoutes(appRoutes).toList();

    test('every GoRoute has a non-empty name', () {
      for (final r in goRoutes) {
        expect(r.name, isNotNull, reason: 'GoRoute ${r.path} missing name');
        expect(r.name, isNotEmpty,
            reason: 'GoRoute ${r.path} has empty name');
      }
    });

    test('every GoRoute (path, name) matches a Routes.x entry', () {
      final byName = Routes.byName;
      for (final r in goRoutes) {
        final spec = byName[r.name];
        expect(
          spec,
          isNotNull,
          reason: 'GoRoute name "${r.name}" not in Routes.byName',
        );
        expect(
          r.path,
          equals(spec!.path),
          reason:
              'GoRoute name "${r.name}" path "${r.path}" mismatches RouteSpec.path "${spec.path}"',
        );
      }
    });

    test('every Routes.x is registered as a GoRoute', () {
      final registeredNames = {for (final r in goRoutes) r.name};
      for (final spec in Routes.all) {
        expect(
          registeredNames.contains(spec.name),
          isTrue,
          reason:
              'Routes.${spec.name} declared but no GoRoute(name: "${spec.name}") found',
        );
      }
    });
  });
}

/// Recursively yields every `GoRoute` reachable from [routes], descending into
/// `StatefulShellRoute.branches`, `ShellRoute.routes`, and `GoRoute.routes`.
Iterable<GoRoute> _flattenGoRoutes(List<RouteBase> routes) sync* {
  for (final r in routes) {
    if (r is GoRoute) {
      yield r;
      yield* _flattenGoRoutes(r.routes);
    } else if (r is ShellRoute) {
      yield* _flattenGoRoutes(r.routes);
    } else if (r is StatefulShellRoute) {
      for (final branch in r.branches) {
        yield* _flattenGoRoutes(branch.routes);
      }
    }
  }
}
