import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:global_net/l10n/l10n.dart';
import 'package:global_net/news/data/news_api_repository.dart';
import 'package:global_net/news/data/response/model/articel.dart';
import 'package:global_net/provider/locale_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class News extends StatefulWidget {
  const News({
    Key? key,
  }) : super(key: key);

  static const route = '/news';

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final PagingController<int, Artticle> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((page) {
      _fetchPage(page: page);
    });
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
              SliverAppBar(
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
                    final isColapse =
                        constraints.biggest.height.toInt() == kToolbarHeight;
                    return Container(
                      color: isColapse
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).backgroundColor,
                      child: isColapse
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
                                            image: isColapse
                                                ? null
                                                : DecorationImage(
                                                    image: NetworkImage(
                                                      'https://picsum.photos/${size.width.toInt()}/${expandedHeight.toInt()}?random=$e',
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
              ),
            ];
          },
          body: Column(
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
                      child: PagedListView<int, Artticle>(
                        padding: EdgeInsets.zero,
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<Artticle>(
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
                            child: const CupertinoActivityIndicator(
                                animating: true),
                          ),
                          // noItemsFoundIndicatorBuilder: (_) => NoItemsFoundIndicator(),
                          // noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
                          itemBuilder: (context, item, index) =>
                              _itemBuild(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  Future<void> _fetchPage({
    required int page,
    int pageSize = 10,
  }) async {
    String country = 'us';
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    if (locale?.languageCode == L10n.languageCodeChinese) {
      country = 'cn';
    }
    try {
      final newsApiResponse = await NewsApiRepository.instance
          .topHeadlines(page: page, pageSize: pageSize, country: country);
      final isLastPage = newsApiResponse.articles.length < pageSize;
      final articles = newsApiResponse.articles;
      if (isLastPage) {
        _pagingController.appendLastPage(articles);
      } else {
        final nextPage = page + 1;
        _pagingController.appendPage(articles, nextPage);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Widget _itemBuild(Artticle item) {
    final date = DateFormat('MMM d, kk:mm a').format(
      DateTime.parse(item.publishedAt),
    );
    return Container(
      height: 135,
      margin: const EdgeInsets.only(
        bottom: 6,
        right: 6,
        left: 6,
      ),
      child: Card(
        margin: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: item.urlToImage,
                imageBuilder: (context, imageProvider) => Container(
                  height: double.infinity,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                      // colorFilter: const ColorFilter.mode(
                      //   Colors.red,
                      //   BlendMode.colorBurn,
                      // ),
                    ),
                  ),
                ),
                placeholder: (context, url) => const SizedBox(
                  height: double.infinity,
                  width: 100,
                  child: CupertinoActivityIndicator(
                    animating: true,
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: double.infinity,
                  width: 100,
                  child: Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: LayoutBuilder(
                  builder: (p0, p1) {
                    final biggest = p1.biggest;
                    return SizedBox(
                      height: biggest.height,
                      width: biggest.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded),
                                      const SizedBox(width: 4),
                                      Text(
                                        date,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
