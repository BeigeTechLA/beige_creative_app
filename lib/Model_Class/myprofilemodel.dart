import 'dart:convert';

class CrewFile {
  final int crewFilesId; // 🔥 ADD THIS
  final String fileType;
  final String filePath;
  final String tag;

  CrewFile({
    required this.fileType,
    required this.filePath,
    required this.tag, required this.crewFilesId,
  });

  factory CrewFile.fromJson(Map<String, dynamic> json) => CrewFile(
    crewFilesId: json["crew_files_id"] ?? 0, // 🔥 ADD THIS
    fileType: json["file_type"] ?? "",
    filePath: json["file_path"] ?? "",
    tag: json["tag"] ?? "",
  );
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

  final List<Skill> skills;
  final Map<String, dynamic> socialMediaLinks;
  final List<CrewFile> crewMemberFiles;

  final User user; // nested

  Data({
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
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    crewMemberFiles: json["crew_member_files"] == null
        ? []
        : List<CrewFile>.from(
      json["crew_member_files"].map((x) => CrewFile.fromJson(x)),
    ),
    crewMemberId: json["crew_member_id"] ?? 0,
    firstName: json["first_name"] ?? "",
    lastName: json["last_name"] ?? "",
    email: json["email"] ?? "",
    phoneNumber: json["phone_number"] ?? "",
    location: json["location"] ?? "",
    workingDistance: json["working_distance"] ?? "",
    yearsOfExperience: json["years_of_experience"] ?? 0,
    hourlyRate: json["hourly_rate"]?.toString() ?? "",
    isAvailable: json["is_available"] ?? 0,

    skills: json["skills"] == null
        ? []
        : List<Skill>.from(
      json["skills"].map((x) => Skill.fromJson(x)),
    ),

    socialMediaLinks: json["social_media_links"] != null
        ? Map<String, dynamic>.from(json["social_media_links"])
        : {},

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

    /// 🔥 SKILLS FIX
    skills: json["skills"] == null
        ? []
        : List<Skill>.from(
      json["skills"].map((x) => Skill.fromJson(x)),
    ),

    equipmentOwnership: json["equipment_ownership"] ?? [],
    availability: json["availability"]?.toString() ?? "",
    certifications: json["certifications"]?.toString() ?? "",

    /// 🔥 MAIN FIX (dynamic social links)
    socialMediaLinks: json["social_media_links"] != null
        ? Map<String, dynamic>.from(json["social_media_links"])
        : {},

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