import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/app/text_styles.dart';
import 'package:beige_creative_app/shared/widgets/app_avatar.dart';
import 'package:beige_creative_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for `AppCard` + `AppAvatar`. Catches drift in
/// `AppRadii.lgAll`, `AppShadows.card`, `AppColors.surface`,
/// `AppTextStyles` initials styling, and the avatar diameter scale.
///
/// Regenerate with
/// `flutter test --update-goldens test/golden/cards_test.dart`.

Widget _frame(Widget child, {bool dark = true}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: dark ? AppColors.background : AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: child,
        ),
      ),
    ),
  );
}

Widget _stack(List<Widget> children) {
  return SizedBox(
    width: 400,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final w in children) ...[
          w,
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    ),
  );
}

void main() {
  testWidgets('AppCard — flat / outlined / elevated (dark surface)',
      (tester) async {
    await tester.pumpWidget(
      _frame(_stack([
        AppCard(
          child: Text(
            'Flat card',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
          ),
        ),
        AppCard(
          variant: AppCardVariant.outlined,
          child: Text(
            'Outlined card',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
          ),
        ),
        AppCard(
          variant: AppCardVariant.elevated,
          child: Text(
            'Elevated card',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
          ),
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_card_variants_dark.png'),
    );
  });

  testWidgets('AppCard — variants on light surface', (tester) async {
    await tester.pumpWidget(
      _frame(
        _stack([
          AppCard(
            child: Text('Flat', style: AppTextStyles.bodyLarge),
          ),
          AppCard(
            variant: AppCardVariant.outlined,
            child: Text('Outlined', style: AppTextStyles.bodyLarge),
          ),
          AppCard(
            variant: AppCardVariant.elevated,
            child: Text('Elevated', style: AppTextStyles.bodyLarge),
          ),
        ]),
        dark: false,
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_card_variants_light.png'),
    );
  });

  testWidgets('AppAvatar — all sizes with initials', (tester) async {
    await tester.pumpWidget(
      _frame(
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            AppAvatar(name: 'Ada Lovelace', size: AppAvatarSize.xs),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: 'Ada Lovelace', size: AppAvatarSize.sm),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: 'Ada Lovelace', size: AppAvatarSize.md),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: 'Ada Lovelace', size: AppAvatarSize.lg),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: 'Ada Lovelace', size: AppAvatarSize.xl),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_avatar_sizes_dark.png'),
    );
  });

  testWidgets('AppAvatar — single-name, empty-name fallback, multi-word',
      (tester) async {
    await tester.pumpWidget(
      _frame(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppAvatar(name: 'Ada', size: AppAvatarSize.lg),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: '', size: AppAvatarSize.lg),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: null, size: AppAvatarSize.lg),
            SizedBox(width: AppSpacing.md),
            AppAvatar(name: 'Mary Jane Watson', size: AppAvatarSize.lg),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_avatar_initials_variants_dark.png'),
    );
  });
}
