import 'package:beige_creative_app/core/restoration/restoration_keys.dart';
import 'package:beige_creative_app/core/restoration/route_restoration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RouteRestorationService.shouldPersist', () {
    test('public paths are skipped', () {
      expect(RouteRestorationService.shouldPersist('/splash'), isFalse);
      expect(RouteRestorationService.shouldPersist('/login'), isFalse);
      expect(RouteRestorationService.shouldPersist('/signup-step-1'), isFalse);
      expect(RouteRestorationService.shouldPersist('/forgot-otp'), isFalse);
    });

    test('OTP / success surfaces are skipped', () {
      expect(RouteRestorationService.shouldPersist('/profile-otp'), isFalse);
      expect(
        RouteRestorationService.shouldPersist('/profile-password-success'),
        isFalse,
      );
      expect(
        RouteRestorationService.shouldPersist('/delete-account-success'),
        isFalse,
      );
    });

    test('authed feature routes are persisted', () {
      expect(RouteRestorationService.shouldPersist('/home'), isTrue);
      expect(RouteRestorationService.shouldPersist('/shoots'), isTrue);
      expect(
        RouteRestorationService.shouldPersist('/upcoming-shoot-details'),
        isTrue,
      );
    });
  });

  group('RouteRestorationService persist + readRestorable', () {
    late SharedPreferences prefs;
    late RouteRestorationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = RouteRestorationService(prefs);
    });

    test('no-ops while kRestorationEnabled is false', () async {
      // kRestorationEnabled defaults to false in this build — persist + read
      // should both no-op.
      await service.persist(matchedLocation: '/home');
      expect(service.readRestorable(), isNull);
      expect(prefs.getString(RestorationKeys.lastRoute), isNull);
    });

    test('clearAll wipes every restoration key', () async {
      await prefs.setString(RestorationKeys.lastRoute, '/home');
      await prefs.setString(RestorationKeys.lastQueryJson, '{}');
      await prefs.setString(RestorationKeys.lastPathParamsJson, '{}');
      await prefs.setInt(RestorationKeys.lastActiveTs, 123);

      await service.clearAll();

      for (final key in RestorationKeys.allKeys) {
        // schemaVersion is wiped then re-stamped by _migrateSchema in
        // construction. clearAll only removes — the migrate-stamp happens
        // on next construction.
        if (key == RestorationKeys.schemaVersion) continue;
        expect(prefs.getString(key), isNull);
        expect(prefs.getInt(key), isNull);
      }
    });
  });
}
