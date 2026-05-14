import 'dart:convert';

class Upcomingshootsmodel {
  final bool error;
  final String message;
  final List<upcomingdatum> data;

  Upcomingshootsmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Upcomingshootsmodel.fromRawJson(String str) => Upcomingshootsmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Upcomingshootsmodel.fromJson(Map<String, dynamic> json) => Upcomingshootsmodel(
    error: json["error"],
    message: json["message"],
    data: List<upcomingdatum>.from(json["data"].map((x) => upcomingdatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class upcomingdatum {
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

  upcomingdatum({
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

  factory upcomingdatum.fromRawJson(String str) => upcomingdatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory upcomingdatum.fromJson(Map<String, dynamic> json) => upcomingdatum(
    shootType: json["shoot_type"] ?? "",
    shootTypeImageUrl: json["shoot_type_image_url"] ?? "",
    projectId: json["project_id"],
    projectName: json["project_name"],
    eventDate: DateTime.parse(json["event_date"]),
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
