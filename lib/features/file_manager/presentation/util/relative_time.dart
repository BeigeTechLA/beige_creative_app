/// Coarse relative-time formatter for the "Opened X ago" footer.
///
/// Local-only — no Intl dependency. If the project later adopts a shared
/// time formatter, swap this for it.
String formatOpenedAgo(DateTime? at, {DateTime? now}) {
  if (at == null) return '';
  final reference = now ?? DateTime.now();
  final diff = reference.difference(at);
  if (diff.inSeconds < 60) return 'Opened just now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return 'Opened $m ${m == 1 ? 'minute' : 'minutes'} ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return 'Opened $h ${h == 1 ? 'hour' : 'hours'} ago';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return 'Opened $d ${d == 1 ? 'day' : 'days'} ago';
  }
  if (diff.inDays < 30) {
    final w = (diff.inDays / 7).floor();
    return 'Opened $w ${w == 1 ? 'week' : 'weeks'} ago';
  }
  if (diff.inDays < 365) {
    final mo = (diff.inDays / 30).floor();
    return 'Opened $mo ${mo == 1 ? 'month' : 'months'} ago';
  }
  final y = (diff.inDays / 365).floor();
  return 'Opened $y ${y == 1 ? 'year' : 'years'} ago';
}
