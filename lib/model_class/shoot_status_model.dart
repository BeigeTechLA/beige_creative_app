import 'dart:convert';

class ShootStatusModel {
  final bool error;
  final String message;
  final ShootStatusData data;

  ShootStatusModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory ShootStatusModel.fromRawJson(String str) => ShootStatusModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShootStatusModel.fromJson(Map<String, dynamic> json) => ShootStatusModel(
    error: json["error"],
    message: json["message"],
    data: ShootStatusData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class ShootStatusData {
  final int completedShoots;
  final int pendingShoots;
  final int rejectedShoots;
  final int shootRequests;
  final int photographyShoots;
  final int videographyShoots;

  ShootStatusData({
    required this.completedShoots,
    required this.pendingShoots,
    required this.rejectedShoots,
    required this.shootRequests,
    required this.photographyShoots,
    required this.videographyShoots,
  });

  factory ShootStatusData.fromRawJson(String str) => ShootStatusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShootStatusData.fromJson(Map<String, dynamic> json) => ShootStatusData(
    completedShoots: json["completedShoots"],
    pendingShoots: json["pendingShoots"],
    rejectedShoots: json["rejectedShoots"],
    shootRequests: json["shootRequests"],
    photographyShoots: json["photographyShoots"],
    videographyShoots: json["videographyShoots"],
  );

  Map<String, dynamic> toJson() => {
    "completedShoots": completedShoots,
    "pendingShoots": pendingShoots,
    "rejectedShoots": rejectedShoots,
    "shootRequests": shootRequests,
    "photographyShoots": photographyShoots,
    "videographyShoots": videographyShoots,
  };
}
