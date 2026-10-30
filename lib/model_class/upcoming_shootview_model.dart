import 'dart:convert';

class UpcomingShootViewModel {
  final bool error;
  final String message;
  final MyData data;

  UpcomingShootViewModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory UpcomingShootViewModel.fromRawJson(String str) =>
      UpcomingShootViewModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UpcomingShootViewModel.fromJson(Map<String, dynamic> json) =>
      UpcomingShootViewModel(
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

  factory MyData.fromJson(Map<String, dynamic> json) {
    final rawMembers =
        json["team_members"] ?? json["cp_profiles"] ?? json["cp_profile"];
    final membersList = rawMembers is List
        ? List<TeamMember>.from(
            rawMembers
                .whereType<Map<String, dynamic>>()
                .map(TeamMember.fromJson),
          )
        : <TeamMember>[];

    final summary =
        json["team_summary"] != null && json["team_summary"] is Map<String, dynamic>
            ? TeamSummary.fromJson(json["team_summary"])
            : TeamSummary(
                assignedCount: membersList.length,
                totalRequired: membersList.length,
              );

    return MyData(
      project: Project.fromJson(json["project"] ?? {}),
      paymentStatus: json["payment_state"] ?? json["payment_status"] ?? "",
      teamMembers: membersList,
      teamSummary: summary,
      clientContact: ClientContact.fromJson(json["client_contact"] ?? {}),
    );
  }

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

  factory ClientContact.fromRawJson(String str) =>
      ClientContact.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClientContact.fromJson(Map<String, dynamic> json) => ClientContact(
        fullName: json["full_name"] ?? 'No name found',
        email: json["email"] ?? 'No email found',
        phone: json["phone"] ?? 'No phone number found',
      );

  Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "email": email,
        "phone": phone,
      };
}

class MultiDaySchedule {
  final int dayNumber;
  final String date;
  final String startTime;
  final String endTime;
  final String location;
  final String description;

  const MultiDaySchedule({
    this.dayNumber = 1,
    this.date = '',
    this.startTime = '',
    this.endTime = '',
    this.location = '',
    this.description = '',
  });

  factory MultiDaySchedule.fromJson(Map<String, dynamic> json) {
    return MultiDaySchedule(
      dayNumber: (json['day'] ?? json['day_number'] ?? json['index'] ?? 1) is int
          ? (json['day'] ?? json['day_number'] ?? json['index'] ?? 1) as int
          : int.tryParse((json['day'] ?? json['day_number'] ?? 1).toString()) ?? 1,
      date: json['date']?.toString() ??
          json['event_date']?.toString() ??
          json['day_date']?.toString() ??
          '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      location: json['location']?.toString() ??
          json['event_location']?.toString() ??
          '',
      description: json['description']?.toString() ??
          json['notes']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'day_number': dayNumber,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'location': location,
        'description': description,
      };
}

class Project {
  final int projectId;
  final String projectName;
  final String status;
  final dynamic imageUrl;
  final String? eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final String shootType;
  final String bookingType;
  final dynamic lastUpdated;
  final double totalTimeDurationHours;
  final dynamic budget;
  final dynamic totalAmount;
  final String idLabel;
  final String creativeName;
  final List<MultiDaySchedule> multiDaySchedules;
  final bool isMultiDay;

