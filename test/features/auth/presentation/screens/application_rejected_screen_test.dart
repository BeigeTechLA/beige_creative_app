import 'package:beige_creative_app/features/auth/presentation/screens/application_rejected_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows respectful rejected-state guidance and actions', (
    tester,
  ) async {
    await tester.pumpProviderApp(const ApplicationRejectedScreen());

    expect(find.text('An Update on Your Application'), findsOneWidget);
    expect(
      find.textContaining('This decision does not diminish your experience'),
      findsOneWidget,
    );
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
