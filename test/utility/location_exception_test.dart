import 'package:beige_creative_app/utility/location_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationException', () {
    test('status enum fields map correctly', () {
      expect(LocationStatus.values, contains(LocationStatus.serviceDisabled));
      expect(LocationStatus.values, contains(LocationStatus.denied));
      expect(LocationStatus.values, contains(LocationStatus.permanentlyDenied));
      expect(LocationStatus.values, contains(LocationStatus.unknown));
    });

    test('toString formats correctly with message', () {
      const exception = LocationException(LocationStatus.denied, 'Permission was denied');
      expect(exception.status, LocationStatus.denied);
      expect(exception.message, 'Permission was denied');
      expect(exception.toString(), 'LocationException(LocationStatus.denied: Permission was denied)');
    });

    test('toString formats correctly without message', () {
      const exception = LocationException(LocationStatus.serviceDisabled);
      expect(exception.status, LocationStatus.serviceDisabled);
      expect(exception.message, isNull);
      expect(exception.toString(), 'LocationException(LocationStatus.serviceDisabled)');
    });
  });
}
