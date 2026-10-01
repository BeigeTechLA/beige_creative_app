import 'package:flutter/foundation.dart' show ChangeNotifier, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/connectivity/connectivity_providers.dart';
import '../core/connectivity/connectivity_status.dart';
import '../core/firebase/app_analytics_observer.dart';
import '../core/providers/auth_state_provider.dart';
import '../core/providers/core_providers.dart';
import '../core/providers/guest_mode_provider.dart';
import '../core/providers/onboarding_seen_provider.dart';
import '../core/restoration/restoration_providers.dart';
import '../core/session/temporary_auth_session.dart';
import '../features/affiliate/presentation/screens/affiliate_screen.dart';
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
/// `guestModeProvider` + `onboardingSeenProvider` for redirect logic and
/// listens to them via a merged `Listenable` so the router re-evaluates
/// redirect on any state flip.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash.path,
    refreshListenable: notifier,
    observers: [AppAnalyticsObserver()],
    redirect: (context, state) {
      final currentUser = ref.read(currentSessionUserProvider);
      return appRedirect(
        isAuth: ref.read(authStateProvider),
        isGuest: ref.read(guestModeProvider),
        hasSeenOnboarding: ref.read(onboardingSeenProvider),
        connStatus: ref.read(connectivityStatusProvider),
        location: state.matchedLocation,
        isRegistrationComplete: currentUser?.isRegistrationComplete,
        isCrewVerified: currentUser?.isCrewVerified,
        isStep2Complete: currentUser?.isStep2Complete,
      );
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
  bool isGuest = false,
  int? isRegistrationComplete,
  int? isCrewVerified,
  bool? isStep2Complete,
}) {
  final isPublic = Routes.publicPaths.contains(location);

  // Unauthed non-guest user touching a protected route → /login.
  if (!isAuth && !isGuest && !isPublic) return Routes.login.path;

  // Guest user touching a route outside home shell + public auth routes → /home.
  if (!isAuth && isGuest && location != Routes.home.path && !isPublic) {
    return Routes.home.path;
  }

  // Authed user logic
  if (isAuth) {
    final regComplete = isRegistrationComplete;
    final crewVerified = isCrewVerified;

    // A token without a valid persisted account status must never inherit
    // approved access. Keep the user on Login so a fresh response can rebuild
    // the session snapshot.
    if (regComplete == null ||
        !const {0, 1}.contains(regComplete) ||
        crewVerified == null ||
        !const {0, 1, 2}.contains(crewVerified)) {
      return location == Routes.login.path ? null : Routes.login.path;
    }

    // Case 1: Registration incomplete means account registration (Step 1)
    // already exists. Resume profile completion from Step 2.
    if (regComplete == 0) {
      final target = isStep2Complete == true
          ? Routes.signupStep3.path
          : Routes.signupStep2.path;
      // The backend flag selects the login/resume landing step. Once the user
      // is inside the signup flow, allow its own forward/back navigation so a
      // successful Step 2 submit can advance without racing this redirect.
      final isResumeRoute =
          location == Routes.signupStep2.path ||
          location == Routes.signupStep3.path ||
          location == Routes.signupSuccess.path;
      if (!isResumeRoute) {
        return target;
      }
      return null;
    }

    // Case 2: Registration complete, but application under review or rejected.
    // Home is a blocked landing surface with a non-dismissible status dialog;
    // profile routes remain available so the CP can review or improve their profile.
    if (regComplete == 1 && (crewVerified == 0 || crewVerified == 2)) {
      final isPendingAllowedRoute =
          location == Routes.home.path ||
          location == Routes.myProfile.path ||
          location == Routes.cropImage.path ||
          location == Routes.editPersonalDetails.path ||
          location == Routes.enterProfessionalDetails.path ||
          location == Routes.profileDetails.path ||
          location == Routes.featuredWorks.path ||
          location == Routes.featuredWorkDetails.path ||
          location == Routes.certificates.path ||
          location == Routes.resume.path ||
          location == Routes.appPreferences.path ||
          location == Routes.changePassword.path ||
          location == Routes.profileOtp.path ||
          location == Routes.newPassword.path ||
          location == Routes.profilePasswordSuccess.path ||
          location == Routes.deleteAccount.path ||
          location == Routes.deleteAccountOtp.path ||
          location == Routes.deleteAccountSuccess.path;

      if (!isPendingAllowedRoute &&
          location != Routes.splash.path &&
          location != Routes.login.path) {
        return Routes.home.path;
      }
      return null;
    }

    // Case 3: Approved CP (is_registration_complete == 1 && is_crew_verified == 1)
    if (location == Routes.login.path ||
        location == Routes.onboarding.path ||
        location.startsWith('/signup-step') ||
        location == Routes.forgotPassword.path ||
        location == Routes.forgotOtp.path ||
        location == Routes.resetPassword.path ||
        location == Routes.applicationRejected.path) {
      return Routes.home.path;
    }
  }

  return null;
}

/// Bridges `authStateProvider` + `guestModeProvider` + `onboardingSeenProvider` +
/// `connectivityStatusProvider` to `Listenable` for `GoRouter.refreshListenable`.
/// Any flip triggers redirect re-eval.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _authSub = _ref.listen<bool>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
    _guestSub = _ref.listen<bool>(
      guestModeProvider,
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
    _temporaryAuthSub = _ref.listen<TemporaryAuthState>(
      temporaryAuthSessionProvider,
      (previous, next) => notifyListeners(),
    );
  }
  final Ref _ref;
  late final ProviderSubscription<bool> _authSub;
  late final ProviderSubscription<bool> _guestSub;
  late final ProviderSubscription<bool> _onboardingSub;
  late final ProviderSubscription<ConnectivityStatus> _connSub;
  late final ProviderSubscription<TemporaryAuthState> _temporaryAuthSub;

  @override
  void dispose() {
    _authSub.close();
    _guestSub.close();
    _onboardingSub.close();
    _connSub.close();
    _temporaryAuthSub.close();
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
            builder: (context, state) => const AffiliateScreen(),
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