  Project({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.imageUrl,
    this.eventDate,
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
    this.creativeName = '',
    this.multiDaySchedules = const [],
    this.isMultiDay = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    // 1. Safe extraction of shoot_type (handles Map, List, String, or null)
    String resolvedShootType = '';
    dynamic shootTypeImageUrl;
    final rawShootType = json['shoot_type'];
    if (rawShootType is Map) {
      resolvedShootType = rawShootType['name']?.toString() ??
          rawShootType['shoot_type']?.toString() ??
          rawShootType['title']?.toString() ??
          '';
      shootTypeImageUrl = rawShootType['image_url'] ??
          rawShootType['shoot_type_image_url'] ??
          rawShootType['image'];
    } else if (rawShootType is List && rawShootType.isNotEmpty) {
      final first = rawShootType.first;
      if (first is Map) {
        resolvedShootType = first['name']?.toString() ??
            first['shoot_type']?.toString() ??
            '';
        shootTypeImageUrl = first['image_url'] ?? first['image'];
      } else {
        resolvedShootType = first.toString();
      }
    } else if (rawShootType is String) {
      resolvedShootType = rawShootType;
    } else if (rawShootType != null) {
      resolvedShootType = rawShootType.toString();
    }

    // 2. Safe extraction of multi_day schedules (handles List, Map, or null)
    final List<MultiDaySchedule> parsedMultiDaySchedules = [];
    final rawMultiDay = json['multi_day'] ??
        json['multi_days'] ??
        json['multi_day_schedule'] ??
        json['multi_day_schedules'];

    if (rawMultiDay is List) {
      for (final item in rawMultiDay) {
        if (item is Map<String, dynamic>) {
          parsedMultiDaySchedules.add(MultiDaySchedule.fromJson(item));
        } else if (item is Map) {
          parsedMultiDaySchedules.add(
            MultiDaySchedule.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    } else if (rawMultiDay is Map) {
      final rawSchedules = rawMultiDay['schedules'] ??
          rawMultiDay['dates'] ??
          rawMultiDay['schedule'] ??
          rawMultiDay['items'];
      if (rawSchedules is List) {
        for (final item in rawSchedules) {
          if (item is Map<String, dynamic>) {
            parsedMultiDaySchedules.add(MultiDaySchedule.fromJson(item));
          } else if (item is Map) {
            parsedMultiDaySchedules.add(
              MultiDaySchedule.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      } else {
        parsedMultiDaySchedules.add(
          MultiDaySchedule.fromJson(Map<String, dynamic>.from(rawMultiDay)),
        );
      }
    }

    final isMultiDay = parsedMultiDaySchedules.isNotEmpty ||
        json['is_multi_day'] == true ||
        json['is_multi_day'] == 1 ||
        json['multi_day'] == true ||
        json['multi_day'] == 1 ||
        (json['booking_type']?.toString().toLowerCase().contains('multi') == true);

    return Project(
      projectId: (json['project_id'] is int)
          ? json['project_id'] as int
          : (int.tryParse(json['project_id']?.toString() ?? '') ?? 0),
      projectName: json['project_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      imageUrl: json['image_url'] ??
          json['shoot_type_image_url'] ??
          json['shoot_type_image'] ??
          shootTypeImageUrl,
      eventDate: json['event_date']?.toString(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      eventLocation: (json['event_location'] != null && json['event_location'].toString().isNotEmpty)
          ? json['event_location'].toString()
          : (json['location']?.toString() ?? ''),
      shootType: resolvedShootType,
      bookingType: json['booking_type']?.toString() ?? '',
      lastUpdated: json['last_updated'],
      totalTimeDurationHours: (json['total_time_duration_hours'] is num)
          ? (json['total_time_duration_hours'] as num).toDouble()
          : (double.tryParse(json['total_time_duration_hours']?.toString() ?? '') ?? 0.0),
      budget: json['budget'],
      totalAmount: json['total_amount'],
      idLabel: json['id_label']?.toString() ?? '',
      creativeName: json['creative_name']?.toString() ??
          json['creator_name']?.toString() ??
          json['crew_name']?.toString() ??
          json['assigned_to']?.toString() ??
          '',
      multiDaySchedules: parsedMultiDaySchedules,
      isMultiDay: isMultiDay,
    );
  }

  Map<String, dynamic> toJson() => {
        "project_id": projectId,
        "project_name": projectName,
        "status": status,
        "image_url": imageUrl,
        "event_date": eventDate,
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
        "creative_name": creativeName,
        "multi_day_schedules":
            multiDaySchedules.map((x) => x.toJson()).toList(),
        "is_multi_day": isMultiDay,
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

  factory TeamMember.fromRawJson(String str) =>
      TeamMember.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        crewMemberId:
            json["crew_member_id"] ?? json["id"] ?? json["user_id"] ?? 0,
        name: json["name"] ??
            json["full_name"] ??
            json["first_name"] ??
            "Member",
        roleName: json["role_name"] ?? json["role"] ?? "",
        profileImageUrl: json["profile_image_url"] ??
            json["image_url"] ??
            json["avatar"] ??
            "",
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

  factory TeamSummary.fromRawJson(String str) =>
      TeamSummary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamSummary.fromJson(Map<String, dynamic> json) => TeamSummary(
        assignedCount: json["assigned_count"] ?? json["assigned"] ?? 0,
        totalRequired: json["total_required"] ?? json["total"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "assigned_count": assignedCount,
        "total_required": totalRequired,
      };
}
