import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for `AppButton`. Catches accidental token drift in
/// `AppColors` / `AppRadii` / `AppSpacing` / `AppTextStyles`.
///
/// Regenerate with `flutter test --update-goldens test/golden/buttons_test.dart`
/// after deliberate design changes.

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

Widget _row(List<Widget> children) {
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
  testWidgets('AppButton — all variants (dark surface)', (tester) async {
    await tester.pumpWidget(
      _frame(_row([
        const AppButton(
          label: 'Primary',
          onPressed: _noop,
        ),
        const AppButton(
          label: 'Secondary',
          onPressed: _noop,
          variant: AppButtonVariant.secondary,
        ),
        const AppButton(
          label: 'Outline',
          onPressed: _noop,
          variant: AppButtonVariant.outline,
        ),
        const AppButton(
          label: 'Text',
          onPressed: _noop,
          variant: AppButtonVariant.text,
        ),
        const AppButton(
          label: 'Destructive',
          onPressed: _noop,
          variant: AppButtonVariant.destructive,
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button_variants_dark.png'),
    );
  });

  testWidgets('AppButton — all sizes (dark surface)', (tester) async {
    await tester.pumpWidget(
      _frame(_row([
        const AppButton(label: 'Small', onPressed: _noop, size: AppButtonSize.sm),
        const AppButton(label: 'Medium', onPressed: _noop, size: AppButtonSize.md),
        const AppButton(label: 'Large', onPressed: _noop, size: AppButtonSize.lg),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button_sizes_dark.png'),
    );
  });

  testWidgets('AppButton — disabled + loading states', (tester) async {
    await tester.pumpWidget(
      _frame(_row([
        const AppButton(label: 'Disabled primary', onPressed: null),
        const AppButton(
          label: 'Disabled outline',
          onPressed: null,
          variant: AppButtonVariant.outline,
        ),
        const AppButton(
          label: 'Loading',
          onPressed: _noop,
          isLoading: true,
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button_states_dark.png'),
    );
  });

  testWidgets('AppButton — fullWidth + icon', (tester) async {
    await tester.pumpWidget(
      _frame(_row([
        const AppButton(
          label: 'Full width',
          onPressed: _noop,
          fullWidth: true,
        ),
        const AppButton(
          label: 'With icon',
          onPressed: _noop,
          icon: Icons.check,
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button_fullwidth_icon_dark.png'),
    );
  });

  testWidgets('AppButton — variants on light surface', (tester) async {
    await tester.pumpWidget(
      _frame(
        _row([
          const AppButton(label: 'Primary', onPressed: _noop),
          const AppButton(
            label: 'Secondary',
            onPressed: _noop,
            variant: AppButtonVariant.secondary,
          ),
          const AppButton(
            label: 'Outline',
            onPressed: _noop,
            variant: AppButtonVariant.outline,
          ),
          const AppButton(
            label: 'Destructive',
            onPressed: _noop,
            variant: AppButtonVariant.destructive,
          ),
        ]),
        dark: false,
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button_variants_light.png'),
    );
  });
}

void _noop() {}
