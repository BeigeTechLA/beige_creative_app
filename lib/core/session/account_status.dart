enum AccountStatus {
  active,
  deletionPending,
  deleted,
  unknown;

  static AccountStatus parse(Object? value) => switch (value) {
    'active' || null => AccountStatus.active,
    'deletion_pending' => AccountStatus.deletionPending,
    'deleted' => AccountStatus.deleted,
    _ => AccountStatus.unknown,
  };

  String get apiValue => switch (this) {
    active => 'active',
    deletionPending => 'deletion_pending',
    deleted => 'deleted',
    unknown => 'unknown',
  };
}
