import 'dart:convert';

ShootsModel shootsModelFromJson(String str) =>
    ShootsModel.fromJson(json.decode(str));

class ShootsModel {
  final bool error;
  final String message;
  final Data data;

  ShootsModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory ShootsModel.fromJson(Map<String, dynamic> json) {
    return ShootsModel(
      error: json["error"] ?? false,
      message: json["message"] ?? "",
      data: Data.fromJson(json["data"] ?? {}),
    );
  }
}

class Data {
  final List<Shoot> shoots;

  Data({required this.shoots});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      shoots: json["shoots"] != null
          ? List<Shoot>.from(
          json["shoots"].map((x) => Shoot.fromJson(x)))
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
  final int shootTypeId;
  final String shootType;
  final String shootTypeImageUrl;
  final String totalAmount;
  final dynamic budget;
  final String status;
  final int crewAccept;
  final bool canTakeAction;
  final Cta? cta;

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
  });

  factory Shoot.fromJson(Map<String, dynamic> json) {
    return Shoot(
      id: json["id"] ?? 0,
      projectId: json["project_id"] ?? 0,
      crewMemberId: json["crew_member_id"] ?? 0,
      projectName: json["project_name"] ?? "",
      eventDate:
      DateTime.tryParse(json["event_date"] ?? "") ?? DateTime.now(),
      startTime: json["start_time"] ?? "",
      endTime: json["end_time"] ?? "",
      eventLocation: json["event_location"] ?? "",
      contentType: json["content_type"] ?? "",
      shootTypeId: json["shoot_type_id"] ?? 0,
      shootType: json["shoot_type"] ?? "",
      shootTypeImageUrl: json["shoot_type_image_url"] ?? "",
      totalAmount: json["total_amount"] ?? "0",
      budget: json["budget"],
      status: json["status"] ?? "",
      crewAccept: json["crew_accept"] ?? 0,
      canTakeAction: json["can_take_action"] ?? false,
      cta: json["cta"] != null ? Cta.fromJson(json["cta"]) : null,
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