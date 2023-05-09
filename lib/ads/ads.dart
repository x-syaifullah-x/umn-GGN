// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:global_net/ads/ad_unit_id.dart';
// import 'package:global_net/gen/assets.gen.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'ads_web.dart';

// class Ads extends StatefulWidget {
//   final double space;

//   const Ads({
//     Key? key,
//     required this.space,
//   }) : super(key: key);

//   @override
//   State createState() => _State();
// }

// class _State extends State<Ads> {
//   BannerAd? _bannerAd;

//   @override
//   Widget build(BuildContext context) {
//     if (kIsWeb) {
//       return webAds(
//         width: widget.space,
//         height: 250,
//         src: 'assets/${Assets.html.adsense}',
//         adViewType: 'adsense',
//       );
//     }

//     final bannerAd = _bannerAd;
//     if (bannerAd != null) {
//       final size = bannerAd.size;
//       return Container(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         width: size.width.toDouble(),
//         height: size.height.toDouble(),
//         child: AdWidget(ad: bannerAd),
//       );
//     }
//     return Container();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadAd();
//   }

//   Future<void> _loadAd() async {
//     if (kIsWeb) return;
//     await _bannerAd?.dispose();

//     final width = (widget.space - 3).toInt();
//     final adSize = AdSize(
//       width: width,
//       height: (width + (width / 1.5)).toInt(),
//     );
//     await BannerAd(
//       adUnitId: adUnitId,
//       size: adSize,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) {
//           setState(() {
//             _bannerAd = ad as BannerAd;
//           });
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           debugPrint(error.message);
//           ad.dispose();
//         },
//       ),
//     ).load();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _bannerAd?.dispose();
//   }
// }
