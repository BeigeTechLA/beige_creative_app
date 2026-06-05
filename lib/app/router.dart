import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    redirect: (context, state) {
      final isAuth = ref.read(authStateProvider);
      final hasSeenOnboarding = ref.read(onboardingSeenProvider);
      final loc = state.matchedLocation;
      final isPublic = Routes.publicPaths.contains(loc);

      // Unauthed user touching a protected route → /login.
      if (!isAuth && !isPublic) return Routes.login.path;

      // Onboarding skipped once seen — bounce to /login.
      if (!isAuth && hasSeenOnboarding && loc == Routes.onboarding.path) {
        return Routes.login.path;
      }

      // Authed user on /login or sign-up flow → /home.
      if (isAuth &&
          (loc == Routes.login.path ||
              loc == Routes.onboarding.path ||
              loc.startsWith('/signup-step') ||
              loc == Routes.forgotPassword.path ||
              loc == Routes.forgotOtp.path ||
              loc == Routes.resetPassword.path)) {
        return Routes.home.path;
      }
      return null;
    },
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

/// Bridges `authStateProvider` + `onboardingSeenProvider` to `Listenable`
/// for `GoRouter.refreshListenable`. Either flip triggers redirect re-eval.
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
  }
  final Ref _ref;
  late final ProviderSubscription<bool> _authSub;
  late final ProviderSubscription<bool> _onboardingSub;

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
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
            builder: (context, state) => const MenuPlaceholderScreen(
              title: 'Meetings',
              description: 'Meetings arriving soon.',
            ),
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
];
