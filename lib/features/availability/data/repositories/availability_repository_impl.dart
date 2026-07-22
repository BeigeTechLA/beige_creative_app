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
      final date = DateTime.tryParse(key.toString());
      if (date == null || value is! Map) return;
      final clean = DateTime(date.year, date.month, date.day);
      if (value['projectAssigned'] == true) {
        final projectDetails = value['projectDetails'];
        final bookingId = projectDetails is Map
            ? _asInt(projectDetails['booking_id'])
            : null;
        out[clean] = AvailabilityDay(
          status: AvailabilityStatus.shoot,
          bookingId: bookingId,
        );
      } else if (value['available'] == true) {
        out[clean] = const AvailabilityDay(status: AvailabilityStatus.available);
      }
    });
    return out;
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
