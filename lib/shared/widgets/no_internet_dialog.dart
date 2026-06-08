import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/connectivity/connectivity_providers.dart';
import '../../core/connectivity/connectivity_status.dart';

/// Platform-adaptive offline alert.
///
/// Cupertino on iOS, Material on Android. Fully blocking — barrier tap and
/// system back are both no-ops. Only exits are:
///
/// 1. `Retry` succeeds — reachability probe reports `online`, dialog flips
///    `canPop` and pops itself.
/// 2. Background `ConnectivityListener` sees stream flip to `online` and
///    invokes the dismiss callback.
Future<void> showNoInternetDialog(BuildContext context) {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _NoInternetDialog(),
  );
}

class _NoInternetDialog extends ConsumerStatefulWidget {
  const _NoInternetDialog();

  @override
  ConsumerState<_NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends ConsumerState<_NoInternetDialog> {
  bool _checking = false;
  bool _allowPop = false;

  /// Flip `canPop` then pop on the next frame so the `PopScope` rebuild
  /// commits before `Navigator.pop()` is dispatched (otherwise the pop is
  /// intercepted by the stale `canPop: false` state).
  void _dismiss() {
    if (_allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _onRetry() async {
    if (_checking) return;
    setState(() => _checking = true);
    final status = await ref.read(connectivityServiceProvider).current();
    if (!mounted) return;
    if (status == ConnectivityStatus.online) {
      _dismiss();
      return;
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    // Auto-dismiss when background stream flips online (e.g. connectivity
    // returns without the user tapping Retry).
    ref.listen<ConnectivityStatus>(connectivityStatusProvider,
        (prev, next) {
      if (next == ConnectivityStatus.online && mounted && !_allowPop) {
        _dismiss();
      }
    });
    return PopScope(
      canPop: _allowPop,
      child: AlertDialog.adaptive(
        title: const Text('No Internet'),
        content: const Text(
          'You are offline. Please check your connection and try again.',
        ),
        actions: [
          _adaptiveAction(
            onPressed: _checking ? null : _onRetry,
            child: Text(_checking ? 'Checking…' : 'Retry'),
          ),
        ],
      ),
    );
  }
}

Widget _adaptiveAction({
  required VoidCallback? onPressed,
  required Widget child,
}) {
  if (Platform.isIOS) {
    return CupertinoDialogAction(onPressed: onPressed, child: child);
  }
  return TextButton(onPressed: onPressed, child: child);
}
