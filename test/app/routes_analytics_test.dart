import 'package:beige_creative_app/app/routes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Analytics-focused invariants for `Routes.all`. Complements the broader
/// route-completeness suite in `router_test.dart`.
void main() {
  group('Routes.x.name is a valid Firebase screen_name', () {
    // Firebase Analytics screen_name accepts letters/digits/underscore, max
    // 40 chars. Our convention is snake_case starting with a lowercase
    // letter.
    final snakeCase = RegExp(r'^[a-z][a-z0-9_]{0,39}$');

    test('every name matches snake_case ≤40 chars', () {
      for (final r in Routes.all) {
        expect(
          snakeCase.hasMatch(r.name),
          isTrue,
          reason: 'Route ${r.path} name "${r.name}" violates snake_case ≤40',
        );
      }
    });

    test('no name contains a hyphen (kebab leak)', () {
      for (final r in Routes.all) {
        expect(
          r.name.contains('-'),
          isFalse,
          reason: 'Route ${r.path} name "${r.name}" is kebab-case',
        );
      }
    });

    test('names are unique', () {
      final seen = <String>{};
      for (final r in Routes.all) {
        expect(seen.add(r.name), isTrue, reason: 'Duplicate name: ${r.name}');
      }
    });
  });

  group('RouteSpec.trackScreenView opt-outs', () {
    test('expected opt-outs are flagged false', () {
      const expectedOptOuts = {
        'splash',
        'profile_password_success',
        'delete_account_success',
        'shoot_cancelotties',
        'files_success',
      };
      for (final name in expectedOptOuts) {
        final spec = Routes.byName[name];
        expect(spec, isNotNull, reason: 'Routes.$name missing');
        expect(
          spec!.trackScreenView,
          isFalse,
          reason: 'Routes.$name should opt out of screen_view',
        );
      }
    });

    test('all other routes default to trackScreenView: true', () {
      const optOuts = {
        'splash',
        'profile_password_success',
        'delete_account_success',
        'shoot_cancelotties',
        'meeting_scheduled',
        'files_success',
      };
      for (final r in Routes.all) {
        if (optOuts.contains(r.name)) continue;
        expect(
          r.trackScreenView,
          isTrue,
          reason: 'Routes.${r.name} unexpectedly opts out of screen_view',
        );
      }
    });
  });

  group('RouteSpec.featureArea definitions', () {
    test('expected routes define correct feature area', () {
      final expected = {
        'login': 'auth',
        'home': 'home',
        'shoots': 'shoots',
        'files': 'files',
        'messages': 'messages',
        'my_profile': 'profile',
        'add_availability': 'availability',
      };

      for (final entry in expected.entries) {
        final spec = Routes.byName[entry.key];
        expect(spec, isNotNull, reason: 'Routes.${entry.key} missing');
        expect(
          spec!.featureArea,
          entry.value,
          reason: 'Routes.${entry.key} should map to featureArea "${entry.value}"',
        );
      }
    });
  });
}
