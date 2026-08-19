import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public BEIGE legal pages, opened in the platform's external browser.
const String termsAndConditionsUrl = 'https://beige.app/terms-and-conditions';
const String privacyPolicyUrl = 'https://beige.app/privacy-policy';

/// Opens [url] in the external browser.
///
/// Falls back to an inline snackbar on parse failure, `launchUrl`
/// returning false, or any `PlatformException` thrown by the launcher.
Future<void> launchPolicyLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Invalid link')),
    );
    return;
  }

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open link')),
    );
  }
}
