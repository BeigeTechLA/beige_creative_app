import '../../domain/models/fm_comment.dart';
import '../../domain/repositories/comments_repository.dart';
import '../sources/comments_remote_source.dart';

class CommentsRepositoryRemote implements CommentsRepository {
  CommentsRepositoryRemote(this._remote);

  final CommentsRemoteSource _remote;

  @override
  Future<List<FmComment>> list(String fileMetaId) =>
      _remote.list(fileMetaId);

  @override
  Future<FmComment> add({
    required String fileMetaId,
    required String userId,
    required String body,
    int? timestamp,
  }) => _remote.add(
    fileMetaId: fileMetaId,
    userId: userId,
    body: body,
    timestamp: timestamp,
  );

  @override
  Future<FmComment> reply({
    required String parentId,
    required String userId,
    required String body,
  }) => _remote.reply(parentId: parentId, userId: userId, body: body);

  @override
  Future<void> delete({
    required String commentId,
    required String userId,
  }) => _remote.delete(commentId: commentId, userId: userId);
}
