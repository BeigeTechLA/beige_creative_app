import 'dart:convert';

class Shootstatusmodel {
  final bool error;
  final String message;
  final shootstatusdata data;

  Shootstatusmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Shootstatusmodel.fromRawJson(String str) => Shootstatusmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Shootstatusmodel.fromJson(Map<String, dynamic> json) => Shootstatusmodel(
    error: json["error"],
    message: json["message"],
    data: shootstatusdata.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class shootstatusdata {
  final int completedShoots;
  final int pendingShoots;
  final int rejectedShoots;
  final int shootRequests;
  final int photographyShoots;
  final int videographyShoots;

  shootstatusdata({
    required this.completedShoots,
    required this.pendingShoots,
    required this.rejectedShoots,
    required this.shootRequests,
    required this.photographyShoots,
    required this.videographyShoots,
  });

  factory shootstatusdata.fromRawJson(String str) => shootstatusdata.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory shootstatusdata.fromJson(Map<String, dynamic> json) => shootstatusdata(
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
