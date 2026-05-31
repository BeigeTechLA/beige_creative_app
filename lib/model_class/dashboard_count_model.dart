import 'dart:convert';

class DashboardCountModel {
  final bool error;
  final String message;
  final DashboardCountData data;

  DashboardCountModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory DashboardCountModel.fromRawJson(String str) => DashboardCountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardCountModel.fromJson(Map<String, dynamic> json) => DashboardCountModel(
    error: json["error"],
    message: json["message"],
    data: DashboardCountData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };

  void operator [](String other) {}
}

class DashboardCountData {
  final int completedShoots;
  final int upcomingShoots;
  final int pendingRequests;
  final int equipmentRequests;

  DashboardCountData({
    required this.completedShoots,
    required this.upcomingShoots,
    required this.pendingRequests,
    required this.equipmentRequests,
  });

  factory DashboardCountData.fromRawJson(String str) => DashboardCountData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardCountData.fromJson(Map<String, dynamic> json) => DashboardCountData(
    completedShoots: json["completedShoots"],
    upcomingShoots: json["upcomingShoots"],
    pendingRequests: json["pendingRequests"],
    equipmentRequests: json["equipmentRequests"],
  );

  Map<String, dynamic> toJson() => {
    "completedShoots": completedShoots,
    "upcomingShoots": upcomingShoots,
    "pendingRequests": pendingRequests,
    "equipmentRequests": equipmentRequests,
  };
}
