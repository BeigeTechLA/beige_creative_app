/// Tolerant unwrapper for paginated REST responses.
///
/// REST spec (`external-chat-api-reference.md`) flags response shape as
/// undocumented. Backend may return either:
///   - bare list: `[ {...}, {...} ]`
///   - wrapped:   `{ "data": [ ... ], "page": 1, "limit": 30, "total": 120, "hasMore": true }`
///   - alt key:   `{ "results": [...] }` / `{ "items": [...] }`
///
/// `unwrapList` walks the common shapes and returns the inner list. Update
/// once backend pins the envelope.
class PaginationEnvelope {
  PaginationEnvelope._();

  /// Pulls the list payload out of a tolerated set of envelope shapes.
  /// Throws [FormatException] if no list found.
  static List<Map<String, dynamic>> unwrapList(dynamic raw) {
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    if (raw is Map<String, dynamic>) {
      for (final key in const ['data', 'results', 'items', 'rooms', 'messages']) {
        final v = raw[key];
        if (v is List) return v.cast<Map<String, dynamic>>();
      }
    }
    throw const FormatException('Unrecognized list envelope');
  }

  /// Pulls a single object out of `{data: {...}}` / `{result: {...}}` /
  /// bare object. Throws [FormatException] when neither matches.
  static Map<String, dynamic> unwrapItem(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      for (final key in const ['data', 'result', 'room', 'message']) {
        final v = raw[key];
        if (v is Map<String, dynamic>) return v;
      }
      return raw;
    }
    throw const FormatException('Unrecognized item envelope');
  }

  /// Reads `hasMore` / `has_more`, falling back to `data.length == limit`.
  static bool hasMore(dynamic raw, {int? limit}) {
    if (raw is Map<String, dynamic>) {
      final v = raw['hasMore'] ?? raw['has_more'];
      if (v is bool) return v;
      if (limit != null) {
        try {
          return unwrapList(raw).length >= limit;
        } catch (_) {/* fall through */}
      }
    }
    return false;
  }

  /// Reads `nextCursor` / `next_cursor` / `next_page`. Returns null when absent.
  static String? nextCursor(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final v = raw['nextCursor'] ?? raw['next_cursor'] ?? raw['next_page'];
      return v?.toString();
    }
    return null;
  }
}
