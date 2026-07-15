import 'package:flutter/foundation.dart';

/// Author sub-object attached to every comment/reply payload.
@immutable
class FmCommentAuthor {
  final String id;
  final String name;
  final String? email;
  final String? role;

  /// `user_type` numeric enum from the API — kept opaque here; UI does
  /// not currently branch on it.
  final int? userType;

  final String? profilePictureUrl;

  const FmCommentAuthor({
    required this.id,
    required this.name,
    this.email,
    this.role,
    this.userType,
    this.profilePictureUrl,
  });
}

/// Domain comment. Replies are flattened into [replies] on the top-level
/// comment when returned by `GET /comments?metaId=…`.
@immutable
class FmComment {
  final String id;
  final String fileMetaId;
  final FmCommentAuthor author;
  final String body;

  /// Video timecode (seconds) if the comment is anchored to a moment
  /// inside a video. Null for image / doc comments.
  final int? timestamp;

  /// Set on replies — parent comment's id.
  final String? parentId;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<FmComment> replies;

  const FmComment({
    required this.id,
    required this.fileMetaId,
    required this.author,
    required this.body,
    this.timestamp,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.replies = const [],
  });
}
