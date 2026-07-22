
import 'cp_profile_model.dart';

class CreatorDashboardDetailsModel {
  final bool error;
  final String message;
  final CreatorDashboardData data;

  CreatorDashboardDetailsModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory CreatorDashboardDetailsModel.fromJson(Map<String, dynamic> json) =>
      CreatorDashboardDetailsModel(
        error: json["error"],
        message: json["message"],
        data: CreatorDashboardData.fromJson(json["data"]),
      );
}

class CreatorDashboardData {
  final List<PendingRequestCard> shoots;

  CreatorDashboardData({required this.shoots});

  factory CreatorDashboardData.fromJson(Map<String, dynamic> json) => CreatorDashboardData(
    shoots: json["shoots"] != null
        ? List<PendingRequestCard>.from(
            json["shoots"].map((x) => PendingRequestCard.fromJson(x)),
          )
        : [],
  );
}

class PendingRequestCard {
  final String shootType;
  final String shootTypeImageUrl;
  final int id;
  final int projectId;
  final int crewMemberId;
  final String projectName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final String contentType;
  final dynamic shootTypeId;
  final int   totalAmount;
  final dynamic budget;
  final String status;
  final int crewAccept;
  final bool canTakeAction;
  final Cta? cta; // ✅ NULL SAFE
  final String requestTimeAgo;
  final List<CpProfile> cpProfiles;

  PendingRequestCard({
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
    required this.totalAmount,
    required this.budget,
    required this.status,
    required this.crewAccept,
    required this.canTakeAction,
    required this.shootType,
    required this.shootTypeImageUrl,
    this.cta,
    this.requestTimeAgo = "",
    this.cpProfiles = const [],
  });

  factory PendingRequestCard.fromJson(Map<String, dynamic> json) =>
      PendingRequestCard(
        shootType: json["shoot_type"] ?? "",
        shootTypeImageUrl: json["shoot_type_image_url"] ?? "",
        id: json["id"] ?? 0,
        projectId: json["project_id"] ?? 0,
        crewMemberId: json["crew_member_id"] ?? 0,
        projectName: json["project_name"] ?? "",
        eventDate: json["event_date"] != null ? DateTime.parse(json["event_date"]).toLocal() : DateTime.now(),
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        eventLocation: json["event_location"] ?? "",
        contentType: json["content_type"] ?? "",
        shootTypeId: json["shoot_type_id"],
        totalAmount: json["total_amount"] ?? 0,

        budget: json["budget"],
        status: json["status"] ?? "",
        crewAccept: json["crew_accept"] ?? 0,
        canTakeAction: json["can_take_action"] ?? false,

        /// ✅ SAFE CTA
        cta: json["cta"] != null ? Cta.fromJson(json["cta"]) : null,
        requestTimeAgo: json["request_time_ago"] ?? "",
        cpProfiles: json["cp_profiles"] != null && json["cp_profiles"] is List
            ? (json["cp_profiles"] as List)
                .whereType<Map<String, dynamic>>()
                .map(CpProfile.fromJson)
                .toList()
            : const [],
      );
}

class Cta {
  final String primary;
  final String secondary;

  Cta({required this.primary, required this.secondary});

  factory Cta.fromJson(Map<String, dynamic> json) =>
      Cta(primary: json["primary"] ?? "", secondary: json["secondary"] ?? "");
}
