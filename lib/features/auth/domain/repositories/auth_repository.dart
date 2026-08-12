import 'dart:io';

import '../../../../core/session/session_store.dart';

class LoginResult {
  final String token;
  final UserSnapshot? user;
  final int isRegistrationComplete;
  final int isCrewVerified;
  final int? crewMemberId;

  const LoginResult({
    required this.token,
    this.user,
    this.isRegistrationComplete = 1,
    this.isCrewVerified = 1,
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
  final File profileImage;

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
    required this.profileImage,
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
  final List<Map<String, String>> socialMediaLinks;
  final List<Map<String, String>> portfolioLinks;
  final List<Map<String, dynamic>> featuredWork;
  final List<File> certificationFiles;
  final File? resume;
  final File? portfolio;
  final List<File> recentWorkMediaFiles;
  final List<int> recentWorkMediaIndexes;

  const Step3Payload({
    required this.crewMemberId,
    required this.socialMediaLinks,
    required this.portfolioLinks,
    required this.featuredWork,
    required this.certificationFiles,
    required this.resume,
    required this.portfolio,
    required this.recentWorkMediaFiles,
    required this.recentWorkMediaIndexes,
  });
}

abstract class AuthRepository {
  /// POST `auth/login`. Throws on non-2xx, missing token, or `error: true`.
  Future<LoginResult> login({
    required String email,
    required String password,
  });

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

  /// POST `auth/register-crew-step3` (multipart). Uploads resume, portfolio,
  /// certifications, and recent-work media + paired indexes.
  Future<void> registerStep3(Step3Payload payload);

  /// GET `auth/crew-roles`.
  Future<List<LookupOption>> fetchRoles();

  /// GET `auth/skills`.
  Future<List<LookupOption>> fetchSkills();

  /// GET `auth/equipment-autocomplete?query=...`.
  Future<List<LookupOption>> searchEquipments(String query);
}
