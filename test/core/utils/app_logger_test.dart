import 'package:beige_creative_app/core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

class _Capture {
  Object? error;
  StackTrace? stack;
  String? reason;
  bool? fatal;
  int calls = 0;
}

void main() {
  late _Capture capture;

  setUp(() {
    capture = _Capture();
    AppLogger.crashRecorder = (
      Object error,
      StackTrace? stack, {
      String? reason,
      bool fatal = false,
    }) async {
      capture
        ..calls += 1
        ..error = error
        ..stack = stack
        ..reason = reason
        ..fatal = fatal;
    };
  });

  tearDown(() {
    // Restore so other tests don't inherit the stubs.
    AppLogger.crashRecorder = AppLogger.defaultCrashRecorder;
    AppLogger.debugModeOverride = () => true;
  });

  group('AppLogger.e Crashlytics bridge', () {
    test('forwards to Crashlytics with error + stack in release path',
        () async {
      AppLogger.debugModeOverride = () => false; // simulate release
      final st = StackTrace.current;
      final err = StateError('boom');

      AppLogger.e('upload failed', err, st);
      await Future<void>.delayed(Duration.zero); // drain unawaited future.

      expect(capture.calls, 1);
      expect(capture.error, same(err));
      expect(capture.stack, same(st));
      expect(capture.reason, 'logger.e: upload failed');
      expect(capture.fatal, isFalse);
    });

    test('does NOT forward when error is null (message-only)', () async {
      AppLogger.debugModeOverride = () => false;
      AppLogger.e('nothing-to-report');
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('does NOT forward in debug mode even when error is present',
        () async {
      AppLogger.debugModeOverride = () => true; // simulate debug
      AppLogger.e('upload failed', StateError('boom'), StackTrace.current);
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });

    test('forwards each call once — no batching, no recursion', () async {
      AppLogger.debugModeOverride = () => false;
      AppLogger.e('first', StateError('a'));
      AppLogger.e('second', StateError('b'));
      AppLogger.e('third'); // no error → skipped
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 2);
    });
  });

  group('AppLogger.e — non-error logging behavior preserved', () {
    test('d / i / w never invoke crashRecorder', () async {
      AppLogger.debugModeOverride = () => false;
      AppLogger.d('debug');
      AppLogger.i('info');
      AppLogger.w('warn');
      await Future<void>.delayed(Duration.zero);
      expect(capture.calls, 0);
    });
  });
}
