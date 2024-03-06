import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/applovin_ad_unit_id.dart';
import 'package:nb_utils/nb_utils.dart';

class AdOne extends StatefulWidget {
  const AdOne({Key? key}) : super(key: key);

  @override
  State<AdOne> createState() => _AdOneState();
}

class _AdOneState extends State<AdOne>
    with AutomaticKeepAliveClientMixin<AdOne> {
  final _nativeAdViewController = MaxNativeAdViewController();

  bool _isLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.all(8.0),
      height: _isLoad ? 165 : 0.5,
      width: double.infinity,
      child: MaxNativeAdView(
        adUnitId: '8ed2644f59ef2ee2',
        controller: _nativeAdViewController,
        listener: NativeAdListener(
          onAdLoadedCallback: (ad) {
            // if (!_isLoad) {
            //   setState(() {
            //     _isLoad = true;
            //   });
            // }
            setState(() {
              _isLoad = true;
              Future.delayed(const Duration(seconds: 15), () {
                _nativeAdViewController.loadAd();
              });
            });
          },
          onAdLoadFailedCallback: (adUnitId, error) {
              _nativeAdViewController.loadAd();
          },
          onAdClickedCallback: (ad) {},
          onAdRevenuePaidCallback: (ad) {},
        ),
        child: Container(
          color: const Color(0xffefefef),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    child: const MaxNativeAdIconView(
                      width: 48,
                      height: 48,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        MaxNativeAdTitleView(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                        MaxNativeAdAdvertiserView(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                        MaxNativeAdStarRatingView(
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                  const MaxNativeAdOptionsView(
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Flexible(
                    child: MaxNativeAdBodyView(
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Expanded(
              //   child: AspectRatio(
              //     aspectRatio: _mediaViewAspectRatio ?? 0,
              //     child: const MaxNativeAdMediaView(),
              //   ),
              // ),
              const SizedBox(
                width: double.infinity,
                child: MaxNativeAdCallToActionView(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                      Color(0xff2d545e),
                    ),
                    textStyle: MaterialStatePropertyAll<TextStyle>(
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdTwo extends StatefulWidget {
  const AdTwo({Key? key}) : super(key: key);

  @override
  State<AdTwo> createState() => _AdTwoState();
}

class _AdTwoState extends State<AdTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: MaxAdView(
        adaptiveBannerWidth: double.infinity,
        adUnitId: AppLovin.adUnitId,
        adFormat: AdFormat.banner,
        listener: AdViewAdListener(
          onAdLoadedCallback: (ad) {
            log(ad.toString());
          },
          onAdLoadFailedCallback: (adUnitId, error) {},
          onAdClickedCallback: (ad) {},
          onAdExpandedCallback: (ad) {},
          onAdCollapsedCallback: (ad) {},
        ),
      ),
    );
  }
}
