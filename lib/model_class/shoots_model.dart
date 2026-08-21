import 'dart:convert';
import 'cp_profile_model.dart';

ShootsModel shootsModelFromJson(String str) =>
    ShootsModel.fromJson(json.decode(str));

class ShootsModel {
  final bool error;
  final String message;
  final ShootsData data;

  ShootsModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory ShootsModel.fromJson(Map<String, dynamic> json) {
    return ShootsModel(
      error: json["error"] ?? false,
      message: json["message"] ?? "",
      data: ShootsData.fromJson(json["data"] ?? {}),
    );
  }
}

class ShootsData {
  final List<Shoot> requests;
  final List<Shoot> shoots;

  ShootsData({
    this.requests = const [],
    this.shoots = const [],
  });

  List<Shoot> get all => [...requests, ...shoots];

  factory ShootsData.fromJson(Map<String, dynamic> json) {
    return ShootsData(
      requests: json["request"] != null && json["request"] is List
          ? List<Shoot>.from(
              (json["request"] as List).map((x) => Shoot.fromJson(x)),
            )
          : [],
      shoots: json["shoots"] != null && json["shoots"] is List
          ? List<Shoot>.from(
              (json["shoots"] as List).map((x) => Shoot.fromJson(x)),
            )
          : [],
    );
  }
}

class Shoot {
  final int id;
  final int projectId;
  final int crewMemberId;
  final String projectName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final String contentType;

  final int? shootTypeId; // ✅ nullable

  final String shootType;
  final String shootTypeImageUrl;

  final dynamic totalAmount; // ✅ int/string dono handle

  final dynamic budget;
  final String status;
  final int crewAccept;
  final bool canTakeAction;
  final Cta? cta;
  final String requestTimeAgo;
  final List<CpProfile> cpProfiles;

  Shoot({
    required this.id,
    required this.projectId,
    required this.crewMemberId,
    required this.projectName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.eventLocation,
    required this.contentType,
    required this.shootTypeId,
    required this.shootType,
    required this.shootTypeImageUrl,
    required this.totalAmount,
    required this.budget,
    required this.status,
    required this.crewAccept,
    required this.canTakeAction,
    this.cta,
    this.requestTimeAgo = "",
    this.cpProfiles = const [],
  });

  factory Shoot.fromJson(Map<String, dynamic> json) {
    final parsedCpProfiles = json["cp_profiles"] != null && json["cp_profiles"] is List
        ? (json["cp_profiles"] as List)
            .whereType<Map<String, dynamic>>()
            .map(CpProfile.fromJson)
            .toList()
        : <CpProfile>[];

    final rawCrewId = json["crew_member_id"];
    final resolvedCrewId = rawCrewId is int && rawCrewId > 0
        ? rawCrewId
        : (parsedCpProfiles.isNotEmpty ? parsedCpProfiles.first.id : 0);

    return Shoot(
      id: json["id"] ?? json["project_id"] ?? 0,
      projectId: json["project_id"] ?? json["id"] ?? 0,
      crewMemberId: resolvedCrewId,
      projectName: json["project_name"] ?? "",

      eventDate:
          DateTime.tryParse(json["event_date"] ?? "")?.toLocal() ??
              DateTime.now(),

      startTime: json["start_time"] ?? "",
      endTime: json["end_time"] ?? "",
      eventLocation: json["event_location"] ?? "",
      contentType: json["content_type"] ?? "",

      shootTypeId: json["shoot_type_id"], // ✅ null allowed

      shootType: json["shoot_type"] ?? "",
      shootTypeImageUrl:
          json["shoot_type_image_url"] ?? "",

      totalAmount: json["total_amount"] ?? 0, // ✅ direct

      budget: json["budget"],

      status: json["status"] ?? "",

      crewAccept: json["crew_accept"] ?? 0,

      canTakeAction:
          json["can_take_action"] ?? false,

      cta: json["cta"] != null
          ? Cta.fromJson(json["cta"])
          : null,
      requestTimeAgo: json["request_time_ago"] ?? "",
      cpProfiles: parsedCpProfiles,
    );
  }
}
class Cta {
  final String primary;
  final String secondary;

  Cta({
    required this.primary,
    required this.secondary,
  });

  factory Cta.fromJson(Map<String, dynamic> json) {
    return Cta(
      primary: json["primary"] ?? "",
      secondary: json["secondary"] ?? "",
    );
  }
}