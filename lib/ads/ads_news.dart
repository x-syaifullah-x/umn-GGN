import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/ad_unit_id.dart';
import 'package:global_net/ads/inline_adaptive_ads.dart';
import 'package:global_net/gen/assets.gen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_web.dart';

class AdsNews extends StatefulWidget {
  const AdsNews({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _State();
}

class _State extends State<AdsNews> {
  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    // if (kIsWeb) {
    //   return webAds(
    //     width: widget.space,
    //     height: 250,
    //     src: 'assets/${Assets.html.adsense}',
    //     adViewType: 'adsense',
    //   );
    // }
    final bannerAd = _bannerAd;
    if (bannerAd != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: bannerAd.size.height.toDouble(),
            width: bannerAd.size.width.toDouble(),
            child: AdWidget(ad: bannerAd),
          )
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * .75,
          margin: const EdgeInsets.only(bottom: 20),
          child: const Text(
            'GLOBAL NET NEWS FEED',
            style: TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (kIsWeb) return;
    await _bannerAd?.dispose();

    // final width = (widget.space - 3).toInt();
    // final adSize = AdSize(width: 320, height: 50);
    final a = MediaQuery.of(context).size;
    final adSize = AdSize(height: 50, width: a.width.toInt());
    // final a = MediaQuery.of(context).size;
    // final adSize = AdSize(width: 100, height: 50);
    await BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint(error.message);
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }
}
