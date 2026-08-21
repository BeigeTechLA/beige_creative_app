import 'package:beige_creative_app/core/restoration/splash_restorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const restorer = SplashRestorer();

  group('SplashRestorer.shouldRestore', () {
    test('returns false when feature flag is off', () {
      expect(
        restorer.shouldRestore(
          isEnabled: false,
          isLoggedIn: true,
          persistedRoute: '/home',
        ),
        isFalse,
      );
    });

    test('returns false when user is logged out', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: false,
          persistedRoute: '/home',
        ),
        isFalse,
      );
    });

    test('returns false for null / empty persisted route', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: null,
        ),
        isFalse,
      );
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '',
        ),
        isFalse,
      );
    });

    test('returns false for public paths', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '/login',
        ),
        isFalse,
      );
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '/signup-step-2',
        ),
        isFalse,
      );
    });

    test('returns false for forbidden OTP / success surfaces', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '/profile-otp',
        ),
        isFalse,
      );
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '/delete-account-success',
        ),
        isFalse,
      );
    });

    test('returns true for authed feature routes', () {
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '/home',
        ),
        isTrue,
      );
      expect(
        restorer.shouldRestore(
          isEnabled: true,
          isLoggedIn: true,
          persistedRoute: '/upcoming-shoot-details',
        ),
        isTrue,
      );
    });
  });
}
