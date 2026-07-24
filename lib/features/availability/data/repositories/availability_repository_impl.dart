import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/upcoming_shoots_model.dart';
import '../../domain/entities/availability_entry.dart';
import '../../domain/repositories/availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final DioClient _client;

  const AvailabilityRepositoryImpl(this._client);

  Dio get _dio => _client.dio;

  @override
  Future<Map<DateTime, AvailabilityDay>> fetchMonth({
    required int month,
    required int year,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createavailability,
      data: {'month': month, 'year': year},
    );
    final body = response.data;
    if (body is! Map || body['error'] == true) {
      return const {};
    }
    final raw = (body['data']?['availability'] as Map?) ?? const {};
    final out = <DateTime, AvailabilityDay>{};
    raw.forEach((key, value) {
      if (value is! Map) return;
      final keyStr = key.toString().split('T').first;
      final date = DateTime.tryParse(keyStr) ?? DateTime.tryParse(key.toString());
      if (date == null) return;
      final clean = DateTime(date.year, date.month, date.day);

      final projectDetails = value['projectDetails'];
      final isAssigned = _isTrue(value['projectAssigned']) ||
          (projectDetails is List && projectDetails.isNotEmpty) ||
          (projectDetails is Map && projectDetails.isNotEmpty) ||
          value['status'] == 'shoot' ||
          value['status'] == 'Shoot';

      if (isAssigned) {
        final bookingId = _extractBookingId(value, projectDetails);
        out[clean] = AvailabilityDay(
          status: AvailabilityStatus.shoot,
          bookingId: bookingId,
        );
      } else if (_isTrue(value['available']) || value['status'] == 'available') {
        out[clean] = const AvailabilityDay(status: AvailabilityStatus.available);
      }
    });
    return out;
  }

  @override
  Future<List<UpcomingShootDatum>> fetchUpcomingShoots() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.upcomingshoots);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Upcoming shoots returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load upcoming shoots');
    }
    return UpcomingShootsModel.fromJson(data).data;
  }

  bool _isTrue(Object? v) {

    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  int? _extractBookingId(Map value, Object? projectDetails) {
    if (projectDetails is List && projectDetails.isNotEmpty) {
      for (final item in projectDetails) {
        if (item is Map) {
          final id = _asInt(item['booking_id']) ??
              _asInt(item['id']) ??
              _asInt(item['project_id']) ??
              _asInt(item['shoot_id']) ??
              _asInt(item['bookingId']) ??
              _asInt(item['projectId']);
          if (id != null) return id;
        } else {
          final id = _asInt(item);
          if (id != null) return id;
        }
      }
    }
    if (projectDetails is Map) {
      final id = _asInt(projectDetails['booking_id']) ??
          _asInt(projectDetails['id']) ??
          _asInt(projectDetails['project_id']) ??
          _asInt(projectDetails['shoot_id']) ??
          _asInt(projectDetails['bookingId']) ??
          _asInt(projectDetails['projectId']);
      if (id != null) return id;
    }
    return _asInt(value['booking_id']) ??
        _asInt(value['project_id']) ??
        _asInt(value['id']) ??
        _asInt(value['shoot_id']) ??
        _asInt(value['bookingId']) ??
        _asInt(value['projectId']);
  }

  int? _asInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  Future<void> createAvailability(AvailabilityPayload payload) async {
    await _dio.post(
      ApiEndpoints.add_availability,
      data: payload.toJson(),
    );
  }
}
