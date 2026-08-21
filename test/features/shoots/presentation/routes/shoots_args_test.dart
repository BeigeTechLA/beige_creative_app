import 'package:beige_creative_app/features/shoots/presentation/routes/shoots_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpcomingShootDetailsArgs', () {
    test('null extra yields null projectId (no throw — P15 fix)', () {
      final args = UpcomingShootDetailsArgs.fromExtra(null);
      expect(args.projectId, isNull);
    });

    test('Map extra round-trips', () {
      const original = UpcomingShootDetailsArgs(projectId: 42);
      final restored =
          UpcomingShootDetailsArgs.fromExtra(original.toExtra());
      expect(restored.projectId, 42);
    });

    test('String projectId is parsed to int', () {
      final args = UpcomingShootDetailsArgs.fromExtra({'projectId': '7'});
      expect(args.projectId, 7);
    });

    test('non-numeric String yields null', () {
      final args = UpcomingShootDetailsArgs.fromExtra({'projectId': 'abc'});
      expect(args.projectId, isNull);
    });
  });

  group('CancelShootArgs', () {
    test('null extra yields null projectId', () {
      expect(CancelShootArgs.fromExtra(null).projectId, isNull);
    });

    test('round-trip preserves projectId', () {
      const original = CancelShootArgs(projectId: 7);
      expect(
        CancelShootArgs.fromExtra(original.toExtra()).projectId,
        7,
      );
    });
  });
}
