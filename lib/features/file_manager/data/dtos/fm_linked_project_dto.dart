import '../../../../config/env.dart';
import '../../domain/models/fm_linked_project.dart';

/// snake_case server shape per FILE_MANAGER_UI_PLAN.md §8.1.
class FmLinkedProjectDto {
  static FmLinkedProject? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['id']?.toString();
    final displayName = raw['display_name']?.toString();
    if (id == null || id.isEmpty || displayName == null) return null;
    return FmLinkedProject(
      id: id,
      displayName: displayName,
      projectCode: raw['project_code']?.toString(),
      thumbnailUrl: _resolveUrl(raw['thumbnail_url']?.toString()),
      badgeLabel: raw['badge_label']?.toString(),
    );
  }

  static String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${Env.imageUrl}$url';
  }
}
