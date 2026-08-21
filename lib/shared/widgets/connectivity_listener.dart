import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigator_key.dart';
import '../../core/connectivity/connectivity_providers.dart';
import '../../core/connectivity/connectivity_status.dart';
import 'no_internet_dialog.dart';

/// Sits above the routed `Navigator`. Watches `connectivityStatusProvider`
/// and:
///
/// - Shows `showNoInternetDialog` on `online → offline`.
/// - Dialog self-dismisses on `offline → online` via its own `ref.listen`
///   (it owns its `PopScope.canPop` flag, so popping from outside is blocked).
/// - Ignores `unknown` (first-frame state, prevents cold-start false-flag).
///
/// Single-shot guard (`_isDialogShowing`) prevents stacking if multiple
/// transitions fire before the previous future resolves.
class ConnectivityListener extends ConsumerStatefulWidget {
  const ConnectivityListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ConnectivityListener> createState() =>
      _ConnectivityListenerState();
}

class _ConnectivityListenerState extends ConsumerState<ConnectivityListener> {
  bool _isDialogShowing = false;

  void _handle(ConnectivityStatus? previous, ConnectivityStatus next) {
    if (next == ConnectivityStatus.unknown) return;

    if (next == ConnectivityStatus.offline && !_isDialogShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx == null || _isDialogShowing) return;
        _isDialogShowing = true;
        showNoInternetDialog(ctx).whenComplete(() {
          _isDialogShowing = false;
        });
      });
      return;
    }

    // Dialog handles its own dismissal on offline → online (it owns
    // PopScope.canPop, so an outside pop would be blocked anyway).
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectivityStatus>(connectivityStatusProvider, _handle);
    return widget.child;
  }
}
