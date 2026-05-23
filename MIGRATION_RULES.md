# Flutter Project Migration Rules — Riverpod Architecture

> **Purpose:** Complete migration rulebook for converting an existing Flutter project to Clean Architecture with **Riverpod** state management, following the team's established guidelines from:
> - `FLUTTER_BASE_GUIDELINES.md` — Architecture, Network, Firebase, Navigation, CI/CD
> - `FLUTTER_DESIGN_SYSTEM.md` — Typography, Colors, Spacing, Radii, Shadows, Themes, Components
> - `FLUTTER_TESTING_GUIDELINES.md` — Unit, Widget, Integration, Golden tests
>
> **Golden Rule:** Never break working functionality. The app must remain shippable after every commit.

---

## 1. Core Migration Principles

### 1.1 — Never Rewrite, Always Migrate

- Migrate ONE feature at a time. Never refactor the entire codebase in a single pass.
- Every migration step must be a standalone commit that compiles and runs.
- If a migration step touches more than 8–10 files, break it into smaller steps.
- Old code and new code will coexist during migration — that is expected and acceptable.

### 1.2 — Migration Phase Order (Strictly Follow)

```
Phase 1 → Audit & document current state
Phase 2 → Create CLAUDE.md + target folder structure (empty)
Phase 3 → Extract foundations (design tokens, network layer, router)
Phase 4 → Migrate features to Riverpod (simplest → most complex)
Phase 5 → Remove dead code & standardize naming
Phase 6 → Add tests & CI enforcement
```

Never skip a phase. Never start Phase 4 before Phase 3 is fully committed.

### 1.3 — The Shippable Rule

After EVERY migration step, the following must pass:

```bash
flutter analyze        # Zero errors (warnings acceptable during migration)
flutter build apk      # Builds successfully
flutter build ios      # Builds successfully (if on macOS)
flutter run             # App launches and primary flows work
```

If any of these fail, fix before proceeding. Never stack broken changes.

### 1.4 — Flavor Protection

```
CRITICAL: NEVER modify the flavors/ directory or flavor configuration
during migration unless explicitly approved. Flavors are already set up
correctly — treat them as read-only.
```

---

## 2. Target Folder Structure (From FLUTTER_BASE_GUIDELINES.md)

```
lib/
├── main.dart                           # App entry
├── main_dev.dart                       # Dev flavor entry — DO NOT TOUCH
├── main_staging.dart                   # Staging flavor entry — DO NOT TOUCH
├── main_prod.dart                      # Prod flavor entry — DO NOT TOUCH
│
├── app/
│   ├── app.dart                        # MaterialApp.router / ProviderScope root
│   ├── router.dart                     # GoRouter setup + route definitions
│   ├── theme.dart                      # AppTheme.light() + AppTheme.dark()
│   ├── colors.dart                     # AppColors — all color constants
│   ├── text_styles.dart                # AppTextStyles — centralized typography
│   ├── spacing.dart                    # AppSpacing — padding/margin constants
│   ├── radii.dart                      # AppRadii — border radius values
│   ├── shadows.dart                    # AppShadows — elevation shadows
│   ├── durations.dart                  # AppDurations — animation timings
│   ├── assets.dart                     # AppAssets — image/icon/font path constants
│   └── flavor_config.dart              # Environment/flavor configuration — DO NOT TOUCH
│
├── core/
│   ├── network/
│   │   ├── dio_client.dart             # Singleton Dio instance + BaseOptions
│   │   ├── api_endpoints.dart          # All API endpoint constants
│   │   ├── api_response.dart           # Generic API response wrapper
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart   # QueuedInterceptor — token inject + refresh
│   │   │   ├── error_interceptor.dart  # DioException → AppException mapping
│   │   │   ├── logging_interceptor.dart# Request/response logging (dev only)
│   │   │   └── retry_interceptor.dart  # Retry on 5xx with exponential backoff
│   │   └── exceptions/
│   │       ├── app_exception.dart      # sealed class AppException
│   │       ├── network_exception.dart  # NoInternet, Timeout, Cancelled
│   │       ├── server_exception.dart   # 5xx errors
│   │       ├── client_exception.dart   # 401, 403, 404, 422, 429
│   │       └── exception_handler.dart  # ExceptionHandler.guardAsync()
│   │
│   ├── firebase/
│   │   ├── firebase_service.dart       # Firebase init + flavor-aware config
│   │   ├── analytics_service.dart      # Centralized screen + event tracking
│   │   ├── analytics_events.dart       # Event name constants + param builders
│   │   ├── analytics_observer.dart     # RouteObserver for automatic screen tracking
│   │   ├── crashlytics_service.dart    # Crash reporting + custom error logging
│   │   └── crashlytics_keys.dart       # Custom key constants
│   │
│   ├── providers/
│   │   └── core_providers.dart         # App-wide Riverpod providers (DioClient, etc.)
│   ├── utils/
│   │   └── [utility_files].dart        # Date formatters, validators, helpers
│   └── extensions/
│       └── [extension_files].dart      # Context, String, DateTime extensions
│
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── models/                 # DTOs — fromJson/toJson (freezed + json_serializable)
│       │   ├── datasources/
│       │   │   ├── [feature]_remote_datasource.dart
│       │   │   └── [feature]_local_datasource.dart
│       │   └── repositories/
│       │       └── [feature]_repository_impl.dart
│       ├── domain/
│       │   ├── entities/               # Pure Dart classes — zero dependencies
│       │   ├── repositories/
│       │   │   └── [feature]_repository.dart   # Abstract contract
│       │   └── usecases/
│       │       └── [usecase_name].dart
│       └── presentation/
│           ├── screens/
│           │   └── [screen_name]_screen.dart
│           ├── widgets/                # Feature-specific widgets
│           └── providers/              # Riverpod providers for this feature
│               ├── [feature]_provider.dart
│               └── [feature]_state.dart
│
├── shared/
│   ├── widgets/                        # Reusable UI components (used by 2+ features)
│   └── layouts/                        # Shell layouts, scaffolds, wrappers
│
└── dummy/
    └── dummy_data.dart                 # All placeholder/mock data in one place
```

