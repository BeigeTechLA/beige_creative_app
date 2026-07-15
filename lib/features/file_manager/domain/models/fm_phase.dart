/// Workspace phase. Every folder/file below the workspace root is scoped
/// by one of these — the API `?phase=` query and `POST /folder` body use
/// the [apiValue] wire values.
enum FmPhase { root, pre, post }

extension FmPhaseX on FmPhase {
  String get apiValue {
    switch (this) {
      case FmPhase.root:
        return 'root';
      case FmPhase.pre:
        return 'pre';
      case FmPhase.post:
        return 'post';
    }
  }

  /// URL segment for the physical folder on the object store — `pre` →
  /// `Pre-Production`, `post` → `Post-Production`, `root` → empty. Used
  /// by [FmPath] when composing an absolute `filepath` for mutations.
  String get folderSegment {
    switch (this) {
      case FmPhase.root:
        return '';
      case FmPhase.pre:
        return 'Pre-Production';
      case FmPhase.post:
        return 'Post-Production';
    }
  }

  static FmPhase fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'pre':
      case 'preproduction':
      case 'pre-production':
        return FmPhase.pre;
      case 'post':
      case 'postproduction':
      case 'post-production':
        return FmPhase.post;
      case 'root':
      case null:
      case '':
        return FmPhase.root;
      default:
        return FmPhase.root;
    }
  }
}
