import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup1_header.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup2_header.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup3_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Device-matrix goldens for header widgets touched in design-audit Task 2.
///
/// Renders each header at three reference viewports so regressions in the
/// clamp bounds (`AppSpacing` tokens, header inner offsets, status-bar /
/// Dynamic Island clearance) get caught before they ship.
///
/// Regenerate after deliberate design changes with:
///   flutter test --update-goldens test/golden/device_matrix_test.dart
///
/// Re-run on the same Flutter SDK version that produced the baselines —
/// cross-SDK pixel diffs are noise.

const _viewports = <(String, Size)>[
  ('320x568', Size(320, 568)),  // iPhone SE 1st gen — iOS floor
  ('393x852', Size(393, 852)),  // iPhone 15 Pro — Dynamic Island
  ('744x1133', Size(744, 1133)), // iPad mini / foldable open
];

Widget _frame(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.background,
      body: child,
    ),
  );
}

Future<void> _runMatrix(
  WidgetTester tester,
  String name,
  Widget child,
) async {
  for (final (label, size) in _viewports) {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(_frame(child));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_$label.png'),
    );
  }
  await tester.binding.setSurfaceSize(null);
}

void main() {
  testWidgets('SignUp1Header — viewport matrix', (tester) async {
    await _runMatrix(tester, 'signup1_header', const SignUp1Header());
  });

  testWidgets('SignUp2Header — viewport matrix', (tester) async {
    await _runMatrix(tester, 'signup2_header', const SignUp2Header());
  });

  testWidgets('SignUp3Header — viewport matrix', (tester) async {
    await _runMatrix(tester, 'signup3_header', const SignUp3Header());
  });
}
