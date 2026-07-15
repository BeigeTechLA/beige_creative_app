import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_comment.dart';
import '../dtos/fm_comment_dto.dart';
import '../dtos/fm_envelope_dto.dart';

class CommentsRemoteSource {
  CommentsRemoteSource(this._client);

  final DioClient _client;
  Dio get _dio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<List<FmComment>> list(String fileMetaId) => _guard(() async {
    final resp = await _dio.get<dynamic>(
      ApiEndpoints.comments,
      queryParameters: {'metaId': fileMetaId},
    );
    return FmCommentDto.listFromJson(FmJson.unwrap(resp.data));
  });

  Future<FmComment> add({
    required String fileMetaId,
    required String userId,
    required String body,
    int? timestamp,
  }) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.comments,
      data: {
        'fileMetaId': fileMetaId,
        'user_id': userId,
        'comment': body,
        'timestamp': ?timestamp,
      },
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmCommentDto.fromJson(data);
  });

  Future<FmComment> reply({
    required String parentId,
    required String userId,
    required String body,
  }) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.commentReply(parentId),
      data: {
        'user_id': userId,
        'comment': body,
      },
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmCommentDto.fromJson(data);
  });

  Future<void> delete({
    required String commentId,
    required String userId,
  }) => _guard(() async {
    await _dio.delete<dynamic>(
      ApiEndpoints.commentById(commentId),
      data: {'user_id': userId},
    );
  });
}
