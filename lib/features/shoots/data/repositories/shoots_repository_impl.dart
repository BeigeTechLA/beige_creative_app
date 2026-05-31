import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/shoot_count_model.dart' as count_model;
import '../../../../model_class/shoots_model.dart';
import '../../../../model_class/upcoming_shootview_model.dart';
import '../../domain/repositories/shoots_repository.dart';

class ShootsRepositoryImpl implements ShootsRepository {
  final DioClient _client;

  const ShootsRepositoryImpl(this._client);

  @override
  Future<MyData> fetchProjectDetail(int projectId) async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.projectDetails(projectId));
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Project details returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load project');
    }
    return UpcomingShootViewModel.fromJson(data).data;
  }

  @override
  Future<void> respondToProject({
    required int projectId,
    required String status,
    String? reason,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'project_id': projectId,
      'status': status,
      'reason': ?reason,
      'comment': ?comment,
    };
    final response = await _client.dio
        .post<dynamic>(ApiEndpoints.acceptdeclineproject, data: body);
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }

  @override
  Future<List<Shoot>> fetchShoots() async {
    final response = await _client.dio
        .get<dynamic>(ApiEndpoints.creatordashboarddetails);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Dashboard details returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load shoots');
    }
    return ShootsModel.fromJson(data).data.shoots;
  }

  @override
  Future<count_model.ShootCountData> fetchShootCount() async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.myshootcount);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Shoot count returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load shoot count');
    }
    return count_model.ShootCountModel.fromJson(data).data;
  }
}
