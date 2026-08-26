class NotificationSettingsRequestDto {
  final String sessionId;
  final NotificationPreferencesDto notificationPreferences;

  const NotificationSettingsRequestDto({
    required this.sessionId,
    required this.notificationPreferences,
  });

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'notification_preferences': notificationPreferences.toJson(),
      };

  factory NotificationSettingsRequestDto.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsRequestDto(
      sessionId: json['session_id'] as String? ?? '',
      notificationPreferences: NotificationPreferencesDto.fromJson(
        json['notification_preferences'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class NotificationPreferencesDto {
  final bool pushEnabled;
  final NotificationTopicsDto topics;

  const NotificationPreferencesDto({
    required this.pushEnabled,
    required this.topics,
  });

  Map<String, dynamic> toJson() => {
        'push_enabled': pushEnabled,
        'topics': topics.toJson(),
      };

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDto(
      pushEnabled: json['push_enabled'] as bool? ?? true,
      topics: NotificationTopicsDto.fromJson(
        json['topics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class NotificationTopicsDto {
  final bool shoots;
  // final bool payments;
  final bool messages;
  final bool meetings;
  // final bool proposals;
  final bool files;
  // final bool system;

  const NotificationTopicsDto({
    this.shoots = true,
    // this.payments = true,
    this.messages = true,
    this.meetings = true,
    // this.proposals = true,
    this.files = true,
    // this.system = true,
  });

  Map<String, dynamic> toJson() => {
        'shoots': shoots,
        // 'payments': payments,
        'messages': messages,
        'meetings': meetings,
        // 'proposals': proposals,
        'files': files,
        // 'system': system,
      };

  factory NotificationTopicsDto.fromJson(Map<String, dynamic> json) {
    return NotificationTopicsDto(
      shoots: json['shoots'] as bool? ?? true,
      // payments: json['payments'] as bool? ?? true,
      messages: json['messages'] as bool? ?? true,
      meetings: json['meetings'] as bool? ?? true,
      // proposals: json['proposals'] as bool? ?? true,
      files: json['files'] as bool? ?? true,
      // system: json['system'] as bool? ?? true,
    );
  }
}
