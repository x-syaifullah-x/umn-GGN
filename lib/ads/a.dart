import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ads extends StatefulWidget {
  const Ads({Key? key}) : super(key: key);

  @override
  AdsState createState() => AdsState();
}

class AdsState extends State<Ads> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  late Orientation _currentOrientation;

  @override
  Widget build(BuildContext context) => _getAdWidget(context);

  Widget _getAdWidget(BuildContext context) {
    if (kIsWeb) return Container();
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isA = _currentOrientation == orientation &&
            _anchoredAdaptiveAd != null &&
            _isLoaded;
        if (isA) {
          return SingleChildScrollView(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            ),
          );
          // return ;
        }
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd(context);
        }
        return Container();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd(context);
  }

  Future<void> _loadAd(BuildContext context) async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });

    if (!mounted) return;
    final size = AdSize(
      width: (MediaQuery.of(context).size.width * 0.25).toInt(),
      height: MediaQuery.of(context).size.height.toInt(),
    );

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6893234291134320/6968645751'
          : 'ca-app-pub-5132780917564352/9977646966',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );

    return _anchoredAdaptiveAd!.load();
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}
