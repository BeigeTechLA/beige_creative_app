import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/file_type.dart';
import '../../domain/models/fm_folder_key.dart';
import 'fm_choose_document_sheet.dart';
import 'fm_file_type_icon.dart';

class FmUploadSheet extends ConsumerStatefulWidget {
  final FmFolderKey folderKey;
  final String folderName;

  const FmUploadSheet({
    super.key,
    required this.folderKey,
    required this.folderName,
  });

  static Future<void> show(
    BuildContext context,
    FmFolderKey folderKey,
    String folderName,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (context) =>
          FmUploadSheet(folderKey: folderKey, folderName: folderName),
    );
  }

  @override
  ConsumerState<FmUploadSheet> createState() => _FmUploadSheetState();
}

class _FmUploadSheetState extends ConsumerState<FmUploadSheet> {
  final List<_PickedFile> _queuedFiles = [];
  final bool _isUploading = false;
  final double _uploadProgress = 0.0;
  final int _uploadedCount = 0;
  bool _cellularOverride = false;

  static const int _maxSizeLimit = 5 * 1024 * 1024 * 1024; // 5GB
  static const int _maxCountLimit = 50;

  /// MIME allowlist per `FLUTTER_UPLOAD_CONSTRAINTS.md` §Validation Rules.
  /// Image + video are wildcarded by prefix; the specific document
  /// types are enumerated because `application/*` includes many things
  /// we do not want (executables, archives, …).
  static const _allowedMimePrefixes = <String>['image/', 'video/'];
  static const _allowedMimeExact = <String>{
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  };

  int get _totalSize => _queuedFiles.fold(0, (sum, f) => sum + f.sizeBytes);
  bool get _isSizeExceeded => _totalSize > _maxSizeLimit;
  bool get _isCountExceeded => _queuedFiles.length > _maxCountLimit;
  bool get _needsWifiWarning => _totalSize > 50 * 1024 * 1024; // >50MB

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _openPicker() async {
    final sourceType = await FmChooseDocumentSheet.show(context);
    if (sourceType == null || !mounted) return;

    final List<_PickedFile> picked;
    try {
      picked = sourceType == DocumentSourceType.photoVideo
          ? await _pickPhotosAndVideos()
          : await _pickDocuments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Picker failed: $e')));
      }
      return;
    }
    if (picked.isEmpty || !mounted) return;

    // MIME allowlist gate — reject non-allowed types before they land
    // in the queue, per upload constraints §Validation Rule 3.
    final accepted = <_PickedFile>[];
    final rejected = <String>[];
    for (final item in picked) {
      if (_isMimeAllowed(item.mimeType)) {
        accepted.add(item);
      } else {
        rejected.add(item.name);
      }
    }

    if (accepted.isNotEmpty) {
      setState(() => _queuedFiles.addAll(accepted));
    }

