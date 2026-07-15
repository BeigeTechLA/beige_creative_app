import '../../domain/models/fm_comment.dart';
import '../../domain/repositories/comments_repository.dart';

/// In-memory comments store. Keyed by `fileMetaId`. Replies live inside
/// their parent's [FmComment.replies] list — matches the API's list
/// shape so the widget layer stays identical across dummy and remote.
class CommentsRepositoryDummy implements CommentsRepository {
  static const Duration _latency = Duration(milliseconds: 150);
  static final Map<String, List<FmComment>> _store = {};
  static int _idCounter = 0;

  String _nextId() {
    _idCounter++;
    return 'dummy_c_${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  @override
  Future<List<FmComment>> list(String fileMetaId) async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_store[fileMetaId] ?? const <FmComment>[]);
  }

  @override
  Future<FmComment> add({
    required String fileMetaId,
    required String userId,
    required String body,
    int? timestamp,
  }) async {
    await Future<void>.delayed(_latency);
    final comment = FmComment(
      id: _nextId(),
      fileMetaId: fileMetaId,
      author: FmCommentAuthor(id: userId, name: 'You'),
      body: body,
      timestamp: timestamp,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _store.putIfAbsent(fileMetaId, () => []).add(comment);
    return comment;
  }

  @override
  Future<FmComment> reply({
    required String parentId,
    required String userId,
    required String body,
  }) async {
    await Future<void>.delayed(_latency);
    for (final entry in _store.entries) {
      for (var i = 0; i < entry.value.length; i++) {
        final parent = entry.value[i];
        if (parent.id != parentId) continue;
        final reply = FmComment(
          id: _nextId(),
          fileMetaId: parent.fileMetaId,
          author: FmCommentAuthor(id: userId, name: 'You'),
          body: body,
          parentId: parentId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        entry.value[i] = FmComment(
          id: parent.id,
          fileMetaId: parent.fileMetaId,
          author: parent.author,
          body: parent.body,
          timestamp: parent.timestamp,
          parentId: parent.parentId,
          createdAt: parent.createdAt,
          updatedAt: parent.updatedAt,
          replies: [...parent.replies, reply],
        );
        return reply;
      }
    }
    throw StateError('Parent comment $parentId not found');
  }

  @override
  Future<void> delete({
    required String commentId,
    required String userId,
  }) async {
    await Future<void>.delayed(_latency);
    for (final entry in _store.entries) {
      final before = entry.value.length;
      entry.value.removeWhere((c) => c.id == commentId);
      if (entry.value.length < before) return;
      for (var i = 0; i < entry.value.length; i++) {
        final parent = entry.value[i];
        if (!parent.replies.any((r) => r.id == commentId)) continue;
        entry.value[i] = FmComment(
          id: parent.id,
          fileMetaId: parent.fileMetaId,
          author: parent.author,
          body: parent.body,
          timestamp: parent.timestamp,
          parentId: parent.parentId,
          createdAt: parent.createdAt,
          updatedAt: parent.updatedAt,
          replies: parent.replies.where((r) => r.id != commentId).toList(),
        );
        return;
      }
    }
  }
}