### Folder Rules

- One widget per file. No exceptions.
- Feature folders are `lowercase_snake_case`.
- Never import from one feature's `data/` layer into another feature — go through `domain/`.
- `core/` is shared infrastructure — never contains UI widgets.
- `shared/widgets/` is for truly reusable components used by 2+ features.
- Feature-specific widgets live inside `features/[feature]/presentation/widgets/`.

---

## 3. Riverpod State Management — Migration Rules

### 3.1 — Architecture Flow (Riverpod Specific)

```
UI (ConsumerWidget) → Provider → UseCase → Repository → DataSource → DioClient
```

- **Screens** extend `ConsumerWidget` or `ConsumerStatefulWidget`
- **Providers** are the only bridge between UI and business logic
- **Providers** call UseCases or Repositories — never Dio directly
- **Repositories** use `ExceptionHandler.guardAsync()` — return `Either<AppException, T>`

### 3.2 — Root Setup

```dart
// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
```

**Entry point update** (each flavor file):

```dart
// lib/main_dev.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.init(Flavor.dev);
  await FirebaseService.initialize();
  runApp(const App());   // App already wraps in ProviderScope
}
```

### 3.3 — Provider Types & When to Use Each

| Provider Type | When to Use | Example |
|---|---|---|
| `Provider` | Computed values, service instances that don't change | `dioClientProvider`, `authRepositoryProvider` |
| `StateProvider` | Simple single-value state (selected tab, toggle, filter) | `selectedTabProvider` |
| `FutureProvider` | One-shot async data fetch (profile, config) | `userProfileProvider` |
| `StreamProvider` | Real-time data streams (chat, notifications) | `messagesProvider` |
| `NotifierProvider` | Complex state with multiple actions (forms, lists, CRUD) | `loginNotifierProvider` |
| `AsyncNotifierProvider` | Complex state with async initialization + actions | `cartNotifierProvider` |

### 3.4 — Provider Naming Convention

```dart
// Service/Repository providers (singleton-like)
final dioClientProvider = Provider<DioClient>((ref) => DioClient());
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Simple state
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Future data
final userProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final result = await repo.getProfile();
  return result.fold((error) => throw error, (data) => data);
});

// Complex state with Notifier
final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

// Async Notifier
final cartNotifierProvider = AsyncNotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
```

### 3.5 — Provider File Structure

```
features/auth/presentation/providers/
├── auth_providers.dart          # All providers for this feature
├── login_notifier.dart          # LoginNotifier class
├── login_state.dart             # LoginState (freezed or manual)
├── register_notifier.dart       # RegisterNotifier class
└── register_state.dart          # RegisterState
```

