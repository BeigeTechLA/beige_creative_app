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
  final DashboardPercentages? percentages;

  DashboardCountData({
    required this.completedShoots,
    required this.upcomingShoots,
    required this.pendingRequests,
    required this.equipmentRequests,
    this.percentages,
  });

  factory DashboardCountData.fromRawJson(String str) => DashboardCountData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardCountData.fromJson(Map<String, dynamic> json) => DashboardCountData(
    completedShoots: json["completedShoots"],
    upcomingShoots: json["upcomingShoots"],
    pendingRequests: json["pendingRequests"],
    equipmentRequests: json["equipmentRequests"],
    percentages: json["percentages"] == null
        ? null
        : DashboardPercentages.fromJson(json["percentages"]),
  );

  Map<String, dynamic> toJson() => {
    "completedShoots": completedShoots,
    "upcomingShoots": upcomingShoots,
    "pendingRequests": pendingRequests,
    "equipmentRequests": equipmentRequests,
    "percentages": percentages?.toJson(),
  };
}

class DashboardPercentages {
  final PercentageInfo completedShoots;
  final PercentageInfo upcomingShoots;
  final PercentageInfo pendingRequests;

  DashboardPercentages({
    required this.completedShoots,
    required this.upcomingShoots,
    required this.pendingRequests,
  });

  factory DashboardPercentages.fromJson(Map<String, dynamic> json) => DashboardPercentages(
        completedShoots: PercentageInfo.fromJson(json["completedShoots"] ?? {}),
        upcomingShoots: PercentageInfo.fromJson(json["upcomingShoots"] ?? {}),
        pendingRequests: PercentageInfo.fromJson(json["pendingRequests"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "completedShoots": completedShoots.toJson(),
        "upcomingShoots": upcomingShoots.toJson(),
        "pendingRequests": pendingRequests.toJson(),
      };
}

class PercentageInfo {
  final String label;

  PercentageInfo({
    required this.label,
  });

  factory PercentageInfo.fromJson(Map<String, dynamic> json) => PercentageInfo(
        label: json["label"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "label": label,
      };
}
