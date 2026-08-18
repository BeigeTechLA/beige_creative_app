import '../repositories/auth_repository.dart';

class SignupStep1Prefill {
  final int? crewMemberId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final String workingDistance;
  final double? latitude;
  final double? longitude;
  final String profileImageUrl;
  final List<LookupOption> primaryRoles;
  final String yearsOfExperience;
  final String hourlyRate;
  final String bio;
  final List<LookupOption> skills;
  final List<LookupOption> equipments;
  final List<Map<String, dynamic>> socialMediaLinks;
  final List<Map<String, dynamic>> portfolioLinks;

  const SignupStep1Prefill({
    this.crewMemberId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.location,
    required this.workingDistance,
    this.latitude,
    this.longitude,
    required this.profileImageUrl,
    this.primaryRoles = const [],
    this.yearsOfExperience = '',
    this.hourlyRate = '',
    this.bio = '',
    this.skills = const [],
    this.equipments = const [],
    this.socialMediaLinks = const [],
    this.portfolioLinks = const [],
  });
}
