
class CrewStatsModel {
  final bool error;
  final String message;
  final CrewStatsData data;

  CrewStatsModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory CrewStatsModel.fromJson(Map<String, dynamic> json) =>
      CrewStatsModel(
        error: json["error"],
        message: json["message"],
        data: CrewStatsData.fromJson(json["data"]),
      );
}

class CrewStatsData {
  final int completedShoots;
  final int pendingShoots;
  final int rejectedShoots;
  final int shootRequests;
  final int photographyShoots;
  final int videographyShoots;

  CrewStatsData({
    required this.completedShoots,
    required this.pendingShoots,
    required this.rejectedShoots,
    required this.shootRequests,
    required this.photographyShoots,
    required this.videographyShoots,
  });

  factory CrewStatsData.fromJson(Map<String, dynamic> json) =>
      CrewStatsData(
        completedShoots: json["completedShoots"] ?? 0,
        pendingShoots: json["pendingShoots"] ?? 0,
        rejectedShoots: json["rejectedShoots"] ?? 0,
        shootRequests: json["shootRequests"] ?? 0,
        photographyShoots: json["photographyShoots"] ?? 0,
        videographyShoots: json["videographyShoots"] ?? 0,
      );
}