import 'dart:async' show unawaited;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/telemetry_client.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/session/session_store.dart';
import '../../../../core/session/temporary_auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/signup_resume_repository_impl.dart';
import '../../domain/models/signup_step1_prefill.dart';
import '../../domain/models/working_distance_options.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/signup_resume_repository.dart';
import '../widgets/signup3_constants.dart';
import 'signup_state.dart';

final signupRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(dioClientProvider)),
);

final signupResumeRepositoryProvider = Provider<SignupResumeRepository>(
  (ref) => SignupResumeRepositoryImpl(ref.read(dioClientProvider)),
);

/// Shared across SignUp1 + SignUp2 (and forward into SignUp3). Plain
/// `NotifierProvider` (not auto-dispose) so accumulated state survives
/// `context.goNamed`/`pushNamed` between steps. Use [reset] when the user
/// re-enters the flow from scratch.
class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void reset() => state = const SignupState();

  /// Abandon an in-progress signup and return to a clean unauthenticated
  /// state. Drops the process-only signup token so it can never leak past the
  /// flow, and — for a resume session that arrived already authenticated —
  /// performs a full logout so the router redirect stops steering back into
  /// the signup steps. Caller navigates to Login afterwards.
  Future<void> cancelSignup() async {
    ref.read(temporaryAuthSessionProvider.notifier).clear();
    if (ref.read(authStateProvider)) {
      await ref.read(authStateProvider.notifier).logout();
    }
    reset();
  }

  void prefillStep1(UserSnapshot user) {
    final nameParts = (user.name ?? '').trim().split(RegExp(r'\s+'));
    final fallbackFirstName = nameParts.firstOrNull ?? '';
    final fallbackLastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';
    final workingDistance = canonicalSignupWorkingDistance(
      user.workingDistance,
    );
    state = state.copyWith(
      firstName: user.firstName ?? fallbackFirstName,
      lastName: user.lastName ?? fallbackLastName,
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      location: user.location ?? '',
      selectedAddress: user.location ?? state.selectedAddress,
      workingDistance: workingDistance ?? '',
      selectedDistance: workingDistance,
      crewMemberId: user.crewMemberId,
      remoteProfileImageUrl: user.profileImageUrl ?? '',
    );
  }

  Future<bool> loadStep1Prefill() async {
    final temporarySession = ref.read(temporaryAuthSessionProvider);
    final temporaryUser = temporarySession.user;
    if (!temporarySession.isActive || temporaryUser == null) return true;
    prefillStep1(temporaryUser);
    state = state.copyWith(
      isLoadingStep1Prefill: true,
      clearStep1PrefillError: true,
    );

    try {
      final prefill = await ref
          .read(signupResumeRepositoryProvider)
          .fetchStep1Prefill();
      _applyApiPrefill(prefill);
      _updateTemporaryUser(prefill);
      state = state.copyWith(isLoadingStep1Prefill: false);
      return true;
    } catch (e, st) {
      AppLogger.e('Signup.loadStep1Prefill failed', e, st);
      state = state.copyWith(
        isLoadingStep1Prefill: false,
        step1PrefillError:
            'Could not refresh profile details. Showing login data.',
      );
      return false;
    }
  }

  void _applyApiPrefill(SignupStep1Prefill prefill) {
    final hasCoordinates =
        prefill.latitude != null && prefill.longitude != null;
    final workingDistance = canonicalSignupWorkingDistance(
      prefill.workingDistance,
    );
    final roleNames = _optionNames(prefill.primaryRoles);
    final skillNames = _optionNames(prefill.skills);
    final equipmentNames = _optionNames(prefill.equipments);
    final roleIds = _optionIds(prefill.primaryRoles);
    final skillIds = _optionIds(prefill.skills);
    final equipmentIds = _optionIds(prefill.equipments);
    final socialLinks = prefill.socialMediaLinks
        .map(
          (e) => <String, dynamic>{
            'name': signup3SocialDisplayName(e['platform']?.toString() ?? ''),
            'url': e['url']?.toString() ?? '',
            'icon': signup3SocialIcon(e['platform']?.toString() ?? ''),
          },
        )
        .where((e) => e['name'] != '' && e['url'] != '')
        .toList();
    final portfolioLinks = prefill.portfolioLinks
        .map(
          (e) => <String, dynamic>{
            'name': signup3PortfolioDisplayName(
              e['platform']?.toString() ?? '',
            ),
            'url': e['url']?.toString() ?? '',
            'icon': signup3PortfolioIcon(e['platform']?.toString() ?? ''),
          },
        )
        .where((e) => e['name'] != '' && e['url'] != '')
        .toList();
    state = state.copyWith(
      firstName: _prefer(prefill.firstName, state.firstName),
      lastName: _prefer(prefill.lastName, state.lastName),
      email: _prefer(prefill.email, state.email),
      phone: _prefer(prefill.phone, state.phone),
      location: _prefer(prefill.location, state.location),
      selectedAddress: _prefer(prefill.location, state.selectedAddress),
      workingDistance: workingDistance ?? state.workingDistance,
      selectedDistance: workingDistance ?? state.selectedDistance,
      crewMemberId: prefill.crewMemberId ?? state.crewMemberId,
      remoteProfileImageUrl: _prefer(
        prefill.profileImageUrl,
        state.remoteProfileImageUrl,
      ),
      currentLatLng: hasCoordinates
          ? LatLng(prefill.latitude!, prefill.longitude!)
          : state.currentLatLng,
      showMap: hasCoordinates || state.showMap,
      roles: _mergeOptions(state.roles, prefill.primaryRoles),
      skills: _mergeOptions(state.skills, prefill.skills),
      equipmentSuggestions: _mergeOptions(
        state.equipmentSuggestions,
        prefill.equipments,
      ),
      selectedRoles: roleNames.isEmpty ? state.selectedRoles : roleNames,
      selectedSkills: skillNames.isEmpty ? state.selectedSkills : skillNames,
      selectedEquipments: equipmentNames.isEmpty
          ? state.selectedEquipments
          : equipmentNames,
      selectedRoleIds: roleIds.isEmpty ? state.selectedRoleIds : roleIds,
      selectedSkillIds: skillIds.isEmpty ? state.selectedSkillIds : skillIds,
      selectedEquipmentIds: equipmentIds.isEmpty
          ? state.selectedEquipmentIds
          : equipmentIds,
      primaryRoleDisplay: roleNames.isEmpty
          ? state.primaryRoleDisplay
          : roleNames.join(', '),
      experienceDisplay: _prefer(
        prefill.yearsOfExperience,
        state.experienceDisplay,
      ),
      hourlyRateDisplay: _prefer(prefill.hourlyRate, state.hourlyRateDisplay),
      bioDisplay: _prefer(prefill.bio, state.bioDisplay),
      skillsDisplay: skillNames.isEmpty
          ? state.skillsDisplay
          : skillNames.join(', '),
      equipmentsDisplay: equipmentNames.isEmpty
          ? state.equipmentsDisplay
          : equipmentNames.join(', '),
      // getProfile runs once on load; only seed when the user hasn't
      // added links yet so in-session edits are never clobbered.
      savedSocialLinks: state.savedSocialLinks.isNotEmpty || socialLinks.isEmpty
          ? state.savedSocialLinks
          : socialLinks,
      savedPortfolioLinks:
          state.savedPortfolioLinks.isNotEmpty || portfolioLinks.isEmpty
          ? state.savedPortfolioLinks
          : portfolioLinks,
    );
  }

  void _updateTemporaryUser(SignupStep1Prefill prefill) {
    final temporary = ref.read(temporaryAuthSessionProvider);
    final current = temporary.user;
    if (!temporary.isActive || current == null) return;
    ref
        .read(temporaryAuthSessionProvider.notifier)
        .updateUser(
          UserSnapshot(
            id: current.id,
            firstName: _preferNullable(prefill.firstName, current.firstName),
            lastName: _preferNullable(prefill.lastName, current.lastName),
            name: current.name,
            email: _preferNullable(prefill.email, current.email),
            phoneNumber: _preferNullable(prefill.phone, current.phoneNumber),
            location: _preferNullable(prefill.location, current.location),
            workingDistance: _preferNullable(
              prefill.workingDistance,
              current.workingDistance,
            ),
            role: current.role,
            userType: current.userType,
            profileImageUrl: _preferNullable(
              prefill.profileImageUrl,
              current.profileImageUrl,
            ),
            isRegistrationComplete: current.isRegistrationComplete,
            isCrewVerified: current.isCrewVerified,
            isStep2Complete: current.isStep2Complete,
            crewMemberId: prefill.crewMemberId ?? current.crewMemberId,
          ),
        );
  }

  String _prefer(String incoming, String fallback) =>
      incoming.trim().isEmpty ? fallback : incoming.trim();

  String? _preferNullable(String incoming, String? fallback) =>
      incoming.trim().isEmpty ? fallback : incoming.trim();

  /// Fires `signup_started` exactly once per active signup flow. Called from
  /// the first text-field interaction on signup1 — subsequent calls (other
  /// fields, edits, rebuilds) are no-ops courtesy of the
  /// [SignupState.signupStartedEmitted] flag. The flag is cleared by [reset]
  /// when the user re-enters the flow from scratch.
  void markSignupStarted() {
    if (state.signupStartedEmitted) return;
    state = state.copyWith(signupStartedEmitted: true);
    unawaited(ref.read(telemetryClientProvider).signupStarted());
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void setProfileImage(File? image) {
    state = state.copyWith(profileImage: image);
  }

  void setSelectedDistance(String? value) {
    state = state.copyWith(
      selectedDistance: canonicalSignupWorkingDistance(value),
    );
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
    if (state.profileImage != null || state.remoteProfileImageUrl.isNotEmpty) {
      filled++;
    }
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
    if (!isValidEmail(email)) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid email address',
      );
      return false;
    }
    if (!state.acceptedTerms) {
      state = state.copyWith(errorMessage: 'Please accept Terms & Conditions');
      return false;
    }
    if (state.profileImage == null && state.remoteProfileImageUrl.isEmpty) {
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
      final crewMemberId = await ref
          .read(signupRepositoryProvider)
          .registerStep1(
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
              profileImage: state.profileImage,
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
        // Held in memory only so the success screen can auto-login this fresh
        // signup — the register endpoints return no token. Wiped by reset().
        password: password.trim(),
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

  void seedStep2Resume({
    int? crewMemberId,
    String? firstName,
    String? lastName,
    String? email,
    String? location,
    String? workingDistance,
    int step1Progress = 30,
  }) {
    final canonicalDistance = canonicalSignupWorkingDistance(workingDistance);
    state = state.copyWith(
      crewMemberId: crewMemberId ?? state.crewMemberId,
      firstName: _prefer(firstName ?? '', state.firstName),
      lastName: _prefer(lastName ?? '', state.lastName),
      email: _prefer(email ?? '', state.email),
      location: _prefer(location ?? '', state.location),
      selectedAddress: _prefer(location ?? '', state.selectedAddress),
      workingDistance: canonicalDistance ?? state.workingDistance,
      selectedDistance: canonicalDistance ?? state.selectedDistance,
      step1Progress: state.step1Progress == 0
          ? step1Progress
          : state.step1Progress,
    );
  }

  Future<void> loadStep2Lookups() async {
    state = state.copyWith(isLoadingLookups: true, clearError: true);
    try {
      final repo = ref.read(signupRepositoryProvider);
      final roles = await repo.fetchRoles();
      final skills = await repo.fetchSkills();
      final mergedRoles = _mergeOptions(roles, state.roles);
      final mergedSkills = _mergeOptions(skills, state.skills);
      state = state.copyWith(
        roles: mergedRoles,
        skills: mergedSkills,
        selectedRoles: _resolveSelectedNames(
          state.selectedRoles,
          state.selectedRoleIds,
          mergedRoles,
        ),
        selectedSkills: _resolveSelectedNames(
          state.selectedSkills,
          state.selectedSkillIds,
          mergedSkills,
        ),
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
      state = state.copyWith(
        equipmentSuggestions: state.equipmentSuggestions
            .where(
              (option) =>
                  state.selectedEquipmentIds.contains(option.id) ||
                  state.selectedEquipments.contains(option.name),
            )
            .toList(),
      );
      return;
    }
    state = state.copyWith(isLoadingEquipments: true);
    try {
      final results = await ref
          .read(signupRepositoryProvider)
          .searchEquipments(query.trim());
      state = state.copyWith(
        equipmentSuggestions: _mergeOptions(
          results,
          state.equipmentSuggestions,
        ),
        isLoadingEquipments: false,
      );
    } catch (e, st) {
      AppLogger.e('Signup.searchEquipments failed', e, st);
      state = state.copyWith(isLoadingEquipments: false);
    }
  }

  void toggleRole(String name, {required bool selected}) {
    final next = [...state.selectedRoles];
    final nextIds = [...state.selectedRoleIds];
    final id = _lookupId(state.roles, name);
    if (selected) {
      if (!next.contains(name)) next.add(name);
      if (id != null && !nextIds.contains(id)) nextIds.add(id);
    } else {
      next.remove(name);
      if (id != null) nextIds.remove(id);
    }
    state = state.copyWith(selectedRoles: next, selectedRoleIds: nextIds);
  }

  void toggleSkill(String name, {required bool selected}) {
    final next = [...state.selectedSkills];
    final nextIds = [...state.selectedSkillIds];
    final id = _lookupId(state.skills, name);
    if (selected) {
      if (!next.contains(name)) next.add(name);
      if (id != null && !nextIds.contains(id)) nextIds.add(id);
    } else {
      next.remove(name);
      if (id != null) nextIds.remove(id);
    }
    state = state.copyWith(selectedSkills: next, selectedSkillIds: nextIds);
  }

  void addEquipment(String name) {
    if (state.selectedEquipments.contains(name)) return;
    final id = _lookupId(state.equipmentSuggestions, name);
    state = state.copyWith(
      selectedEquipments: [...state.selectedEquipments, name],
      selectedEquipmentIds: id == null
          ? state.selectedEquipmentIds
          : {...state.selectedEquipmentIds, id}.toList(),
    );
  }

  void removeEquipment(String name) {
    final id = _lookupId(state.equipmentSuggestions, name);
    state = state.copyWith(
      selectedEquipments: state.selectedEquipments
          .where((e) => e != name)
          .toList(),
      selectedEquipmentIds: id == null
          ? state.selectedEquipmentIds
          : state.selectedEquipmentIds.where((value) => value != id).toList(),
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

    final roleIds = {
      ...state.selectedRoleIds,
      ...state.selectedRoles
          .map((name) => _lookupId(state.roles, name))
          .whereType<int>(),
    }.toList();
    final skillIds = {
      ...state.selectedSkillIds,
      ...state.selectedSkills
          .map((name) => _lookupId(state.skills, name))
          .whereType<int>(),
    }.toList();
    final equipmentIds = {
      ...state.selectedEquipmentIds,
      ...state.selectedEquipments
          .map((name) => _lookupId(state.equipmentSuggestions, name))
          .whereType<int>(),
    }.toList();

    try {
      await ref
          .read(signupRepositoryProvider)
          .registerStep2(
            Step2Payload(
              crewMemberId: crewMemberId,
              primaryRoleIds: roleIds,
              yearsOfExperience: int.tryParse(yearsOfExperience.trim()) ?? 0,
              hourlyRate: double.tryParse(hourlyRate.trim()) ?? 0.0,
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
      final temporary = ref.read(temporaryAuthSessionProvider);
      final user = temporary.user;
      if (temporary.isActive && user != null) {
        ref
            .read(temporaryAuthSessionProvider.notifier)
            .updateUser(
              UserSnapshot(
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                name: user.name,
                email: user.email,
                phoneNumber: user.phoneNumber,
                location: user.location,
                workingDistance: user.workingDistance,
                role: user.role,
                userType: user.userType,
                profileImageUrl: user.profileImageUrl,
                isRegistrationComplete: user.isRegistrationComplete,
                isCrewVerified: user.isCrewVerified,
                isStep2Complete: true,
                crewMemberId: user.crewMemberId,
              ),
            );
      }
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
      step2Progress: state.step2Progress != 0
          ? state.step2Progress
          : step2Progress,
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

  void setFeaturedProjects(List<List<File>> projects, List<String> titles) {
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
    state = state.copyWith(certificateFiles: [...state.certificateFiles, file]);
  }

  void removeCertificateAt(int index) {
    final next = [...state.certificateFiles]..removeAt(index);
    state = state.copyWith(certificateFiles: next);
  }

  void setResumeFile(File? file) {
    state = state.copyWith(resumeFile: file, clearResumeFile: file == null);
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
    if (state.savedSocialLinks.isEmpty) {
      state = state.copyWith(errorMessage: 'Please add at least 1 social link');
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
        .map(
          (e) => {
            'platform': signup3SocialPlatformKey(e['name'].toString()),
            'url': signup3NormalizeUrl(e['url']),
          },
        )
        .toList();
    final portfolioLinks = state.savedPortfolioLinks
        .map(
          (e) => {
            'platform': signup3PortfolioPlatformKey(e['name'].toString()),
            'url': signup3NormalizeUrl(e['url']),
          },
        )
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
      await ref
          .read(signupRepositoryProvider)
          .registerStep3(
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
      unawaited(
        ref
            .read(telemetryClientProvider)
            .signupCompleted(
              hasResume: state.resumeFile != null,
              hasFeaturedWork: state.featuredProjects.isNotEmpty,
              socialCount: state.savedSocialLinks.length,
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
      if (o.name == name && o.id > 0) return o.id;
    }
    return null;
  }

  List<int> _optionIds(List<LookupOption> options) =>
      options.map((option) => option.id).where((id) => id > 0).toSet().toList();

  List<String> _optionNames(List<LookupOption> options) => options
      .map((option) => option.name.trim())
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList();

  List<LookupOption> _mergeOptions(
    List<LookupOption> preferred,
    List<LookupOption> fallback,
  ) {
    final merged = <LookupOption>[];
    final ids = <int>{};
    final names = <String>{};
    for (final option in [...preferred, ...fallback]) {
      final normalizedName = option.name.trim().toLowerCase();
      if (option.id > 0 && ids.contains(option.id)) continue;
      if (normalizedName.isNotEmpty && names.contains(normalizedName)) continue;
      merged.add(option);
      if (option.id > 0) ids.add(option.id);
      if (normalizedName.isNotEmpty) names.add(normalizedName);
    }
    return merged;
  }

  List<String> _resolveSelectedNames(
    List<String> existingNames,
    List<int> selectedIds,
    List<LookupOption> options,
  ) {
    final resolved = <String>{
      ...existingNames
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty),
    };
    for (final option in options) {
      if (selectedIds.contains(option.id) && option.name.trim().isNotEmpty) {
        resolved.add(option.name.trim());
      }
    }
    return resolved.toList();
  }

  String? _formatError(Object e) {
    // Unwrap the typed AppException the ErrorInterceptor attaches so the user
    // sees the clean server message (e.g. "Email already registered.") instead
    // of the raw DioException dump.
    AppException? typed;
    if (e is AppException) {
      typed = e;
    } else if (e is DioException && e.error is AppException) {
      typed = e.error as AppException;
    }
    if (typed != null) {
      final msg = typed.message.trim();
      if (msg.isNotEmpty) return msg;
    }
    final raw = e.toString().replaceFirst('Exception: ', '');
    if (raw.startsWith('DioException')) return null;
    return raw.isEmpty ? null : raw;
  }
}

final signupNotifierProvider = NotifierProvider<SignupNotifier, SignupState>(
  SignupNotifier.new,
);
