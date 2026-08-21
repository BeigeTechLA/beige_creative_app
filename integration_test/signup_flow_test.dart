import 'dart:convert';
import 'dart:io';

import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/features/auth/presentation/routes/signup_args.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/signup1_screen.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/signup2_screen.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/signup3_screen.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup3_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/mocks.dart';
import 'robots/signup_robot.dart';

/// Phase 6 signup integration test.
///
/// Drives the real signup screens + SignupNotifier + AuthRepositoryImpl across
/// step 1 -> 2 -> 3. Dio is stubbed, and the final assertions inspect the
/// actual JSON / multipart payloads captured at the repository boundary.
///
/// Run locally with:
///   `flutter test integration_test/signup_flow_test.dart -d macos`
///
/// On-device promotion follows the 6.11 pattern: swap the binding to
/// `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` and run with a
/// device id.

class _StubTelemetry implements TelemetryClient {
  final List<({String name, Map<String, Object>? parameters})> events = [];

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

class _SignupFixtures {
  _SignupFixtures._(this.dir)
    : profileImage = _writePng(dir, 'signup_profile.png'),
      featureA = _writePng(dir, 'feature_a.png'),
      featureB = _writePng(dir, 'feature_b.png'),
      featureC = _writePng(dir, 'feature_c.png'),
      featureD = _writePng(dir, 'feature_d.png'),
      featureE = _writePng(dir, 'feature_e.png'),
      certificate = _writeBytes(dir, 'signup_cert.pdf', const [1, 2, 3]),
      resume = _writeBytes(dir, 'signup_resume.pdf', const [4, 5, 6]),
      portfolio = _writeBytes(dir, 'signup_portfolio.pdf', const [7, 8, 9]);

  final Directory dir;
  final File profileImage;
  final File featureA;
  final File featureB;
  final File featureC;
  final File featureD;
  final File featureE;
  final File certificate;
  final File resume;
  final File portfolio;

  static _SignupFixtures create() {
    final dir = Directory.systemTemp.createTempSync('beige_signup_flow_');
    return _SignupFixtures._(dir);
  }

