import 'dart:convert';

/// API sometimes double-encodes strings (e.g. `location` arrives as
/// `"\"Dallas Street...\""`). Strip one layer of wrapping quotes.
String _cleanString(dynamic value) {
  final s = value?.toString() ?? "";
  if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
    return s.substring(1, s.length - 1);
  }
  return s;
}

class CrewFile {
  final int crewFilesId; // 🔥 ADD THIS
  final String fileType;
  final String filePath;
  final String tag;
  final String title;

  CrewFile({
    required this.fileType,
    required this.filePath,
    required this.tag,
    required this.crewFilesId,
    required this.title,
  });

  factory CrewFile.fromJson(Map<String, dynamic> json) => CrewFile(
    crewFilesId: (json["crew_files_id"] as num?)?.toInt() ?? 0, // 🔥 ADD THIS
    fileType: json["file_type"] ?? "",
    filePath: json["file_path"] ?? "",
    tag: json["tag"] ?? "",
    title: json["title"] ?? "",
  );
}

class MyProfileModel {
  final bool error;
  final int code;
  final String message;
  final MyProfileData data;

  MyProfileModel({
    required this.error,
    required this.code,
    required this.message,
    required this.data,
  });

  factory MyProfileModel.fromRawJson(String str) =>
      MyProfileModel.fromJson(json.decode(str));

  factory MyProfileModel.fromJson(Map<String, dynamic> json) => MyProfileModel(
    error: json["error"] ?? false,
    code: (json["code"] as num?)?.toInt() ?? 0,
    message: json["message"] ?? "",
    data: MyProfileData.fromJson(json["data"] ?? {}),
  );
}

class MyProfileData {
  final Map<String, dynamic> stats;
  final List<dynamic> equipmentOwnership;
  final String bio;
  final String primaryRole;
  final int crewMemberId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String location;
  final String workingDistance;
  final int yearsOfExperience;
  final String hourlyRate;
  final int isAvailable;
  final dynamic availability;
  final List<CrewFile> featuredWorkFiles;
  final List<Skill> skills;
  final Map<String, dynamic> socialMediaLinks;
  final List<CrewFile> crewMemberFiles;
  final List<CrewFile> portfolioLinks;
  final List<CrewFile> certificateFiles;
  final List<CrewFile> resumeFiles;
  final String profileImageUrl;
  final User user; // nested

  MyProfileData({
    required this.crewMemberId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.workingDistance,
    required this.yearsOfExperience,
    required this.hourlyRate,
    required this.isAvailable,
    required this.skills,
    required this.socialMediaLinks,
    required this.user,
    required this.crewMemberFiles,
    required this.portfolioLinks,
    required this.primaryRole,
    required this.bio,
    required this.equipmentOwnership,
    required this.availability,
    required this.featuredWorkFiles,
    required this.stats,
    required this.certificateFiles,
    required this.resumeFiles,
    required this.profileImageUrl,
  });

  factory MyProfileData.fromJson(Map<String, dynamic> json) => MyProfileData(
    stats: json["stats"] ?? {},
    availability: json["availability"],
    equipmentOwnership:
        json["equipment_ownership"] is List ? json["equipment_ownership"] : [],
    bio: json["bio"] ?? "",
    primaryRole: json["primary_role"]?.toString() ?? "",
    crewMemberFiles: json["crew_member_files"] is List
        ? List<CrewFile>.from(
            json["crew_member_files"].map((x) => CrewFile.fromJson(x)),
          )
        : [],
    portfolioLinks: json["portfolio_links"] is List
        ? List<CrewFile>.from(
            json["portfolio_links"].map((x) => CrewFile.fromJson(x)),
          )
        : [],
    crewMemberId: (json["crew_member_id"] as num?)?.toInt() ?? 0,
    firstName: json["first_name"] ?? "",
    lastName: json["last_name"] ?? "",
    email: json["email"] ?? "",
    phoneNumber: json["phone_number"] ?? "",
    location: _cleanString(json["location"]),
    workingDistance: json["working_distance"] ?? "",
    yearsOfExperience: (json["years_of_experience"] as num?)?.toInt() ?? 0,
    hourlyRate: json["hourly_rate"]?.toString() ?? "",
    isAvailable: (json["is_available"] as num?)?.toInt() ?? 0,

    // 🔥 ADD THIS
    featuredWorkFiles: json["featured_work_files"] is List
        ? List<CrewFile>.from(
            json["featured_work_files"].map((x) => CrewFile.fromJson(x)),
          )
        : [],
    certificateFiles: json["certificate_files"] is List
        ? List<CrewFile>.from(
            json["certificate_files"].map((x) => CrewFile.fromJson(x)),
          )
        : [],
    resumeFiles: json["resume_files"] is List
        ? List<CrewFile>.from(
            json["resume_files"].map((x) => CrewFile.fromJson(x)),
          )
        : [],
    skills: json["skills"] == null
        ? []
        : List<Skill>.from(json["skills"].map((x) => Skill.fromJson(x))),

    socialMediaLinks: () {
      final raw = json["social_media_links"];
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String && raw.isNotEmpty) {
        try {
          final parsed = jsonDecode(raw);
          if (parsed is List) {
            return Map<String, dynamic>.fromEntries(
              parsed.map((e) => MapEntry(
                e["platform"]?.toString() ?? "",
                e["url"]?.toString() ?? "",
              )),
            );
          }
        } catch (_) {}
      }
      return <String, dynamic>{};
    }(),
    // API may return `user: null`; synthesize from the top-level crew fields
    // so consumers reading `user.*` (screens, session snapshot) keep working.
    user: User.fromJson(
      json["user"] is Map<String, dynamic>
          ? json["user"]
          : <String, dynamic>{
              "id": json["user_id"],
              "name": json["display_name"] ??
                  "${json["first_name"] ?? ""} ${json["last_name"] ?? ""}"
                      .trim(),
              "email": json["email"],
              "phone_number": json["phone_number"],
              "location": json["location"],
              "latitude": json["latitude"],
              "longitude": json["longitude"],
              "working_distance": json["working_distance"],
              "hourly_rate": json["hourly_rate"],
              "years_of_experience": json["years_of_experience"],
              "bio": json["bio"],
              "primary_role": json["primary_role"],
              "is_available": json["is_available"],
              "skills": json["skills"],
              "equipment_ownership": json["equipment_ownership"],
              "certifications": json["certifications"],
              "social_media_links": json["social_media_links"],
              "profile_image_url": json["profile_image_url"],
              "user_profile_image_url": json["profile_image_url"],
            },
    ),
    profileImageUrl: json["profile_image_url"]?.toString() ?? "",
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

