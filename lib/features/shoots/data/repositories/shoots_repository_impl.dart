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
    final normalized = status.toLowerCase();
    final crewAccept = normalized == 'accepted' ? 1 : 2;
    final body = <String, dynamic>{
      'project_id': projectId,
      'crew_accept': crewAccept,
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
  Future<ShootsData> fetchShoots({
    String requestStatus = 'all',
    String shootStatus = 'completed',
  }) async {
    final endpoint = ApiEndpoints.creatorShoots(
      requestStatus: requestStatus,
      shootStatus: shootStatus,
    );
    final response = await _client.dio.get<dynamic>(endpoint);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Shoots details returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load shoots');
    }
    return ShootsModel.fromJson(data).data;
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

  @override
  Future<List<Shoot>> fetchShootCardDetails(String status) async {
    final endpoint = ApiEndpoints.creatorShootCardDetails(status);
    final response = await _client.dio.get<dynamic>(endpoint);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Shoot card details returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load shoot card details');
    }
    final rawData = data['data'];
    if (rawData is List) {
      return rawData
          .whereType<Map<String, dynamic>>()
          .map((x) => Shoot.fromJson(x))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      final shootsData = ShootsData.fromJson(rawData);
      return shootsData.all;
    }
    return [];
  }
}
