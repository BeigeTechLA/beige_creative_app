import '../../domain/models/fm_folder_created.dart';
import 'fm_envelope_dto.dart';

/// Result of `POST /external-file-manager/folder` and the common-events
/// creator-folder variant.
///
/// ```json
/// "data": {
///   "folder": {
///     "id": "6a423e46f5594aec67acc09b",
///     "path": "corporate_harsh_#4833/Post-Production/Test1/",
///     "name": "Test1",
///     "isFolder": true
///   },
///   "alreadyExists": false
/// }
/// ```
///
/// The creator-folder variant wraps the same `folder` object with extra
/// event coordinates (`externalId`, `folderName`); [fromCreatorFolderJson]
/// handles that shape.
class FmFolderCreatedDto {
  static FmFolderCreated fromJson(Map<String, dynamic> j) {
    final folder = FmJson.asMap(j['folder']) ?? const {};
    return FmFolderCreated(
      id: (folder['id'] ?? '').toString(),
      path: (folder['path'] ?? '').toString(),
      name: (folder['name'] ?? '').toString(),
      alreadyExists: FmJson.asBool(j['alreadyExists']),
    );
  }

  static FmFolderCreated fromCreatorFolderJson(Map<String, dynamic> j) {
    final folder = FmJson.asMap(j['folder']) ?? const {};
    return FmFolderCreated(
      id: (folder['id'] ?? '').toString(),
      path: (folder['path'] ?? '').toString(),
      name: (folder['name'] ?? j['folderName'] ?? '').toString(),
      alreadyExists: FmJson.asBool(j['alreadyExists']),
    );
  }
}
