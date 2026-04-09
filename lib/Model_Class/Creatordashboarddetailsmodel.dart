import 'dart:convert';

class Creatordashboarddetailsmodel {
  final bool error;
  final String message;
  final Data data;

  Creatordashboarddetailsmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Creatordashboarddetailsmodel.fromRawJson(String str) => Creatordashboarddetailsmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Creatordashboarddetailsmodel.fromJson(Map<String, dynamic> json) => Creatordashboarddetailsmodel(
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
  final List<PendingRequestCard> pendingRequestCards;

  Data({
    required this.pendingRequestCards,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pendingRequestCards: List<PendingRequestCard>.from(json["pendingRequestCards"].map((x) => PendingRequestCard.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pendingRequestCards": List<dynamic>.from(pendingRequestCards.map((x) => x.toJson())),
  };
}

class PendingRequestCard {
  final int id;
  final int projectId;
  final int crewMemberId;
  final String projectName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final String contentType;
  final dynamic shootTypeId;
  final String totalAmount;
  final dynamic budget;
  final String status;
  final int crewAccept;
  final Cta cta;

  PendingRequestCard({
    required this.id,
    required this.projectId,
    required this.crewMemberId,
    required this.projectName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.eventLocation,
    required this.contentType,
    required this.shootTypeId,
    required this.totalAmount,
    required this.budget,
    required this.status,
    required this.crewAccept,
    required this.cta,
  });

  factory PendingRequestCard.fromRawJson(String str) => PendingRequestCard.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PendingRequestCard.fromJson(Map<String, dynamic> json) => PendingRequestCard(
    id: json["id"],
    projectId: json["project_id"],
    crewMemberId: json["crew_member_id"],
    projectName: json["project_name"],
    eventDate: DateTime.parse(json["event_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    eventLocation: json["event_location"],
    contentType: json["content_type"],
    shootTypeId: json["shoot_type_id"],
    totalAmount: json["total_amount"],
    budget: json["budget"],
    status: json["status"],
    crewAccept: json["crew_accept"],
    cta: Cta.fromJson(json["cta"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "project_id": projectId,
    "crew_member_id": crewMemberId,
    "project_name": projectName,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "event_location": eventLocation,
    "content_type": contentType,
    "shoot_type_id": shootTypeId,
    "total_amount": totalAmount,
    "budget": budget,
    "status": status,
    "crew_accept": crewAccept,
    "cta": cta.toJson(),
  };
}

class Cta {
  final String primary;
  final String secondary;

  Cta({
    required this.primary,
    required this.secondary,
  });

  factory Cta.fromRawJson(String str) => Cta.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Cta.fromJson(Map<String, dynamic> json) => Cta(
    primary: json["primary"],
    secondary: json["secondary"],
  );

  Map<String, dynamic> toJson() => {
    "primary": primary,
    "secondary": secondary,
  };
}