  void dispose() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

class _HarnessApp extends StatelessWidget {
  const _HarnessApp();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: Routes.signupStep1.path,
      routes: [
        GoRoute(
          path: Routes.signupStep1.path,
          name: Routes.signupStep1.name,
          builder: (_, _) => const SignUp1Screen(),
        ),
        GoRoute(
          path: Routes.signupStep2.path,
          name: Routes.signupStep2.name,
          builder: (_, state) {
            final args = SignUpStep2Args.fromExtra(state.extra);
            return SignUp2Screen(
              crewMemberId: args.crewMemberId,
              profileImage: args.profileImage,
              email: args.email,
              firstName: args.firstName,
              lastName: args.lastName,
              location: args.location,
              workingDistance: args.workingDistance,
              step1Progress: args.step1Progress,
            );
          },
        ),
        GoRoute(
          path: Routes.signupStep3.path,
          name: Routes.signupStep3.name,
          builder: (_, state) {
            final args = SignUpStep3Args.fromExtra(state.extra);
            return SignUp3Screen(
              crewMemberId: args.crewMemberId,
              profileImage: args.profileImage,
              email: args.email,
              firstName: args.firstName,
              lastName: args.lastName,
              location: args.location,
              workingDistance: args.workingDistance,
              primaryRole: args.primaryRole,
              experience: args.experience,
              hourlyRate: args.hourlyRate,
              bio: args.bio,
              skills: args.skills,
              equipments: args.equipments,
              step2Progress: args.step2Progress,
            );
          },
        ),
        GoRoute(
          path: Routes.signupSuccess.path,
          name: Routes.signupSuccess.name,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('signup-success-stub'))),
        ),
        GoRoute(
          path: Routes.login.path,
          name: Routes.login.name,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('login-stub'))),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

void main() {
  // Vm-mode binding. Swap to IntegrationTestWidgetsFlutterBinding for device
  // promotion, matching integration_test/login_logout_test.dart.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Env.init(Environment.dev);
    registerHelperFallbacks();
    _installGeolocatorStubs();
    CrashlyticsBreadcrumbs.setCustomKey = (_, _) async {};
    CrashlyticsBreadcrumbs.log = (_) async {};
  });

  tearDownAll(() {
    _clearGeolocatorStubs();
    CrashlyticsBreadcrumbs.resetForTesting();
  });

  testWidgets(
    'signup step1 -> step2 -> step3 posts expected multipart payload',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fixtures = _SignupFixtures.create();
      addTearDown(fixtures.dispose);

      final dio = MockDio();
      final dioClient = MockDioClient();
      when(() => dioClient.dio).thenReturn(dio);
      _stubSignupDio(dio);

      final telemetry = _StubTelemetry();
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          dioClientProvider.overrideWithValue(dioClient),
          telemetryClientProvider.overrideWithValue(telemetry),
          currentSessionUserProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _HarnessApp(),
        ),
      );
      tester.takeException();
      await tester.pump();

      final robot = SignupRobot(tester, container);

      await robot.expectOnStep1();
      await robot.enterStep1Text(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        phone: '5551234567',
        password: 'pw123456',
      );
      await robot.seedStep1PickerOutcomes(
        profileImage: fixtures.profileImage,
        latLng: const LatLng(40.73061, -73.935242),
        workingDistance: 'Upto 50 Miles',
      );
      await robot.tapStep1Next();

      await robot.expectOnStep2();
      await robot.seedStep2Selections(
        role: 'Director of Photography',
        skill: 'Lighting',
      );
      await robot.enterStep2Text(
        yearsOfExperience: '5',
        hourlyRate: '125',
        bio: 'Cinematographer focused on commercial tabletop work.',
      );
      await robot.tapStep2Next();

      await robot.expectOnStep3();
      await robot.seedStep3PickerOutcomes(
        socialLinks: [
          {
            'name': 'Instagram',
            'url': 'insta.com/ada',
            'icon': kSignup3SocialIcons[1],
          },
        ],
        portfolioLinks: [
          {
            'name': 'Google Drive',
            'url': 'drive.google.com/ada',
            'icon': kSignup3PortfolioIcons[2],
          },
        ],
        featuredProjects: [
          [
            fixtures.featureA,
            fixtures.featureB,
            fixtures.featureC,
            fixtures.featureD,
            fixtures.featureE,
          ],
        ],
        featuredProjectTitles: ['Launch Spot'],
        certificates: [fixtures.certificate],
        resume: fixtures.resume,
        portfolio: fixtures.portfolio,
      );
      await robot.tapCreateProfile();

      await robot.expectOnSignupSuccessStub();

      final posts = _capturedPosts(dio);
      expect(posts.map((e) => e.path).toList(), containsAll([
        ApiEndpoints.register_step1,
        ApiEndpoints.register_step2,
        ApiEndpoints.register_step3_file,
        ApiEndpoints.register_step3,
      ]));

      final step1 = posts.firstWhere((p) => p.path == ApiEndpoints.register_step1).data as FormData;
      expect(_fieldMap(step1), {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@example.com',
        'phone': '5551234567',
        'password': 'pw123456',
        'location': '',
        'working_distance': 'Upto 50 Miles',
        'lat': '40.73061',
        'lng': '-73.935242',
      });
      expect(_fileNames(step1, 'profile_photo'), ['signup_profile.png']);

      final step2 = posts.firstWhere((p) => p.path == ApiEndpoints.register_step2).data;
      expect(step2, {
        'crew_member_id': 314,
        'primary_role': [1],
        'years_of_experience': 5,
        'hourly_rate': 125,
        'bio': 'Cinematographer focused on commercial tabletop work.',
        'skills': [10],
        'equipment_ownership': <int>[],
      });

      final step3 = posts.lastWhere((p) => p.path == ApiEndpoints.register_step3).data;
      expect(step3, isA<Map<String, dynamic>>());
      final step3Map = step3 as Map<String, dynamic>;
      expect(step3Map['crew_member_id'], 314);
      expect(step3Map['social_media_links'], {
        'instagram': 'https://insta.com/ada',
      });

      expect(
        telemetry.events.map((e) => e.name),
        containsAll(['signup_started', 'signup_completed']),
      );
    },
  );
}

