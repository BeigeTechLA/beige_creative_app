import 'package:beige_creative_app/app/router.dart';
import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_status.dart';
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
        expect(r.name, isNotEmpty, reason: 'GoRoute ${r.path} has empty name');
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

  group('appRedirect logic', () {
    test('unauthed non-guest user touching protected route returns /login', () {
      final res = appRedirect(
        isAuth: false,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.shoots.path,
        isGuest: false,
      );
      expect(res, equals(Routes.login.path));
    });

    test('guest mode user touching protected route returns /home', () {
      final res = appRedirect(
        isAuth: false,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.shoots.path,
        isGuest: true,
      );
      expect(res, equals(Routes.home.path));
    });

    test('guest mode user accessing /home is allowed (returns null)', () {
      final res = appRedirect(
        isAuth: false,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.home.path,
        isGuest: true,
      );
      expect(res, isNull);
    });

    test(
      'guest mode user accessing public login route is allowed (returns null)',
      () {
        final res = appRedirect(
          isAuth: false,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.login.path,
          isGuest: true,
        );
        expect(res, isNull);
      },
    );

    test(
      'authed user with is_registration_complete == 0 redirects to /signup-step-2',
      () {
        final res = appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.home.path,
          isRegistrationComplete: 0,
          isCrewVerified: 0,
        );
        expect(res, equals(Routes.signupStep2.path));
      },
    );

    test('incomplete registration cannot return to signup step 1', () {
      final res = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.signupStep1.path,
        isRegistrationComplete: 0,
        isCrewVerified: 0,
      );
      expect(res, equals(Routes.signupStep2.path));
    });

    test('incomplete registration may continue through steps 2 and 3', () {
      expect(
        appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.signupStep2.path,
          isRegistrationComplete: 0,
          isCrewVerified: 0,
          isStep2Complete: false,
        ),
        isNull,
      );
      expect(
        appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.signupStep3.path,
          isRegistrationComplete: 0,
          isCrewVerified: 0,
          isStep2Complete: true,
        ),
        isNull,
      );
    });

    test(
      'completed Step 2 redirects incomplete profile directly to Step 3',
      () {
        final res = appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.login.path,
          isRegistrationComplete: 0,
          isCrewVerified: 0,
          isStep2Complete: true,
        );
        expect(res, Routes.signupStep3.path);
      },
    );

    test('unfinished Step 2 may advance to Step 3 inside the signup flow', () {
      final res = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.signupStep3.path,
        isRegistrationComplete: 0,
        isCrewVerified: 0,
        isStep2Complete: false,
      );
      expect(res, isNull);
    });

    test('pending review uses /home as blocked landing surface', () {
      final res = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.home.path,
        isRegistrationComplete: 1,
        isCrewVerified: 0,
      );
      expect(res, isNull);

      final protectedRes = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.shoots.path,
        isRegistrationComplete: 1,
        isCrewVerified: 0,
      );
      expect(protectedRes, equals(Routes.home.path));

      for (final profileRoute in [
        Routes.myProfile.path,
        Routes.profileDetails.path,
        Routes.editPersonalDetails.path,
        Routes.enterProfessionalDetails.path,
        Routes.featuredWorks.path,
        Routes.certificates.path,
        Routes.resume.path,
      ]) {
        final profileRes = appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: profileRoute,
          isRegistrationComplete: 1,
          isCrewVerified: 0,
        );
        expect(profileRes, isNull, reason: '$profileRoute must stay editable');
      }
    });

    test(
      'authed user with is_registration_complete == 1 and is_crew_verified == 2 (rejected) redirects to /application-rejected',
      () {
        final res = appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.home.path,
          isRegistrationComplete: 1,
          isCrewVerified: 2,
        );
        expect(res, equals(Routes.applicationRejected.path));
      },
    );

    test(
      'approved CP (is_registration_complete == 1 and is_crew_verified == 1) has full access',
      () {
        final res = appRedirect(
          isAuth: true,
          hasSeenOnboarding: true,
          connStatus: ConnectivityStatus.online,
          location: Routes.home.path,
          isRegistrationComplete: 1,
          isCrewVerified: 1,
        );
        expect(res, isNull);
      },
    );

    test('missing or unknown account status fails closed to /login', () {
      final missing = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.home.path,
      );
      expect(missing, Routes.login.path);

      final unknown = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.home.path,
        isRegistrationComplete: 1,
        isCrewVerified: 9,
      );
      expect(unknown, Routes.login.path);
    });

    test('offline state does not bypass auth or CP status restrictions', () {
      final unauthed = appRedirect(
        isAuth: false,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.offline,
        location: Routes.shoots.path,
      );
      expect(unauthed, Routes.login.path);

      final pending = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.offline,
        location: Routes.shoots.path,
        isRegistrationComplete: 1,
        isCrewVerified: 0,
      );
      expect(pending, Routes.home.path);

      final rejected = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.offline,
        location: Routes.home.path,
        isRegistrationComplete: 1,
        isCrewVerified: 2,
      );
      expect(rejected, Routes.applicationRejected.path);
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
