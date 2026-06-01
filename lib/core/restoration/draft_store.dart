import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pref keys for draft payloads. Share the `restoration.draft.` prefix so a
/// single sweep clears them all.
abstract class DraftKeys {
  static const _prefix = 'restoration.draft.';

  static const signUp = '${_prefix}sign_up_json';
}

/// JSON storage for multi-step signup draft.
///
/// Drafts mirror the `state.extra` payload accepted by `/signup-step-2/3` so
/// a cold-start restore can rebuild the form without the original navigation
/// call. Files (profile image, featured images) are NOT persisted — user
/// re-picks on resume.
class DraftStore {
  DraftStore(this._prefs);

  final SharedPreferences _prefs;

  // ── SignUpDraft ──────────────────────────────────────────────────────

  Future<void> writeSignUpDraft(SignUpDraft draft) async {
    try {
      await _prefs.setString(DraftKeys.signUp, jsonEncode(draft.toJson()));
    } catch (e) {
      debugPrint('DraftStore.writeSignUpDraft failed: $e');
    }
  }

  SignUpDraft? readSignUpDraft() {
    final raw = _prefs.getString(DraftKeys.signUp);
    if (raw == null || raw.isEmpty) return null;
    try {
      return SignUpDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('DraftStore.readSignUpDraft parse failed: $e');
      _prefs.remove(DraftKeys.signUp);
      return null;
    }
  }

  Future<void> clearSignUpDraft() => _prefs.remove(DraftKeys.signUp);

  /// Wipes every draft key. Called on logout + signup success.
  Future<void> clearAll() async {
    await _prefs.remove(DraftKeys.signUp);
  }
}

// ── Models ────────────────────────────────────────────────────────────

@immutable
class SignUpDraft {
  const SignUpDraft({
    this.crewMemberId,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,
    this.primaryRole,
    this.experience,
    this.hourlyRate,
    this.bio,
    this.skills,
    this.equipments,
    this.step1Progress,
    this.step2Progress,
    this.currentRoute,
  });

  final int? crewMemberId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? location;
  final String? workingDistance;
  final String? primaryRole;
  final String? experience;
  final String? hourlyRate;
  final String? bio;
  final String? skills;
  final String? equipments;
  final int? step1Progress;
  final int? step2Progress;

  /// Last signup-flow route the user reached. Used so splash can re-enter
  /// the wizard at the right step.
  final String? currentRoute;

  Map<String, dynamic> toJson() => {
        if (crewMemberId != null) 'crewMemberId': crewMemberId,
        if (email != null) 'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (location != null) 'location': location,
        if (workingDistance != null) 'workingDistance': workingDistance,
        if (primaryRole != null) 'primaryRole': primaryRole,
        if (experience != null) 'experience': experience,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (bio != null) 'bio': bio,
        if (skills != null) 'skills': skills,
        if (equipments != null) 'equipments': equipments,
        if (step1Progress != null) 'step1Progress': step1Progress,
        if (step2Progress != null) 'step2Progress': step2Progress,
        if (currentRoute != null) 'currentRoute': currentRoute,
      };

  factory SignUpDraft.fromJson(Map<String, dynamic> json) => SignUpDraft(
        crewMemberId: _asInt(json['crewMemberId']),
        email: json['email'] as String?,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        location: json['location'] as String?,
        workingDistance: json['workingDistance'] as String?,
        primaryRole: json['primaryRole'] as String?,
        experience: json['experience'] as String?,
        hourlyRate: json['hourlyRate'] as String?,
        bio: json['bio'] as String?,
        skills: json['skills'] as String?,
        equipments: json['equipments'] as String?,
        step1Progress: _asInt(json['step1Progress']),
        step2Progress: _asInt(json['step2Progress']),
        currentRoute: json['currentRoute'] as String?,
      );

  /// Convenience builder from the `state.extra` map shape used by the
  /// existing signup routes.
  factory SignUpDraft.fromRouteExtra(
    Map<String, dynamic>? extra, {
    String? currentRoute,
  }) {
    final map = extra ?? const <String, dynamic>{};
    return SignUpDraft(
      crewMemberId: _asInt(map['crewMemberId']),
      email: map['email'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      location: map['location'] as String?,
      workingDistance: map['workingDistance'] as String?,
      primaryRole: map['primaryRole'] as String?,
      experience: map['experience'] as String?,
      hourlyRate: map['hourlyRate'] as String?,
      bio: map['bio'] as String?,
      skills: map['skills'] as String?,
      equipments: map['equipments'] as String?,
      step1Progress: _asInt(map['step1Progress']),
      step2Progress: _asInt(map['step2Progress']),
      currentRoute: currentRoute,
    );
  }

  /// Merges [other]'s non-null fields into this draft (this takes precedence).
  SignUpDraft mergeOver(SignUpDraft other) => SignUpDraft(
        crewMemberId: crewMemberId ?? other.crewMemberId,
        email: email ?? other.email,
        firstName: firstName ?? other.firstName,
        lastName: lastName ?? other.lastName,
        location: location ?? other.location,
        workingDistance: workingDistance ?? other.workingDistance,
        primaryRole: primaryRole ?? other.primaryRole,
        experience: experience ?? other.experience,
        hourlyRate: hourlyRate ?? other.hourlyRate,
        bio: bio ?? other.bio,
        skills: skills ?? other.skills,
        equipments: equipments ?? other.equipments,
        step1Progress: step1Progress ?? other.step1Progress,
        step2Progress: step2Progress ?? other.step2Progress,
        currentRoute: currentRoute ?? other.currentRoute,
      );
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
