import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_net/news/bing_news/data/response/bing_news_response.dart';
import 'package:global_net/news/bing_news/data/response/model/provider.dart';
import 'package:global_net/news/news_api/data/response/model/source.dart';
import 'package:global_net/news/presentation/app_web_view.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetail extends StatelessWidget {
  const NewsDetail({
    Key? key,
    required this.article,
  }) : super(key: key);

  final BingNewsResponse article;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final expandedHeight = size.height * (isLandscape ? .4 : .3);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _sliverAppBar(expandedHeight, article),
            ];
          },
          body: _body(context),
          // body: _body(),
        ),
      ),
    );
  }

  Widget _sliverAppBar(double expandedHeight, BingNewsResponse article) {
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
            child: FlexibleSpaceBar(
              title: Text(
                article.name,
                maxLines: (isCollapse ? 1 : 2),
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  image: isCollapse
                      ? null
                      : DecorationImage(
                          image: NetworkImage(article.image.contentUrl),
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final double width = size.width < 600 ? 10.0 : (size.width * .2);
    final double paddingLeft = width;
    final double paddingRight = width;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateBuild(
                dateTime: DateTime.parse(article.datePublished),
                padding: EdgeInsets.only(
                    left: paddingLeft, right: paddingRight, top: 8),
              ),
              _titleBuild(
                title: article.name,
                padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: 12,
                ),
              ),
              _card(
                width: size.width,
                padding: EdgeInsets.only(
                  left: paddingLeft + 20,
                  right: paddingRight + 20,
                  top: 24,
                ),
              ),
              _descriptions(
                descriptions: article.description,
                padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: 8,
                ),
              ),
              _source(
                context: context,
                source: article.providers,
                url: article.url,
                padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: 30,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: 10,
                ),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                ),
              ),
              _related(
                  padding: EdgeInsets.only(
                left: paddingLeft,
                right: paddingRight,
                top: 10,
              )),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          left: size.width * .3,
          right: size.width * .3,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.indigo),
              elevation: MaterialStateProperty.resolveWith<double?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return 16;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () {
              openBrowser(context, article);
            },
            child: Text('Read More'),
          ),
        )
      ],
    );
  }

  void openBrowser(BuildContext context, BingNewsResponse article) {
    if (kIsWeb) {
      launchUrl(Uri.parse(article.url));
    } else {
      String title;
      if (article.providers.isNotEmpty) {
        title = article.providers.first.name;
      } else {
        title = 'New';
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AppWebView(
            url: article.url,
            title: title,
          ),
        ),
      );
    }
  }

  Widget _dateBuild({
    required DateTime dateTime,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    final date = DateFormat('MMM d, kk:mm a').format(dateTime);
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        date,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _titleBuild({
    required String title,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card({
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? width = double.infinity,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Card(
        margin: margin,
        child: Container(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cardItemBuild(iconData: Icons.thumb_up, title: 'Like'),
              _cardItemBuild(iconData: Icons.comment, title: 'Comment'),
              _cardItemBuild(iconData: Icons.share, title: 'Share'),
              _cardItemBuild(iconData: Icons.save, title: 'Save'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardItemBuild({required IconData iconData, required String title}) {
    return InkWell(
      child: Column(
        children: [
          Icon(iconData),
          Text(title),
        ],
      ),
      onTap: () {
        toast('Soon');
      },
    );
  }

  Widget _descriptions({
    required String descriptions,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      child: Text(
        descriptions,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _source({
    required BuildContext context,
    required List<Provider> source,
    required String url,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    final String sourceName;
    if (source.isNotEmpty) {
      sourceName = source.first.name;
    } else {
      sourceName = '-';
    }
    return Container(
      padding: padding,
      margin: margin,
      child: Row(
        children: [
          Text(
            'Source: ',
          ),
          InkWell(
            child: Text(
              sourceName,
              style: TextStyle(color: Colors.indigo),
            ),
            onTap: () {
              openBrowser(context, article);
            },
          )
        ],
      ),
    );
  }

  Widget _related({
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    const length = 10;
    const size = length - 1;
    const left = 10.0;
    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: left, right: left, top: 14),
            child: Text(
              'Related',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () {
              toast('Soon');
            },
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: length,
                itemBuilder: (context, index) {
                  final leftItem = index == 0 ? left : 4.0;
                  final rightItem = (index == size) ? leftItem : 4.0;
                  return Container(
                    width: 140,
                    color: Theme.of(context).primaryColor,
                    margin: EdgeInsets.only(left: leftItem, right: rightItem),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
