import 'dart:convert';

class UpcomingShootsModel {
  final bool error;
  final String message;
  final List<UpcomingShootDatum> data;

  UpcomingShootsModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory UpcomingShootsModel.fromRawJson(String str) => UpcomingShootsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UpcomingShootsModel.fromJson(Map<String, dynamic> json) => UpcomingShootsModel(
    error: json["error"],
    message: json["message"],
    data: List<UpcomingShootDatum>.from(json["data"].map((x) => UpcomingShootDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class UpcomingShootDatum {
  final String shootType;
  final String shootTypeImageUrl;
  final int projectId;
  final String projectName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final dynamic budget;
  final bool isCompleted;

  UpcomingShootDatum({
    required this.shootType,
    required this.shootTypeImageUrl,
    required this.projectId,
    required this.projectName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.eventLocation,
    required this.budget,
    required this.isCompleted,
  });

  factory UpcomingShootDatum.fromRawJson(String str) => UpcomingShootDatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UpcomingShootDatum.fromJson(Map<String, dynamic> json) => UpcomingShootDatum(
    shootType: json["shoot_type"] ?? "",
    shootTypeImageUrl: json["shoot_type_image_url"] ?? "",
    projectId: json["project_id"],
    projectName: json["project_name"],
    eventDate: DateTime.parse(json["event_date"]).toLocal(),
    startTime: json["start_time"],
    endTime: json["end_time"],
    eventLocation: json["event_location"],
    budget: json["budget"],
    isCompleted: json["is_completed"],
  );

  Map<String, dynamic> toJson() => {
    "shoot_type": shootType,
    "shoot_type_image_url": shootTypeImageUrl,
    "project_id": projectId,
    "project_name": projectName,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "event_location": eventLocation,
    "budget": budget,
    "is_completed": isCompleted,
  };
}
