import 'dart:convert';

class CpProfile {
  final int id;
  final String name;
  final String roleName;
  final String profileImageUrl;

  CpProfile({
    required this.id,
    required this.name,
    required this.roleName,
    required this.profileImageUrl,
  });

  factory CpProfile.fromRawJson(String str) =>
      CpProfile.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory CpProfile.fromJson(Map<String, dynamic> json) => CpProfile(
        id: json["id"] ?? json["crew_member_id"] ?? json["user_id"] ?? 0,
        name: json["name"] ??
            json["full_name"] ??
            json["first_name"] ??
            "Member",
        roleName: json["role_name"] ?? json["role"] ?? "",
        profileImageUrl: json["profile_image_url"] ??
            json["image_url"] ??
            json["avatar"] ??
            "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role_name": roleName,
        "profile_image_url": profileImageUrl,
      };
}
