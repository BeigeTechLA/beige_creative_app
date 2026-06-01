import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/delete_account_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/delete_account_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements DeleteAccountRepository {
  bool requestCalled = false;
  bool confirmCalled = false;
  bool resendCalled = false;
  String? lastReason;
  String? lastOtp;
  bool throwOnRequest = false;
  bool throwOnConfirm = false;

  @override
  Future<void> requestDelete(String reason) async {
    requestCalled = true;
    lastReason = reason;
    if (throwOnRequest) throw Exception('User not found');
  }

  @override
  Future<void> confirmDelete(String otp) async {
    confirmCalled = true;
    lastOtp = otp;
    if (throwOnConfirm) throw Exception('Invalid OTP');
  }

  @override
  Future<void> resendOtp() async {
    resendCalled = true;
  }
}

class _FakeSession implements SessionStore {
  bool cleared = false;

  @override
  Future<void> clearSession() async {
    cleared = true;
  }

  // Unused in these tests — throw so accidental use is loud.
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> writeToken(String token) async {}
  @override
  Future<void> clearToken() async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clearRefreshToken() async {}
  @override
  Future<UserSnapshot?> readUser() async => null;
  @override
  Future<void> writeUser(UserSnapshot user) async {}
  @override
  Future<void> clearUser() async {}
  @override
  Future<DateTime?> readLastLoginAt() async => null;
  @override
  Future<void> writeLastLoginAt(DateTime when) async {}
  @override
  Future<bool> readOnboardingSeen() async => false;
  @override
  Future<void> writeOnboardingSeen(bool seen) async {}
  @override
  Future<bool> isLoggedIn() async => false;
}

Future<ProviderContainer> _container({
  required _FakeRepo repo,
  _FakeSession? session,
}) async {
  // Phase B — logout() now wipes restoration + draft stores, both backed
  // by SharedPreferences via prefsProvider. Mock-init prefs so the
  // override resolves to a real (in-memory) instance.
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      deleteAccountRepositoryProvider.overrideWithValue(repo),
      if (session != null)
        sessionStoreProvider.overrideWithValue(session),
      prefsProvider.overrideWithValue(prefs),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('DeleteAccountNotifier.requestDelete', () {
    test('rejects when no reason selected', () async {
      final repo = _FakeRepo();
      final c = await _container(repo: repo);
      final ok = await c
          .read(deleteAccountNotifierProvider.notifier)
          .requestDelete();
      expect(ok, isFalse);
      expect(repo.requestCalled, isFalse);
      expect(
        c.read(deleteAccountNotifierProvider).validationMessage,
        'Please select delete reason',
      );
    });

    test('happy path posts reason', () async {
      final repo = _FakeRepo();
      final c = await _container(repo: repo);
      final notifier = c.read(deleteAccountNotifierProvider.notifier);
      notifier.selectReason('Others');
      final ok = await notifier.requestDelete();
      expect(ok, isTrue);
      expect(repo.lastReason, 'Others');
      expect(c.read(deleteAccountNotifierProvider).requestOk, isTrue);
    });

    test('surfaces repo error', () async {
      final repo = _FakeRepo()..throwOnRequest = true;
      final c = await _container(repo: repo);
      final notifier = c.read(deleteAccountNotifierProvider.notifier);
      notifier.selectReason('Others');
      final ok = await notifier.requestDelete();
      expect(ok, isFalse);
      expect(
        c.read(deleteAccountNotifierProvider).errorMessage,
        'User not found',
      );
    });
  });

  group('DeleteAccountNotifier.confirmDelete', () {
    test('rejects partial OTP', () async {
      final repo = _FakeRepo();
      final session = _FakeSession();
      final c = await _container(repo: repo, session: session);
      final ok = await c
          .read(deleteAccountNotifierProvider.notifier)
          .confirmDelete('123');
      expect(ok, isFalse);
      expect(repo.confirmCalled, isFalse);
      expect(session.cleared, isFalse);
    });

    test('happy path clears session + flips auth state', () async {
      final repo = _FakeRepo();
      final session = _FakeSession();
      final c = await _container(repo: repo, session: session);
      c.read(authStateProvider.notifier).state = true;

      final ok = await c
          .read(deleteAccountNotifierProvider.notifier)
          .confirmDelete('123456');
      expect(ok, isTrue);
      expect(repo.lastOtp, '123456');
      expect(session.cleared, isTrue);
      expect(c.read(authStateProvider), isFalse);
      expect(c.read(deleteAccountNotifierProvider).confirmOk, isTrue);
    });

    test('repo failure leaves session intact', () async {
      final repo = _FakeRepo()..throwOnConfirm = true;
      final session = _FakeSession();
      final c = await _container(repo: repo, session: session);
      c.read(authStateProvider.notifier).state = true;

      final ok = await c
          .read(deleteAccountNotifierProvider.notifier)
          .confirmDelete('123456');
      expect(ok, isFalse);
      expect(session.cleared, isFalse);
      expect(c.read(authStateProvider), isTrue);
      expect(
        c.read(deleteAccountNotifierProvider).errorMessage,
        'Invalid OTP',
      );
    });
  });
}
