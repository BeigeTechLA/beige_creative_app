import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/models/fm_comment.dart';
import '../../domain/repositories/comments_repository.dart';
import 'comments_repository_provider.dart';

/// Async comments list keyed by `fileMetaId`. Load happens on `build`;
/// mutations (post/reply/delete) update the state in place after the
/// server round-trip so consumers see the new comment immediately without
/// a full re-fetch.
class CommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<FmComment>, String> {
  late CommentsRepository _repo;
  late String _fileMetaId;

  @override
  Future<List<FmComment>> build(String fileMetaId) async {
    _repo = ref.watch(commentsRepositoryProvider);
    _fileMetaId = fileMetaId;
    return _repo.list(fileMetaId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.list(_fileMetaId));
  }

  /// Post a top-level comment. Uses the current session user's id.
  /// Returns the persisted comment or throws if the write failed.
  Future<FmComment> post(String body, {int? timestamp}) async {
    final userId = await _requireUserId();
    final comment = await _repo.add(
      fileMetaId: _fileMetaId,
      userId: userId,
      body: body,
      timestamp: timestamp,
    );
    final current = state.value ?? const <FmComment>[];
    state = AsyncData([...current, comment]);
    return comment;
  }

  /// Reply to [parentId]. Splices the reply into the parent's local
  /// `replies` list.
  Future<FmComment> reply(String parentId, String body) async {
    final userId = await _requireUserId();
    final reply = await _repo.reply(
      parentId: parentId,
      userId: userId,
      body: body,
    );
    final current = state.value ?? const <FmComment>[];
    state = AsyncData([
      for (final c in current)
        if (c.id != parentId)
          c
        else
          FmComment(
            id: c.id,
            fileMetaId: c.fileMetaId,
            author: c.author,
            body: c.body,
            timestamp: c.timestamp,
            parentId: c.parentId,
            createdAt: c.createdAt,
            updatedAt: c.updatedAt,
            replies: [...c.replies, reply],
          ),
    ]);
    return reply;
  }

  /// Delete a comment (top-level or reply). No-op if the id isn't in
  /// current state (still hits the server so cross-device deletes work).
  Future<void> delete(String commentId) async {
    final userId = await _requireUserId();
    await _repo.delete(commentId: commentId, userId: userId);
    final current = state.value ?? const <FmComment>[];
    final next = <FmComment>[];
    for (final c in current) {
      if (c.id == commentId) continue;
      if (c.replies.any((r) => r.id == commentId)) {
        next.add(FmComment(
          id: c.id,
          fileMetaId: c.fileMetaId,
          author: c.author,
          body: c.body,
          timestamp: c.timestamp,
          parentId: c.parentId,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
          replies: c.replies.where((r) => r.id != commentId).toList(),
        ));
      } else {
        next.add(c);
      }
    }
    state = AsyncData(next);
  }

  Future<String> _requireUserId() async {
    final user = await ref.read(sessionStoreProvider).readUser();
    final id = user?.id;
    if (id == null || id.isEmpty) {
      throw StateError('No session user — cannot post comment.');
    }
    return id;
  }
}

final commentsNotifierProvider = AutoDisposeAsyncNotifierProvider
    .family<CommentsNotifier, List<FmComment>, String>(
      CommentsNotifier.new,
    );
