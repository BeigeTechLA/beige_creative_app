import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/radii.dart';
import '../../domain/models/file_type.dart';
import '../../domain/models/fm_node.dart';
import '../providers/file_image_preview_provider.dart';

/// Shared image preview; unavailable or unsupported images retain the fallback.
class FmImagePreview extends ConsumerWidget {
  const FmImagePreview({
    super.key,
    required this.file,
    required this.fallback,
    this.fit = BoxFit.contain,
  });

  final FmFile file;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isImageFile(file.name) &&
        !isImageFile(file.filepath) &&
        file.type != FileType.image) {
      return fallback;
    }
    return ref
        .watch(fileImagePreviewProvider(file))
        .when(
          loading: () => fallback,
          error: (_, _) => fallback,
          data: (url) => url == null
              ? fallback
              : ClipRRect(
                  borderRadius: AppRadii.mdAll,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    cacheKey: fileImageCacheKey(file),
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    width: double.infinity,
                    height: double.infinity,
                    fit: fit,
                    imageBuilder: (context, provider) => Image(
                      image: provider,
                      fit: fit,
                      semanticLabel: file.name,
                    ),
                    placeholder: (_, _) => fallback,
                    errorWidget: (_, _, _) => fallback,
                  ),
                ),
        );
  }
}
