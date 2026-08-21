import 'package:beige_creative_app/features/auth/presentation/routes/signup_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignUpStep2Args.fromExtra', () {
    test('null extra yields defaults (no throw)', () {
      final args = SignUpStep2Args.fromExtra(null);
      expect(args.crewMemberId, isNull);
      expect(args.email, isNull);
      expect(args.step1Progress, 0);
    });

    test('round-trip via toExtra preserves fields', () {
      const original = SignUpStep2Args(
        crewMemberId: 7,
        email: 'a@b.co',
        firstName: 'Foo',
        lastName: 'Bar',
        location: 'NYC',
        workingDistance: '25',
        step1Progress: 30,
      );
      final restored = SignUpStep2Args.fromExtra(original.toExtra());
      expect(restored.crewMemberId, 7);
      expect(restored.email, 'a@b.co');
      expect(restored.firstName, 'Foo');
      expect(restored.lastName, 'Bar');
      expect(restored.location, 'NYC');
      expect(restored.workingDistance, '25');
      expect(restored.step1Progress, 30);
    });
  });

  group('SignUpStep3Args.fromExtra', () {
    test('null extra yields defaults (no throw)', () {
      final args = SignUpStep3Args.fromExtra(null);
      expect(args.primaryRole, '');
      expect(args.experience, '');
      expect(args.step2Progress, 0);
    });

    test('round-trip preserves all 14 fields', () {
      const original = SignUpStep3Args(
        crewMemberId: 1,
        email: 'x@y.z',
        firstName: 'A',
        lastName: 'B',
        location: 'L',
        workingDistance: 'D',
        primaryRole: 'P',
        experience: 'E',
        hourlyRate: 'H',
        bio: 'Bio',
        skills: 'S',
        equipments: 'Eq',
        step2Progress: 60,
      );
      final restored = SignUpStep3Args.fromExtra(original.toExtra());
      expect(restored.crewMemberId, 1);
      expect(restored.firstName, 'A');
      expect(restored.primaryRole, 'P');
      expect(restored.bio, 'Bio');
      expect(restored.step2Progress, 60);
    });
  });

  group('ViewDetailsArgs.fromExtra', () {
    test('null extra yields empty defaults', () {
      final args = ViewDetailsArgs.fromExtra(null);
      expect(args.firstName, '');
      expect(args.email, '');
      expect(args.featuredImages, isEmpty);
    });

    test('round-trip preserves text fields', () {
      const original = ViewDetailsArgs(
        firstName: 'F',
        lastName: 'L',
        email: 'e@m.co',
        location: 'Loc',
        workingDistance: '25',
        primaryRole: 'role',
        experience: 'exp',
        hourlyRate: '50',
        bio: 'bio',
        skills: 'sk',
        equipments: 'eq',
      );
      final restored = ViewDetailsArgs.fromExtra(original.toExtra());
      expect(restored.firstName, 'F');
      expect(restored.lastName, 'L');
      expect(restored.email, 'e@m.co');
      expect(restored.bio, 'bio');
    });
  });
}
