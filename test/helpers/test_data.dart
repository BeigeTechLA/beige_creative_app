/// Canonical JSON fixtures for Phase 6 tests.
///
/// Drawn from real API response shapes (sanitized — no production data, no
/// PII). Each fixture is a builder that takes overrides so tests can tweak
/// only the field they're asserting on. Builders return `Map<String, dynamic>`
/// (not Dart model instances) so they round-trip through `fromJson` exactly
/// like the network would.
///
/// Add a fixture here only when ≥2 tests need the same shape. One-off shapes
/// belong inline in the test file.
library;

/// `POST auth/login` happy-path response. Real API returns `data` containing
/// `token` + `crew_member`. Test asserts can override individual fields.
Map<String, dynamic> loginResponse({
  String token = 'fake-jwt-token',
  int crewMemberId = 1,
  String email = 'crew@example.com',
  String firstName = 'Test',
  String lastName = 'Crew',
  int isRegistrationComplete = 1,
  int isCrewVerified = 1,
}) => {
  'error': false,
  'message': 'ok',
  'data': {
    'token': token,
    'crew_member': {
      'id': crewMemberId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_registration_complete': isRegistrationComplete,
      'is_crew_verified': isCrewVerified,
    },
  },
};

/// `POST creator/get-profile-detail` happy-path response. Shape mirrors
/// `MyProfileModel.fromJson` — see `lib/model_class/myprofile_model.dart`.
Map<String, dynamic> profileResponse({
  int crewMemberId = 42,
  String firstName = 'Alice',
  String lastName = 'Doe',
  String email = 'alice@example.com',
  String location = 'NYC',
  String workingDistance = 'Upto 50 Miles',
  int yearsOfExperience = 3,
  String hourlyRate = '55',
  int isAvailable = 1,
  String profileImageUrl = '',
  String bio = '',
  String primaryRole = '',
  List<Map<String, dynamic>> skills = const [],
  Map<String, dynamic> socialMediaLinks = const {},
  List<Map<String, dynamic>> featuredWorkFiles = const [],
  List<Map<String, dynamic>> certificateFiles = const [],
  List<Map<String, dynamic>> resumeFiles = const [],
  List<Map<String, dynamic>> portfolioLinks = const [],
}) => {
  'error': false,
  'code': 200,
  'message': 'ok',
  'data': {
    'crew_member_id': crewMemberId,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone_number': '',
    'location': location,
    'working_distance': workingDistance,
    'years_of_experience': yearsOfExperience,
    'hourly_rate': hourlyRate,
    'is_available': isAvailable,
    'profile_image_url': profileImageUrl,
    'bio': bio,
    'primary_role': primaryRole,
    'skills': skills,
    'social_media_links': socialMediaLinks,
    'featured_work_files': featuredWorkFiles,
    'certificate_files': certificateFiles,
    'resume_files': resumeFiles,
    'portfolio_links': portfolioLinks,
    'crew_member_files': const <Map<String, dynamic>>[],
    'equipment_ownership': const <dynamic>[],
    'stats': const <String, dynamic>{},
    'availability': null,
    'user': {
      'id': crewMemberId,
      'name': '$firstName $lastName',
      'email': email,
      'user_type': 2,
      'location': location,
      'latitude': '',
      'longitude': '',
      'phone_number': '',
      'user_profile_image_url': profileImageUrl,
      'hourly_rate': hourlyRate,
      'years_of_experience': yearsOfExperience,
      'bio': bio,
      // `User.fromJson` decodes `primary_role` as JSON if non-null.
      // Keep null in the fixture; tests asserting on this field should
      // pass a JSON-encoded list like `'["1"]'` explicitly.
      'primary_role': null,
      'skills': const <Map<String, dynamic>>[],
      'equipment_ownership': const <dynamic>[],
      'availability': '',
      'certifications': '',
      'social_media_links': socialMediaLinks,
      'is_available': isAvailable,
      'working_distance': workingDistance,
      'profile_image_url': profileImageUrl,
    },
  },
};

/// `GET creator/dashboard-count` happy-path response.
Map<String, dynamic> dashboardCountResponse({
  int completed = 5,
  int upcoming = 3,
  int pending = 2,
  int equipment = 0,
  String completedLabel = '+10% vs last month',
  String upcomingLabel = '+5% vs last month',
  String pendingLabel = '-12% vs last month',
}) => {
  'error': false,
  'message': 'ok',
  'data': {
    'completedShoots': completed,
    'upcomingShoots': upcoming,
    'pendingRequests': pending,
    'equipmentRequests': equipment,
    'percentages': {
      'completedShoots': {'label': completedLabel},
      'upcomingShoots': {'label': upcomingLabel},
      'pendingRequests': {'label': pendingLabel},
    },
  },
};

/// `GET creator/shoot-count` happy-path response.
Map<String, dynamic> shootCountResponse({
  int completed = 10,
  int pending = 4,
  int confirmed = 6,
  int rejected = 1,
}) => {
  'error': false,
  'message': 'ok',
  'data': {
    'completedShoots': completed,
    'pendingRequests': pending,
    'confirmedRequests': confirmed,
    'rejectedRequests': rejected,
  },
};

/// `GET creator/shoots` shape — `data.request` & `data.shoots` lists.
Map<String, dynamic> shootsListResponse({
  List<Map<String, dynamic>>? requests,
  List<Map<String, dynamic>>? shoots,
}) => {
  'error': false,
  'message': 'ok',
  'data': {
    'request': requests ?? [],
    'shoots': shoots ?? (requests == null ? [singleShootJson()] : []),
  },
};

/// Single shoot row used by both `dashboard-details` and `accept-project`
/// flows. Defaults to a pending photo shoot.
Map<String, dynamic> singleShootJson({
  int id = 1,
  int projectId = 7,
  String projectName = 'Skyline Shoot',
  String status = 'pending',
  String shootType = 'Editorial',
  String eventDate = '2026-06-15',
  String startTime = '09:00',
  String endTime = '17:00',
  String eventLocation = 'NYC',
  String contentType = 'photo',
  int totalAmount = 1200,
  int crewAccept = 0,
  bool canTakeAction = true,
  Map<String, dynamic>? cta,
}) => {
  'id': id,
  'project_id': projectId,
  'crew_member_id': 42,
  'project_name': projectName,
  'event_date': eventDate,
  'start_time': startTime,
  'end_time': endTime,
  'event_location': eventLocation,
  'content_type': contentType,
  'shoot_type_id': null,
  'shoot_type': shootType,
  'shoot_type_image_url': '',
  'total_amount': totalAmount,
  'budget': totalAmount,
  'status': status,
  'crew_accept': crewAccept,
  'can_take_action': canTakeAction,
  'cta': cta,
};

/// Stub for an error envelope — any endpoint can return this on failure.
Map<String, dynamic> errorResponse({String message = 'Something went wrong'}) =>
    {'error': true, 'message': message, 'data': null};
