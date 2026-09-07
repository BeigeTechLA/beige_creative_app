import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/my_profile_providers.dart';
import 'package:beige_creative_app/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:beige_creative_app/model_class/myprofile_model.dart';
import 'package:beige_creative_app/shared/widgets/loading.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Widget smoke for MyProfileScreen. Subclasses MyProfileNotifier so build()
/// skips the auto-microtask `refresh()` (which would hit
/// `profileFilesRepositoryProvider`). Seeded state drives the on-screen text.

class _FakeMyProfileNotifier extends MyProfileNotifier {
  _FakeMyProfileNotifier({this.seed = const MyProfileState()});

  final MyProfileState seed;

  @override
  MyProfileState build() => seed;

  @override
  Future<void> refresh() async {}
}

MyProfileData _profile({
  String firstName = 'Ada',
  String lastName = 'Lovelace',
  String email = 'ada@example.com',
  String location = 'London',
}) {
  final base = MyProfileData.fromJson(const {});
  return MyProfileData(
    stats: base.stats,
    equipmentOwnership: base.equipmentOwnership,
    bio: base.bio,
    primaryRole: base.primaryRole,
    crewMemberId: base.crewMemberId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: base.phoneNumber,
    location: location,
    workingDistance: 'Upto 50 Miles',
    yearsOfExperience: 4,
    hourlyRate: '55',
    isAvailable: 1,
    availability: base.availability,
    featuredWorkFiles: base.featuredWorkFiles,
    skills: base.skills,
    socialMediaLinks: base.socialMediaLinks,
    crewMemberFiles: base.crewMemberFiles,
    portfolioLinks: base.portfolioLinks,
    certificateFiles: base.certificateFiles,
    resumeFiles: base.resumeFiles,
    profileImageUrl: '',
    user: base.user,
  );
}

Future<_FakeMyProfileNotifier> _pump(
  WidgetTester tester, {
  MyProfileState? seed,
}) async {
  final fake = _FakeMyProfileNotifier(seed: seed ?? const MyProfileState());
  await tester.pumpProviderApp(
    const Myprofile(),
    overrides: [
      myProfileNotifierProvider.overrideWith(() => fake),
      currentSessionUserProvider.overrideWithValue(null),
    ],
  );
  // Drain asset-decode errors from AppAssets / SvgPicture / Lottie loaders.
  tester.takeException();
  return fake;
}

void main() {
  testWidgets('renders profile name + email + location from seeded state',
      (tester) async {
    await _pump(
      tester,
      seed: MyProfileState(profile: _profile()),
    );

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
  });

  testWidgets('shows loader overlay while isLoading=true', (tester) async {
    await _pump(
      tester,
      seed: const MyProfileState(isLoading: true),
    );

    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('renders stats labels from profile (hourly rate + experience)',
      (tester) async {
    await _pump(
      tester,
      seed: MyProfileState(profile: _profile()),
    );

    // ProfileStatsPanel formats "$55" + "04 yrs".
    expect(find.text('\$55'), findsOneWidget);
    expect(find.text('04 yrs'), findsOneWidget);
    expect(find.text('Upto 50 Miles'), findsOneWidget);
  });
}
