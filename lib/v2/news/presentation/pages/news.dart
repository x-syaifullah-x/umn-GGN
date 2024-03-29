import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/ads_news.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../ads/applovin_ad_unit_id.dart';
import '../../../../share_preference/preferences_key.dart';
import '../../data/bing_news/data/bing_news_repository.dart';
import '../../data/bing_news/data/response/bing_news_response.dart';
import '../widgets/item.dart';

class News extends StatefulWidget {
  const News({
    Key? key,
  }) : super(key: key);

  static const route = '/news';

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final PagingController<int, BingNewsResponse> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((page) {
      _fetchPage(page: page);
    });
  }

  Future<void> _fetchPage({
    required int page,
    int pageSize = 20,
  }) async {
    String country = 'en-US';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(SharedPreferencesKey.languageCode);
    if (code == 'zh') {
      country = 'zh-CN';
    }
    try {
      final results = await BingNewsRepository.instance
          .search(page: page, pageSize: pageSize, mkt: country);

      final isLastPage = results.length < pageSize;
      final items = results.toSet().toList();
      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        final nextPage = page + results.length;
        _pagingController.appendPage(items, nextPage);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final expandedHeight = size.height * (isLandscape ? .45 : .3);
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _sliverAppBar(expandedHeight, size.width),
            ];
          },
          body: _body(),
        ),
      ),
    );
  }

  Widget _sliverAppBar(double expandedHeight, double width) {
    return SliverAppBar(
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      expandedHeight: expandedHeight,
      // floating: true,
      pinned: true,
      // snap: true,
      elevation: 5,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isCollapse =
              constraints.biggest.height.toInt() == kToolbarHeight;
          return Container(
              color: isCollapse
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).backgroundColor,
              child: isCollapse
                  ? const FlexibleSpaceBar(title: Text('GLOBAL NET NEWS FEED'))
                  : Container(
                      height: 300,
                      decoration: BoxDecoration(
                        image: isCollapse
                            ? null
                            : DecorationImage(
                                image: NetworkImage(
                                  'https://picsum.photos/${width.toInt()}/${expandedHeight.toInt()}?random=1',
                                ),
                                fit: BoxFit.fill,
                              ),
                      ),
                      // child: const AdsNews(),
                      // child: MaxAdView(
                      //   adUnitId: AppLovin.adUnitId,
                      //   adFormat: AdFormat.banner,
                      //   listener: AdViewAdListener(
                      //     onAdLoadedCallback: (ad) {},
                      //     onAdLoadFailedCallback: (adUnitId, error) {},
                      //     onAdClickedCallback: (ad) {},
                      //     onAdExpandedCallback: (ad) {},
                      //     onAdCollapsedCallback: (ad) {},
                      //   ),
                      // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!kIsWeb)
                            MaxAdView(
                              adUnitId: AppLovin.adUnitId,
                              adFormat: AdFormat.banner,
                              listener: AdViewAdListener(
                                onAdLoadedCallback: (ad) {},
                                onAdLoadFailedCallback: (adUnitId, error) {},
                                onAdClickedCallback: (ad) {},
                                onAdExpandedCallback: (ad) {},
                                onAdCollapsedCallback: (ad) {},
                              ),
                            ),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                      // child: Column(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //   AdsNews(space: 0),
                      // ]),
                    )
              // : FlexibleSpaceBar(
              //     title: AdsNews(),
              //     background: Container(
              //       decoration: BoxDecoration(
              //         image: isCollapse
              //             ? null
              //             : DecorationImage(
              //                 image: NetworkImage(
              //                   'https://picsum.photos/${width.toInt()}/${expandedHeight.toInt()}?random=1',
              //                 ),
              //                 fit: BoxFit.fill,
              //               ),
              //       ),
              //       // child: Column(
              //       //   mainAxisAlignment: MainAxisAlignment.end,
              //       //   children: [
              //       //   AdsNews(space: 0),
              //       // ]),
              //     ),
              //   )
              // : CarouselSlider(
              //     options: CarouselOptions(
              //       height: double.infinity,
              //       viewportFraction: 1,
              //       initialPage: 0,
              //       enableInfiniteScroll: true,
              //       reverse: false,
              //       autoPlay: true,
              //       autoPlayInterval: const Duration(seconds: 5),
              //       autoPlayAnimationDuration:
              //           const Duration(milliseconds: 800),
              //       autoPlayCurve: Curves.fastOutSlowIn,
              //       enlargeCenterPage: true,
              //       enlargeFactor: 0.3,
              //       // onPageChanged: callbackFunction,
              //       scrollDirection: Axis.horizontal,
              //     ),
              //     items: [
              //       'EXAMPLE BANNER ONE',
              //       'EXAMPLE BANNER TWO',
              //       'EXAMPLE BANNER THREE'
              //     ]
              //         .map((e) => FlexibleSpaceBar(
              //               title: AdsNews(space: 0),
              //               background: Container(
              //                 decoration: BoxDecoration(
              //                   image: isCollapse
              //                       ? null
              //                       : DecorationImage(
              //                           image: NetworkImage(
              //                             'https://picsum.photos/${width.toInt()}/${expandedHeight.toInt()}?random=$e',
              //                           ),
              //                           fit: BoxFit.fill,
              //                         ),
              //                 ),
              //                 // child: Column(
              //                 //   mainAxisAlignment: MainAxisAlignment.end,
              //                 //   children: [
              //                 //   AdsNews(space: 0),
              //                 // ]),
              //               ),
              //             ))
              //         .toList(),
              //   ),
              );
        },
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          child: const Text(
            'Top Headlines',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: LayoutBuilder(
            builder: (p0, p1) {
              final biggest = p1.biggest;
              final width = biggest.width;
              return SizedBox(
                height: biggest.height,
                width: width > 600 ? width * .65 : width,
                child: PagedListView<int, BingNewsResponse>(
                  padding: EdgeInsets.zero,
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<BingNewsResponse>(
                    animateTransitions: true,
                    // firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                    //   error: _pagingController.error,
                    //   onTryAgain: () => _pagingController.refresh(),
                    // ),
                    // newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                    //   error: _pagingController.error,
                    //   onTryAgain: () => _pagingController.retryLastFailedRequest(),
                    // ),
                    firstPageProgressIndicatorBuilder: (_) =>
                        const CupertinoActivityIndicator(
                            animating: true, radius: 16),
                    newPageProgressIndicatorBuilder: (_) => Container(
                      margin: const EdgeInsets.all(12),
                      child: const CupertinoActivityIndicator(animating: true),
                    ),
                    // noItemsFoundIndicatorBuilder: (_) => NoItemsFoundIndicator(),
                    // noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
                    itemBuilder: (context, item, index) => Item(item: item),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }
}
