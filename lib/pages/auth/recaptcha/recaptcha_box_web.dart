// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'dart:async';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void tryOpenWpaWithFallback(String protocol, String fallbackUrl) {
  js.context.callMethod('openOrInstall', [protocol, fallbackUrl]);
}

Future<void> launchX(String url) async {
  html.window.open(url, '_blank');
}

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
  final String _viewType = 'recaptcha-${DateTime.now().millisecondsSinceEpoch}';
  int _retryCount = 0;
  static const int _maxRetries = 50;

  @override
  void initState() {
    super.initState();
    _setupWebRecaptcha();
  }

  void _setupWebRecaptcha() {
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = html.DivElement()
        ..id = 'recaptcha-container-$viewId'
        ..style.width = '304px'
        ..style.height = '78px'
        ..style.border = '1px solid #ddd'
        ..style.borderRadius = '4px'
        ..style.backgroundColor = '#fff';

      final recaptchaDiv = html.DivElement()
        ..id = 'recaptcha-div-$viewId'
        ..className = 'g-recaptcha';

      container.append(recaptchaDiv);

      final existingScript = html.document.getElementById('recaptcha-script');
      existingScript?.remove();

      final script = html.ScriptElement()
        ..id = 'recaptcha-script'
        ..src =
            'https://www.google.com/recaptcha/api.js?onload=recaptchaOnLoad&render=explicit'
        ..async = true
        ..defer = true;
      html.document.head!.append(script);

      _injectOnLoadHandler(viewId);

      Timer(const Duration(seconds: 1), () {
        if (_retryCount < _maxRetries) {
          _pollAndRender(viewId);
        }
      });

      html.window.addEventListener('recaptchaTokenEvent', (event) {
        final customEvent = event as html.CustomEvent;
        final token = customEvent.detail as String?;
        if (token != null && token.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onVerified(token);
          });
        }
      });

      return container;
    });
  }

  void _injectOnLoadHandler(int viewId) {
    final script = html.ScriptElement()
      ..innerHtml = '''
        window.recaptchaOnLoad = function() {
          renderRecaptcha_$viewId();
        };
        
        function renderRecaptcha_$viewId() {
          var divId = 'recaptcha-div-$viewId';
          var siteKey = '${widget.siteKey}';
          
          if (typeof grecaptcha === 'undefined') return;

          grecaptcha.render(divId, {
            'sitekey': siteKey,
            'callback': function(token) {
              window.dispatchEvent(new CustomEvent('recaptchaTokenEvent', { detail: token }));
            },
            'size': 'normal',
            'theme': 'light'
          });
        }
      ''';
    html.document.body!.append(script);
  }

  void _pollAndRender(int viewId) {
    _retryCount++;
    final script = html.ScriptElement()
      ..innerHtml = '''
        (function() {
          if (typeof grecaptcha !== 'undefined') {
            renderRecaptcha_$viewId();
          } else if ($_retryCount < $_maxRetries) {
            setTimeout(arguments.callee, 100);
          }
        })();
      ''';
    html.document.body!.append(script);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: 304,
      height: 78,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
