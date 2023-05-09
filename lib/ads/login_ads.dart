import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/anchored_adaptive_ads.dart';
import 'package:global_net/gen/assets.gen.dart';
import 'package:applovin_max/applovin_max.dart';

import 'ads_web.dart';
import 'applovin_ad_unit_id.dart';

class LoginAds extends StatelessWidget {
  const LoginAds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return Container();

    return MaxAdView(
      adUnitId: AppLovin.adUnitId,
      adFormat: AdFormat.banner,
      listener: AdViewAdListener(
        onAdLoadedCallback: (ad) {},
        onAdLoadFailedCallback: (adUnitId, error) {},
        onAdClickedCallback: (ad) {},
        onAdExpandedCallback: (ad) {},
        onAdCollapsedCallback: (ad) {},
      ),
    );

    // if (kIsWeb) {
    //   return webAds(
    //     width: 320,
    //     height: 80,
    //     src: 'assets/${Assets.html.loginAds}',
    //     adViewType: 'adsense',
    //   );
    // }
    // return const AnchoredAd();
  }
}
