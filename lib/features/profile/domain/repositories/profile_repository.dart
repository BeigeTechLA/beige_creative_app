import 'dart:io';

import '../../../../model_class/edit_profile_model.dart';

abstract class ProfileRepository {
  /// POST `creator/edit-profile` with empty body — backend returns the
  /// hydrated edit form snapshot.
  Future<EditProfileModel> fetchEditProfile();

  /// POST `creator/edit-profile` with field map. Backend silently merges the
  /// updates; success surfaces as `error == false`.
  Future<void> updateProfile(Map<String, dynamic> body);

  /// GET `auth/crew-roles` → map of role label → role id.
  Future<Map<String, int>> fetchRoles();

  /// GET `auth/skills` → map of skill name → id.
  Future<Map<String, int>> fetchSkills();

  /// Multipart upload of `profile_photo`. Returns the new relative URL the
  /// backend persisted (empty string if backend echoed none).
  Future<String> uploadPhoto(File file, {String? crewMemberId});

  /// Replace the entire social-media-links list on the user record.
  /// POST `creator/edit-profile { social_media_links: [...] }`.
  Future<void> updateSocialLinks(List<Map<String, String>> links);

  /// Append portfolio links. POST `creator/profile/add-portfolio-links`.
  Future<void> addPortfolioLinks(List<Map<String, dynamic>> links);

  /// Edit a single portfolio link by id. POST `creator/profile/edit-portfolio-link/$id`.
  Future<void> editPortfolioLink({
    required int id,
    required String url,
    required String platform,
    required String title,
  });
}
