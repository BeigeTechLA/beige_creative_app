import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/repositories/auth_repository.dart';

@immutable
class SignupState {
  // Step 1 — collected via widget controllers; notifier owns non-text pieces.
  final File? profileImage;
  final LatLng? currentLatLng;
  final String selectedAddress;
  final bool showMap;
  final bool isLocationFocused;
  final String? selectedDistance;
  final bool acceptedTerms;

  // Step 1 result.
  final int? crewMemberId;
  final bool step1Success;
  final int step1Progress;
  final bool isSubmittingStep1;

  // Captured snapshot of step-1 form values (frozen at submit time so
  // step-2 / step-3 can read them without re-entering controllers).
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final String workingDistance;

  // Step 2 lookups.
  final List<LookupOption> roles;
  final List<LookupOption> skills;
  final List<LookupOption> equipmentSuggestions;
  final bool isLoadingLookups;
  final bool isLoadingEquipments;

  // Step 2 selections.
  final List<String> selectedRoles;
  final List<String> selectedSkills;
  final List<String> selectedEquipments;

  final bool isSubmittingStep2;
  final bool step2Success;
  final int step2Progress;

  // Step 3 selections (mirrors legacy SignUp3ScreenState fields).
  final List<Map<String, dynamic>> savedSocialLinks;
  final List<Map<String, dynamic>> savedPortfolioLinks;
  final List<List<File>> featuredProjects;
  final List<String> featuredProjectsTitles;
  final List<String> selectedFeaturedTags;
  final List<File> certificateFiles;
  final File? resumeFile;
  final File? portfolioFile;

  // Step 3 step-2 carry-through (joined display strings used by preview card).
  final String primaryRoleDisplay;
  final String experienceDisplay;
  final String hourlyRateDisplay;
  final String bioDisplay;
  final String skillsDisplay;
  final String equipmentsDisplay;

  final bool isSubmittingStep3;
  final bool step3Success;
  final int step3Progress;

  /// Sticky flag set the first time the user interacts with any signup1
  /// field — used to fire `signup_started` exactly once per flow without
  /// duplicating on rebuild.
  final bool signupStartedEmitted;

  // Shared error/toast surface.
  final String? errorMessage;
  final String? toastMessage;

  const SignupState({
    this.profileImage,
    this.currentLatLng,
    this.selectedAddress = 'Search or select location',
    this.showMap = false,
    this.isLocationFocused = false,
    this.selectedDistance,
    this.acceptedTerms = false,
    this.crewMemberId,
    this.step1Success = false,
    this.step1Progress = 0,
    this.isSubmittingStep1 = false,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.workingDistance = '',
    this.roles = const [],
    this.skills = const [],
    this.equipmentSuggestions = const [],
    this.isLoadingLookups = false,
    this.isLoadingEquipments = false,
    this.selectedRoles = const [],
    this.selectedSkills = const [],
    this.selectedEquipments = const [],
    this.isSubmittingStep2 = false,
    this.step2Success = false,
    this.step2Progress = 0,
    this.savedSocialLinks = const [],
    this.savedPortfolioLinks = const [],
    this.featuredProjects = const [],
    this.featuredProjectsTitles = const [],
    this.selectedFeaturedTags = const [],
    this.certificateFiles = const [],
    this.resumeFile,
    this.portfolioFile,
    this.primaryRoleDisplay = '',
    this.experienceDisplay = '',
    this.hourlyRateDisplay = '',
    this.bioDisplay = '',
    this.skillsDisplay = '',
    this.equipmentsDisplay = '',
    this.isSubmittingStep3 = false,
    this.step3Success = false,
    this.step3Progress = 0,
    this.signupStartedEmitted = false,
    this.errorMessage,
    this.toastMessage,
  });

