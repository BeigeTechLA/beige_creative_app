/// Whether a folder is bound to an external shoot/project/work item.
///
/// Backend is still finalizing this signal — when the API omits the field
/// the DTO boundary returns `null`, and [FmLinkedBadge] renders nothing.
/// Once the backend lands, the same enum drives the badge color variant.
enum LinkState { linked, unlinked }

extension LinkStateX on LinkState {
  String get label {
    switch (this) {
      case LinkState.linked:
        return 'Linked';
      case LinkState.unlinked:
        return 'Unlinked';
    }
  }

  String get apiValue {
    switch (this) {
      case LinkState.linked:
        return 'linked';
      case LinkState.unlinked:
        return 'unlinked';
    }
  }

  static LinkState? fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'linked':
        return LinkState.linked;
      case 'unlinked':
        return LinkState.unlinked;
      default:
        return null;
    }
  }
}
