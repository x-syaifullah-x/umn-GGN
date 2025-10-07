import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void tryOpenWpaWithFallback(String protocol, String fallbackUrl) {
  Uri uri = Uri.parse(fallbackUrl);
  launchUrl(
    uri,
    mode: LaunchMode.platformDefault,
    webOnlyWindowName: '_self',
  );
}

class RecaptchaBox extends StatelessWidget {
  final String siteKey;
  final void Function(String token) onVerified;
  final void Function(String error)? onError;

  const RecaptchaBox({
    Key? key,
    required this.siteKey,
    required this.onVerified,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('reCAPTCHA tidak tersedia di platform ini.');
  }
}
