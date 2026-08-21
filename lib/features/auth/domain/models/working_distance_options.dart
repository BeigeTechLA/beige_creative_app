const List<String> signupWorkingDistanceOptions = <String>[
  'Upto 50 Miles',
  'Upto 75 miles',
  'Upto 100 miles',
  'I’m open to traveling',
];

/// Resolves API/login capitalization and whitespace variants to the exact
/// value used by the Signup Step 1 dropdown.
String? canonicalSignupWorkingDistance(String? value) {
  final normalized = value
      ?.trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;

  for (final option in signupWorkingDistanceOptions) {
    if (option.toLowerCase() == normalized) return option;
  }
  return null;
}
