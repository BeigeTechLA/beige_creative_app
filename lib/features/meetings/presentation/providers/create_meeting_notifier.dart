import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/models/create_meeting_input.dart';
import '../../domain/models/meeting_category.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'create_meeting_state.dart';
import 'meetings_repository_provider.dart';

class CreateMeetingNotifier extends AutoDisposeNotifier<CreateMeetingState> {
  late final MeetingsRepository _repo;

  @override
  CreateMeetingState build() {
    _repo = ref.watch(meetingsRepositoryProvider);
    return const CreateMeetingState();
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setProject(String v) => state = state.copyWith(project: v);
  void setDate(DateTime v) => state = state.copyWith(date: v);
  void setStartTime(TimeOfDayValue v) => state = state.copyWith(startTime: v);
  void setEndTime(TimeOfDayValue v) => state = state.copyWith(endTime: v);
  void setPlatform(MeetingPlatform v) => state = state.copyWith(platform: v);
  void setLink(String v) => state = state.copyWith(link: v);
  void setReminder(int minutes) =>
      state = state.copyWith(reminderMinutes: minutes);

  void addParticipant(String name) {
    if (name.trim().isEmpty) return;
    if (state.invitedParticipants.contains(name.trim())) return;
    state = state.copyWith(
      invitedParticipants: [...state.invitedParticipants, name.trim()],
    );
  }

  void removeParticipant(String name) {
    state = state.copyWith(
      invitedParticipants:
          state.invitedParticipants.where((p) => p != name).toList(),
    );
  }

  Future<void> submit() async {
    if (!state.isValid) return;
    state = state.copyWith(
      status: CreateMeetingSubmitStatus.submitting,
      clearError: true,
    );
    try {
      final d = state.date!;
      final s = state.startTime!;
      final e = state.endTime!;
      final input = CreateMeetingInput(
        title: state.title.trim(),
        description: state.description.trim(),
        project: state.project.trim(),
        startAt: DateTime(d.year, d.month, d.day, s.hour, s.minute),
        endAt: DateTime(d.year, d.month, d.day, e.hour, e.minute),
        platform: state.platform,
        link: state.link.trim(),
        reminderMinutes: state.reminderMinutes,
        category: MeetingCategory.commercial,
        participants: state.invitedParticipants
            .map((name) => MeetingParticipant(
                  id: name.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
                  name: name,
                ))
            .toList(),
      );
      final created = await _repo.create(input);
      state = state.copyWith(
        status: CreateMeetingSubmitStatus.success,
        created: created,
      );
    } catch (err) {
      state = state.copyWith(
        status: CreateMeetingSubmitStatus.error,
        error: _messageFor(err),
      );
      if (err is UnauthorizedException) {
        unawaited(ref.read(authStateProvider.notifier).logout());
      }
    }
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Could not create meeting';
  }
}

final createMeetingNotifierProvider =
    AutoDisposeNotifierProvider<CreateMeetingNotifier, CreateMeetingState>(
      CreateMeetingNotifier.new,
    );