### 3.6 — State Class Pattern

```dart
// features/auth/presentation/providers/login_state.dart

enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  final UserEntity? user;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    UserEntity? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}
```

### 3.7 — Notifier Pattern

```dart
// features/auth/presentation/providers/login_notifier.dart

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: LoginStatus.loading);

    // Log analytics
    AnalyticsService.logEvent(name: AnalyticsEvents.loginAttempted);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email, password);

    result.fold(
      (error) {
        AnalyticsService.logEvent(
          name: AnalyticsEvents.loginFailed,
          parameters: {'error': error.message},
        );
        state = state.copyWith(
          status: LoginStatus.error,
          errorMessage: error.message,
        );
      },
      (user) {
        AnalyticsService.logLogin(method: 'email');
        state = state.copyWith(status: LoginStatus.success, user: user);
      },
    );
  }
}
```

### 3.8 — Screen Pattern (ConsumerWidget)

```dart
// features/auth/presentation/screens/login_screen.dart

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);

    // Listen for side effects (navigation, snackbar)
    ref.listen(loginNotifierProvider, (prev, next) {
      if (next.status == LoginStatus.success) {
        context.goNamed(RouteNames.home);
      }
      if (next.status == LoginStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: switch (loginState.status) {
          LoginStatus.loading => const Center(child: CircularProgressIndicator()),
          _ => _LoginForm(),
        },
      ),
    );
  }
}
```

### 3.9 — Migration from Existing State Management to Riverpod

**Step-by-step per screen:**

1. Create the Riverpod provider + state + notifier for the screen
2. Move business logic from the old state management into the Notifier
3. Update the screen widget to extend `ConsumerWidget` / `ConsumerStatefulWidget`
4. Replace old state reads with `ref.watch()`
5. Replace old state mutations with `ref.read(provider.notifier).methodName()`
6. Verify the screen works identically
7. Remove old state management code from that screen
8. Run `flutter analyze` — zero errors
9. Commit

**From setState:**
```dart
// BEFORE: setState in StatefulWidget
setState(() { _isLoading = true; });
final result = await _apiCall();
setState(() { _isLoading = false; _data = result; });

// AFTER: Notifier handles everything
ref.read(featureNotifierProvider.notifier).loadData();
```

**From Provider/ChangeNotifier:**
```dart
// BEFORE: context.read<MyNotifier>().doSomething()
// AFTER:  ref.read(myNotifierProvider.notifier).doSomething()

// BEFORE: context.watch<MyNotifier>().someValue
// AFTER:  ref.watch(myNotifierProvider).someValue
```

**From BLoC/Cubit:**
```dart
// BEFORE: context.read<MyCubit>().doSomething()
// AFTER:  ref.read(myNotifierProvider.notifier).doSomething()

// BEFORE: BlocBuilder<MyCubit, MyState>(builder: ...)
// AFTER:  final state = ref.watch(myNotifierProvider); then use in build()

// BEFORE: BlocListener<MyCubit, MyState>(listener: ...)
// AFTER:  ref.listen(myNotifierProvider, (prev, next) { ... });
```

### 3.10 — .autoDispose Rule

```
RULE: Use .autoDispose on ALL providers that are screen-specific.
Do NOT use .autoDispose on global providers (DioClient, Repositories).
```

```dart
// Screen-specific — auto dispose when screen is popped
final productDetailProvider = FutureProvider.autoDispose.family<Product, String>(
  (ref, productId) async { ... },
);

// Global — lives forever
final dioClientProvider = Provider<DioClient>((ref) => DioClient());
```

### 3.11 — Cancel Token with Riverpod

```dart
// For search or disposable requests
final searchProvider = FutureProvider.autoDispose.family<List<Product>, String>(
  (ref, query) async {
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());

    final repo = ref.watch(productRepositoryProvider);
    final result = await repo.search(query, cancelToken: cancelToken);
    return result.fold((e) => throw e, (data) => data);
  },
);
```

### 3.12 — Riverpod Rules (Non-Negotiable)

- **NEVER** use `ref.read` inside `build()` — always `ref.watch` for reactive state.
- **NEVER** call providers from outside Riverpod (e.g., interceptors) — pass dependencies through constructor.
- **ALWAYS** use `ref.listen` for side effects (navigation, snackbar) — not in `build()` logic.
- **ALWAYS** use `.autoDispose` for screen-level providers.
- **ALWAYS** use `CancelToken` with `ref.onDispose` for cancelable API calls.
- **NEVER** put UI code (showDialog, Navigator) inside Notifiers — emit state, let UI react.
- **ALWAYS** co-locate providers with their feature: `features/[name]/presentation/providers/`.
- **NEVER** import a feature's provider from another feature — create shared providers in `core/providers/` if needed.

