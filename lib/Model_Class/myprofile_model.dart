import 'dart:convert';

class CrewFile {
  final int crewFilesId; // 🔥 ADD THIS
  final String fileType;
  final String filePath;
  final String tag;
  final String title;


  CrewFile({
    required this.fileType,
    required this.filePath,
    required this.tag, required this.crewFilesId,
    required this.title,
  });

  factory CrewFile.fromJson(Map<String, dynamic> json) => CrewFile(
    crewFilesId: json["crew_files_id"] ?? 0, // 🔥 ADD THIS
    fileType: json["file_type"] ?? "",
    filePath: json["file_path"] ?? "",
    tag: json["tag"] ?? "",
    title: json["title"] ?? "",
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
  final List<CrewFile> certificateFiles;
  final List<CrewFile> resumeFiles;
  final String profileImageUrl;
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    stats: json["stats"] ?? {},
    availability: json["availability"],
    equipmentOwnership: json["equipment_ownership"] ?? [],
    bio: json["bio"] ?? "",
    primaryRole: json["primary_role"]?.toString() ?? "",
    crewMemberFiles: json["crew_member_files"] is List
        ? List<CrewFile>.from(
      json["crew_member_files"].map((x) => CrewFile.fromJson(x)),
    )
        : [],
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
        : List<Skill>.from(
      json["skills"].map((x) => Skill.fromJson(x)),
    ),

    socialMediaLinks: json["social_media_links"] is Map
        ? Map<String, dynamic>.from(json["social_media_links"])
        : {},
    user: User.fromJson(json["user"] ?? {}),
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
    primaryRole: json["primary_role"] != null
        ? (jsonDecode(json["primary_role"]) as List).join(", ")
        : "",


    /// 🔥 SKILLS FIX
    skills: json["skills"] is List
        ? List<Skill>.from(
      json["skills"].map((x) => Skill.fromJson(x)),
    )
        : [],

    equipmentOwnership: json["equipment_ownership"] ?? [],
    availability: json["availability"]?.toString() ?? "",
    certifications: json["certifications"] is List
        ? (json["certifications"] as List).join(", ")
        : json["certifications"]?.toString() ?? "",

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