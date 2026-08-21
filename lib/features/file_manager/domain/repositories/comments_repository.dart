import '../models/fm_comment.dart';

/// File-scoped comments API (endpoint 13 in FILE_MANAGER_API_PLAN.md §3.13).
///
/// [fileMetaId] is the file's `filepath` (per API doc — see §11 Q3 for
/// open confirmation). All mutations resolve with the persisted comment
/// (top-level or reply) so the caller can splice it into local state
/// without a re-fetch.
abstract class CommentsRepository {
  /// `GET /comments?metaId={fileMetaId}` — top-level comments (each with
  /// its nested `replies`).
  Future<List<FmComment>> list(String fileMetaId);

  /// `POST /comments` — top-level comment.
  Future<FmComment> add({
    required String fileMetaId,
    required String userId,
    required String body,
    int? timestamp,
  });

  /// `POST /comments/{commentId}/reply` — reply anchored to [parentId].
  Future<FmComment> reply({
    required String parentId,
    required String userId,
    required String body,
  });

  /// `DELETE /comments/{commentId}` — soft/hard delete decided server-side.
  Future<void> delete({
    required String commentId,
    required String userId,
  });
}
