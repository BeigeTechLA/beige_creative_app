import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/myprofile_model.dart';
import '../widgets/profile_link_mappers.dart';
import 'profile_details_providers.dart' show profileRepositoryProvider;
import 'profile_files_providers.dart' show profileFilesRepositoryProvider;

@immutable
class MyProfileState {
  final Data? profile;
  final List<Map<String, String>> socialLinks;
  final List<Map<String, String>> portfolioLinks;
  final int selectedSocialIndex;
  final int selectedPortfolioIndex;
  final int editingIndex;
  final bool isEditing;
  final bool isLoading;
  final bool isUploadingImage;
  final String? errorMessage;
  final String? toastMessage;
  final int dismissSheetSignal;
  final int saveAllSocialSuccess;
  final int saveAllPortfolioSuccess;

  const MyProfileState({
    this.profile,
    this.socialLinks = const [],
    this.portfolioLinks = const [],
    this.selectedSocialIndex = -1,
    this.selectedPortfolioIndex = -1,
    this.editingIndex = -1,
    this.isEditing = false,
    this.isLoading = false,
    this.isUploadingImage = false,
    this.errorMessage,
    this.toastMessage,
    this.dismissSheetSignal = 0,
    this.saveAllSocialSuccess = 0,
    this.saveAllPortfolioSuccess = 0,
  });

  MyProfileState copyWith({
    Data? profile,
    List<Map<String, String>>? socialLinks,
    List<Map<String, String>>? portfolioLinks,
    int? selectedSocialIndex,
    int? selectedPortfolioIndex,
    int? editingIndex,
    bool? isEditing,
    bool? isLoading,
    bool? isUploadingImage,
    String? errorMessage,
    String? toastMessage,
    int? dismissSheetSignal,
    int? saveAllSocialSuccess,
    int? saveAllPortfolioSuccess,
    bool clearMessages = false,
  }) {
    return MyProfileState(
      profile: profile ?? this.profile,
      socialLinks: socialLinks ?? this.socialLinks,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      selectedSocialIndex: selectedSocialIndex ?? this.selectedSocialIndex,
      selectedPortfolioIndex:
          selectedPortfolioIndex ?? this.selectedPortfolioIndex,
      editingIndex: editingIndex ?? this.editingIndex,
      isEditing: isEditing ?? this.isEditing,
      isLoading: isLoading ?? this.isLoading,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
      toastMessage:
          clearMessages ? null : (toastMessage ?? this.toastMessage),
      dismissSheetSignal: dismissSheetSignal ?? this.dismissSheetSignal,
      saveAllSocialSuccess: saveAllSocialSuccess ?? this.saveAllSocialSuccess,
      saveAllPortfolioSuccess:
          saveAllPortfolioSuccess ?? this.saveAllPortfolioSuccess,
    );
  }
}

class MyProfileNotifier extends AutoDisposeNotifier<MyProfileState> {
  // Mutable backing lists handed to bottom sheets so they can mutate in place.
  // After each mutation the sheet/parent calls `commitSocial` / `commitPortfolio`
  // which emits a fresh immutable copy in `state`.
  final List<Map<String, String>> _socialLinks = [];
  final List<Map<String, String>> _portfolioLinks = [];

  List<Map<String, String>> get mutableSocialLinks => _socialLinks;
  List<Map<String, String>> get mutablePortfolioLinks => _portfolioLinks;

  @override
  MyProfileState build() {
    Future.microtask(refresh);
    return const MyProfileState(isLoading: true);
  }

