import 'package:beige_creative_app/features/auth/domain/models/working_distance_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('canonicalSignupWorkingDistance', () {
    test('normalizes the mobile API 50-mile capitalization variant', () {
      expect(canonicalSignupWorkingDistance('Upto 50 miles'), 'Upto 50 Miles');
    });

    test('normalizes whitespace and case for every supported option', () {
      expect(
        canonicalSignupWorkingDistance('  UPTO   75 MILES '),
        'Upto 75 miles',
      );
      expect(
        canonicalSignupWorkingDistance('I’M OPEN TO TRAVELING'),
        'I’m open to traveling',
      );
    });

    test('returns null for unsupported API values', () {
      expect(canonicalSignupWorkingDistance('Upto 25 Miles'), isNull);
    });
  });
}
