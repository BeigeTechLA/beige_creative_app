import 'package:flutter/foundation.dart';

enum FileKind { pdf, doc }

@immutable
class FileItem {
  final String id;
  final String name;
  final FileKind kind;
  final String ownerInitials;
  final String openedAtLabel;

  const FileItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.ownerInitials,
    required this.openedAtLabel,
  });

  bool get isPdf => kind == FileKind.pdf;
}
