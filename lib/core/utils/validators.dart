/// Centralized input-validation patterns + helpers.
///
/// Patterns live here so duplicated regex literals across feature notifiers
/// stay in sync (e.g. email-format checks previously diverged on TLD
/// quantifier: `{2,}` vs `+`). New validators should be added here and
/// consumed by the feature layer.
library;

/// Standard email pattern (TLD ≥ 2 chars).
const String kEmailPattern =
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

/// Google Plus Code pattern (e.g. `87G8+P9`).
const String kPlusCodePattern = r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$';

final RegExp kEmailRegex = RegExp(kEmailPattern);
final RegExp kPlusCodeRegex = RegExp(kPlusCodePattern);

bool isValidEmail(String value) => kEmailRegex.hasMatch(value.trim());

bool isPlusCode(String value) => kPlusCodeRegex.hasMatch(value.trim());
