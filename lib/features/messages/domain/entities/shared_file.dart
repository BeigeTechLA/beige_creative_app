import 'package:flutter/foundation.dart';

@immutable
class SharedFile {
  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final DateTime uploadedAt;

  const SharedFile({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedAt,
  });
}
