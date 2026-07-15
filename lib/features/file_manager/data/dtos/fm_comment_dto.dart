import '../../domain/models/fm_comment.dart';
import 'fm_envelope_dto.dart';

/// Comment payload from `POST /comments`, `GET /comments?metaId=…`,
/// `POST /comments/{id}/reply`.
///
/// Sample:
///
/// ```json
/// {
///   "id": "6a4257f3f5594aec67ad6cff",
///   "fileMetaId": "…/Version1/5.jpeg",
///   "userId": { "id": "626", "name": "…", "email": "…",
///               "role": "Creative", "user_type": 2,
///               "profile_picture": null },
///   "comment": "Okay",
///   "timestamp": null,
///   "parentId": null,
///   "reactions": [],
///   "createdAt": "…",
///   "updatedAt": "…",
///   "replies": []
/// }
/// ```
class FmCommentDto {
  static FmComment fromJson(Map<String, dynamic> j) {
    final author = FmJson.asMap(j['userId']) ?? const {};
    final replies = FmJson.asList(j['replies']).map(fromJson).toList();

    return FmComment(
      id: (j['id'] ?? '').toString(),
      fileMetaId: (j['fileMetaId'] ?? '').toString(),
      author: FmCommentAuthor(
        id: (author['id'] ?? '').toString(),
        name: (author['name'] ?? '').toString(),
        email: FmJson.nonEmpty(author['email']),
        role: FmJson.nonEmpty(author['role']),
        userType: FmJson.asInt(author['user_type']),
        profilePictureUrl: FmJson.nonEmpty(author['profile_picture']),
      ),
      body: (j['comment'] ?? '').toString(),
      timestamp: FmJson.asInt(j['timestamp']),
      parentId: FmJson.nonEmpty(j['parentId']),
      createdAt: FmJson.asDate(j['createdAt']),
      updatedAt: FmJson.asDate(j['updatedAt']),
      replies: replies,
    );
  }

  static List<FmComment> listFromJson(dynamic raw) {
    if (raw is Map && raw['items'] is List) {
      return FmJson.asList(raw['items']).map(fromJson).toList();
    }
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(fromJson)
          .toList();
    }
    return const [];
  }
}
