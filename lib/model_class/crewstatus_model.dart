
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
  final int photoRejectedShoots;
  final int photoShootRequests;
  final int videoRejectedShoots;
  final int videoShootRequests;

  CrewStatsData({
    required this.completedShoots,
    required this.pendingShoots,
    required this.rejectedShoots,
    required this.shootRequests,
    required this.photographyShoots,
    required this.videographyShoots,
    this.photoRejectedShoots = 0,
    this.photoShootRequests = 0,
    this.videoRejectedShoots = 0,
    this.videoShootRequests = 0,
  });

  factory CrewStatsData.fromJson(Map<String, dynamic> json) =>
      CrewStatsData(
        completedShoots: json["completedShoots"] ?? 0,
        pendingShoots: json["pendingShoots"] ?? 0,
        rejectedShoots: json["rejectedShoots"] ?? 0,
        shootRequests: json["shootRequests"] ?? 0,
        photographyShoots: json["photographyShoots"] ?? 0,
        videographyShoots: json["videographyShoots"] ?? 0,
        photoRejectedShoots: json["photoRejectedShoots"] ?? 0,
        photoShootRequests: json["photoShootRequests"] ?? 0,
        videoRejectedShoots: json["videoRejectedShoots"] ?? 0,
        videoShootRequests: json["videoShootRequests"] ?? 0,
      );
}