---

## 4. Design Token Migration (From FLUTTER_DESIGN_SYSTEM.md)

**Phase 3 priority. Do this BEFORE migrating features.**

### 4.1 — Files to Create

| File | Source | Content |
|---|---|---|
| `lib/app/colors.dart` | FLUTTER_DESIGN_SYSTEM.md Part 3 | Full `AppColors` class with brand, semantic, neutral, text, dark mode, functional colors |
| `lib/app/text_styles.dart` | FLUTTER_DESIGN_SYSTEM.md Part 2 | Full `AppTextStyles` class — semantic names only (display, title, body, label, caption) |
| `lib/app/spacing.dart` | FLUTTER_DESIGN_SYSTEM.md Part 4.1 | `AppSpacing` — 4px base grid, screen padding, component-specific, convenience EdgeInsets |
| `lib/app/radii.dart` | FLUTTER_DESIGN_SYSTEM.md Part 4.2 | `AppRadii` — xs through full, plus convenience `BorderRadius` getters |
| `lib/app/shadows.dart` | FLUTTER_DESIGN_SYSTEM.md Part 4.3 | `AppShadows` — sm, md, lg, xl elevation levels |
| `lib/app/durations.dart` | FLUTTER_DESIGN_SYSTEM.md Part 4.4 | `AppDurations` — instant, fast, normal, slow, pageTransition |
| `lib/app/theme.dart` | FLUTTER_DESIGN_SYSTEM.md Part 5 + 7 | `AppTheme.light()` + `AppTheme.dark()` — full ThemeData with all component themes |
| `lib/app/assets.dart` | FLUTTER_BASE_GUIDELINES.md Part 2 | `AppAssets` — all image/icon/font path constants |

### 4.2 — Extraction Process

```
Step 1: Scan all files for hardcoded Color(), TextStyle(), EdgeInsets, BorderRadius values
Step 2: Group into logical sets (map to AppColors, AppTextStyles, AppSpacing, AppRadii)
Step 3: Create the centralized files using the templates from FLUTTER_DESIGN_SYSTEM.md
Step 4: Replace hardcoded values file-by-file (max 5 files per commit)
Step 5: Verify app visually after each batch — no visual regressions
```

### 4.3 — Design Token Rules (From FLUTTER_DESIGN_SYSTEM.md Part 9)

- **NEVER** use inline `TextStyle()` — always `AppTextStyles` or `Theme.of(context).textTheme`.
- **NEVER** use inline `Color(0xFF...)` — always `AppColors` or `Theme.of(context).colorScheme`.
- **NEVER** use magic number padding/margin — always `AppSpacing`.
- **NEVER** use magic number border radius — always `AppRadii`.
- **NEVER** use size-based names like `text14` or `fontSize16` — always semantic names.
- For dark mode: Use `Theme.of(context)` for surface, text, and border colors. Brand colors (`primary`, `success`, `error`) can use `AppColors` directly since they're mode-consistent.
- Minimum touch target: 48x48 dp.
- Text contrast ratio: 4.5:1 body, 3:1 large text (WCAG AA).
- Clamp text scaling ONLY on rigid UI (buttons, nav, tabs) — never on body/scrollable content.

### 4.4 — Text Style Quick Reference

| UI Element | Style | Size |
|---|---|---|
| Hero / splash heading | `displayLarge` | 32sp |
| Onboarding heading | `displayMedium` | 28sp |
| Large section title | `displaySmall` | 24sp |
| App bar title | `titleLarge` | 22sp |
| Screen section header | `titleMedium` | 18sp |
| Card title / dialog title | `titleSmall` | 16sp |
| Primary body / description | `bodyLarge` | 16sp |
| Default list item / paragraph | `bodyMedium` | 14sp |
| Secondary info / metadata | `bodySmall` | 12sp |
| Button text | `labelLarge` | 14sp |
| Tab / chip / tag text | `labelMedium` | 12sp |
| Badge / overline / helper text | `labelSmall` | 11sp |
| Timestamp / hint text | `caption` | 10sp |

---

