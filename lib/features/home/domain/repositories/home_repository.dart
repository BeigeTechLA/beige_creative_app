import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../model_class/creator_dashboard_model.dart';
import '../../../../model_class/crewstatus_model.dart';
import '../../../../model_class/dashboard_count_model.dart' as dashboard;
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../../model_class/upcoming_shoots_model.dart';

/// Domain contract for Home dashboard data.
abstract class HomeRepository {
  /// GET `creator/dashboard`. Consolidates all dashboard data into a single payload.
  Future<CreatorDashboardPayload> fetchCreatorDashboard({
    required String statsDateFilter,
    String? projectsStatus,
    required int availabilityMonth,
    required int availabilityYear,
    String? projectsDateFilter,
    String? projectsStartDate,
    String? projectsEndDate,
  });
  /// GET `creator/dashboard-count`.
  Future<dashboard.DashboardCountData> fetchDashboardCount();

  /// GET `creator/upcoming-accepted-project`.
  Future<List<UpcomingShootDatum>> fetchUpcomingShoots();

  /// GET `creator/dashboard-details` — returns only pending-status shoots.
  Future<List<PendingRequestCard>> fetchPendingRequests();

  /// GET `creator/get-crew-stats?date_filter=$filter`.
  Future<CrewStatsData> fetchCrewStats(String filter);

  /// GET `creator/shoot-categories?tab=$tab`. Returns the raw `tabs` map
  /// because no dedicated model class exists for this endpoint.
  Future<Map<String, dynamic>> fetchShootCategories(String tab);

  /// POST `creator/availability` with `{month, year}`.
  Future<Map<String, dynamic>> fetchAvailability(int month, int year);

  /// POST `creator/get-profile-detail`.
  Future<profile.MyProfileData> fetchProfile();

  /// POST `creator/accept-project` with `{project_id, crew_accept}`.
  Future<void> acceptDeclineProject(int projectId, int crewAccept);
}
