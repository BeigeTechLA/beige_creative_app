import '../../domain/models/fm_page.dart';

/// Pagination envelope shared by both listing endpoints. Accepts either the
/// canonical `{ items, next_cursor, total }` shape or a flat list (some
/// backends return `[...]` with the cursor in headers — fall back gracefully).
class FmPageDto {
  static FmPage<T> fromJson<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) item,
  ) {
    if (raw is List) {
      return FmPage<T>(
        items: raw
            .whereType<Map>()
            .map((e) => item(Map<String, dynamic>.from(e)))
            .toList(),
        nextCursor: null,
        total: raw.length,
      );
    }
    if (raw is Map) {
      final rawItems = raw['items'];
      final items = <T>[];
      if (rawItems is List) {
        for (final e in rawItems) {
          if (e is Map) {
            try {
              items.add(item(Map<String, dynamic>.from(e)));
            } catch (_) {
              // Drop unknown-kind nodes; remote source logs separately.
            }
          }
        }
      }
      return FmPage<T>(
        items: items,
        nextCursor: _nonEmpty(raw['next_cursor']?.toString()),
        total: _asInt(raw['total']),
      );
    }
    return const FmPage(items: []);
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String? _nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;
}
