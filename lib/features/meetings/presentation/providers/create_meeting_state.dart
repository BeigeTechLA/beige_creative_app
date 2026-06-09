import 'package:flutter/foundation.dart';

import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_platform.dart';

enum CreateMeetingSubmitStatus { idle, submitting, success, error }

@immutable
class CreateMeetingState {
  final String title;
  final String description;
  final String project;
  final DateTime? date;
  final TimeOfDayValue? startTime;
  final TimeOfDayValue? endTime;
  final MeetingPlatform platform;
  final String link;
  final int reminderMinutes;
  final List<String> invitedParticipants;
  final CreateMeetingSubmitStatus status;
  final String? error;
  final Meeting? created;

  const CreateMeetingState({
    this.title = '',
    this.description = '',
    this.project = '',
    this.date,
    this.startTime,
    this.endTime,
    this.platform = MeetingPlatform.meet,
    this.link = '',
    this.reminderMinutes = 15,
    this.invitedParticipants = const [],
    this.status = CreateMeetingSubmitStatus.idle,
    this.error,
    this.created,
  });

  bool get hasTitle => title.trim().isNotEmpty;
  bool get hasDescription => description.trim().isNotEmpty;
  bool get hasDate => date != null;
  bool get hasTimes => startTime != null && endTime != null;
  bool get hasLink => link.trim().isNotEmpty && _looksLikeUrl(link.trim());

  bool get endAfterStart {
    if (!hasTimes) return false;
    final s = startTime!;
    final e = endTime!;
    return (e.hour * 60 + e.minute) > (s.hour * 60 + s.minute);
  }

  bool get isValid =>
      hasTitle &&
      hasDescription &&
      project.trim().isNotEmpty &&
      hasDate &&
      hasTimes &&
      endAfterStart &&
      hasLink &&
      invitedParticipants.isNotEmpty;

  CreateMeetingState copyWith({
    String? title,
    String? description,
    String? project,
    DateTime? date,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    MeetingPlatform? platform,
    String? link,
    int? reminderMinutes,
    List<String>? invitedParticipants,
    CreateMeetingSubmitStatus? status,
    String? error,
    bool clearError = false,
    Meeting? created,
  }) {
    return CreateMeetingState(
      title: title ?? this.title,
      description: description ?? this.description,
      project: project ?? this.project,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      platform: platform ?? this.platform,
      link: link ?? this.link,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      invitedParticipants: invitedParticipants ?? this.invitedParticipants,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      created: created ?? this.created,
    );
  }
}

@immutable
class TimeOfDayValue {
  final int hour;
  final int minute;
  const TimeOfDayValue(this.hour, this.minute);
}

bool _looksLikeUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  if (!uri.hasScheme) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}
