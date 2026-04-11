import 'dart:convert';

SocialMediaLinks _parseSocialLinks(dynamic data) {
  if (data == null) {
    return SocialMediaLinks(instagram: "");
  }

  if (data is String) {
    try {
      final decoded = json.decode(data);
      if (decoded is Map<String, dynamic>) {
        return SocialMediaLinks.fromJson(decoded);
      }
    } catch (e) {
      return SocialMediaLinks(instagram: "");
    }
  }

  if (data is Map<String, dynamic>) {
    return SocialMediaLinks.fromJson(data);
  }

  return SocialMediaLinks(instagram: "");
}

class Myprofilemodel {
  final bool error;
  final int code;
  final String message;
  final Data data;

  Myprofilemodel({
    required this.error,
    required this.code,
    required this.message,
    required this.data,
  });

  factory Myprofilemodel.fromRawJson(String str) =>
      Myprofilemodel.fromJson(json.decode(str));

  factory Myprofilemodel.fromJson(Map<String, dynamic> json) =>
      Myprofilemodel(
        error: json["error"] ?? false,
        code: json["code"] ?? 0,
        message: json["message"] ?? "",
        data: Data.fromJson(json["data"] ?? {}),
      );
}

class Data {
  final User user;

  Data({
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: User.fromJson(json["user"] ?? {}),
  );
}

class User {
  final int isAvailable;
  final String workingDistance;
  final int id;
  final String name;
  final String email;
  final int userType;
  final String location;
  final String latitude;
  final String longitude;
  final String phoneNumber;
  final String userProfileImageUrl;
  final String hourlyRate;
  final int yearsOfExperience;
  final String bio;
  final String primaryRole;

  /// 🔥 UPDATED
  final List<Skill> skills;

  final List<dynamic> equipmentOwnership;
  final String availability;
  final String certifications;
  final SocialMediaLinks socialMediaLinks;
  final String profileImageUrl;

  User({
    required this.isAvailable,
    required this.workingDistance,
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.userProfileImageUrl,
    required this.hourlyRate,
    required this.yearsOfExperience,
    required this.bio,
    required this.primaryRole,
    required this.skills,
    required this.equipmentOwnership,
    required this.availability,
    required this.certifications,
    required this.socialMediaLinks,
    required this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    isAvailable: json["is_available"] ?? 0,
    workingDistance: json["working_distance"]?.toString() ?? "",
    id: json["id"] ?? 0,
    name: json["name"]?.toString() ?? "",
    email: json["email"]?.toString() ?? "",
    userType: json["user_type"] ?? 0,
    location: json["location"]?.toString() ?? "",
    latitude: json["latitude"]?.toString() ?? "",
    longitude: json["longitude"]?.toString() ?? "",
    phoneNumber: json["phone_number"]?.toString() ?? "",
    userProfileImageUrl:
    json["user_profile_image_url"]?.toString() ?? "",
    hourlyRate: json["hourly_rate"]?.toString() ?? "",
    yearsOfExperience: json["years_of_experience"] ?? 0,
    bio: json["bio"]?.toString() ?? "",
    primaryRole: json["primary_role"]?.toString() ?? "",

    /// 🔥 FIXED SKILLS
    skills: json["skills"] == null
        ? []
        : List<Skill>.from(
      json["skills"].map((x) => Skill.fromJson(x)),
    ),

    equipmentOwnership: json["equipment_ownership"] ?? [],
    availability: json["availability"]?.toString() ?? "",
    certifications: json["certifications"]?.toString() ?? "",

    /// 🔥 SAFE PARSE
    socialMediaLinks: _parseSocialLinks(json["social_media_links"]),

    profileImageUrl: json["profile_image_url"]?.toString() ?? "",
  );
}

class Skill {
  final int id;
  final String name;

  Skill({
    required this.id,
    required this.name,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
  );
}

class SocialMediaLinks {
  final String instagram;

  SocialMediaLinks({
    required this.instagram,
  });

  factory SocialMediaLinks.fromJson(Map<String, dynamic> json) =>
      SocialMediaLinks(
        instagram: json["instagram"] ?? "",
      );
}