import 'dart:convert';

class Dashboardcountmodel {
  final bool error;
  final String message;
  final Data data;

  Dashboardcountmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Dashboardcountmodel.fromRawJson(String str) => Dashboardcountmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Dashboardcountmodel.fromJson(Map<String, dynamic> json) => Dashboardcountmodel(
    error: json["error"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };

  void operator [](String other) {}
}

class Data {
  final int completedShoots;
  final int upcomingShoots;
  final int pendingRequests;
  final int equipmentRequests;

  Data({
    required this.completedShoots,
    required this.upcomingShoots,
    required this.pendingRequests,
    required this.equipmentRequests,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
