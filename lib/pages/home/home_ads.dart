import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/ad_unit_id.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeAds extends StatefulWidget {
  const HomeAds({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<HomeAds> {
  @override
  void initState() {
    super.initState();
    final tabController = widget.tabController;
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabController = widget.tabController;
    final isShow = ![1, 2].contains(tabController.index);
    return Offstage(
      offstage: isShow,
      child: const _AdsWidget(),
    );
  }
}

class _AdsWidget extends StatefulWidget {
  const _AdsWidget({Key? key}) : super(key: key);

  @override
  State createState() => _AdsWidgetState();
}

class _AdsWidgetState extends State<_AdsWidget> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    if ((isAndroid && isLandscape) || kIsWeb) return Container();
    if (_anchoredAdaptiveAd != null && _isLoaded) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: _anchoredAdaptiveAd!.size.width.toDouble(),
        height: _anchoredAdaptiveAd!.size.height.toDouble(),
        child: AdWidget(ad: _anchoredAdaptiveAd!),
      );
    }
    _loadAd(context);
    return Container();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd(context);
  }

  Future<void> _loadAd(BuildContext context) async {
    // await _anchoredAdaptiveAd?.dispose();
    // setState(() {
    //   _anchoredAdaptiveAd = null;
    //   _isLoaded = false;
    // });

    if (!mounted) return;
    var truncate = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      truncate,
    );

    if (size == null) {
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: adUnitId,
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

    return _anchoredAdaptiveAd?.load();
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }
}
