import 'package:beige_creative_app/app/routes.dart';
import 'package:beige_creative_app/app/theme.dart';
import 'package:beige_creative_app/core/providers/account_status_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/features/profile/domain/models/deletion_request.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/delete_account_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/delete_account_providers.dart';
import 'package:beige_creative_app/features/profile/presentation/screens/delete_account_otp_screen.dart';
import 'package:beige_creative_app/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:beige_creative_app/features/profile/presentation/screens/delete_account_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDeleteAccountRepository implements DeleteAccountRepository {
  bool otpRequested = false;
  String? confirmedOtp;

  @override
  Future<void> requestOtp() async {
    otpRequested = true;
  }

  @override
  Future<DeletionRequest> confirm(String otp) async {
    confirmedOtp = otp;
    return DeletionRequest(
      id: 'DEL-12345',
      status: 'deletion_pending',
      scheduledAt: DateTime(2026, 5, 15),
      confirmationEmailSent: true,
    );
  }

  @override
  Future<DeletionRequest> status() async {
    return DeletionRequest(
      id: 'DEL-12345',
      status: 'deletion_pending',
      scheduledAt: DateTime(2026, 5, 15),
      confirmationEmailSent: true,
    );
  }

  @override
  Future<DeletionRequest> cancel() async {
    return DeletionRequest(
      id: 'DEL-12345',
      status: 'cancelled',
      scheduledAt: DateTime(2026, 5, 15),
    );
  }
}

GoRouter router({String initial = '/', bool stubSuccess = false}) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const DeleteAccountScreen()),
    GoRoute(
      path: '/otp',
      name: Routes.deleteAccountOtp.name,
      builder: (_, _) => const DeleteAccountOtpScreen(),
    ),
    GoRoute(
      path: '/success',
      name: Routes.deleteAccountSuccess.name,
      builder: (_, _) => stubSuccess
          ? const Scaffold(body: Text('Confirmed receipt'))
          : const DeleteAccountSuccessScreen(),
    ),
  ],
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('deletion notifier lifecycle: request, confirm, cancel', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = FakeDeleteAccountRepository();
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        deleteAccountRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(deletionProvider.notifier);

    // Initial state
    expect(container.read(deletionProvider).busy, isFalse);
    expect(container.read(deletionProvider).otpSent, isFalse);

    // Request OTP
    final requested = await notifier.requestOtp();
    expect(requested, isTrue);
    expect(repo.otpRequested, isTrue);
    expect(container.read(deletionProvider).otpSent, isTrue);

    // Confirm OTP
    final confirmed = await notifier.confirm('123456');
    expect(confirmed, isTrue);
    expect(repo.confirmedOtp, '123456');
    expect(
      container.read(accountStatusProvider),
      AccountStatus.deletionPending,
    );
    expect(container.read(deletionReceiptProvider)?.id, 'DEL-12345');

    // Cancel deletion
    final cancelled = await notifier.cancel();
    expect(cancelled, isTrue);
    expect(container.read(accountStatusProvider), AccountStatus.active);
    expect(container.read(deletionProvider).cancelled, isTrue);
  });

  testWidgets('OTP entry screen supports typing and paste autofill', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = await SharedPreferences.getInstance();
    final repo = FakeDeleteAccountRepository();
    final r = router(initial: '/otp', stubSuccess: true);
    addTearDown(r.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          deleteAccountRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(routerConfig: r, theme: AppTheme.dark()),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(DeleteAccountOtpScreen)),
    );
    await container.read(deletionProvider.notifier).requestOtp();
    await tester.pump();

    // Verify initial button is disabled without 6 digits
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    // Paste 6 digits into first field
    await tester.enterText(
      find.byKey(const ValueKey('deletion-otp-0')),
      '123456',
    );
    await tester.pump();

    expect(repo.confirmedOtp, isNull);
    expect(r.routeInformationProvider.value.uri.path, '/otp');

    // Verify all 6 fields filled
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('deletion-otp-5')))
          .controller!
          .text,
      '6',
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );

    // Resend clears fields
    await tester.tap(find.text('Resend OTP'));
    await tester.pump();
    expect(repo.otpRequested, isTrue);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('deletion-otp-0')))
          .controller!
          .text,
      '',
    );
    for (var i = 0; i < 6; i++) {
      await tester.enterText(
        find.byKey(ValueKey('deletion-otp-$i')),
        '${i + 1}',
      );
    }
    await tester.pump();
    expect(repo.confirmedOtp, isNull);
    await tester.ensureVisible(find.text('Verify & Delete my Account'));
    await tester.tap(find.text('Verify & Delete my Account'));
    await tester.pumpAndSettle();
    expect(repo.confirmedOtp, '123456');
    expect(find.text('Confirmed receipt'), findsOneWidget);
  });

  testWidgets('OTP fits a narrow viewport with keyboard and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
    final repo = FakeDeleteAccountRepository();
    final r = router(initial: '/otp');
    addTearDown(r.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          deleteAccountRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          routerConfig: r,
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Verify & Delete my Account'));
    expect(tester.takeException(), isNull);
  });
}
