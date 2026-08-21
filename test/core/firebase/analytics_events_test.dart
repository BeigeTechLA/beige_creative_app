import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every call routed through [TelemetryClient.logEvent] so the
/// typed-helper extension methods can be asserted without touching the
/// static Firebase wrappers.
class _RecordingTelemetry implements TelemetryClient {
  final List<({String name, Map<String, Object>? parameters})> events =
      <({String name, Map<String, Object>? parameters})>[];

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {}

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

void main() {
  group('TelemetryEventHelpers — parametric helpers', () {
    test('shootAccepted forwards shoot_id', () async {
      final t = _RecordingTelemetry();
      await t.shootAccepted('shoot-42');
      expect(t.events, hasLength(1));
      expect(t.events.single.name, AnalyticsEvents.shootAccepted);
      expect(t.events.single.parameters, {'shoot_id': 'shoot-42'});
    });

    test('loginFailure emits closed-set reason wire name', () async {
      final t = _RecordingTelemetry();
      await t.loginFailure(LoginFailureReason.invalidCredentials);
      expect(t.events.single.name, AnalyticsEvents.loginFailure);
      expect(t.events.single.parameters, {'reason': 'invalid_credentials'});
    });

    test('signupCompleted bundles asset flags', () async {
      final t = _RecordingTelemetry();
      await t.signupCompleted(
        hasResume: true,
        hasFeaturedWork: false,
        socialCount: 3,
      );
      expect(t.events.single.name, AnalyticsEvents.signupCompleted);
      expect(t.events.single.parameters, {
        'has_resume': true,
        'has_featured_work': false,
        'social_count': 3,
      });
    });

    test('profilePhotoUploaded forwards source wire name', () async {
      final t = _RecordingTelemetry();
      await t.profilePhotoUploaded(ProfilePhotoSource.gallery);
      expect(t.events.single.name, AnalyticsEvents.profilePhotoUploaded);
      expect(t.events.single.parameters, {'source': 'gallery'});
    });

    test('featuredWorkUploaded forwards file_count', () async {
      final t = _RecordingTelemetry();
      await t.featuredWorkUploaded(fileCount: 5);
      expect(t.events.single.name, AnalyticsEvents.featuredWorkUploaded);
      expect(t.events.single.parameters, {'file_count': 5});
    });

    test('availabilityAdded forwards duration_days', () async {
      final t = _RecordingTelemetry();
      await t.availabilityAdded(durationDays: 7);
      expect(t.events.single.name, AnalyticsEvents.availabilityAdded);
      expect(t.events.single.parameters, {'duration_days': 7});
    });
  });

  group('TelemetryEventHelpers — nullary helpers', () {
    test('loginSuccess emits name without parameters', () async {
      final t = _RecordingTelemetry();
      await t.loginSuccess();
      expect(t.events.single.name, AnalyticsEvents.loginSuccess);
      expect(t.events.single.parameters, isNull);
    });

    test('logout emits name without parameters', () async {
      final t = _RecordingTelemetry();
      await t.logout();
      expect(t.events.single.name, AnalyticsEvents.logout);
      expect(t.events.single.parameters, isNull);
    });

    test('signupStarted, passwordResetRequested, accountDeletionRequested '
        'all route through logEvent', () async {
      final t = _RecordingTelemetry();
      await t.signupStarted();
      await t.passwordResetRequested();
      await t.accountDeletionRequested();
      expect(t.events.map((e) => e.name), <String>[
        AnalyticsEvents.signupStarted,
        AnalyticsEvents.passwordResetRequested,
        AnalyticsEvents.accountDeletionRequested,
      ]);
      expect(t.events.every((e) => e.parameters == null), isTrue);
    });
  });
}
