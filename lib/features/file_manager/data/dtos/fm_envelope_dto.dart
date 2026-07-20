/// Generic `{ success, message, data }` envelope wrapping every
/// file-manager response. Sources typically peel `data` before deserializing
/// (see `FmJson.unwrap`); this class exists for endpoints where the
/// envelope fields themselves matter (e.g. `message` on create-folder).
class FmEnvelope<T> {
  final bool success;
  final String? message;
  final T data;

  const FmEnvelope({required this.success, required this.data, this.message});

  static FmEnvelope<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) parseData,
  ) {
    return FmEnvelope<T>(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: parseData(json['data']),
    );
  }
}

/// Small parsing helpers shared across every DTO. Kept as top-level
/// functions to avoid the ceremony of inheriting a base class.
class FmJson {
  const FmJson._();

  /// Peels `data` off an envelope when present, else returns the payload
  /// unchanged.
  static dynamic unwrap(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) return raw['data'];
    return raw;
  }

  static int? asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool asBool(dynamic v, {bool orElse = false}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true';
    return orElse;
  }

  static DateTime? asDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
    return null;
  }

  static String? nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static Map<String, dynamic>? asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static List<Map<String, dynamic>> asList(dynamic v) {
    if (v is! List) return const [];
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
