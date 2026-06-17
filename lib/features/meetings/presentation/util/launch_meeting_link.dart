import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a meeting link in the platform's external browser / native app
/// (Meet / Zoom / Teams resolve via OS scheme handler).
///
/// Falls back to an inline snackbar on parse failure, `canLaunchUrl` false,
/// or any `PlatformException` thrown by the launcher.
Future<void> launchMeetingLink(
  BuildContext context,
  String link,
) async {
  final messenger = ScaffoldMessenger.of(context);
  if (link.trim().isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No meeting link available')),
    );
    return;
  }

  final uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Invalid meeting link')),
    );
    return;
  }

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open meeting link')),
      );
    }
  } catch (_) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open meeting link')),
    );
  }
}