## 5. Network Layer Migration (From FLUTTER_BASE_GUIDELINES.md Part 4)

### 5.1 — Architecture Flow

```
UI → Riverpod Provider → UseCase → Repository → DataSource → DioClient
```

- **DioClient** — singleton Dio instance with interceptors. Never accessed from UI or providers directly.
- **Remote DataSource** — raw API calls, returns DTOs. One per feature.
- **Repository** — calls DataSource, maps DTO → Entity, returns `Either<AppException, T>`.
- **Notifier/Provider** — calls Repository, emits states. Never touches Dio.

### 5.2 — Network Layer Rules (Non-Negotiable)

- **NEVER** put API URLs as strings in UI or provider files — use `ApiEndpoints`.
- **NEVER** use raw `http` package — always Dio.
- **NEVER** return `dynamic` from repositories — always typed models.
- **NEVER** pre-check connectivity before API calls — let request fail and catch exception.
- **NEVER** retry on 4xx errors — only on 5xx.
- **ALWAYS** pass `CancelToken` for search, pagination, and any screen that can be disposed mid-request.
- **ALWAYS** use `QueuedInterceptor` for auth (not regular `Interceptor`).
- **ALWAYS** use `ExceptionHandler.guardAsync()` in repositories — no raw try/catch.

### 5.3 — Exception Hierarchy

```
sealed class AppException
├── NoInternetException
├── TimeoutException
├── RequestCancelledException
├── ServerException
├── ServiceUnavailableException
├── UnauthorizedException (401)
├── ForbiddenException (403)
├── NotFoundException (404)
├── ValidationException (422, with fieldErrors)
└── TooManyRequestsException (429)
```

### 5.4 — Interceptor Order

```dart
_dio.interceptors.addAll([
  AuthInterceptor(),              // 1st: Injects token + handles refresh
  RetryInterceptor(dio: _dio),    // 2nd: Retries 5xx with backoff
  ErrorInterceptor(),             // 3rd: Maps DioException → AppException
  if (FlavorConfig.isDev) LoggingInterceptor(), // 4th: Dev only
]);
```

### 5.5 — Repository Pattern with Riverpod

```dart
// Provider for repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final remoteDataSource = AuthRemoteDataSource(dioClient);
  return AuthRepositoryImpl(remoteDataSource);
});

// Repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, UserEntity>> login(String email, String password) {
    return ExceptionHandler.guardAsync(() async {
      final dto = await _remoteDataSource.login(email, password);
      return dto.toEntity();
    });
  }
}
```

---

## 6. Navigation Migration (From FLUTTER_BASE_GUIDELINES.md Part 7)

### 6.1 — GoRouter Rules

- Every route MUST have a `name` property — used for analytics screen tracking.
- Never use `Navigator.push()` directly — always `context.goNamed()` or `context.pushNamed()`.
- Route names are `lowercase_snake_case`: `product_detail`, `order_history`.
- Use `ShellRoute` for bottom navigation / persistent layouts.
- Attach `AppAnalyticsObserver` to GoRouter for automatic screen tracking.

### 6.2 — Route Names

```dart
// lib/app/route_names.dart
abstract class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const search = 'search';
  static const profile = 'profile';
  static const settings = 'settings';
  // Add per feature...
}
```

### 6.3 — Navigation calls

```dart
// CORRECT
context.goNamed(RouteNames.home);
context.pushNamed(RouteNames.productDetail, pathParameters: {'id': productId});

// WRONG — never use raw paths
context.go('/home');
context.push('/product/$id');
```

### 6.4 — Migration Steps

1. List every `Navigator.push`, `Navigator.pushNamed`, `Navigator.pop` call in the project
2. Create `app/router.dart` with GoRouter mapping all existing routes
3. Create `app/route_names.dart` with all route name constants
4. Update `MaterialApp` → `MaterialApp.router` in `app.dart`
5. Attach `AppAnalyticsObserver` to router
6. Replace navigation calls ONE screen at a time
7. Test forward + backward navigation after each screen

---

## 7. Firebase Rules (From FLUTTER_BASE_GUIDELINES.md Part 5)

