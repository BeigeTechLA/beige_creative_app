import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Boolean derived from the live `SessionStore` token presence.
///
/// Single source of truth for "is the user logged in?" — the router redirect
/// reads it; login/logout flows update it.
///
/// Default value `false`. `startApp` overrides with the synchronous
/// `PrefsService.isLoggedIn` (which reads the secure-storage cached token).
/// Auth flows (login success, `clearSession` from interceptor on 401) flip
/// the value via `ref.read(authStateProvider.notifier).state = …`.
final authStateProvider = StateProvider<bool>((ref) => false);
