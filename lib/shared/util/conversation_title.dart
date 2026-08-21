/// Server names conversations as `shootType_name_#shootOrderId`
/// (e.g. `corporate_pranav_#3905`). UI shows only `name_#shootOrderId`.
/// Falls back to the raw string when the pattern does not match.
String displayConversationTitle(String? raw) {
  if (raw == null) return '';
  final s = raw.trim();
  if (s.isEmpty) return '';
  final i = s.indexOf('_');
  if (i < 0 || i == s.length - 1) return s;
  return s.substring(i + 1);
}
