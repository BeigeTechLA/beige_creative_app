import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/telemetry_client.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../session/session_store.dart';

/// App-wide singleton providers. None of these are `.autoDispose` — they live
/// for the process lifetime per `MIGRATION_RULES.md` §3.10.

/// Resolved by overriding with `SharedPreferences.getInstance()` in `startApp`
/// (or `Future.value(prefs)` inside test `pumpProviderApp`). Consumers call
/// `ref.watch(sharedPreferencesProvider.future)` or `.requireValue` post-load.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) async {
    throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in startApp / test harness.',
    );
  },
);

/// Synchronous handle to the same `SharedPreferences` instance, available
/// once `startApp` has awaited `SharedPreferences.getInstance()`. Used by
/// restoration / draft providers that need sync read on first router build.
final prefsProvider = Provider<SharedPreferences>(
  (ref) {
    throw UnimplementedError(
      'prefsProvider must be overridden in startApp / test harness.',
    );
  },
);

/// Concrete `SessionStore` implementations land in Task 3.13. Until overridden
/// this provider throws — the override is wired in Task 3.16 (`pumpProviderApp`)
/// and in `startApp` once Task 3.13 closes.
final sessionStoreProvider = Provider<SessionStore>(
  (ref) {
    throw UnimplementedError(
      'sessionStoreProvider must be overridden — concrete impl arrives in Task 3.13.',
    );
  },
);

/// Single Dio holder with interceptors attached in canonical order:
/// `Auth → Retry → Error → Logging` (dev only). Per `MIGRATION_RULES.md` §5.4.
final dioClientProvider = Provider<DioClient>(
  (ref) {
    final session = ref.watch(sessionStoreProvider);
    final client = DioClient();
    client.attachInterceptors([
      AuthInterceptor(
        tokenReader: session.readToken,
        onUnauthorized: () async {
          await session.clearSession();
          // 401 / token-expiry: drop telemetry identity too so the next
          // crash report isn't attributed to a stale user. Skip the logout
          // event — the user didn't choose this.
          try {
            await ref
                .read(telemetryClientProvider)
                .clearUserIdentity();
          } catch (_) {
            // Best-effort — interceptor must complete.
          }
        },
      ),
      RetryInterceptor(dio: client.dio),
      ErrorInterceptor(),
   //   if (kDebugMode) LoggingInterceptor(),
    ]);
    return client;
  },
);

/// Connectivity moved to `lib/core/connectivity/connectivity_providers.dart`
/// in the no-internet-handling work (debounced + reachability-checked status
/// stream with a domain `ConnectivityStatus` enum). Import from there.
