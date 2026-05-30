import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../data/repositories/profile_files_repository_impl.dart';
import '../../domain/repositories/profile_files_repository.dart';

final profileFilesRepositoryProvider = Provider<ProfileFilesRepository>(
  (ref) => ProfileFilesRepositoryImpl(ref.read(dioClientProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Shared list state shape (resume, certificates).
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class FilesListState {
  final List<CrewFile> files;
  final bool isLoading;
  final String? errorMessage;

  const FilesListState({
    this.files = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FilesListState copyWith({
    List<CrewFile>? files,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FilesListState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resume.
// ─────────────────────────────────────────────────────────────────────────────

class ResumeNotifier extends AutoDisposeNotifier<FilesListState> {
  @override
  FilesListState build() {
    Future.microtask(refresh);
    return const FilesListState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(profileFilesRepositoryProvider).fetchProfile();
      state = state.copyWith(files: data.resumeFiles, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Resume fetch failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load resume',
      );
    }
  }

  Future<bool> upload(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(profileFilesRepositoryProvider).uploadResume(file);
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.e('Resume upload failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Upload failed',
      );
      return false;
    }
  }

  Future<bool> delete(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(profileFilesRepositoryProvider).deleteFile(id);
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.e('Resume delete failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Delete failed',
      );
      return false;
    }
  }
}

final resumeNotifierProvider =
    AutoDisposeNotifierProvider<ResumeNotifier, FilesListState>(
  ResumeNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Certificates.
// ─────────────────────────────────────────────────────────────────────────────

class CertificatesNotifier extends AutoDisposeNotifier<FilesListState> {
  @override
  FilesListState build() {
    Future.microtask(refresh);
    return const FilesListState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(profileFilesRepositoryProvider).fetchProfile();
      state = state.copyWith(files: data.certificateFiles, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Certificates fetch failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load certificates',
      );
    }
  }

  Future<bool> upload(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(profileFilesRepositoryProvider).uploadCertificate(file);
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.e('Certificate upload failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Upload failed',
      );
      return false;
    }
  }

  Future<bool> delete(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(profileFilesRepositoryProvider).deleteFile(id);
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.e('Certificate delete failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Delete failed',
      );
      return false;
    }
  }
}

final certificatesNotifierProvider =
    AutoDisposeNotifierProvider<CertificatesNotifier, FilesListState>(
  CertificatesNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Featured work — keeps full grid shape (not flat). Upload takes title+tags+files.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class FeaturedWorkState {
  final List<CrewFile> files;
  final bool isLoading;
  final String? errorMessage;

  const FeaturedWorkState({
    this.files = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FeaturedWorkState copyWith({
    List<CrewFile>? files,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeaturedWorkState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FeaturedWorkNotifier extends AutoDisposeNotifier<FeaturedWorkState> {
  @override
  FeaturedWorkState build() {
    Future.microtask(refresh);
    return const FeaturedWorkState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(profileFilesRepositoryProvider).fetchProfile();
      state = state.copyWith(files: data.featuredWorkFiles, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Featured work fetch failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load featured work',
      );
    }
  }

  Future<bool> upload({
    required String title,
    required List<String> tags,
    required List<File> files,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(profileFilesRepositoryProvider).uploadFeaturedWork(
            title: title,
            tags: tags,
            files: files,
          );
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.e('Featured work upload failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Upload failed',
      );
      return false;
    }
  }

  Future<bool> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(profileFilesRepositoryProvider);
      for (final id in ids) {
        await repo.deleteFile(id);
      }
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.e('Featured work delete failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Delete failed',
      );
      return false;
    }
  }
}

final featuredWorkNotifierProvider =
    AutoDisposeNotifierProvider<FeaturedWorkNotifier, FeaturedWorkState>(
  FeaturedWorkNotifier.new,
);
