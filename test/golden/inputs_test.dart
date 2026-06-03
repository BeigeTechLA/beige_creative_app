import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for `AppTextField`. Catches drift in
/// `AppColors.surfaceInput` / `dividerDark` / `primary` / `error`,
/// `AppRadii.mdAll`, and the label / hint / error typography.
///
/// Regenerate with
/// `flutter test --update-goldens test/golden/inputs_test.dart`.

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final w in children) ...[
          w,
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    ),
  );
}

void main() {
  testWidgets('AppTextField — label + hint + filled (empty)', (tester) async {
    await tester.pumpWidget(
      _frame(_stack([
        const AppTextField(
          label: 'Email',
          hint: 'name@example.com',
        ),
        const AppTextField(
          label: 'Password',
          hint: '••••••••',
          obscureText: true,
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_text_field_empty_dark.png'),
    );
  });

  testWidgets('AppTextField — initial value + prefix icon + suffix',
      (tester) async {
    await tester.pumpWidget(
      _frame(_stack([
        const AppTextField(
          label: 'Search',
          initialValue: 'wedding',
          prefixIcon: Icons.search,
        ),
        const AppTextField(
          label: 'Phone',
          initialValue: '+1 555 0123',
          suffix: Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_text_field_filled_dark.png'),
    );
  });

  testWidgets('AppTextField — error + disabled', (tester) async {
    await tester.pumpWidget(
      _frame(_stack([
        const AppTextField(
          label: 'Email',
          initialValue: 'not-an-email',
          errorText: 'Please enter a valid email address',
        ),
        const AppTextField(
          label: 'Working distance',
          initialValue: 'Upto 50 Miles',
          enabled: false,
        ),
      ])),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_text_field_error_disabled_dark.png'),
    );
  });

  testWidgets('AppTextField — light surface variants', (tester) async {
    await tester.pumpWidget(
      _frame(
        _stack([
          const AppTextField(
            label: 'Email',
            hint: 'name@example.com',
          ),
          const AppTextField(
            label: 'Email',
            initialValue: 'bad',
            errorText: 'Please enter a valid email address',
          ),
        ]),
        dark: false,
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_text_field_states_light.png'),
    );
  });
}
