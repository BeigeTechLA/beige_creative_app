import 'package:flutter/foundation.dart' show ChangeNotifier, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/connectivity/connectivity_providers.dart';
import '../core/connectivity/connectivity_status.dart';
import '../core/firebase/app_analytics_observer.dart';
import '../core/providers/auth_state_provider.dart';
import '../core/providers/onboarding_seen_provider.dart';
import '../core/restoration/restoration_providers.dart';
import '../features/availability/presentation/routes/availability_routes.dart';
import '../features/availability/presentation/screens/manage_availability_screen.dart';
import '../features/auth/presentation/routes/auth_routes.dart';
import '../features/file_manager/presentation/routes/file_manager_routes.dart';
import '../features/file_manager/presentation/screens/file_manager_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/menu_placeholders/presentation/screens/menu_placeholder_screen.dart';
import '../features/meetings/presentation/routes/meetings_routes.dart';
import '../features/meetings/presentation/screens/meetings_screen.dart';
import '../features/messages/presentation/routes/messages_routes.dart';
import '../features/messages/presentation/screens/messages_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/routes/profile_routes.dart';
import '../features/shoots/presentation/routes/shoots_routes.dart';
import '../features/shoots/presentation/screens/shoots_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../shared/layouts/app_shell.dart';
import 'navigator_key.dart';
import 'routes.dart';

/// Built once per [ProviderScope]. Reads `authStateProvider` +
/// `onboardingSeenProvider` for redirect logic and listens to both via a
/// merged `Listenable` so the router re-evaluates redirect on either flip.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash.path,
    refreshListenable: notifier,
    observers: [AppAnalyticsObserver()],
    redirect: (context, state) => appRedirect(
      isAuth: ref.read(authStateProvider),
      hasSeenOnboarding: ref.read(onboardingSeenProvider),
      connStatus: ref.read(connectivityStatusProvider),
      location: state.matchedLocation,
    ),
    routes: appRoutes,
  );

  // Phase B — persist matchedLocation on every router change. No-op while
  // kRestorationEnabled is false (service short-circuits internally).
  final restoration = ref.read(routeRestorationServiceProvider);
  void persistOnChange() {
    final match = router.routerDelegate.currentConfiguration;
    final loc = match.uri.path;
    restoration.persist(
      matchedLocation: loc,
      queryParameters: match.uri.queryParameters,
    );
  }

  router.routerDelegate.addListener(persistOnChange);
  ref.onDispose(() => router.routerDelegate.removeListener(persistOnChange));

  return router;
});

/// Pure redirect logic — kept top-level so router behaviour stays testable
/// without spinning up the whole `routerProvider` graph (restoration, splash
/// lottie, etc.).
///
/// Returns a target path when the redirect should override navigation, or
/// `null` to allow the requested location.
@visibleForTesting
String? appRedirect({
  required bool isAuth,
  required bool hasSeenOnboarding,
  required ConnectivityStatus connStatus,
  required String location,
}) {
  final isPublic = Routes.publicPaths.contains(location);

  // Offline + protected target → stay put; ConnectivityListener shows
  // the dialog over the current screen. Public routes (splash/auth/
  // onboarding) stay reachable so cold-start without network resolves.
  if (connStatus == ConnectivityStatus.offline && !isPublic) {
    return null;
  }

  // Unauthed user touching a protected route → /login.
  if (!isAuth && !isPublic) return Routes.login.path;

  // Onboarding skipped once seen — bounce to /login.
  if (!isAuth && hasSeenOnboarding && location == Routes.onboarding.path) {
    return Routes.login.path;
  }

  // Authed user on /login or sign-up flow → /home.
  if (isAuth &&
      (location == Routes.login.path ||
          location == Routes.onboarding.path ||
          location.startsWith('/signup-step') ||
          location == Routes.forgotPassword.path ||
          location == Routes.forgotOtp.path ||
          location == Routes.resetPassword.path)) {
    return Routes.home.path;
  }
  return null;
}

/// Bridges `authStateProvider` + `onboardingSeenProvider` +
/// `connectivityStatusProvider` to `Listenable` for `GoRouter.refreshListenable`.
/// Any flip triggers redirect re-eval.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _authSub = _ref.listen<bool>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
    _onboardingSub = _ref.listen<bool>(
      onboardingSeenProvider,
      (previous, next) => notifyListeners(),
    );
    _connSub = _ref.listen<ConnectivityStatus>(
      connectivityStatusProvider,
      (previous, next) => notifyListeners(),
    );
  }
  final Ref _ref;
  late final ProviderSubscription<bool> _authSub;
  late final ProviderSubscription<bool> _onboardingSub;
  late final ProviderSubscription<ConnectivityStatus> _connSub;

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
    _connSub.close();
    super.dispose();
  }
}

/// Composed route tree. Entry-point routes (splash, onboarding) and root
/// `StatefulShellRoute` destinations stay inline because they describe the
/// app's global lifecycle. Everything else lives in per-feature `*_routes.dart`
/// fragment files and is spread in below.
final List<RouteBase> appRoutes = [
  GoRoute(
    path: Routes.splash.path,
    name: Routes.splash.name,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: Routes.onboarding.path,
    name: Routes.onboarding.name,
    builder: (context, state) => const OnboardingScreen(),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(shell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.home.path,
            name: Routes.home.name,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.shoots.path,
            name: Routes.shoots.name,
            builder: (context, state) => const ShootsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.files.path,
            name: Routes.files.name,
            builder: (context, state) => const FileManagerScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.messages.path,
            name: Routes.messages.name,
            builder: (context, state) => const MessagesScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.meetings.path,
            name: Routes.meetings.name,
            builder: (context, state) => const MeetingsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.manageAvailability.path,
            name: Routes.manageAvailability.name,
            builder: (context, state) => const ManageAvailabilityScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.affiliate.path,
            name: Routes.affiliate.name,
            builder: (context, state) => const MenuPlaceholderScreen(
              title: 'Affiliate',
              description: 'Affiliate tools arriving soon.',
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Routes.payouts.path,
            name: Routes.payouts.name,
            builder: (context, state) => const MenuPlaceholderScreen(
              title: 'Payouts',
              description: 'Payouts arriving soon.',
            ),
          ),
        ],
      ),
    ],
  ),
  ...authRoutes,
  ...profileRoutes,
  ...shootsRoutes,
  ...availabilityRoutes,
  ...fileManagerRoutes,
  ...messagesRoutes,
  ...meetingsRoutes,
];
