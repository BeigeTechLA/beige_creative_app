import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_share.dart';
import '../../domain/repositories/shares_repository.dart';

class SharesRepositoryRemote implements SharesRepository {
  SharesRepositoryRemote(this._client);
  final DioClient _client;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  dynamic _unwrap(dynamic body) {
    if (body is! Map || body['success'] != true) {
      throw StateError(
        body is Map
            ? (body['message']?.toString() ?? 'Share request failed')
            : 'Invalid share response',
      );
    }
    return body['data'];
  }

  // GET response examples have not yet been supplied. Accept explicit list
  // containers only; unknown shapes must not masquerade as no existing access.
  List<Map<String, dynamic>> _rows(dynamic data, String key) {
    final rows = data is Map ? data[key] : data;
    if (rows is! List || rows.any((row) => row is! Map)) {
      throw const FormatException('Unrecognized share response');
    }
    return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  FmShareRecipient _share(
    Map<String, dynamic> row, {
    String? email,
    FmSharePermission? permission,
  }) {
    final rawPermission = row['permission'];
    final parsedPermission = switch (rawPermission) {
      'view_download' => FmSharePermission.canDownload,
      'upload_download' => FmSharePermission.canUploadAndDownload,
      null when permission != null => permission,
      _ => throw const FormatException('Unrecognized share permission'),
    };
    final rawId = row['shareId'] ?? row['id'];
    final id = rawId == null ? null : int.tryParse(rawId.toString());
    if (rawId != null && (id == null || id <= 0)) {
      throw const FormatException('Invalid share ID');
    }
    final mode = row['accessMode'];
    final recipientEmail = row['email']?.toString() ?? email;
    if (mode != null && mode != 'email_only' && mode != 'anyone_with_link') {
      throw const FormatException('Unrecognized share access mode');
    }
    if (mode == 'email_only' &&
        (recipientEmail == null || recipientEmail.trim().isEmpty)) {
      throw const FormatException('Missing share email');
    }
    final url = row['shareUrl']?.toString();
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !uri.hasAuthority ||
          !['http', 'https'].contains(uri.scheme)) {
        throw const FormatException('Invalid share URL');
      }
    }
    return FmShareRecipient(
      shareId: id,
      email: mode == 'anyone_with_link' ? null : recipientEmail,
      permission: parsedPermission,
      shareLink: url,
      shareToken: row['shareToken']?.toString(),
    );
  }

  @override
  Future<List<FmShareRecipient>> list(FmShareTarget target) => _guard(() async {
    final response = await _client.dio.get<dynamic>(
      ApiEndpoints.fmShare,
      queryParameters: target.parameters,
    );
    return _rows(_unwrap(response.data), 'shares').map(_share).toList();
  });

  @override
  Future<FmShareRecipient> create(
    FmShareTarget target, {
    String? email,
    required FmSharePermission permission,
    String message = '',
  }) => _guard(() async {
    final recipient = email?.trim();
    if (recipient != null && recipient.isEmpty) {
      throw ArgumentError('Email must not be empty');
    }
    if (recipient == null && permission != FmSharePermission.canDownload) {
      throw ArgumentError('Public links support view and download only');
    }
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.fmShare,
      data: {
        ...target.parameters,
        'email': ?recipient,
        'accessMode': recipient == null ? 'anyone_with_link' : 'email_only',
        'permission': permission.apiValue,
        'message': message,
      },
    );
    final data = _unwrap(response.data);
    if (data is! Map) throw const FormatException('Missing created share');
    final result = _share(
      Map<String, dynamic>.from(data),
      email: recipient,
      permission: permission,
    );
    if (result.shareLink == null) {
      throw const FormatException('Missing share URL');
    }
    return result;
  });

  @override
  Future<void> revoke(int shareId) => _guard(() async {
    if (shareId <= 0) throw ArgumentError.value(shareId, 'shareId');
    final response = await _client.dio.delete<dynamic>(
      ApiEndpoints.fmShare,
      data: {'shareId': shareId},
    );
    _unwrap(response.data);
  });

  @override
  Future<List<FmShareAccessLog>> accessLogs(FmShareTarget target) =>
      _guard(() async {
        final response = await _client.dio.get<dynamic>(
          ApiEndpoints.fmShareAccessLogs,
          queryParameters: target.parameters,
        );
        return _rows(_unwrap(response.data), 'logs').map((row) {
          final action = row['action'];
          if (action is! String || action.isEmpty) {
            throw const FormatException('Missing access log action');
          }
          return FmShareAccessLog(
            action: action,
            email: row['email']?.toString(),
            createdAt: DateTime.tryParse(row['createdAt']?.toString() ?? ''),
          );
        }).toList();
      });
}