  /// ✅ SKILLS
  final List<Skill> skills;

  final List<dynamic> equipmentOwnership;
  final String availability;
  final String certifications;

  /// 🔥 IMPORTANT CHANGE (dynamic map)
  final Map<String, dynamic> socialMediaLinks;
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
    isAvailable: (json["is_available"] as num?)?.toInt() ?? 0,
    workingDistance: json["working_distance"]?.toString() ?? "",
    id: (json["id"] as num?)?.toInt() ?? 0,
    name: json["name"]?.toString() ?? "",
    email: json["email"]?.toString() ?? "",
    userType: (json["user_type"] as num?)?.toInt() ?? 0,
    location: _cleanString(json["location"]),
    latitude: json["latitude"]?.toString() ?? "",
    longitude: json["longitude"]?.toString() ?? "",
    phoneNumber: json["phone_number"]?.toString() ?? "",
    userProfileImageUrl: json["user_profile_image_url"]?.toString() ?? "",
    hourlyRate: json["hourly_rate"]?.toString() ?? "",
    yearsOfExperience: (json["years_of_experience"] as num?)?.toInt() ?? 0,
    bio: json["bio"]?.toString() ?? "",
    primaryRole: () {
      final raw = json["primary_role"];
      if (raw == null) return "";
      if (raw is List) return raw.join(", ");
      if (raw is String) {
        try {
          final parsed = jsonDecode(raw);
          if (parsed is List) return parsed.join(", ");
        } catch (_) {}
        return raw;
      }
      return raw.toString();
    }(),

    /// 🔥 SKILLS FIX
    skills: json["skills"] is List
        ? List<Skill>.from(json["skills"].map((x) => Skill.fromJson(x)))
        : [],

    equipmentOwnership:
        json["equipment_ownership"] is List ? json["equipment_ownership"] : [],
    availability: json["availability"]?.toString() ?? "",
    certifications: json["certifications"] is List
        ? (json["certifications"] as List).join(", ")
        : json["certifications"]?.toString() ?? "",

    /// 🔥 MAIN FIX (dynamic social links)
    socialMediaLinks: () {
      final raw = json["social_media_links"];
      if (raw is Map) return Map<String, dynamic>.from(raw);
      if (raw is String && raw.isNotEmpty) {
        try {
          final parsed = jsonDecode(raw);
          if (parsed is List) {
            return Map<String, dynamic>.fromEntries(
              parsed.map((e) => MapEntry(
                e["platform"]?.toString() ?? "",
                e["url"]?.toString() ?? "",
              )),
            );
          }
        } catch (_) {}
      }
      return <String, dynamic>{};
    }(),
    profileImageUrl: json["profile_image_url"]?.toString() ?? "",
  );
}

class Skill {
  final int id;
  final String name;

  Skill({required this.id, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) =>
      Skill(
        id: (json["id"] as num?)?.toInt() ?? 0,
        name: json["name"]?.toString() ?? "",
      );
}
