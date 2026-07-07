/// Server-emitted meeting stage. [serverValue] is the raw wire value
/// (`post_production`); [label] is the display form (`Post Production`).
/// Unknown / unmapped raws resolve to `null` — UI falls back to
/// `Meeting.meetingTypeRaw` via `meetingTypeDisplay`.
enum MeetingType {
  planning('planning', 'Planning'),
  preProduction('pre_production', 'Pre Production'),
  production('production', 'Production'),
  postProduction('post_production', 'Post Production'),
  review('review', 'Review'),
  delivery('delivery', 'Delivery');

  const MeetingType(this.serverValue, this.label);

  final String serverValue;
  final String label;

  static MeetingType? fromServer(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final t in values) {
      if (t.serverValue == raw) return t;
    }
    return null;
  }
}
