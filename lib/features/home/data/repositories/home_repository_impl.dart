import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../model_class/crewstatus_model.dart';
import '../../../../model_class/dashboard_count_model.dart' as dashboard;
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../../model_class/upcoming_shoots_model.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final DioClient _client;

  const HomeRepositoryImpl(this._client);

  @override
  Future<dashboard.Data> fetchDashboardCount() async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.dashboardcount);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Dashboard count returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load dashboard count');
    }
    return dashboard.Dashboardcountmodel.fromJson(data).data;
  }

  @override
  Future<List<upcomingdatum>> fetchUpcomingShoots() async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.upcomingshoots);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Upcoming shoots returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load upcoming shoots');
    }
    return Upcomingshootsmodel.fromJson(data).data;
  }

  @override
  Future<List<PendingRequestCard>> fetchPendingRequests() async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.creatordashboarddetails);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Dashboard details returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load dashboard details');
    }
    final model = Creatordashboarddetailsmodel.fromJson(data);
    return model.data.shoots
        .where(
          (e) => e.status.toString().trim().toLowerCase().contains('pending'),
        )
        .toList();
  }

  @override
  Future<CrewStatsData> fetchCrewStats(String filter) async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.crewStats(filter));
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Crew stats returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load crew stats');
    }
    return CrewStatsModel.fromJson(data).data;
  }

  @override
  Future<Map<String, dynamic>> fetchShootCategories(String tab) async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.shootCategories(tab));
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Shoot categories returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load shoot categories');
    }
    final tabs = (data['data'] as Map<String, dynamic>?)?['tabs'];
    return (tabs is Map<String, dynamic>) ? tabs : <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> fetchAvailability(int month, int year) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.createavailability,
      data: {'month': month, 'year': year},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Availability returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load availability');
    }
    final availability =
        (data['data'] as Map<String, dynamic>?)?['availability'];
    return (availability is Map<String, dynamic>)
        ? availability
        : <String, dynamic>{};
  }

  @override
  Future<profile.Data> fetchProfile() async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.profiledetails,
      data: {},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Profile returned unexpected payload');
    }
    final model = profile.Myprofilemodel.fromJson(data);
    if (model.error == true) {
      throw Exception(model.message);
    }
    return model.data;
  }

  @override
  Future<void> acceptDeclineProject(int projectId, int crewAccept) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.acceptdeclineproject,
      data: {'project_id': projectId, 'crew_accept': crewAccept},
    );
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }
}
