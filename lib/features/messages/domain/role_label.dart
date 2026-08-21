/// Maps backend role codes to display labels used in chat UI (bubble badge,
/// app bar subtitle). Unknown roles are title-cased so future codes still
/// render readably without code changes.
String roleLabel(String? raw) {
  if (raw == null) return '';
  final r = raw.trim().toLowerCase();
  if (r.isEmpty) return '';
  switch (r) {
    case 'cp':
    case 'creative_partner':
      return 'Creative Partner';
    case 'client':
      return 'Client';
    case 'admin':
      return 'Admin';
    case 'sales_rep':
    case 'salesrep':
      return 'Sales Rep';
  }
  final clean = r.replaceAll('_', ' ').replaceAll('-', ' ');
  return clean
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
