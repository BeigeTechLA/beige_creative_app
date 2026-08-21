/// Coarse-grained file-type bucket used by [FmFileTypeIcon] and action
/// sheets. Backend returns a string discriminator on every file payload; the
/// DTO boundary normalizes it via [FileTypeX.fromApi]. Unknown values map to
/// [FileType.other] so a single rogue extension never breaks rendering.
enum FileType { pdf, doc, sheet, image, video, audio, zip, other }

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
        return FileType.image;
      case 'video':
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
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
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return FileType.other;
    return fromApi(fileName.substring(dot + 1));
  }
}
