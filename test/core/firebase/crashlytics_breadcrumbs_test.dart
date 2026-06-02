import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final keys = <({String key, Object value})>[];
  final logs = <String>[];

  setUp(() {
    keys.clear();
    logs.clear();
    CrashlyticsBreadcrumbs.setCustomKey = (key, value) async {
      keys.add((key: key, value: value));
    };
    CrashlyticsBreadcrumbs.log = (message) async {
      logs.add(message);
    };
  });

  tearDown(CrashlyticsBreadcrumbs.resetForTesting);

  test('start sets feature_area and writes breadcrumb', () async {
    CrashlyticsBreadcrumbs.start(
      featureArea: 'shoots.accept',
      message: 'shoot.accept.start id=42',
    );

    await pumpEventQueue();

    expect(keys, [(key: CrashlyticsKeys.featureArea, value: 'shoots.accept')]);
    expect(logs, ['shoot.accept.start id=42']);
  });

  test('success and failure write terminal breadcrumbs only', () async {
    CrashlyticsBreadcrumbs.success('shoot.accept.success id=42');
    CrashlyticsBreadcrumbs.failure('shoot.accept.failure id=42');

    await pumpEventQueue();

    expect(keys, isEmpty);
    expect(logs, ['shoot.accept.success id=42', 'shoot.accept.failure id=42']);
  });
}
