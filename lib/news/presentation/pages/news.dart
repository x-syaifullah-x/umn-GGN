import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/l10n/l10n.dart';
import 'package:global_net/news/bing_news/data/bing_news_repository.dart';
import 'package:global_net/news/bing_news/data/response/bing_news_response.dart';
import 'package:global_net/provider/locale_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

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
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    if (locale?.languageCode == L10n.languageCodeChinese) {
      country = 'zh-CN';
    }
    try {
      final results = await BingNewsRepository.instance
          .search(page: page, pageSize: pageSize, mkt: country);

      final isLastPage = results.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(results.toSet().toList());
      } else {
        final nextPage = page + results.length;
        _pagingController.appendPage(results.toSet().toList(), nextPage);
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
    final expandedHeight = size.height * (isLandscape ? .4 : .3);
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
                ? const FlexibleSpaceBar(title: Text('News'))
                : CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      // onPageChanged: callbackFunction,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: [
                      'EXAMPLE BANNER ONE',
                      'EXAMPLE BANNER TWO',
                      'EXAMPLE BANNER THREE'
                    ]
                        .map((e) => FlexibleSpaceBar(
                              title: Text(e),
                              background: Container(
                                decoration: BoxDecoration(
                                  image: isCollapse
                                      ? null
                                      : DecorationImage(
                                          image: NetworkImage(
                                            'https://picsum.photos/${width.toInt()}/${expandedHeight.toInt()}?random=$e',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
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
