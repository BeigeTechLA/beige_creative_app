import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_upload_item.dart';
import '../../domain/models/fm_upload_policy.dart';
import '../dtos/fm_envelope_dto.dart';
import '../dtos/fm_upload_policy_dto.dart';

/// Remote data source for File Manager upload flows:
/// 1. Requesting presigned upload policies from the Beige API backend
/// 2. Direct binary PUT to Cloud Storage (S3 / GCS)
/// 3. Confirming completed uploads in batch with the Beige API backend
class UploadRemoteSource {
  UploadRemoteSource(this._client, [Dio? rawStorageDio])
      : _storageDio = rawStorageDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(minutes: 5),
                sendTimeout: const Duration(minutes: 30),
                receiveTimeout: const Duration(minutes: 5),
              ),
            );

  final DioClient _client;
  final Dio _storageDio;

  Dio get _apiDio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  /// `POST /external-file-manager/upload-policies/batch`
  Future<List<FmUploadPolicy>> getUploadPolicies(
    List<FmUploadItem> items,
  ) =>
      _guard(() async {
        final payload = {
          'items': items.map((i) => i.toPresignJson()).toList(),
        };
        final resp = await _apiDio.post<dynamic>(
          ApiEndpoints.fmUploadPolicies,
          data: payload,
        );
        final unwrapped = FmJson.unwrap(resp.data);
        return FmUploadPolicyDto.listFromJson(unwrapped);
      });

  /// Streams the raw file bytes directly to the presigned [uploadUrl] via HTTP PUT.
  /// Bypasses the app backend and does not send app auth tokens.
  Future<void> uploadToStorage({
    required String uploadUrl,
    required File file,
    required Map<String, String> headers,
    String method = 'PUT',
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fileLength = await file.length();
      final stream = file.openRead();

      final cleanHeaders = Map<String, dynamic>.from(headers);
      cleanHeaders[Headers.contentLengthHeader] = fileLength;

      await _storageDio.request<dynamic>(
        uploadUrl,
        data: stream,
        options: Options(
          method: method.toUpperCase(),
          headers: cleanHeaders,
          responseType: ResponseType.plain,
        ),
        onSendProgress: onProgress,
      );
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  /// `POST /external-file-manager/files-uploaded/batch`
  Future<void> confirmUploads(List<FmUploadItem> items) => _guard(() async {
        final payload = {
          'items': items.map((i) => i.toConfirmJson()).toList(),
        };
        await _apiDio.post<dynamic>(
          ApiEndpoints.fmFilesUploaded,
          data: payload,
        );
      });
}
