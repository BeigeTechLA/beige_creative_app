import 'package:flutter/material.dart';

import '../../app/colors.dart';

/// Shared `Scaffold` wrapper.
///
/// Centralises the defaults that every feature screen repeats:
/// `backgroundColor: AppColors.background`, a `SafeArea` around `body`
/// (`top: true, bottom: false, left: true, right: true` by default), and
/// `resizeToAvoidBottomInset: true`.
///
/// SafeArea bottom defaults to `false` because `bottomNavigationBar` and
/// the home-indicator are already inset by Flutter. Decorative screens
/// that intentionally bleed under the status bar set `safeTop: false` and
/// handle their own top offset with `MediaQuery.padding.top`.
///
/// Do not use inside `AppShell` itself — the shell is the route host.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Color? backgroundColor;

  final bool safeTop;
  final bool safeBottom;
  final bool safeLeft;
  final bool safeRight;

  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.backgroundColor,
    this.safeTop = true,
    this.safeBottom = false,
    this.safeLeft = true,
    this.safeRight = true,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final wantsSafeArea = safeTop || safeBottom || safeLeft || safeRight;
    final content = wantsSafeArea
        ? SafeArea(
            top: safeTop,
            bottom: safeBottom,
            left: safeLeft,
            right: safeRight,
            child: body,
          )
        : body;
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
