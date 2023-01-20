import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:global_net/ads/adunit_id.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'package:global_net/gen/assets.gen.dart';
// import 'dart:html' as html;
// import 'dart:ui' as ui;

Widget webAds(double width) {
  // const String adViewType = 'adsense';
  // // ignore: undefined_prefixed_name
  // ui.platformViewRegistry.registerViewFactory(adViewType, (int viewID) {
  //   return html.IFrameElement()
  //     // ..width = "${width}px"
  //     // ..height = '200'
  //     ..src = "assets/${Assets.html.adsense}"
  //     ..style.border = 'none';
  // });
  // return SizedBox(
  //   width: width,
  //   height: 250,
  //   child: const HtmlElementView(
  //     viewType: adViewType,
  //   ),
  // );
  return Container();
}

class Ads extends StatefulWidget {
  final double space;

  const Ads({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State createState() => _State();
}

class _State extends State<Ads> {
  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return webAds(widget.space);
    final bannerAd = _bannerAd;
    if (bannerAd != null) {
      final size = bannerAd.size;
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: size.width.toDouble(),
        height: size.height.toDouble(),
        child: AdWidget(ad: bannerAd),
      );
    }
    return Container();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (kIsWeb) return;
    await _bannerAd?.dispose();

    final width = (widget.space - 3).toInt();
    final adSize = AdSize(
      width: width,
      height: (width + (width / 1.5)).toInt(),
    );
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
