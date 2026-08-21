import '../../domain/models/fm_node.dart';
import 'fm_file_dto.dart';
import 'fm_folder_dto.dart';

/// Discriminator-aware deserializer. Reads `kind: "folder" | "file"` and
/// branches. Unknown kinds throw — the source layer logs + drops the row.
class FmNodeDto {
  static FmNode fromJson(Map<String, dynamic> j) {
    final kind = FmNodeKindX.fromApi(j['kind']?.toString());
    switch (kind) {
      case FmNodeKind.folder:
        return FmFolderDto.fromJson(j);
      case FmNodeKind.file:
        return FmFileDto.fromJson(j);
      case null:
        throw FormatException(
          'fm_node missing or unknown kind: ${j['kind']}',
        );
    }
  }
}