  // ───── Fetch
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final data = await ref.read(profileFilesRepositoryProvider).fetchProfile();
      _hydrateSocialLinks(data.socialMediaLinks);
      _hydratePortfolioLinks(
        (data.portfolioLinks.isNotEmpty
                ? data.portfolioLinks
                : data.crewMemberFiles)
            .where((e) => e.fileType == 'link')
            .toList(),
      );
      state = state.copyWith(
        profile: data,
        isLoading: false,
        socialLinks: List<Map<String, String>>.from(_socialLinks),
        portfolioLinks: List<Map<String, String>>.from(_portfolioLinks),
      );
    } catch (e, st) {
      AppLogger.e('MyProfile fetch failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile',
      );
    }
  }

  void _hydrateSocialLinks(Map<String, dynamic> links) {
    _socialLinks.clear();
    if (links.isEmpty) return;
    links.forEach((key, value) {
      _socialLinks.add({
        'name': key[0].toUpperCase() + key.substring(1),
        'url': value.toString(),
        'icon': socialIcon(key),
      });
    });
  }

  void _hydratePortfolioLinks(List<CrewFile> links) {
    _portfolioLinks.clear();
    for (final item in links.where((e) => e.fileType == 'link')) {
      final platformKey = item.tag.isNotEmpty ? item.tag : item.title;
      _portfolioLinks.add({
        'id': item.crewFilesId.toString(),
        'name': formatPortfolioName(platformKey),
        'url': item.filePath,
        'icon': portfolioIcon(platformKey),
      });
    }
  }

  // ───── Photo upload
  Future<bool> uploadPhoto(File file) async {
    state = state.copyWith(isUploadingImage: true, clearMessages: true);
    try {
      await ref.read(profileRepositoryProvider).uploadPhoto(
            file,
            crewMemberId: state.profile?.crewMemberId.toString(),
          );
      await refresh();
      state = state.copyWith(isUploadingImage: false);
      return true;
    } catch (e, st) {
      AppLogger.e('MyProfile uploadPhoto failed', e, st);
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Photo upload failed',
      );
      return false;
    }
  }

  // ───── Sheet mutation commits
  void commitSocial() {
    state = state.copyWith(
      socialLinks: List<Map<String, String>>.from(_socialLinks),
    );
  }

  void commitPortfolio() {
    state = state.copyWith(
      portfolioLinks: List<Map<String, String>>.from(_portfolioLinks),
    );
  }

  void setSocialSelection({
    int? selectedIndex,
    int? editingIndex,
    bool? isEditing,
  }) {
    state = state.copyWith(
      selectedSocialIndex: selectedIndex,
      editingIndex: editingIndex,
      isEditing: isEditing,
    );
  }

  void setPortfolioSelection({
    int? selectedIndex,
    int? editingIndex,
  }) {
    state = state.copyWith(
      selectedPortfolioIndex: selectedIndex,
      editingIndex: editingIndex,
    );
  }

  // ───── Social link API
  Future<void> saveSocialLinksToApi() async {
    if (_socialLinks.isEmpty) {
      state = state.copyWith(toastMessage: 'Add at least one link');
      return;
    }
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final payload = _socialLinks
          .map((e) => {
                'platform': e['name'] ?? '',
                'url': e['url'] ?? '',
              })
          .toList();
      await ref.read(profileRepositoryProvider).updateSocialLinks(payload);
      await refresh();
      state = state.copyWith(
        isLoading: false,
        dismissSheetSignal: state.dismissSheetSignal + 1,
        saveAllSocialSuccess: state.saveAllSocialSuccess + 1,
      );
    } catch (e, st) {
      AppLogger.e('saveSocialLinksToApi failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong',
      );
    }
  }

  Future<void> deleteSocialLink(int index) async {
    if (index < 0 || index >= _socialLinks.length) return;
    _socialLinks.removeAt(index);
    commitSocial();
    final payload = _socialLinks
        .map((e) => {
              'platform': socialPlatformKey(e['name']!),
              'url': e['url'] ?? '',
            })
        .toList();
    try {
      await ref.read(profileRepositoryProvider).updateSocialLinks(payload);
      await refresh();
    } catch (e, st) {
      AppLogger.e('deleteSocialLink failed', e, st);
      state = state.copyWith(errorMessage: 'Delete failed');
    }
  }

  // ───── Portfolio link API
  Future<void> savePortfolioLinksToApi() async {
    if (_portfolioLinks.isEmpty) {
      state = state.copyWith(toastMessage: 'Add at least one portfolio link');
      return;
    }
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final payload = _portfolioLinks
          .map((e) => {
                'platform': portfolioKey(e['name']!),
                'url': e['url'],
              })
          .toList();
      await ref.read(profileRepositoryProvider).addPortfolioLinks(payload);
      await refresh();
      state = state.copyWith(
        isLoading: false,
        dismissSheetSignal: state.dismissSheetSignal + 1,
        saveAllPortfolioSuccess: state.saveAllPortfolioSuccess + 1,
        toastMessage: 'Portfolio links added ✅',
      );
    } catch (e, st) {
      AppLogger.e('savePortfolioLinksToApi failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong',
      );
    }
  }

  Future<void> deletePortfolioFile(int id) async {
    try {
      await ref.read(profileFilesRepositoryProvider).deleteFile(id);
      _portfolioLinks.removeWhere((e) => e['id'].toString() == id.toString());
      commitPortfolio();
      await refresh();
    } catch (e, st) {
      AppLogger.e('deletePortfolioFile failed', e, st);
      state = state.copyWith(errorMessage: 'Delete failed');
    }
  }

  Future<bool> editPortfolioLinkApi({
    required int id,
    required String url,
    required String platform,
    required String title,
  }) async {
    try {
      await ref.read(profileRepositoryProvider).editPortfolioLink(
            id: id,
            url: url,
            platform: platform,
            title: title,
          );
      await refresh();
      state = state.copyWith(
        dismissSheetSignal: state.dismissSheetSignal + 1,
      );
      return true;
    } catch (e, st) {
      AppLogger.e('editPortfolioLink failed', e, st);
      state = state.copyWith(errorMessage: 'Edit failed');
      return false;
    }
  }

  void addPortfolioLocal({
    required String name,
    required String url,
    required String icon,
  }) {
    _portfolioLinks.add({
      'id': '',
      'name': name,
      'url': url,
      'icon': icon,
    });
    commitPortfolio();
    state = state.copyWith(
      editingIndex: -1,
      selectedPortfolioIndex: -1,
    );
  }

  void clearMessage() {
    state = state.copyWith(clearMessages: true);
  }
}

final myProfileNotifierProvider =
    AutoDisposeNotifierProvider<MyProfileNotifier, MyProfileState>(
  MyProfileNotifier.new,
);
