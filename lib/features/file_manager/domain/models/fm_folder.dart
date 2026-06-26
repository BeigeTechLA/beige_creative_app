part of 'fm_node.dart';

@immutable
class FmFolder extends FmNode {
  /// Total files contained, including descendants. Server-computed — the
  /// client never recomputes after deletes; it re-fetches the parent.
  final int fileCount;

  /// Free-form tag like `"Corporate Event"`. Rendered as `FmTagChip`.
  final String? tagLabel;

  /// Hidden when null (backend hasn't decided the link signal yet).
  final LinkState? linkState;

  final FmLinkedProject? linkedProject;

  const FmFolder({
    required super.id,
    required super.name,
    required this.fileCount,
    super.openedAt,
    this.tagLabel,
    this.linkState,
    this.linkedProject,
  });
}