  SignupState copyWith({
    File? profileImage,
    LatLng? currentLatLng,
    String? selectedAddress,
    bool? showMap,
    bool? isLocationFocused,
    String? selectedDistance,
    bool? acceptedTerms,
    int? crewMemberId,
    bool? step1Success,
    int? step1Progress,
    bool? isSubmittingStep1,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? location,
    String? workingDistance,
    List<LookupOption>? roles,
    List<LookupOption>? skills,
    List<LookupOption>? equipmentSuggestions,
    bool? isLoadingLookups,
    bool? isLoadingEquipments,
    List<String>? selectedRoles,
    List<String>? selectedSkills,
    List<String>? selectedEquipments,
    bool? isSubmittingStep2,
    bool? step2Success,
    int? step2Progress,
    List<Map<String, dynamic>>? savedSocialLinks,
    List<Map<String, dynamic>>? savedPortfolioLinks,
    List<List<File>>? featuredProjects,
    List<String>? featuredProjectsTitles,
    List<String>? selectedFeaturedTags,
    List<File>? certificateFiles,
    File? resumeFile,
    File? portfolioFile,
    bool clearResumeFile = false,
    bool clearPortfolioFile = false,
    String? primaryRoleDisplay,
    String? experienceDisplay,
    String? hourlyRateDisplay,
    String? bioDisplay,
    String? skillsDisplay,
    String? equipmentsDisplay,
    bool? isSubmittingStep3,
    bool? step3Success,
    int? step3Progress,
    bool? signupStartedEmitted,
    String? errorMessage,
    String? toastMessage,
    bool clearError = false,
    bool clearToast = false,
  }) {
    return SignupState(
      profileImage: profileImage ?? this.profileImage,
      currentLatLng: currentLatLng ?? this.currentLatLng,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      showMap: showMap ?? this.showMap,
      isLocationFocused: isLocationFocused ?? this.isLocationFocused,
      selectedDistance: selectedDistance ?? this.selectedDistance,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      crewMemberId: crewMemberId ?? this.crewMemberId,
      step1Success: step1Success ?? this.step1Success,
      step1Progress: step1Progress ?? this.step1Progress,
      isSubmittingStep1: isSubmittingStep1 ?? this.isSubmittingStep1,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      workingDistance: workingDistance ?? this.workingDistance,
      roles: roles ?? this.roles,
      skills: skills ?? this.skills,
      equipmentSuggestions: equipmentSuggestions ?? this.equipmentSuggestions,
      isLoadingLookups: isLoadingLookups ?? this.isLoadingLookups,
      isLoadingEquipments: isLoadingEquipments ?? this.isLoadingEquipments,
      selectedRoles: selectedRoles ?? this.selectedRoles,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      selectedEquipments: selectedEquipments ?? this.selectedEquipments,
      isSubmittingStep2: isSubmittingStep2 ?? this.isSubmittingStep2,
      step2Success: step2Success ?? this.step2Success,
      step2Progress: step2Progress ?? this.step2Progress,
      savedSocialLinks: savedSocialLinks ?? this.savedSocialLinks,
      savedPortfolioLinks: savedPortfolioLinks ?? this.savedPortfolioLinks,
      featuredProjects: featuredProjects ?? this.featuredProjects,
      featuredProjectsTitles:
          featuredProjectsTitles ?? this.featuredProjectsTitles,
      selectedFeaturedTags:
          selectedFeaturedTags ?? this.selectedFeaturedTags,
      certificateFiles: certificateFiles ?? this.certificateFiles,
      resumeFile:
          clearResumeFile ? null : (resumeFile ?? this.resumeFile),
      portfolioFile:
          clearPortfolioFile ? null : (portfolioFile ?? this.portfolioFile),
      primaryRoleDisplay: primaryRoleDisplay ?? this.primaryRoleDisplay,
      experienceDisplay: experienceDisplay ?? this.experienceDisplay,
      hourlyRateDisplay: hourlyRateDisplay ?? this.hourlyRateDisplay,
      bioDisplay: bioDisplay ?? this.bioDisplay,
      skillsDisplay: skillsDisplay ?? this.skillsDisplay,
      equipmentsDisplay: equipmentsDisplay ?? this.equipmentsDisplay,
      isSubmittingStep3: isSubmittingStep3 ?? this.isSubmittingStep3,
      step3Success: step3Success ?? this.step3Success,
      step3Progress: step3Progress ?? this.step3Progress,
      signupStartedEmitted:
          signupStartedEmitted ?? this.signupStartedEmitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }
}
