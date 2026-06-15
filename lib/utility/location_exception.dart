enum LocationStatus {
  serviceDisabled,
  denied,
  permanentlyDenied,
  unknown,
}

class LocationException implements Exception {
  final LocationStatus status;
  final String? message;

  const LocationException(this.status, [this.message]);

  @override
  String toString() => 'LocationException($status${message != null ? ': $message' : ''})';
}
