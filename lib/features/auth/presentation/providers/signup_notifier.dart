import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/signup3_constants.dart';
import 'signup_state.dart';

final signupRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(dioClientProvider)),
);

final _emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

/// Shared across SignUp1 + SignUp2 (and forward into SignUp3). Plain
/// `NotifierProvider` (not auto-dispose) so accumulated state survives
/// `context.goNamed`/`pushNamed` between steps. Use [reset] when the user
/// re-enters the flow from scratch.
class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void reset() => state = const SignupState();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void setProfileImage(File? image) {
    state = state.copyWith(profileImage: image);
  }

  void setSelectedDistance(String? value) {
    state = state.copyWith(selectedDistance: value);
  }

  void setAcceptedTerms(bool value) {
    state = state.copyWith(acceptedTerms: value);
  }

  void setLocationFocused(bool focused) {
    state = state.copyWith(
      isLocationFocused: focused,
      showMap: focused ? true : state.showMap,
    );
  }

  void setCurrentLatLng(LatLng latLng, {String? address}) {
    state = state.copyWith(
      currentLatLng: latLng,
      selectedAddress: address ?? state.selectedAddress,
      showMap: true,
    );
  }

  void updateAddress(String address) {
    state = state.copyWith(selectedAddress: address);
  }

  int calculateStep1Progress({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    const int totalFields = 7;
    int filled = 0;
    if (firstName.trim().isNotEmpty) filled++;
    if (lastName.trim().isNotEmpty) filled++;
    if (email.trim().isNotEmpty) filled++;
    if (password.trim().isNotEmpty) filled++;
    if (confirmPassword.trim().isNotEmpty) filled++;
    if (state.profileImage != null) filled++;
    if (state.selectedDistance != null && state.selectedDistance!.isNotEmpty) {
      filled++;
    }
    return ((filled / totalFields) * 30).toInt();
  }

  Future<bool> submitStep1({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String location,
  }) async {
    if (password != confirmPassword) {
      state = state.copyWith(
        errorMessage: 'Password and Confirm Password do not match',
      );
      return false;
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid email address',
      );
      return false;
    }
    if (!state.acceptedTerms) {
      state = state.copyWith(errorMessage: 'Please accept Terms & Conditions');
      return false;
    }
    if (state.profileImage == null) {
      state = state.copyWith(errorMessage: 'Please upload profile picture');
      return false;
    }
    if (state.selectedDistance == null || state.selectedDistance!.isEmpty) {
      state = state.copyWith(errorMessage: 'Please select working distance');
      return false;
    }
    if (state.currentLatLng == null) {
      state = state.copyWith(errorMessage: 'Please select location on map');
      return false;
    }

    state = state.copyWith(
      isSubmittingStep1: true,
      clearError: true,
      clearToast: true,
    );

    try {
      final progress = calculateStep1Progress(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      final crewMemberId =
          await ref.read(signupRepositoryProvider).registerStep1(
                Step1Payload(
                  firstName: firstName.trim(),
                  lastName: lastName.trim(),
                  email: email.trim(),
                  phone: phone.trim(),
                  password: password.trim(),
                  location: location.trim(),
                  workingDistance: state.selectedDistance!,
                  latitude: state.currentLatLng!.latitude,
                  longitude: state.currentLatLng!.longitude,
                  profileImage: state.profileImage!,
                ),
              );
      state = state.copyWith(
        isSubmittingStep1: false,
        step1Success: true,
        crewMemberId: crewMemberId,
        step1Progress: progress,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        location: location.trim(),
        workingDistance: state.selectedDistance!,
      );
      return true;
    } catch (e, st) {
      AppLogger.e('Signup.submitStep1 failed', e, st);
      state = state.copyWith(
        isSubmittingStep1: false,
        errorMessage: _formatError(e) ?? 'Something went wrong',
      );
      return false;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> loadStep2Lookups() async {
    state = state.copyWith(isLoadingLookups: true, clearError: true);
    try {
      final repo = ref.read(signupRepositoryProvider);
      final roles = await repo.fetchRoles();
      final skills = await repo.fetchSkills();
      state = state.copyWith(
        roles: roles,
        skills: skills,
        isLoadingLookups: false,
      );
    } catch (e, st) {
      AppLogger.e('Signup.loadStep2Lookups failed', e, st);
      state = state.copyWith(
        isLoadingLookups: false,
        errorMessage: _formatError(e) ?? 'Failed to load options',
      );
    }
  }

  Future<void> searchEquipments(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(equipmentSuggestions: const []);
      return;
    }
    state = state.copyWith(isLoadingEquipments: true);
    try {
      final results = await ref
          .read(signupRepositoryProvider)
          .searchEquipments(query.trim());
      state = state.copyWith(
        equipmentSuggestions: results,
        isLoadingEquipments: false,
      );
    } catch (e, st) {
      AppLogger.e('Signup.searchEquipments failed', e, st);
      state = state.copyWith(isLoadingEquipments: false);
    }
  }

  void toggleRole(String name, {required bool selected}) {
    final next = [...state.selectedRoles];
    if (selected) {
      if (!next.contains(name)) next.add(name);
    } else {
      next.remove(name);
    }
    state = state.copyWith(selectedRoles: next);
  }

  void toggleSkill(String name, {required bool selected}) {
    final next = [...state.selectedSkills];
    if (selected) {
      if (!next.contains(name)) next.add(name);
    } else {
      next.remove(name);
    }
    state = state.copyWith(selectedSkills: next);
  }

  void addEquipment(String name) {
    if (state.selectedEquipments.contains(name)) {
      state = state.copyWith(equipmentSuggestions: const []);
      return;
    }
    state = state.copyWith(
      selectedEquipments: [...state.selectedEquipments, name],
      equipmentSuggestions: const [],
    );
  }

  void removeEquipment(String name) {
    state = state.copyWith(
      selectedEquipments:
          state.selectedEquipments.where((e) => e != name).toList(),
    );
  }

  int calculateStep2Progress({
    required String yearsOfExperience,
    required String hourlyRate,
    required String bio,
  }) {
    const int totalFields = 6;
    int filled = 0;
    if (state.selectedRoles.isNotEmpty) filled++;
    if (yearsOfExperience.trim().isNotEmpty) filled++;
    if (hourlyRate.trim().isNotEmpty) filled++;
    if (bio.trim().isNotEmpty) filled++;
    if (state.selectedSkills.isNotEmpty) filled++;
    if (state.selectedEquipments.isNotEmpty) filled++;
    return state.step1Progress + ((filled / totalFields) * 40).toInt();
  }

  Future<bool> submitStep2({
    required String yearsOfExperience,
    required String hourlyRate,
    required String bio,
  }) async {
    final crewMemberId = state.crewMemberId;
    if (crewMemberId == null) {
      state = state.copyWith(errorMessage: 'Missing crew member id');
      return false;
    }

    state = state.copyWith(
      isSubmittingStep2: true,
      clearError: true,
      clearToast: true,
    );

    final roleIds = state.selectedRoles
        .map((name) => _lookupId(state.roles, name))
        .whereType<int>()
        .toList();
    final skillIds = state.selectedSkills
        .map((name) => _lookupId(state.skills, name))
        .whereType<int>()
        .toList();
    final equipmentIds = state.selectedEquipments
        .map((name) => _lookupId(state.equipmentSuggestions, name))
        .whereType<int>()
        .toList();

    try {
      await ref.read(signupRepositoryProvider).registerStep2(
            Step2Payload(
              crewMemberId: crewMemberId,
              primaryRoleIds: roleIds,
              yearsOfExperience: int.tryParse(yearsOfExperience.trim()) ?? 0,
              hourlyRate: int.tryParse(hourlyRate.trim()) ?? 0,
              bio: bio.trim(),
              skillIds: skillIds,
              equipmentIds: equipmentIds,
            ),
          );
      final progress = calculateStep2Progress(
        yearsOfExperience: yearsOfExperience,
        hourlyRate: hourlyRate,
        bio: bio,
      );
      state = state.copyWith(
        isSubmittingStep2: false,
        step2Success: true,
        step2Progress: progress,
      );
      return true;
    } catch (e, st) {
      AppLogger.e('Signup.submitStep2 failed', e, st);
      state = state.copyWith(
        isSubmittingStep2: false,
        errorMessage: _formatError(e) ?? 'Something went wrong',
      );
      return false;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Seed the step-2 carry-through display fields from route-extra. Called
  /// once per signup3 mount so the preview card has data even on cold entry.
  /// Also adopts a routed `crewMemberId` when notifier state was lost (e.g.
  /// hot restart between steps).
  void seedStep3FromRoute({
    int? crewMemberId,
    String primaryRole = '',
    String experience = '',
    String hourlyRate = '',
    String bio = '',
    String skills = '',
    String equipments = '',
    int step2Progress = 0,
  }) {
    state = state.copyWith(
      crewMemberId: state.crewMemberId ?? crewMemberId,
      step2Progress:
          state.step2Progress != 0 ? state.step2Progress : step2Progress,
      primaryRoleDisplay: primaryRole,
      experienceDisplay: experience,
      hourlyRateDisplay: hourlyRate,
      bioDisplay: bio,
      skillsDisplay: skills,
      equipmentsDisplay: equipments,
    );
  }

  void setSocialLinks(List<Map<String, dynamic>> next) {
    state = state.copyWith(savedSocialLinks: next);
  }

  void removeSocialLinkAt(int index) {
    final next = [...state.savedSocialLinks]..removeAt(index);
    state = state.copyWith(savedSocialLinks: next);
  }

  void setPortfolioLinks(List<Map<String, dynamic>> next) {
    state = state.copyWith(savedPortfolioLinks: next);
  }

  void removePortfolioLinkAt(int index) {
    final next = [...state.savedPortfolioLinks]..removeAt(index);
    state = state.copyWith(savedPortfolioLinks: next);
  }

  void setFeaturedProjects(
    List<List<File>> projects,
    List<String> titles,
  ) {
    state = state.copyWith(
      featuredProjects: projects,
      featuredProjectsTitles: titles,
    );
  }

  void removeFeaturedProjectAt(int index) {
    final projects = [...state.featuredProjects]..removeAt(index);
    final titles = [...state.featuredProjectsTitles];
    if (index < titles.length) titles.removeAt(index);
    state = state.copyWith(
      featuredProjects: projects,
      featuredProjectsTitles: titles,
    );
  }

  void addCertificate(File file) {
    state = state.copyWith(
      certificateFiles: [...state.certificateFiles, file],
    );
  }

  void removeCertificateAt(int index) {
    final next = [...state.certificateFiles]..removeAt(index);
    state = state.copyWith(certificateFiles: next);
  }

  void setResumeFile(File? file) {
    state = state.copyWith(
      resumeFile: file,
      clearResumeFile: file == null,
    );
  }

  void setPortfolioFile(File? file) {
    state = state.copyWith(
      portfolioFile: file,
      clearPortfolioFile: file == null,
    );
  }

  int calculateStep3Progress() {
    const int total = 5;
    int filled = 0;
    if (state.savedSocialLinks.isNotEmpty) filled++;
    if (state.featuredProjects.isNotEmpty) filled++;
    if (state.certificateFiles.isNotEmpty) filled++;
    if (state.resumeFile != null) filled++;
    if (state.portfolioFile != null || state.savedPortfolioLinks.isNotEmpty) {
      filled++;
    }
    return state.step2Progress + ((filled / total) * 30).toInt();
  }

  Future<bool> submitStep3() async {
    final crewMemberId = state.crewMemberId;
    if (crewMemberId == null) {
      state = state.copyWith(errorMessage: 'Missing crew member id');
      return false;
    }

    state = state.copyWith(
      isSubmittingStep3: true,
      clearError: true,
      clearToast: true,
    );

    final recentWorkFiles = <File>[];
    final recentWorkIndexes = <int>[];
    for (var i = 0; i < state.featuredProjects.length; i++) {
      for (final f in state.featuredProjects[i]) {
        recentWorkFiles.add(f);
        recentWorkIndexes.add(i);
      }
    }

    final socialLinks = state.savedSocialLinks
        .map((e) => {
              'platform': signup3SocialPlatformKey(e['name'].toString()),
              'url': signup3NormalizeUrl(e['url']),
            })
        .toList();
    final portfolioLinks = state.savedPortfolioLinks
        .map((e) => {
              'platform':
                  signup3PortfolioPlatformKey(e['name'].toString()),
              'url': signup3NormalizeUrl(e['url']),
            })
        .toList();
    final featuredWork = List<Map<String, dynamic>>.generate(
      state.featuredProjects.length,
      (i) => {
        'work_title': i < state.featuredProjectsTitles.length
            ? state.featuredProjectsTitles[i]
            : '',
        'tags': state.selectedFeaturedTags,
      },
    );

    try {
      await ref.read(signupRepositoryProvider).registerStep3(
            Step3Payload(
              crewMemberId: crewMemberId,
              socialMediaLinks: socialLinks,
              portfolioLinks: portfolioLinks,
              featuredWork: featuredWork,
              certificationFiles: state.certificateFiles,
              resume: state.resumeFile,
              portfolio: state.portfolioFile,
              recentWorkMediaFiles: recentWorkFiles,
              recentWorkMediaIndexes: recentWorkIndexes,
            ),
          );
      state = state.copyWith(
        isSubmittingStep3: false,
        step3Success: true,
        step3Progress: calculateStep3Progress(),
      );
      return true;
    } catch (e, st) {
      AppLogger.e('Signup.submitStep3 failed', e, st);
      state = state.copyWith(
        isSubmittingStep3: false,
        errorMessage: _formatError(e) ?? 'Something went wrong',
      );
      return false;
    }
  }

  int? _lookupId(List<LookupOption> options, String name) {
    for (final o in options) {
      if (o.name == name) return o.id;
    }
    return null;
  }

  String? _formatError(Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '');
    return raw.isEmpty ? null : raw;
  }
}

final signupNotifierProvider =
    NotifierProvider<SignupNotifier, SignupState>(SignupNotifier.new);
