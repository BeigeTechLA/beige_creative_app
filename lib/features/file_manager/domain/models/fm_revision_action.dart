/// `POST /external-file-manager/revision-file/review` action selector.
enum FmRevisionAction { approve, requestRevision }

extension FmRevisionActionX on FmRevisionAction {
  String get apiValue {
    switch (this) {
      case FmRevisionAction.approve:
        return 'approve';
      case FmRevisionAction.requestRevision:
        return 'request_revision';
    }
  }

  static FmRevisionAction? fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'approve':
        return FmRevisionAction.approve;
      case 'request_revision':
        return FmRevisionAction.requestRevision;
      default:
        return null;
    }
  }
}
