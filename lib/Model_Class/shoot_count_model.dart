import 'dart:convert';

class Shootcountmodel {
  final bool error;
  final String message;
  final Data data;

  Shootcountmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Shootcountmodel.fromRawJson(String str) => Shootcountmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Shootcountmodel.fromJson(Map<String, dynamic> json) => Shootcountmodel(
    error: json["error"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final int completedShoots;
  final int pendingRequests;
  final int confirmedRequests;
  final int rejectedRequests;

  Data({
    required this.completedShoots,
    required this.pendingRequests,
    required this.confirmedRequests,
    required this.rejectedRequests,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
