import 'dart:convert';

class Upcomingshootviewmodel {
  final bool error;
  final String message;
  final MyData data;

  Upcomingshootviewmodel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory Upcomingshootviewmodel.fromRawJson(String str) => Upcomingshootviewmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Upcomingshootviewmodel.fromJson(Map<String, dynamic> json) => Upcomingshootviewmodel(
    error: json["error"],
    message: json["message"],
    data: MyData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class MyData {
  final Project project;
  final String paymentStatus;
  final List<TeamMember> teamMembers;
  final TeamSummary teamSummary;
  final ClientContact clientContact;

  MyData({
    required this.project,
    required this.paymentStatus,
    required this.teamMembers,
    required this.teamSummary,
    required this.clientContact,
  });

  factory MyData.fromRawJson(String str) => MyData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyData.fromJson(Map<String, dynamic> json) => MyData(
    project: Project.fromJson(json["project"]),
    paymentStatus: json["payment_status"],
    teamMembers: List<TeamMember>.from(json["team_members"].map((x) => TeamMember.fromJson(x))),
    teamSummary: TeamSummary.fromJson(json["team_summary"]),
    clientContact: ClientContact.fromJson(json["client_contact"]),
  );

  Map<String, dynamic> toJson() => {
    "project": project.toJson(),
    "payment_status": paymentStatus,
    "team_members": List<dynamic>.from(teamMembers.map((x) => x.toJson())),
    "team_summary": teamSummary.toJson(),
    "client_contact": clientContact.toJson(),
  };
}

class ClientContact {
  final String fullName;
  final String email;
  final String phone;

  ClientContact({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory ClientContact.fromRawJson(String str) => ClientContact.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClientContact.fromJson(Map<String, dynamic> json) => ClientContact(
    fullName: json["full_name"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "email": email,
    "phone": phone,
  };
}

class Project {
  final int projectId;
  final String projectName;
  final String status;
  final dynamic imageUrl;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final String shootType;
  final String bookingType;
  final dynamic lastUpdated;
  final int totalTimeDurationHours;
  final int budget;
  final String totalAmount;
  final String idLabel;

  Project({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.imageUrl,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.eventLocation,
    required this.shootType,
    required this.bookingType,
    required this.lastUpdated,
    required this.totalTimeDurationHours,
    required this.budget,
    required this.totalAmount,
    required this.idLabel,
  });

  factory Project.fromRawJson(String str) => Project.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    projectId: json["project_id"],
    projectName: json["project_name"],
    status: json["status"],
    imageUrl: json["image_url"],
    eventDate: DateTime.parse(json["event_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    eventLocation: json["event_location"],
    shootType: json["shoot_type"],
    bookingType: json["booking_type"],
    lastUpdated: json["last_updated"],
    totalTimeDurationHours: json["total_time_duration_hours"],
    budget: json["budget"],
    totalAmount: json["total_amount"],
    idLabel: json["id_label"],
  );

  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "project_name": projectName,
    "status": status,
    "image_url": imageUrl,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "event_location": eventLocation,
    "shoot_type": shootType,
    "booking_type": bookingType,
    "last_updated": lastUpdated,
    "total_time_duration_hours": totalTimeDurationHours,
    "budget": budget,
    "total_amount": totalAmount,
    "id_label": idLabel,
  };
}

class TeamMember {
  final int crewMemberId;
  final String name;
  final String roleName;
  final String profileImageUrl;

  TeamMember({
    required this.crewMemberId,
    required this.name,
    required this.roleName,
    required this.profileImageUrl,
  });

  factory TeamMember.fromRawJson(String str) => TeamMember.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    crewMemberId: json["crew_member_id"],
    name: json["name"],
    roleName: json["role_name"],
    profileImageUrl: json["profile_image_url"],
  );

  Map<String, dynamic> toJson() => {
    "crew_member_id": crewMemberId,
    "name": name,
    "role_name": roleName,
    "profile_image_url": profileImageUrl,
  };
}

class TeamSummary {
  final int assignedCount;
  final int totalRequired;

  TeamSummary({
    required this.assignedCount,
    required this.totalRequired,
  });

  factory TeamSummary.fromRawJson(String str) => TeamSummary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamSummary.fromJson(Map<String, dynamic> json) => TeamSummary(
    assignedCount: json["assigned_count"],
    totalRequired: json["total_required"],
  );

  Map<String, dynamic> toJson() => {
    "assigned_count": assignedCount,
    "total_required": totalRequired,
  };
}
