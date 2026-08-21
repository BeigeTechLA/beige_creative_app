import 'dart:io';

import 'package:flutter/foundation.dart';

/// Typed args for `/signup-step-2`. Mirrors the existing `state.extra` map
/// shape so legacy callers can migrate in one step.
@immutable
class SignUpStep2Args {
  const SignUpStep2Args({
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,
    this.step1Progress = 0,
    this.isResume = false,
  });

  final int? crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? location;
  final String? workingDistance;
  final int step1Progress;

  /// True when the user reached this step via the login-resume path (profile
  /// incomplete). Step 1 is already done, so the stepper collapses to 2 steps.
  final bool isResume;

  Map<String, dynamic> toExtra() => {
        'crewMemberId': crewMemberId,
        'profileImage': profileImage,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'location': location,
        'workingDistance': workingDistance,
        'step1Progress': step1Progress,
        'isResume': isResume,
      };

  factory SignUpStep2Args.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return SignUpStep2Args(
      crewMemberId: m['crewMemberId'] as int?,
      profileImage: m['profileImage'] as File?,
      email: m['email'] as String?,
      firstName: m['firstName'] as String?,
      lastName: m['lastName'] as String?,
      location: m['location'] as String?,
      workingDistance: m['workingDistance'] as String?,
      step1Progress: (m['step1Progress'] as int?) ?? 0,
      isResume: (m['isResume'] as bool?) ?? false,
    );
  }
}

/// Typed args for `/signup-step-3`. Adds step-2 fields onto step-1 shape.
@immutable
class SignUpStep3Args {
  const SignUpStep3Args({
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,
    this.primaryRole = '',
    this.experience = '',
    this.hourlyRate = '',
    this.bio = '',
    this.skills = '',
    this.equipments = '',
    this.step2Progress = 0,
    this.isResume = false,
  });

  final int? crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? location;
  final String? workingDistance;
  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;
  final int step2Progress;

  /// True when the user reached this step via the login-resume path. The
  /// stepper collapses to 2 steps (this is the final one → "2/2").
  final bool isResume;

  Map<String, dynamic> toExtra() => {
        'crewMemberId': crewMemberId,
        'profileImage': profileImage,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'location': location,
        'workingDistance': workingDistance,
        'primaryRole': primaryRole,
        'experience': experience,
        'hourlyRate': hourlyRate,
        'bio': bio,
        'skills': skills,
        'equipments': equipments,
        'step2Progress': step2Progress,
        'isResume': isResume,
      };

  factory SignUpStep3Args.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return SignUpStep3Args(
      crewMemberId: m['crewMemberId'] as int?,
      profileImage: m['profileImage'] as File?,
      email: m['email'] as String?,
      firstName: m['firstName'] as String?,
      lastName: m['lastName'] as String?,
      location: m['location'] as String?,
      workingDistance: m['workingDistance'] as String?,
      primaryRole: (m['primaryRole'] as String?) ?? '',
      experience: (m['experience'] as String?) ?? '',
      hourlyRate: (m['hourlyRate'] as String?) ?? '',
      bio: (m['bio'] as String?) ?? '',
      skills: (m['skills'] as String?) ?? '',
      equipments: (m['equipments'] as String?) ?? '',
      step2Progress: (m['step2Progress'] as int?) ?? 0,
      isResume: (m['isResume'] as bool?) ?? false,
    );
  }
}

/// Typed args for `/view-details` (signup-flow preview). Holds all 13
/// signup fields + a `featuredImages: List<File>`.
@immutable
class ViewDetailsArgs {
  const ViewDetailsArgs({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.location = '',
    this.profileImage,
    this.workingDistance = '',
    this.primaryRole = '',
    this.experience = '',
    this.hourlyRate = '',
    this.bio = '',
    this.skills = '',
    this.equipments = '',
    this.featuredImages = const <File>[],
  });

  final String firstName;
  final String lastName;
  final String email;
  final String location;
  final File? profileImage;
  final String workingDistance;
  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;
  final List<File> featuredImages;

  Map<String, dynamic> toExtra() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'location': location,
        'profileImage': profileImage,
        'workingDistance': workingDistance,
        'primaryRole': primaryRole,
        'experience': experience,
        'hourlyRate': hourlyRate,
        'bio': bio,
        'skills': skills,
        'equipments': equipments,
        'featuredImages': featuredImages,
      };

  factory ViewDetailsArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return ViewDetailsArgs(
      firstName: (m['firstName'] as String?) ?? '',
      lastName: (m['lastName'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      location: (m['location'] as String?) ?? '',
      profileImage: m['profileImage'] as File?,
      workingDistance: (m['workingDistance'] as String?) ?? '',
      primaryRole: (m['primaryRole'] as String?) ?? '',
      experience: (m['experience'] as String?) ?? '',
      hourlyRate: (m['hourlyRate'] as String?) ?? '',
      bio: (m['bio'] as String?) ?? '',
      skills: (m['skills'] as String?) ?? '',
      equipments: (m['equipments'] as String?) ?? '',
      featuredImages: (m['featuredImages'] as List?)
              ?.whereType<File>()
              .toList(growable: false) ??
          const <File>[],
    );
  }
}
