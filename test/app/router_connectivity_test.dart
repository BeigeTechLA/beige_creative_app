import 'package:beige_creative_app/app/router.dart';
import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/core/connectivity/connectivity_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appRedirect — connectivity gate', () {
    test('offline + protected route → stay (returns null)', () {
      final result = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.offline,
        location: Routes.shoots.path,
      );
      expect(result, isNull);
    });

    test('offline + public route → falls through to auth/onboarding rules',
        () {
      // Unauthed user on /login while offline should stay on /login (not
      // get bounced back to /login because it already is, and not be sent
      // anywhere protected).
      final result = appRedirect(
        isAuth: false,
        hasSeenOnboarding: false,
        connStatus: ConnectivityStatus.offline,
        location: Routes.login.path,
      );
      expect(result, isNull);
    });

    test('offline + onboarding (public) → reachable', () {
      final result = appRedirect(
        isAuth: false,
        hasSeenOnboarding: false,
        connStatus: ConnectivityStatus.offline,
        location: Routes.onboarding.path,
      );
      expect(result, isNull);
    });

    test('unknown + protected route → falls through (auth rules apply)', () {
      // Cold-start safety: `unknown` must not false-block. Unauthed user
      // hitting a protected route still gets bounced to /login as usual.
      final result = appRedirect(
        isAuth: false,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.unknown,
        location: Routes.shoots.path,
      );
      expect(result, Routes.login.path);
    });

    test('online + authed user on protected route → null', () {
      final result = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.home.path,
      );
      expect(result, isNull);
    });

    test('online + authed user on /login → /home', () {
      final result = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.online,
        location: Routes.login.path,
      );
      expect(result, Routes.home.path);
    });

    test('offline + authed user on /login → authed bounce still wins', () {
      // /login is public, so the offline gate does not short-circuit. The
      // existing authed-on-login rule still bounces to /home. (The dialog
      // will then show over /home — fine; behaviour unchanged from online.)
      final result = appRedirect(
        isAuth: true,
        hasSeenOnboarding: true,
        connStatus: ConnectivityStatus.offline,
        location: Routes.login.path,
      );
      expect(result, Routes.home.path);
    });
  });
}
