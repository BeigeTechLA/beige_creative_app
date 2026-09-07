import 'dart:io';

import '../../../../core/session/session_store.dart';

class LoginResult {
  final String token;
  final UserSnapshot? user;
  final int isRegistrationComplete;
  final int isCrewVerified;
  final bool? isStep2Complete;
  final int? crewMemberId;

  const LoginResult({
    required this.token,
    this.user,
    this.isRegistrationComplete = 1,
    this.isCrewVerified = 1,
    this.isStep2Complete,
    this.crewMemberId,
  });
}

class LookupOption {
  final int id;
  final String name;

  const LookupOption({required this.id, required this.name});
}

class Step1Payload {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String location;
  final String workingDistance;
  final double latitude;
  final double longitude;
  final File? profileImage;

  const Step1Payload({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.location,
    required this.workingDistance,
    required this.latitude,
    required this.longitude,
    this.profileImage,
  });
}

class Step2Payload {
  final int crewMemberId;
  final List<int> primaryRoleIds;
  final int yearsOfExperience;
  final double hourlyRate;
  final String bio;
  final List<int> skillIds;
  final List<int> equipmentIds;

  const Step2Payload({
    required this.crewMemberId,
    required this.primaryRoleIds,
    required this.yearsOfExperience,
    required this.hourlyRate,
    required this.bio,
    required this.skillIds,
    required this.equipmentIds,
  });
}

class Step3Payload {
  final int crewMemberId;
  final Map<String, String> socialMediaLinks;
  final List<Map<String, String>> portfolioLinks;
  final List<Map<String, dynamic>> featuredWork;
  final int? resumeFileId;
  final List<int> portfolioFileIds;
  final List<int> certificationFileIds;

  const Step3Payload({
    required this.crewMemberId,
    required this.socialMediaLinks,
    required this.portfolioLinks,
    required this.featuredWork,
    this.resumeFileId,
    this.portfolioFileIds = const [],
    this.certificationFileIds = const [],
  });
}

abstract class AuthRepository {
  /// POST `auth/login`. Throws on non-2xx, missing token, or `error: true`.
  Future<LoginResult> login({required String email, required String password});

  /// POST `auth/forgot-password-check`. Triggers OTP email. Throws on
  /// non-2xx or `error: true`.
  Future<void> requestPasswordReset(String email);

  /// POST `auth/forgot-password-verify-otp`. Throws on non-2xx or invalid OTP.
  Future<void> verifyResetOtp({required String email, required String otp});

  /// POST `auth/reset-password`. Sets a new password after a verified OTP.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  /// POST `auth/register-crew-step1` (multipart). Returns the crew member id.
  Future<int> registerStep1(Step1Payload payload);

  /// POST `auth/register-crew-step2` (JSON).
  Future<void> registerStep2(Step2Payload payload);

  /// POST `auth/register-crew-step3-file` (multipart). Uploads section files
  /// (`file_type`: "resume", "portfolio", "certifications", or "recent_work").
  /// Returns list of uploaded `crew_files_id` integers.
  Future<List<int>> uploadStep3File({
    required int crewMemberId,
    required String fileType,
    required List<File> files,
  });

  /// POST `auth/register-crew-step3` (JSON). Submits crew metadata and file IDs.
  Future<void> registerStep3(Step3Payload payload);

  /// GET `auth/crew-roles`.
  Future<List<LookupOption>> fetchRoles();

  /// GET `auth/skills`.
  Future<List<LookupOption>> fetchSkills();

  /// GET `auth/equipment-autocomplete?query=...`.
  Future<List<LookupOption>> searchEquipments(String query);
}
