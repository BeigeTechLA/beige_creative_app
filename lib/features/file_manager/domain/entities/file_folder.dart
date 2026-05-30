import 'package:flutter/foundation.dart';

@immutable
class FileFolder {
  final String id;
  final String name;
  final int fileCount;
  final String category;
  final String ownerInitials;
  final String openedAtLabel;

  const FileFolder({
    required this.id,
    required this.name,
    required this.fileCount,
    required this.category,
    required this.ownerInitials,
    required this.openedAtLabel,
  });
}
