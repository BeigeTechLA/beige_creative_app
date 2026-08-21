import 'package:flutter/widgets.dart';

import 'route_restoration_service.dart';

/// Stamps `lastActiveTs` whenever the app leaves the foreground so the splash
/// restore decision can compare against the most recent pause time rather
/// than the last route change.
class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver(this._service);

  final RouteRestorationService _service;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _service.stampLastActive();
      case AppLifecycleState.resumed:
        break;
    }
  }
}