typedef _PostCall = ({String path, dynamic data});

void _stubSignupDio(MockDio dio) {
  Future<Response<dynamic>> handler(Invocation invocation) async {
    final path = invocation.positionalArguments.first as String;
    final data = switch (path) {
      ApiEndpoints.register_step1 => {
        'error': false,
        'message': 'ok',
        'data': {'crew_member_id': 314},
      },
      ApiEndpoints.register_step3_file => {
        'error': false,
        'message': 'ok',
        'data': {'crew_files_id': 640},
      },
      ApiEndpoints.register_step2 || ApiEndpoints.register_step3 => {
        'error': false,
        'message': 'ok',
        'data': <String, dynamic>{},
      },
      _ => {'error': true, 'message': 'unexpected endpoint $path'},
    };
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: data,
    );
  }

  when(() => dio.get<dynamic>(any())).thenAnswer((invocation) async {
    final path = invocation.positionalArguments.single as String;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: switch (path) {
        ApiEndpoints.register_roles => {
          'error': false,
          'data': [
            {'role_id': 1, 'role_name': 'Director of Photography'},
          ],
        },
        ApiEndpoints.register_Skill => {
          'error': false,
          'data': [
            {'id': 10, 'name': 'Lighting'},
          ],
        },
        _ => {'error': false, 'data': <dynamic>[]},
      },
    );
  });

  when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(handler);
  when(
    () => dio.post<dynamic>(
      any(),
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  ).thenAnswer(handler);
}

List<_PostCall> _capturedPosts(MockDio dio) {
  final captured = verify(
    () => dio.post<dynamic>(
      captureAny(),
      data: captureAny(named: 'data'),
      options: captureAny(named: 'options'),
    ),
  ).captured;
  final calls = <_PostCall>[];
  for (var i = 0; i < captured.length; i += 3) {
    calls.add((path: captured[i] as String, data: captured[i + 1]));
  }
  return calls;
}

Map<String, String> _fieldMap(FormData data) => {
  for (final entry in data.fields) entry.key: entry.value,
};

List<String> _fileNames(FormData data, String key) => data.files
    .where((entry) => entry.key == key)
    .map((entry) => entry.value.filename ?? '')
    .toList();

File _writePng(Directory dir, String name) => _writeBytes(
  dir,
  name,
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAA'
    'AAYAAjCB0C8AAAAASUVORK5CYII=',
  ),
);

File _writeBytes(Directory dir, String name, List<int> bytes) {
  final file = File('${dir.path}/$name');
  file.writeAsBytesSync(bytes);
  return file;
}

void _installGeolocatorStubs() {
  const channels = [
    MethodChannel('flutter.baseflow.com/geolocator'),
    MethodChannel('flutter.baseflow.com/geolocator_android'),
    MethodChannel('flutter.baseflow.com/geolocator_apple'),
  ];
  for (final channel in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, _geolocatorHandler);
  }
}

void _clearGeolocatorStubs() {
  const channels = [
    MethodChannel('flutter.baseflow.com/geolocator'),
    MethodChannel('flutter.baseflow.com/geolocator_android'),
    MethodChannel('flutter.baseflow.com/geolocator_apple'),
  ];
  for (final channel in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  }
}

Future<dynamic> _geolocatorHandler(MethodCall call) async {
  switch (call.method) {
    case 'isLocationServiceEnabled':
      return false;
    case 'openLocationSettings':
    case 'openAppSettings':
      return true;
    case 'checkPermission':
    case 'requestPermission':
      return 2; // LocationPermission.whileInUse.
    case 'getCurrentPosition':
      return {
        'longitude': -73.935242,
        'latitude': 40.73061,
        'timestamp': DateTime(2026, 6, 3).millisecondsSinceEpoch,
        'accuracy': 1.0,
        'altitude': 0.0,
        'altitude_accuracy': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'is_mocked': true,
        'gnss_satellite_count': 0.0,
        'gnss_satellites_used_in_fix': 0.0,
      };
    default:
      return null;
  }
}
