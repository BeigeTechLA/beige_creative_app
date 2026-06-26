import '../../domain/models/fm_node.dart';
import '../../domain/models/link_state.dart';
import 'fm_linked_project_dto.dart';

/// Folder DTO. Backend returns a flat object — caller checks `kind: "folder"`
/// before invoking [FmFolderDto.fromJson]. `fileCount` server-computed.
class FmFolderDto {
  static FmFolder fromJson(Map<String, dynamic> j) {
    return FmFolder(
      id: j['id']?.toString() ?? '',
      name: (j['name'] ?? '').toString(),
      fileCount: _asInt(j['file_count']) ?? 0,
      openedAt: _parseDate(j['opened_at']),
      tagLabel: _nonEmpty(j['tag_label']?.toString()),
      linkState: LinkStateX.fromApi(j['link_state']?.toString()),
      linkedProject: FmLinkedProjectDto.fromJson(j['linked_project']),
    );
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  static String? _nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;
}
