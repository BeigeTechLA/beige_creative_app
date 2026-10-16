import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/file_type.dart';
import '../../domain/models/fm_node.dart';
import 'file_ops_repository_provider.dart';

/// Signed URL query strings must not identify cached image bytes. Metadata
/// changes select a new cache entry when a file is replaced or versioned.
String fileImageCacheKey(FmFile file) => jsonEncode([
  'file-manager-image',
  file.filepath ?? file.id,
  file.version,
  file.openedAt?.toUtc().toIso8601String(),
  file.sizeBytes,
]);

typedef _PreviewKey = ({
  String cacheKey,
  bool isImage,
  String? preview,
  String? path,
  String download,
});

/// Value-based keys reuse state even when a refreshed listing recreates FmFile.
AutoDisposeFutureProvider<String?> fileImagePreviewProvider(FmFile file) =>
    _imagePreviewProvider((
      cacheKey: fileImageCacheKey(file),
      isImage:
          isImageFile(file.name) ||
          isImageFile(file.filepath) ||
          file.type == FileType.image,
      preview: file.previewUrl?.trim(),
      path: file.filepath,
      download: file.downloadUrl,
    ));

final _imagePreviewProvider = FutureProvider.autoDispose
    .family<String?, _PreviewKey>((ref, key) async {
      if (!key.isImage) return null;
      // Retain pending requests too, so fast scrolling does not duplicate them.
      final link = ref.keepAlive();
      Timer? timer;
      var disposed = false;
      ref.onDispose(() {
        disposed = true;
        timer?.cancel();
      });
      var lifetime = const Duration(minutes: 5);
      try {
        String? url;
        if (key.preview?.isNotEmpty == true) {
          url = key.preview;
        } else if (key.path?.isNotEmpty == true) {
          final signed = await ref
              .watch(fileOpsRepositoryProvider)
              .viewUrl(key.path!);
          url = signed.url;
          final expiry = signed.expiresAt;
          if (expiry != null) {
            final remaining =
                expiry.difference(DateTime.now()) - const Duration(seconds: 30);
            if (remaining < lifetime) lifetime = remaining;
          }
        } else {
          url = key.download.isEmpty ? null : key.download;
        }
        if (!disposed) {
          if (url == null || lifetime <= Duration.zero) {
            link.close();
          } else {
            timer = Timer(lifetime, link.close);
          }
        }
        return url;
      } catch (_) {
        link.close();
        rethrow;
      }
    });