- All analytics events via `AnalyticsService.logEvent()`. Never call `FirebaseAnalytics.instance` directly.
- All crash reports via `CrashlyticsService`. Never call `FirebaseCrashlytics.instance` directly.
- Event names must exist in `AnalyticsEvents` constants — lowercase_snake_case, max 40 chars.
- Screen names are semantic (`home`, `product_detail`) not widget class names.
- Tab screens use `_tab` suffix: `home_tab`, `search_tab`.
- Disable native auto-tracking (AndroidManifest.xml + Info.plist).
- Always set flavor as Crashlytics custom key.
- Log business events from Notifiers, UI interaction events from widgets.

---

## 8. Model Migration

### 8.1 — Rules

- Use `freezed` + `json_serializable` for all data models in `data/models/`.
- Domain entities in `domain/entities/` are plain Dart classes — no annotations, no dependencies.
- Data models map to domain entities via mapper extensions.
- Never use `Map<String, dynamic>` in presentation or domain layers.

### 8.2 — Pattern

```dart
// Domain entity (pure Dart — domain/entities/user.dart)
class UserEntity {
  final String id;
  final String name;
  final String email;
  const UserEntity({required this.id, required this.name, required this.email});
}

// Data model (data/models/user_model.dart)
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
  }) = _UserModel;
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

// Mapper extension
extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(id: id, name: name, email: email);
}
```

---

## 9. Testing Rules (From FLUTTER_TESTING_GUIDELINES.md)

### 9.1 — Test Structure

```
test/                              # Mirrors lib/ structure
├── features/
│   └── auth/
│       ├── data/repositories/
│       │   └── auth_repository_impl_test.dart
│       └── presentation/
│           ├── providers/
│           │   └── login_notifier_test.dart
│           └── screens/
│               └── login_screen_test.dart
├── helpers/
│   ├── pump_app.dart              # pumpApp + pumpProviderApp extensions
│   ├── mocks.dart                 # All mock classes (mocktail)
│   └── test_data.dart             # Shared test fixtures
└── golden/

integration_test/                  # Separate folder — NOT inside test/
├── app_test.dart
└── robots/                        # Robot pattern helpers
```

### 9.2 — Testing Rules

- Every new feature MUST include unit tests for its business logic
- Every new screen MUST include at least one widget test
- Use mocktail for mocking — no mockito, no code generation
- Run `flutter test` before committing — all tests must pass
- Test file naming: `<source_file>_test.dart`
- Minimum 3 test cases per function: happy path, edge case, error case
- Mock all external dependencies
- Follow AAA pattern: Arrange → Act → Assert
- NEVER make real API calls in unit or widget tests
- NEVER put integration tests inside the `test/` folder

### 9.3 — Riverpod-Specific Testing

```dart
// test/helpers/pump_app.dart
extension PumpProviderApp on WidgetTester {
  Future<void> pumpProviderApp(Widget widget, {List<Override> overrides = const []}) {
    return pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: widget),
      ),
    );
  }
}

// Unit testing a Notifier
void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
  });

  tearDown(() => container.dispose());

  test('should emit success when login succeeds', () async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => Right(mockUser));

    final notifier = container.read(loginNotifierProvider.notifier);
    await notifier.login('test@test.com', 'pass123');

    final state = container.read(loginNotifierProvider);
    expect(state.status, LoginStatus.success);
  });
}
```

### 9.4 — Coverage Targets

- Unit tests: 80%+ on business logic (Notifiers, Repositories, UseCases)
- Widget tests: 60%+ on critical screens
- Integration tests: Top 3–5 user journeys
- Overall: 70%+

---

## 10. Coding Rules (From FLUTTER_BASE_GUIDELINES.md Part 8)

- One widget per file. No exceptions.
- File names: `lowercase_snake_case.dart` — Class names: `PascalCase`
- Never use `print()` — use `debugPrint()` or logging interceptor.
- Never commit commented-out code.
- UI layer NEVER imports from `data/` — only from `domain/`.
- All text styles from `AppTextStyles` or `Theme.of(context).textTheme`.
- All colors from `AppColors`. No inline `Color(0xFF...)`.
- All spacing from `AppSpacing`. No magic numbers.
- All analytics via `AnalyticsService`. All crashes via `CrashlyticsService`.
- All endpoints in `ApiEndpoints`. No hardcoded URL strings.
- All repository methods use `ExceptionHandler.guardAsync()`.

### Import Ordering

```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetical)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Project imports (alphabetical)
import 'package:my_app/app/colors.dart';
```

---

## 11. Recommended Packages

