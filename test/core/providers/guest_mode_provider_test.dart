import 'package:beige_creative_app/core/providers/guest_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuestModeNotifier', () {
    test('initial state is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(guestModeProvider), isFalse);
    });

    test('enter() sets state to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(guestModeProvider.notifier).enter();
      expect(container.read(guestModeProvider), isTrue);
    });

    test('exit() resets state to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(guestModeProvider.notifier).enter();
      expect(container.read(guestModeProvider), isTrue);

      container.read(guestModeProvider.notifier).exit();
      expect(container.read(guestModeProvider), isFalse);
    });
  });
}
