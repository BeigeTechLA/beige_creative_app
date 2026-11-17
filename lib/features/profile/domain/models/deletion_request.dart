import 'package:intl/intl.dart';

class DeletionRequest {
  const DeletionRequest({
    this.id,
    this.status,
    this.scheduledAt,
    this.confirmationEmailSent = false,
  });

  final String? id;
  final String? status;
  final DateTime? scheduledAt;
  final bool confirmationEmailSent;

  factory DeletionRequest.fromResponse(Map<String, dynamic> response) {
    final data = response['data'] is Map
        ? Map<String, dynamic>.from(response['data'] as Map)
        : response;
    final nested = data['request'] ?? data['deletion_request'];
    final request = nested is Map ? Map<String, dynamic>.from(nested) : data;
    final date =
        request['scheduled_deletion_date'] ??
        request['scheduled_deletion_at'] ??
        request['scheduled_at'];
    return DeletionRequest(
      id:
          (request['request_id'] ??
                  request['deletion_request_id'] ??
                  request['id'])
              ?.toString(),
      status: request['status']?.toString(),
      scheduledAt: date == null ? null : DateTime.tryParse(date.toString()),
      confirmationEmailSent:
          data['confirmation_email_sent'] == true ||
          response['confirmation_email_sent'] == true,
    );
  }

  String get dateLabel => scheduledAt == null
      ? 'Date unavailable'
      : DateFormat('MMMM d, yyyy').format(scheduledAt!);
}
