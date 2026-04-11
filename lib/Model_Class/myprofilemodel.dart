import 'dart:convert';

SocialMediaLinks _parseSocialLinks(dynamic data) {
if (data == null) {
return SocialMediaLinks(instagram: "");
}

// 🔥 Case 1: String like "[]"
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

// 🔥 Case 2: Proper Map
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

  factory Myprofilemodel.fromRawJson(String str) => Myprofilemodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Myprofilemodel.fromJson(Map<String, dynamic> json) => Myprofilemodel(
    error: json["error"],
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final User user;

  Data({
    required this.user,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
  };
}

class User {
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
  final List<String> skills;
  final List<dynamic> equipmentOwnership;
  final String availability;
  final String certifications;
  final SocialMediaLinks socialMediaLinks;
  final String profileImageUrl;

  User({
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

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"]?.toString() ?? "",
    email: json["email"]?.toString() ?? "",
    userType: json["user_type"] ?? 0,
    location: json["location"]?.toString() ?? "",

    latitude: json["latitude"]?.toString() ?? "",
    longitude: json["longitude"]?.toString() ?? "",

    phoneNumber: json["phone_number"]?.toString() ?? "",
    userProfileImageUrl: json["user_profile_image_url"]?.toString() ?? "",

    hourlyRate: json["hourly_rate"]?.toString() ?? "",
    yearsOfExperience: json["years_of_experience"] ?? 0,

    bio: json["bio"]?.toString() ?? "",
    primaryRole: json["primary_role"]?.toString() ?? "",

    // ✅ FIX skills (int → string)
    skills: json["skills"] == null
        ? []
        : List<String>.from(json["skills"].map((x) => x.toString())),

    equipmentOwnership: json["equipment_ownership"] ?? [],

    availability: json["availability"]?.toString() ?? "",
    certifications: json["certifications"]?.toString() ?? "",

    // ✅ FIX social_media_links (STRING HANDLE)
    socialMediaLinks: _parseSocialLinks(json["social_media_links"]),

    profileImageUrl: json["profile_image_url"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "user_type": userType,
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "phone_number": phoneNumber,
    "user_profile_image_url": userProfileImageUrl,
    "hourly_rate": hourlyRate,
    "years_of_experience": yearsOfExperience,
    "bio": bio,
    "primary_role": primaryRole,
    "skills": List<dynamic>.from(skills.map((x) => x)),
    "equipment_ownership": List<dynamic>.from(equipmentOwnership.map((x) => x)),
    "availability": availability,
    "certifications": certifications,
    "social_media_links": socialMediaLinks.toJson(),
    "profile_image_url": profileImageUrl,
  };
}

class SocialMediaLinks {
  final String instagram;

  SocialMediaLinks({
    required this.instagram,
  });

  factory SocialMediaLinks.fromRawJson(String str) => SocialMediaLinks.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SocialMediaLinks.fromJson(Map<String, dynamic> json) => SocialMediaLinks(
    instagram: json["instagram"],
  );

  Map<String, dynamic> toJson() => {
    "instagram": instagram,
  };
}
