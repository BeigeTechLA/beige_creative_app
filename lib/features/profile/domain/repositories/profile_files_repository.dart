import 'dart:io';

import '../../../../model_class/myprofile_model.dart';

/// Shared repository for the three profile-file flows (resume / certificates /
/// featured work). Image upload is also reused by the signup3 flow per Group E
/// Unit 17 — keep multipart helpers generic.
abstract class ProfileFilesRepository {
  Future<MyProfileData> fetchProfile();

  Future<void> uploadResume(File file);

  Future<void> uploadCertificate(File file);

  Future<void> uploadFeaturedWork({
    required String title,
    required List<String> tags,
    required List<File> files,
  });

  Future<void> deleteFile(int id);
}
