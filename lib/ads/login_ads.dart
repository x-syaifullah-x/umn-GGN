import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/anchored_adaptive_ads.dart';

// import 'package:global_net/gen/assets.gen.dart';
// import 'dart:html' as html;
// import 'dart:ui' as ui;

Widget webAds(double width) {
  // const String adViewType = 'adsense';
  // // ignore: undefined_prefixed_name
  // ui.platformViewRegistry.registerViewFactory(adViewType, (int viewID) {
  //   return html.IFrameElement()
  //     ..src = "assets/${Assets.html.loginAds}"
  //     ..style.border = 'none';
  // });
  // return SizedBox(
  //   width: width,
  //   height: 80,
  //   child: const HtmlElementView(
  //     viewType: adViewType,
  //   ),
  // );
  return Container();
}

class LoginAds extends StatelessWidget {
  const LoginAds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return webAds(320);
    }
    return const AnchoredAd();
  }
}
