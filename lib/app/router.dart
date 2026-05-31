import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/firebase/app_analytics_observer.dart';
import '../core/providers/auth_state_provider.dart';
import '../core/providers/onboarding_seen_provider.dart';
import '../features/availability/presentation/routes/availability_routes.dart';
import '../features/availability/presentation/screens/manage_availability_screen.dart';
import '../features/auth/presentation/routes/auth_routes.dart';
import '../features/file_manager/presentation/routes/file_manager_routes.dart';
import '../features/file_manager/presentation/screens/file_manager_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/messages/presentation/screens/messages_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/routes/profile_routes.dart';
import '../features/shoots/presentation/routes/shoots_routes.dart';
import '../features/shoots/presentation/screens/shoots_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../shared/layouts/app_shell.dart';
import 'route_names.dart';

/// Public routes — reachable while unauthenticated.
const Set<String> _publicRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/signup-step-1',
  '/signup-step-2',
  '/signup-step-3',
  '/forgot-password',
  '/forgot-otp',
  '/reset-password',
};

/// Built once per [ProviderScope]. Reads `authStateProvider` for redirect
/// logic and listens to it via a `ChangeNotifier` adapter so the router
/// re-evaluates redirect on token writes/clears (login + logout + 401).
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    observers: [AppAnalyticsObserver()],
    redirect: (context, state) {
      final isAuth = ref.read(authStateProvider);
      final hasSeenOnboarding = ref.read(onboardingSeenProvider);
      final loc = state.matchedLocation;
      final isPublic = _publicRoutes.contains(loc);

      // Unauthed user touching a protected route → /login.
      if (!isAuth && !isPublic) return '/login';

      // Onboarding skipped once seen — bounce to /login.
      if (!isAuth && hasSeenOnboarding && loc == '/onboarding') {
        return '/login';
      }

      // Authed user on /login or sign-up flow → /home.
      if (isAuth &&
          (loc == '/login' ||
              loc == '/onboarding' ||
              loc.startsWith('/signup-step') ||
              loc == '/forgot-password' ||
              loc == '/forgot-otp' ||
              loc == '/reset-password')) {
        return '/home';
      }
      return null;
    },
    routes: _routes,
  );
});

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _sub = _ref.listen<bool>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }
  final Ref _ref;
  late final ProviderSubscription<bool> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Composed route tree. Entry-point routes (splash, onboarding) + the
/// 5-tab `StatefulShellRoute` stay inline because they describe the app's
/// global lifecycle. Everything else lives in per-feature `*_routes.dart`
/// fragment files and is spread in below.
final List<RouteBase> _routes = [
  GoRoute(
    path: '/splash',
    name: RouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: '/onboarding',
    name: RouteNames.onboarding,
    builder: (context, state) => const OnboardingScreen(),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(shell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/shoots',
            name: RouteNames.shoots,
            builder: (context, state) => const ShootsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/files',
            name: RouteNames.files,
            builder: (context, state) => const FileManagerScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/messages',
            name: RouteNames.messages,
            builder: (context, state) => const MessagesScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/manage-availability',
            name: RouteNames.manageAvailability,
            builder: (context, state) => const ManageAvailabilityScreen(),
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
