import 'dart:convert';

class ShootCountModel {
  final bool error;
  final String message;
  final ShootCountData data;

  ShootCountModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory ShootCountModel.fromRawJson(String str) => ShootCountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShootCountModel.fromJson(Map<String, dynamic> json) => ShootCountModel(
    error: json["error"],
    message: json["message"],
    data: ShootCountData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class ShootCountData {
  final int completedShoots;
  final int pendingRequests;
  final int confirmedRequests;
  final int rejectedRequests;

  ShootCountData({
    required this.completedShoots,
    required this.pendingRequests,
    required this.confirmedRequests,
    required this.rejectedRequests,
  });

  factory ShootCountData.fromRawJson(String str) => ShootCountData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShootCountData.fromJson(Map<String, dynamic> json) => ShootCountData(
    completedShoots: json["completedShoots"],
    pendingRequests: json["pendingRequests"],
    confirmedRequests: json["confirmedRequests"],
    rejectedRequests: json["rejectedRequests"],
  );

  Map<String, dynamic> toJson() => {
    "completedShoots": completedShoots,
    "pendingRequests": pendingRequests,
    "confirmedRequests": confirmedRequests,
    "rejectedRequests": rejectedRequests,
  };
}
