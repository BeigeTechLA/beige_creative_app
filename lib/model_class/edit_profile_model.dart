
class EditProfileResponse {
  final bool error;
  final int code;
  final String message;
  final EditProfileModel data;

  EditProfileResponse({
    required this.error,
    required this.code,
    required this.message,
    required this.data,
  });

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      error: json["error"] ?? false,
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: EditProfileModel.fromJson(json["data"]),
    );
  }
}

class EditProfileModel {
  final int crewMemberId;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String location;
  final String workingDistance;
  final String primaryRole;
  final int yearsOfExperience;
  final double hourlyRate;
  final String bio;
  final String age; // Added age

  final List<Skill> skills;
  final List<int> skillIds;

  final User user;
  final Stats stats;

  final String profileImageUrl;

  EditProfileModel({
    required this.crewMemberId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.workingDistance,
    required this.primaryRole,
    required this.yearsOfExperience,
    required this.hourlyRate,
    required this.bio,
    required this.age, // Added age
    required this.skills,
    required this.skillIds,
    required this.user,
    required this.stats,
    required this.profileImageUrl,
  });

  factory EditProfileModel.fromJson(Map<String, dynamic> json) {
    return EditProfileModel(
      crewMemberId: json["crew_member_id"] ?? 0,
      userId: json["user_id"] ?? 0,
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phone_number"] ?? "",
      location: json["location"] ?? "",
      workingDistance: json["working_distance"] ?? "",
      primaryRole: json["primary_role"] ?? "",
      yearsOfExperience: json["years_of_experience"] ?? 0,
      hourlyRate:
      double.tryParse(json["hourly_rate"].toString()) ?? 0.0,
      bio: json["bio"] ?? "",
      age: json["age"]?.toString() ?? "", // Added age
      skills: (json["skills"] as List? ?? [])
          .map((e) => Skill.fromJson(e))
          .toList(),
      skillIds: List<int>.from(json["skill_ids"] ?? []),
      user: User.fromJson(json["user"] ?? {}),
      stats: Stats.fromJson(json["stats"] ?? {}),
      profileImageUrl: json["profile_image_url"] ?? "",
    );
  }
}

class Skill {
  final int id;
  final String name;

  Skill({
    required this.id,
    required this.name,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String location;
  final double latitude;
  final double longitude;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phone_number"] ?? "",
      location: json["location"] ?? "",
      latitude:
      double.tryParse(json["latitude"].toString()) ?? 0.0,
      longitude:
      double.tryParse(json["longitude"].toString()) ?? 0.0,
    );
  }
}

class Stats {
  final int hourlyRate;
  final int yearsOfExperience;
  final String workingDistance;
  final int rating;
  final int totalReviews;

  Stats({
    required this.hourlyRate,
    required this.yearsOfExperience,
    required this.workingDistance,
    required this.rating,
    required this.totalReviews,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      hourlyRate: json["hourly_rate"] ?? 0,
      yearsOfExperience: json["years_of_experience"] ?? 0,
      workingDistance: json["working_distance"] ?? "",
      rating: json["rating"] ?? 0,
      totalReviews: json["total_reviews"] ?? 0,
    );
  }
}
