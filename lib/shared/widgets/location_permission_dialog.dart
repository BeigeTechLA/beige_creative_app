import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../utility/location_exception.dart';

/// Adaptive dialog explaining why location is needed and routing the user
/// to the correct system surface (device location settings vs app settings).
///
/// Returns `true` if user tapped the primary (settings / retry) action.
Future<bool> showLocationPermissionDialog(
  BuildContext context,
  LocationStatus status,
) async {
  if (status == LocationStatus.unknown) return false;

  final copy = _copyFor(status);
  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog.adaptive(
      title: Text(copy.title),
      content: Text(copy.body),
      actions: [
        _adaptiveAction(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(copy.secondary),
        ),
        _adaptiveAction(
          onPressed: () async {
            switch (status) {
              case LocationStatus.serviceDisabled:
                await Geolocator.openLocationSettings();
              case LocationStatus.permanentlyDenied:
                await Geolocator.openAppSettings();
              case LocationStatus.denied:
              case LocationStatus.unknown:
                break;
            }
            if (ctx.mounted) Navigator.of(ctx).pop(true);
          },
          child: Text(copy.primary),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _Copy {
  final String title;
  final String body;
  final String primary;
  final String secondary;
  const _Copy(this.title, this.body, this.primary, this.secondary);
}

_Copy _copyFor(LocationStatus s) => switch (s) {
      LocationStatus.serviceDisabled => const _Copy(
          'Location Off',
          'Turn on device location to autofill your address.',
          'Open Settings',
          'Not Now',
        ),
      LocationStatus.denied => const _Copy(
          'Location Needed',
          'BEIGE needs location to autofill your address.',
          'Allow',
          'Not Now',
        ),
      LocationStatus.permanentlyDenied => const _Copy(
          'Permission Blocked',
          'Enable location in app settings to autofill your address.',
          'Open Settings',
          'Cancel',
        ),
      LocationStatus.unknown => const _Copy('', '', '', ''),
    };

Widget _adaptiveAction({
  required VoidCallback onPressed,
  required Widget child,
}) {
  if (Platform.isIOS) {
    return CupertinoDialogAction(onPressed: onPressed, child: child);
  }
  return TextButton(onPressed: onPressed, child: child);
}
