import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaBox extends StatefulWidget {
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
  State<RecaptchaBox> createState() => _RecaptchaBoxState();
}

class _RecaptchaBoxState extends State<RecaptchaBox> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

// class RecaptchaBox extends StatefulWidget {
//   final String siteKey;
//   final void Function(String token) onVerified;
//   final void Function(String error)? onError;

//   const RecaptchaBox({
//     Key? key,
//     required this.siteKey,
//     required this.onVerified,
//     this.onError,
//   }) : super(key: key);

//   @override
//   State<RecaptchaBox> createState() => _RecaptchaBoxState();
// }

// class _RecaptchaBoxState extends State<RecaptchaBox> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..addJavaScriptChannel(
//         'RecaptchaFlutter',
//         onMessageReceived: (message) {
//           widget.onVerified(message.message);
//         },
//       )
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onWebResourceError: (error) {
//             widget.onError?.call(error.description);
//           },
//         ),
//       )
//       ..loadHtmlString(_getHtml());
//   }

//   String _getHtml() {
//     return '''
// <!DOCTYPE html>
// <html>
// <head>
//   <meta charset="UTF-8">
//   <title>reCAPTCHA</title>
//   <script src="https://www.google.com/recaptcha/api.js" async defer></script>
// </head>
// <body>
//   <div class="g-recaptcha"
//        data-sitekey="${widget.siteKey}"
//        data-callback="onSuccess">
//   </div>
//   <script>
//     function onSuccess(token) {
//       RecaptchaFlutter.postMessage(token);
//     }
//   </script>
// </body>
// </html>
// ''';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 304,
//       height: 78,
//       child: WebViewWidget(controller: _controller),
//     );
//   }
// }
