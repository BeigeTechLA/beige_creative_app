import 'package:integration_test/integration_test.dart';

import '../test/app/route_page_builder_test.dart' as page_gestures;
import '../test/shared/layouts/app_shell_test.dart' as drawer_navigation;

/// Runs the same regression cases on a device binding, with deterministic
/// branch content and Home provider data. No login or backend mutations.
/// Platform variants exercise both transition policies; the host device/OS
/// must be recorded separately and is not changed by those variants.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  page_gestures.main();
  drawer_navigation.main();
}
