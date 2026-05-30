import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/availability_entry.dart';
import '../../domain/repositories/availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final DioClient _client;

  const AvailabilityRepositoryImpl(this._client);

  Dio get _dio => _client.dio;

  @override
  Future<Map<DateTime, AvailabilityStatus>> fetchMonth({
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
    final out = <DateTime, AvailabilityStatus>{};
    raw.forEach((key, value) {
      final date = DateTime.tryParse(key.toString());
      if (date == null || value is! Map) return;
      final clean = DateTime(date.year, date.month, date.day);
      if (value['projectAssigned'] == true) {
        out[clean] = AvailabilityStatus.shoot;
      } else if (value['available'] == true) {
        out[clean] = AvailabilityStatus.available;
      }
    });
    return out;
  }

  @override
  Future<void> createAvailability(AvailabilityPayload payload) async {
    await _dio.post(
      ApiEndpoints.add_availability,
      data: payload.toJson(),
    );
  }
}
