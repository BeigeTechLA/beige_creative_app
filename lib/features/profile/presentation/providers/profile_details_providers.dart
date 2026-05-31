import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/edit_profile_model.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_files_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.read(dioClientProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// ProfileDetails1 — read-only view fed by `profileFilesRepository.fetchProfile`
// (same Myprofilemodel.Data shape used by Myprofile + featured work).
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ProfileDetailsViewState {
  final MyProfileData? profile;
  final bool isLoading;
  final String? errorMessage;
  final int selectedTab;

  const ProfileDetailsViewState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.selectedTab = 0,
  });

  ProfileDetailsViewState copyWith({
    MyProfileData? profile,
    bool? isLoading,
    String? errorMessage,
    int? selectedTab,
    bool clearError = false,
  }) {
    return ProfileDetailsViewState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class ProfileDetailsViewNotifier
    extends AutoDisposeNotifier<ProfileDetailsViewState> {
  @override
  ProfileDetailsViewState build() {
    Future.microtask(refresh);
    return const ProfileDetailsViewState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(profileFilesRepositoryProvider).fetchProfile();
      state = state.copyWith(profile: data, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Profile details fetch failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile',
      );
    }
  }

  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }
}

final profileDetailsViewProvider = AutoDisposeNotifierProvider<
    ProfileDetailsViewNotifier, ProfileDetailsViewState>(
  ProfileDetailsViewNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// EditPersonalDetails — form for personal data + working distance + location.
// Notifier owns: initial snapshot, working distance selection, submit lifecycle.
// Controllers live in widget per CLAUDE.md precedent.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class EditPersonalState {
  final EditProfileModel? initial;
  final String workingDistance;
  final bool isLoadingInitial;
  final bool isSubmitting;
  final bool savedOk;
  final String? validationMessage;
  final String? errorMessage;

  const EditPersonalState({
    this.initial,
    this.workingDistance = '',
    this.isLoadingInitial = false,
    this.isSubmitting = false,
    this.savedOk = false,
    this.validationMessage,
    this.errorMessage,
  });

  EditPersonalState copyWith({
    EditProfileModel? initial,
    String? workingDistance,
    bool? isLoadingInitial,
    bool? isSubmitting,
    bool? savedOk,
    String? validationMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return EditPersonalState(
      initial: initial ?? this.initial,
      workingDistance: workingDistance ?? this.workingDistance,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      savedOk: savedOk ?? this.savedOk,
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class EditPersonalNotifier extends AutoDisposeNotifier<EditPersonalState> {
  @override
  EditPersonalState build() {
    Future.microtask(load);
    return const EditPersonalState(isLoadingInitial: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoadingInitial: true, clearMessages: true);
    try {
      final data = await ref.read(profileRepositoryProvider).fetchEditProfile();
      state = state.copyWith(
        initial: data,
        workingDistance: data.workingDistance,
        isLoadingInitial: false,
      );
    } catch (e, st) {
      AppLogger.e('Edit profile load failed', e, st);
      state = state.copyWith(
        isLoadingInitial: false,
        errorMessage: 'Failed to load profile',
      );
    }
  }

  void setWorkingDistance(String value) {
    state = state.copyWith(workingDistance: value);
  }

  Future<bool> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String location,
    required String experience,
    required String hourlyRate,
    required String bio,
    required String age,
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      state = state.copyWith(validationMessage: 'Enter full name');
      return false;
    }
    if (email.trim().isEmpty) {
      state = state.copyWith(validationMessage: 'Enter email');
      return false;
    }
    if (location.trim().isEmpty) {
      state = state.copyWith(validationMessage: 'Select location');
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile({
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'phone_number': phone.trim(),
        'location': location.trim(),
        'working_distance': state.workingDistance,
        'years_of_experience': experience.trim(),
        'hourly_rate': hourlyRate.trim(),
        'bio': bio.trim(),
        'age': age.trim(),
      });
      state = state.copyWith(isSubmitting: false, savedOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('EditPersonal.submit failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong',
      );
      return false;
    }
  }
}

final editPersonalNotifierProvider =
    AutoDisposeNotifierProvider<EditPersonalNotifier, EditPersonalState>(
  EditPersonalNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// EnterProfessional — professional details form. Loads roles + skills lists
// alongside the initial profile so the bottom sheets render real options.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class EnterProfessionalState {
  final EditProfileModel? initial;
  final Map<String, int> roleMap;
  final Map<String, int> skillMap;
  final List<String> selectedRoles;
  final List<String> selectedSkills;
  final bool isLoadingInitial;
  final bool isSubmitting;
  final bool savedOk;
  final String? validationMessage;
  final String? errorMessage;

  const EnterProfessionalState({
    this.initial,
    this.roleMap = const {},
    this.skillMap = const {},
    this.selectedRoles = const [],
    this.selectedSkills = const [],
    this.isLoadingInitial = false,
    this.isSubmitting = false,
    this.savedOk = false,
    this.validationMessage,
    this.errorMessage,
  });

  EnterProfessionalState copyWith({
    EditProfileModel? initial,
    Map<String, int>? roleMap,
    Map<String, int>? skillMap,
    List<String>? selectedRoles,
    List<String>? selectedSkills,
    bool? isLoadingInitial,
    bool? isSubmitting,
    bool? savedOk,
    String? validationMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return EnterProfessionalState(
      initial: initial ?? this.initial,
      roleMap: roleMap ?? this.roleMap,
      skillMap: skillMap ?? this.skillMap,
      selectedRoles: selectedRoles ?? this.selectedRoles,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      savedOk: savedOk ?? this.savedOk,
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<String> get roleList => roleMap.keys.toList();
  List<String> get skillList => skillMap.keys.toList();
}

class EnterProfessionalNotifier
    extends AutoDisposeNotifier<EnterProfessionalState> {
  @override
  EnterProfessionalState build() {
    Future.microtask(load);
    return const EnterProfessionalState(isLoadingInitial: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoadingInitial: true, clearMessages: true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchEditProfile(),
        repo.fetchRoles(),
        repo.fetchSkills(),
      ]);
      final initial = results[0] as EditProfileModel;
      final roleMap = results[1] as Map<String, int>;
      final skillMap = results[2] as Map<String, int>;

      state = state.copyWith(
        initial: initial,
        roleMap: roleMap,
        skillMap: skillMap,
        selectedRoles: _decodePrimaryRoles(initial.primaryRole, roleMap),
        selectedSkills: initial.skills.map((s) => s.name).toList(),
        isLoadingInitial: false,
      );
    } catch (e, st) {
      AppLogger.e('EnterProfessional load failed', e, st);
      state = state.copyWith(
        isLoadingInitial: false,
        errorMessage: 'Failed to load profile',
      );
    }
  }

  void setSelectedRoles(List<String> values) {
    state = state.copyWith(selectedRoles: List.unmodifiable(values));
  }

  void setSelectedSkills(List<String> values) {
    state = state.copyWith(selectedSkills: List.unmodifiable(values));
  }

  Future<bool> submit({
    required String experience,
    required String hourlyRate,
    required String bio,
  }) async {
    if (state.selectedRoles.isEmpty) {
      state = state.copyWith(validationMessage: 'Please select role');
      return false;
    }
    final roleIds = state.selectedRoles
        .map((r) => state.roleMap[r] ?? 0)
        .where((id) => id != 0)
        .toList();
    if (roleIds.isEmpty) {
      state = state.copyWith(validationMessage: 'Invalid role selected');
      return false;
    }
    if (experience.trim().isEmpty) {
      state = state.copyWith(validationMessage: 'Enter experience');
      return false;
    }
    if (hourlyRate.trim().isEmpty) {
      state = state.copyWith(validationMessage: 'Enter hourly rate');
      return false;
    }
    if (state.selectedSkills.isEmpty) {
      state = state.copyWith(validationMessage: 'Select skills');
      return false;
    }
    final skillIds = state.selectedSkills
        .map((s) => state.skillMap[s] ?? 0)
        .where((id) => id != 0)
        .toList();

    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile({
        'primary_role': roleIds,
        'years_of_experience': experience.trim(),
        'hourly_rate': hourlyRate.trim(),
        'bio': bio.trim(),
        'skills': skillIds,
      });
      state = state.copyWith(isSubmitting: false, savedOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('EnterProfessional.submit failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong',
      );
      return false;
    }
  }

  Future<bool> uploadPhoto(File file) async {
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      await ref.read(profileRepositoryProvider).uploadPhoto(file);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e, st) {
      AppLogger.e('uploadPhoto failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Photo upload failed',
      );
      return false;
    }
  }
}

final enterProfessionalNotifierProvider = AutoDisposeNotifierProvider<
    EnterProfessionalNotifier, EnterProfessionalState>(
  EnterProfessionalNotifier.new,
);

// Match the legacy parsing: `primary_role` may be a JSON-encoded list, a CSV,
// or a single token. Map ids back to display labels via the role map.
List<String> _decodePrimaryRoles(String raw, Map<String, int> roleMap) {
  if (raw.isEmpty) return const [];
  List<String> ids;
  try {
    if (raw.startsWith('[')) {
      final decoded = jsonDecode(raw);
      ids = (decoded as List).map((e) => e.toString()).toList();
    } else {
      ids = raw.split(',').map((e) => e.trim()).toList();
    }
  } catch (_) {
    return const [];
  }
  final out = <String>[];
  for (final s in ids) {
    final id = int.tryParse(s) ?? 0;
    final match =
        roleMap.entries.where((e) => e.value == id).map((e) => e.key);
    if (match.isNotEmpty) out.add(match.first);
  }
  return out;
}