| Category | Package | Purpose |
|---|---|---|
| HTTP Client | `dio` | Network calls with interceptors |
| Router | `go_router` | Declarative navigation |
| State Management | `flutter_riverpod` | Reactive state management + DI |
| Functional | `dartz` or `fpdart` | Either type for error handling |
| JSON | `freezed` + `json_serializable` + `build_runner` | Code generation for models |
| Firebase | `firebase_core` + `firebase_analytics` + `firebase_crashlytics` | Firebase services |
| Secure Storage | `flutter_secure_storage` | Token storage |
| Image Loading | `cached_network_image` | Cached images |
| Testing | `mocktail` | Mocking without code generation |

**Do NOT use without approval:** `http`, `shared_preferences` for tokens, `mockito`, `get_it`, `provider`, `flutter_bloc`

---

## 12. What NOT To Do During Migration

| Don't | Do Instead |
|---|---|
| Rewrite everything at once | One feature at a time |
| Add new features while migrating | Finish migration first |
| Delete old code immediately | Keep until new code is verified |
| Change business logic during migration | Only move and restructure |
| Modify flavors/build config | Leave untouched |
| Use `dynamic` in domain/presentation | Typed models everywhere |
| Use `ref.read` in `build()` | Always `ref.watch` for reactive UI |
| Put navigation/dialogs in Notifiers | Emit state, UI reacts via `ref.listen` |
| Use `get_it` alongside Riverpod | Riverpod handles DI |
| Hardcode styles after Phase 3 | Always use design tokens |

---

## 13. Commit Message Format

```
type(scope): description

Examples:
  refactor(theme): extract hardcoded colors to AppColors
  refactor(auth): migrate login screen to Riverpod
  refactor(auth): create LoginNotifier and LoginState
  refactor(navigation): replace Navigator.push with GoRouter
  refactor(network): set up DioClient with interceptors
  chore(structure): create feature folder structure
  chore(deps): add flutter_riverpod and go_router
  fix(auth): fix login flow after provider migration
  test(auth): add unit tests for login notifier
```

---

## 14. Migration Checklist Per Feature

```
Feature: _______________

STRUCTURE
□ Create feature folder (data/ domain/ presentation/)
□ Create presentation/providers/ folder

DOMAIN LAYER
□ Create/move domain entities
□ Create repository interface

DATA LAYER
□ Create/move data models (freezed)
□ Create mapper extensions
□ Create remote data source
□ Create repository implementation with ExceptionHandler.guardAsync()

PRESENTATION — RIVERPOD
□ Create state class
□ Create Notifier class
□ Create providers (use .autoDispose for screen-level)
□ Migrate screens to ConsumerWidget
□ Replace state reads → ref.watch()
□ Replace state mutations → ref.read(provider.notifier).method()
□ Add ref.listen() for side effects
□ Add CancelToken with ref.onDispose for cancelable requests

DESIGN TOKENS
□ Colors → AppColors
□ Text styles → AppTextStyles
□ Spacing → AppSpacing
□ Radii → AppRadii

NAVIGATION
□ Replace Navigator calls → GoRouter

FIREBASE
□ Analytics events in Notifier (business events)
□ Analytics in widgets (UI events)
□ Crashlytics in error paths

VERIFICATION
□ All screens work
□ Navigation works
□ API calls work (loading + success + error)
□ Dark mode renders correctly
□ flutter analyze — zero errors
□ Committed with proper message
```

---

## 15. Claude Code Instructions

1. **Always show the plan before executing.** Wait for approval.
2. **Work in small batches.** Max 5 files per task.
3. **Verify after each batch.** Run `flutter analyze`.
4. **Never delete without listing first.** Get approval.
5. **Preserve git history.** Use `git mv`.
6. **When in doubt, ask.** Don't assume intent of unusual patterns.
7. **Log decisions.** Document judgment calls in `MIGRATION_LOG.md`.
8. **Follow the guideline templates exactly.** Don't invent new patterns.
9. **Riverpod only.** No `get_it`, `provider`, or `flutter_bloc`.

---

## 16. Emergency Rollback

```bash
git revert HEAD           # Single commit
git revert HEAD~3..HEAD   # Multiple commits
```

Every step = separate, buildable commit. Never batch into one giant commit.

---

*Based on: FLUTTER_BASE_GUIDELINES.md v3.0, FLUTTER_DESIGN_SYSTEM.md v1.0, FLUTTER_TESTING_GUIDELINES.md v1.0*
*Architecture: Riverpod (flutter_riverpod)*
*Last updated: April 2026*
