class NotificationCounts {
  final int all;
  final int unread;
  final int mentions;
  final int payments;
  final int projects;
  final int files;

  const NotificationCounts({
    this.all = 0,
    this.unread = 0,
    this.mentions = 0,
    this.payments = 0,
    this.projects = 0,
    this.files = 0,
  });

  factory NotificationCounts.fromJson(Map<String, dynamic> json) {
    return NotificationCounts(
      all: json['all'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
      mentions: json['mentions'] as int? ?? 0,
      payments: json['payments'] as int? ?? 0,
      projects: json['projects'] as int? ?? 0,
      files: json['files'] as int? ?? 0,
    );
  }
}
