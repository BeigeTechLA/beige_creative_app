class NotificationCounts {
  final int all;
  final int unread;
  final int mentions;
  final int payments;
  final int projects;
  final int files;
  final int shoots;
  final int messages;
  final int meetings;

  const NotificationCounts({
    this.all = 0,
    this.unread = 0,
    this.mentions = 0,
    this.payments = 0,
    this.projects = 0,
    this.files = 0,
    this.shoots = 0,
    this.messages = 0,
    this.meetings = 0,
  });

  factory NotificationCounts.fromJson(Map<String, dynamic> json) {
    return NotificationCounts(
      all: json['all'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
      mentions: json['mentions'] as int? ?? 0,
      payments: json['payments'] as int? ?? 0,
      projects: json['projects'] as int? ?? 0,
      files: json['files'] as int? ?? 0,
      shoots: json['shoots'] as int? ?? 0,
      messages: json['messages'] as int? ?? 0,
      meetings: json['meetings'] as int? ?? 0,
    );
  }
}
