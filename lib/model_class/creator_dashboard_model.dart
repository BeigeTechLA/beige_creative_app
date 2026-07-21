import 'dart:convert';

import '../features/meetings/data/dto/meeting_dto.dart';
import '../features/meetings/domain/models/meeting.dart';
import 'create_dashboard_details_model.dart';
import 'crewstatus_model.dart';
import 'dashboard_count_model.dart' as dashboard;
import 'myprofile_model.dart' as profile;
import 'upcoming_shoots_model.dart';

class CreatorDashboardModel {
  final bool error;
  final String message;
  final CreatorDashboardPayload data;

  CreatorDashboardModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory CreatorDashboardModel.fromRawJson(String str) =>
      CreatorDashboardModel.fromJson(json.decode(str) as Map<String, dynamic>);

  factory CreatorDashboardModel.fromJson(Map<String, dynamic> json) =>
      CreatorDashboardModel(
        error: json["error"] as bool? ?? false,
        message: json["message"] as String? ?? "",
        data: json["data"] != null
            ? CreatorDashboardPayload.fromJson(json["data"] as Map<String, dynamic>)
            : CreatorDashboardPayload.empty(),
      );
}

class CreatorDashboardPayload {
  final dashboard.DashboardCountData? dashboardCounts;
  final List<UpcomingShootDatum>? upcomingShoots;
  final List<PendingRequestCard>? pendingRequests;
  final CrewStatsData? crewStats;
  final Map<String, dynamic>? shootCategories;
  final Map<String, dynamic>? availability;
  final profile.MyProfileData? profileDetail;
  final List<Meeting>? upcomingMeetings;
  final List<String> failedSections;

  CreatorDashboardPayload({
    this.dashboardCounts,
    this.upcomingShoots,
    this.pendingRequests,
    this.crewStats,
    this.shootCategories,
    this.availability,
    this.profileDetail,
    this.upcomingMeetings,
    this.failedSections = const [],
  });

  factory CreatorDashboardPayload.empty() => CreatorDashboardPayload();

  factory CreatorDashboardPayload.fromJson(Map<String, dynamic> json) {
    // 1. Dashboard counts
    dashboard.DashboardCountData? counts;
    if (json['dashboard_counts'] is Map<String, dynamic>) {
      try {
        counts = dashboard.DashboardCountData.fromJson(
          json['dashboard_counts'] as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    // 2. Upcoming shoots
    List<UpcomingShootDatum>? upcoming;
    final upcomingRaw =
        json['upcoming_accepted_projects'] ?? json['upcoming_accepted_project'];
    if (upcomingRaw is List) {
      try {
        upcoming = upcomingRaw
            .whereType<Map<String, dynamic>>()
            .map(UpcomingShootDatum.fromJson)
            .toList();
      } catch (_) {}
    }

    // 3. Pending requests (from dashboard_details -> shoots)
    List<PendingRequestCard>? pending;
    if (json['dashboard_details'] is Map<String, dynamic>) {
      final detailsMap = json['dashboard_details'] as Map<String, dynamic>;
      if (detailsMap['shoots'] is List) {
        try {
          pending = (detailsMap['shoots'] as List)
              .whereType<Map<String, dynamic>>()
              .map(PendingRequestCard.fromJson)
              .where(
                (e) => e.status
                    .toString()
                    .trim()
                    .toLowerCase()
                    .contains('pending'),
              )
              .toList();
        } catch (_) {}
      }
    }

    // 4. Crew stats
    CrewStatsData? stats;
    if (json['crew_stats'] is Map<String, dynamic>) {
      try {
        stats = CrewStatsData.fromJson(
          json['crew_stats'] as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    // 5. Shoot categories
    Map<String, dynamic>? categories;
    if (json['shoot_categories'] is Map<String, dynamic>) {
      final catObj = json['shoot_categories'] as Map<String, dynamic>;
      final tabs = catObj['tabs'];
      if (tabs is Map<String, dynamic>) {
        categories = tabs;
      } else {
        categories = catObj;
      }
    }

    // 6. Availability
    Map<String, dynamic>? availMap;
    if (json['availability'] is Map<String, dynamic>) {
      final availObj = json['availability'] as Map<String, dynamic>;
      final innerAvail = availObj['availability'];
      if (innerAvail is Map<String, dynamic>) {
        availMap = innerAvail;
      }
    }

    // 7. Profile detail
    profile.MyProfileData? profileData;
    if (json['profile_detail'] is Map<String, dynamic>) {
      try {
        profileData = profile.MyProfileData.fromJson(
          json['profile_detail'] as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    // 8. Upcoming meetings
    List<Meeting>? meetings;
    if (json['upcoming_meetings'] is Map<String, dynamic>) {
      final meetingsObj = json['upcoming_meetings'] as Map<String, dynamic>;
      final results = meetingsObj['results'];
      if (results is List) {
        try {
          meetings = results
              .whereType<Map<String, dynamic>>()
              .map((e) => MeetingDto.fromRestJson(e))
              .toList();
        } catch (_) {}
      }
    }

    // 9. Failed sections
    final failed = (json['failed_sections'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return CreatorDashboardPayload(
      dashboardCounts: counts,
      upcomingShoots: upcoming,
      pendingRequests: pending,
      crewStats: stats,
      shootCategories: categories,
      availability: availMap,
      profileDetail: profileData,
      upcomingMeetings: meetings,
      failedSections: failed,
    );
  }
}