    if (rejected.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(
            'Skipped ${rejected.length} unsupported file'
            '${rejected.length == 1 ? '' : 's'}: ${rejected.join(', ')}',
          ),
        ),
      );
    }
  }

  Future<List<_PickedFile>> _pickPhotosAndVideos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultipleMedia();
    return [
      for (final f in files)
        _PickedFile(
          name: f.name,
          localPath: f.path,
          sizeBytes: await f.length(),
          mimeType: f.mimeType ?? _mimeFromName(f.name),
          type: FileTypeX.fromExtension(f.name),
        ),
    ];
  }

  Future<List<_PickedFile>> _pickDocuments() async {
    final result = await fp.FilePicker.pickFiles(
      allowMultiple: true,
      type: fp.FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
      withData: false, // stream from disk in FM8.04
    );
    if (result == null) return const [];
    return [
      for (final f in result.files)
        if (f.path != null)
          _PickedFile(
            name: f.name,
            localPath: f.path!,
            sizeBytes: f.size,
            mimeType: _mimeFromName(f.name),
            type: FileTypeX.fromExtension(f.name),
          ),
    ];
  }

  bool _isMimeAllowed(String mime) {
    if (_allowedMimeExact.contains(mime)) return true;
    return _allowedMimePrefixes.any(mime.startsWith);
  }

  /// Extension → MIME fallback. Used when the platform picker does not
  /// supply a mime (e.g. `file_picker` on some Android SAF providers).
  String _mimeFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return 'application/octet-stream';
    switch (name.substring(dot + 1).toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }

  void _startUpload() {
    // FM8 multipart transfer is pending. Never simulate progress or save
    // fabricated files while the app is displaying real API data.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'File uploads are not available yet. No files were uploaded.',
        ),
      ),
    );
  }

  void _cancelUpload() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: [
            // Top Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Files',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Uploading to folder: ${widget.folderName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    onPressed: _cancelUpload,
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),

            // Content Area
            Expanded(
              child: _queuedFiles.isEmpty
                  ? _buildEmptyState()
                  : _buildQueuedState(),
            ),

            // Actions Bottom Bar
            const Divider(color: AppColors.dividerDark, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelUpload,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.borderGold,
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Upload / Action button
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_queuedFiles.isEmpty ||
                              _isUploading ||
                              _isSizeExceeded ||
                              _isCountExceeded)
                          ? null
                          : _startUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.disabled,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isUploading ? 'Uploading...' : 'Upload Files',
                        style: AppTextStyles.labelLarge.copyWith(
                          color:
                              (_queuedFiles.isEmpty ||
                                  _isUploading ||
                                  _isSizeExceeded ||
                                  _isCountExceeded)
                              ? AppColors.textTertiary
                              : AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: InkWell(
          onTap: _openPicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderGold.withValues(alpha: 0.3),
                width: 1.5,
                style: BorderStyle.solid, // solid fallback for dashed
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Drag and drop files here or browse',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Supports photos, videos, and PDFs up to 5GB',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _openPicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Browse Files',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueuedState() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Upload Progress Section (if uploading)
        if (_isUploading) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading $_uploadedCount of ${_queuedFiles.length} files...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: _uploadProgress,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceMid,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Size Limit Error
        if (_isSizeExceeded)
          _buildAlertCard(
            title: 'Size Limit Exceeded',
            message:
                'Your batch total size is ${_formatSize(_totalSize)}, which exceeds the 5GB maximum upload limit. Please remove some files.',
            isError: true,
          ),

        // Count Limit Error
        if (_isCountExceeded)
          _buildAlertCard(
            title: 'File Count Exceeded',
            message:
                'You have queued ${_queuedFiles.length} files. The maximum allowed count per batch is 50 files.',
            isError: true,
          ),

        // Wi-Fi Warning Card
        if (_needsWifiWarning && !_isSizeExceeded && !_isCountExceeded)
          _buildWifiWarningCard(),

        // Batch Queue Summary Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Queued Files (${_queuedFiles.length})',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatSize(_totalSize),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Queued Items List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _queuedFiles.length,
          itemBuilder: (context, index) {
            final file = _queuedFiles[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  FmFileTypeIcon(type: file.type, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatSize(file.sizeBytes),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isUploading)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.errorAccent,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _queuedFiles.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            );
          },
        ),

        // Add More trigger
        if (!_isUploading && !_isCountExceeded)
          TextButton.icon(
            onPressed: _openPicker,
            icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
            label: Text(
              'Add More Files',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required bool isError,
  }) {
    final color = isError ? AppColors.errorAccent : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.warning_amber_outlined,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWifiWarningCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_off_outlined,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Wi-Fi Upload Highly Recommended',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Batch size is ${_formatSize(_totalSize)}. By default, uploads over 50MB run over Wi-Fi only.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Allow Cellular Upload',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch.adaptive(
                value: _cellularOverride,
                activeThumbColor: AppColors.primary,
                onChanged: _isUploading
                    ? null
                    : (val) {
                        setState(() {
                          _cellularOverride = val;
                        });
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One picker output row. Carries the on-disk `localPath` so the FM8.04
/// multipart uploader can stream bytes without reloading them through
/// the platform channel.
class _PickedFile {
  final String name;
  final int sizeBytes;
  final FileType type;
  final String localPath;
  final String mimeType;

  const _PickedFile({
    required this.name,
    required this.sizeBytes,
    required this.type,
    required this.localPath,
    required this.mimeType,
  });
}
