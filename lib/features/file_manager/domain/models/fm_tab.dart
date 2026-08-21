/// Tabs on the file-manager root screen.
///
/// Each value maps to a server-side filter (`tab` query param on
/// `GET /api/file-manager/root`). Backend is the source of truth for what
/// each tab returns — UI does no extra filtering.
enum FmTab { all, recent, linked, commonEvents }

extension FmTabX on FmTab {
  String get label {
    switch (this) {
      case FmTab.all:
        return 'All Files';
      case FmTab.recent:
        return 'Recent Files';
      case FmTab.linked:
        return 'Linked Files';
      case FmTab.commonEvents:
        return 'Common Events';
    }
  }

  /// Wire value sent to the backend.
  String get apiValue {
    switch (this) {
      case FmTab.all:
        return 'all';
      case FmTab.recent:
        return 'recent';
      case FmTab.linked:
        return 'linked';
      case FmTab.commonEvents:
        return 'common_events';
    }
  }
}
