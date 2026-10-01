/// Coarse-grained file-type bucket used by [FmFileTypeIcon] and action
/// sheets. Backend returns a string discriminator on every file payload; the
/// DTO boundary normalizes it via [FileTypeX.fromApi]. Unknown values map to
/// [FileType.other] so a single rogue extension never breaks rendering.
enum FileType { pdf, doc, sheet, image, video, audio, zip, other }

/// Detects image filenames and paths, including signed URLs and mixed case.
bool isImageFile(String? nameOrPath) {
  if (nameOrPath == null) return false;
  final value = nameOrPath.trim();
  final uri = Uri.tryParse(value);
  final path = uri?.hasScheme == true ? uri!.path : value.split('?').first;
  final name = path.split('/').last.toLowerCase();
  final dot = name.lastIndexOf('.');
  if (dot < 0) return false;
  return const {
    'jpg',
    'jpeg',
    'jfif',
    'png',
    'gif',
    'webp',
    'bmp',
    'wbmp',
    'ico',
    'heic',
    'heif',
    'avif',
    'tif',
    'tiff',
    'svg',
  }.contains(name.substring(dot + 1));
}

extension FileTypeX on FileType {
  String get apiValue {
    switch (this) {
      case FileType.pdf:
        return 'pdf';
      case FileType.doc:
        return 'doc';
      case FileType.sheet:
        return 'sheet';
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.audio:
        return 'audio';
      case FileType.zip:
        return 'zip';
      case FileType.other:
        return 'other';
    }
  }

  static FileType fromApi(String? value) {
    if (isImageFile('file.${value?.trim()}')) return FileType.image;
    switch (value?.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'doc':
      case 'docx':
        return FileType.doc;
      case 'sheet':
      case 'xls':
      case 'xlsx':
      case 'csv':
        return FileType.sheet;
      case 'image':
      case 'img':
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'bmp':
      case 'tif':
      case 'tiff':
      // Camera RAW formats: classified as image for icon/category, but kept
      // out of [isImageFile] since Flutter can't decode them — the preview
      // falls back to the image-doc icon instead of a doomed network fetch.
      case 'raw':
      case 'nef':
      case 'cr2':
      case 'arw':
      case 'orf':
      case 'dng':
        return FileType.image;
      case 'video':
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
      case 'mpg':
      case 'mpeg':
      case 'wmv':
      case 'flv':
      case '3gp':
      case 'ogg':
        return FileType.video;
      case 'audio':
      case 'mp3':
      case 'wav':
      case 'aac':
        return FileType.audio;
      case 'zip':
      case 'rar':
      case '7z':
        return FileType.zip;
      default:
        return FileType.other;
    }
  }

  /// Used by the dummy source + as a last-resort fallback when the backend
  /// only returns a filename.
  static FileType fromExtension(String fileName) {
    if (isImageFile(fileName)) return FileType.image;
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return FileType.other;
    return fromApi(fileName.substring(dot + 1));
  }
}
