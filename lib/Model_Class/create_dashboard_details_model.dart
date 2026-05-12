import 'dart:convert';

class Creatordashboarddetailsmodel {
  final bool error;
  final String message;
  final Data data;

  Creatordashboarddetailsmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Creatordashboarddetailsmodel.fromJson(Map<String, dynamic> json) =>
      Creatordashboarddetailsmodel(
        error: json["error"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );
}

class Data {
  final List<PendingRequestCard> shoots;

  Data({
    required this.shoots,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
  final String totalAmount;
  final dynamic budget;
  final String status;
  final int crewAccept;
  final Cta? cta; // ✅ NULL SAFE

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
    required this.shootType,
    required this.shootTypeImageUrl,
    this.cta,
  });

  factory PendingRequestCard.fromJson(Map<String, dynamic> json) =>
      PendingRequestCard(
        shootType: json["shoot_type"] ?? "",
        shootTypeImageUrl: json["shoot_type_image_url"] ?? "",
        id: json["id"] ?? 0,
        projectId: json["project_id"] ?? 0,
        crewMemberId: json["crew_member_id"] ?? 0,
        projectName: json["project_name"] ?? "",
        eventDate: DateTime.parse(json["event_date"]),
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        eventLocation: json["event_location"] ?? "",
        contentType: json["content_type"] ?? "",
        shootTypeId: json["shoot_type_id"],
        totalAmount: json["total_amount"] ?? "0",
        budget: json["budget"],
        status: json["status"] ?? "",
        crewAccept: json["crew_accept"] ?? 0,

        /// ✅ SAFE CTA
        cta: json["cta"] != null ? Cta.fromJson(json["cta"]) : null,
      );
}

class Cta {
  final String primary;
  final String secondary;

  Cta({
    required this.primary,
    required this.secondary,
  });

  factory Cta.fromJson(Map<String, dynamic> json) => Cta(
    primary: json["primary"] ?? "",
    secondary: json["secondary"] ?? "",
  );
}