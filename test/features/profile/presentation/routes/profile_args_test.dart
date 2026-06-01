import 'package:beige_creative_app/features/profile/presentation/routes/profile_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeaturedWorkDetailsArgs', () {
    test('null extra yields safe defaults (no throw)', () {
      final args = FeaturedWorkDetailsArgs.fromExtra(null);
      expect(args.title, '');
      expect(args.images, isEmpty);
    });

    test('round-trip via Map preserves fields', () {
      const original =
          FeaturedWorkDetailsArgs(title: 'Trip', images: ['a', 'b']);
      final restored = FeaturedWorkDetailsArgs.fromExtra(original.toExtra());
      expect(restored.title, 'Trip');
      expect(restored.images, ['a', 'b']);
    });
  });

  group('ChangePasswordArgs', () {
    test('accepts bare String extra (legacy shape)', () {
      final args = ChangePasswordArgs.fromExtra('a@b.co');
      expect(args.email, 'a@b.co');
    });

    test('accepts Map extra with email key', () {
      final args = ChangePasswordArgs.fromExtra({'email': 'x@y.z'});
      expect(args.email, 'x@y.z');
    });

    test('null extra yields empty email', () {
      expect(ChangePasswordArgs.fromExtra(null).email, '');
    });

    test('toExtra emits bare String for legacy builder compatibility', () {
      expect(
        const ChangePasswordArgs(email: 'a@b.co').toExtra(),
        'a@b.co',
      );
    });
  });

  group('ProfileOtpArgs / ProfileNewPasswordArgs', () {
    test('ProfileOtpArgs round-trip', () {
      final restored = ProfileOtpArgs.fromExtra(
        const ProfileOtpArgs(email: 'a@b.co').toExtra(),
      );
      expect(restored.email, 'a@b.co');
    });

    test('ProfileNewPasswordArgs round-trip', () {
      final restored = ProfileNewPasswordArgs.fromExtra(
        const ProfileNewPasswordArgs(email: 'a@b.co', otp: '123456')
            .toExtra(),
      );
      expect(restored.email, 'a@b.co');
      expect(restored.otp, '123456');
    });

    test('null extras yield empty strings', () {
      expect(ProfileOtpArgs.fromExtra(null).email, '');
      expect(ProfileNewPasswordArgs.fromExtra(null).email, '');
      expect(ProfileNewPasswordArgs.fromExtra(null).otp, '');
    });
  });
}
