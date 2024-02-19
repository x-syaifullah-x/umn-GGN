import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/v2/news/presentation/app_web_view.dart';
import 'package:global_net/v2/news/presentation/widgets/related.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/bing_news/data/response/bing_news_response.dart';
import '../../data/bing_news/data/response/model/provider.dart';
import 'news_detail_comment.dart';

class NewsDetail extends StatelessWidget {
  const NewsDetail({
    Key? key,
    required this.article,
  }) : super(key: key);

  final BingNewsResponse article;

  @override
  Widget build(BuildContext context) {
    return _NewsDetail(
      key: key,
      article: article,
    );
  }
}

class _NewsDetail extends StatelessWidget {
  const _NewsDetail({
    Key? key,
    required this.article,
  }) : super(key: key);

  final BingNewsResponse article;

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;

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
          body: _body(context, uid!),
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

  Widget _body(BuildContext context, String uid) {
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
                dateTime:
                    DateTime.tryParse(article.datePublished) ?? DateTime(2021),
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
                data: article,
                uid: uid,
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
                q: article.name,
                padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: 10,
                ),
              ),
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
            child: const Text('Read More'),
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
    required BingNewsResponse data,
    required String uid,
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
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('news')
                      .doc('like')
                      .collection(data.name)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    var isLike = false;
                    final dataSnapshot = snapshot.data;
                    final docs = dataSnapshot?.docs;
                    final likeCount = dataSnapshot?.size;
                    docs?.forEach((element) {
                      if (element.id == uid) {
                        isLike = true;
                        return;
                      }
                    });
                    return _cardItemBuild(
                        iconData:
                            isLike ? Icons.thumb_up : Icons.thumb_up_outlined,
                        title: '$likeCount Like',
                        onTap: () async {
                          final fireStore = FirebaseFirestore.instance;
                          if (isLike) {
                            final newsCollections = fireStore
                                .collection('news')
                                .doc('like')
                                .collection(data.name);
                            final get = await newsCollections.get();
                            for (var element in get.docs) {
                              if (element.id == uid) {
                                await element.reference.delete();
                                return;
                              }
                            }
                          } else {
                            final newsCollections = fireStore
                                .collection('news')
                                .doc('like')
                                .collection(data.name);
                            await newsCollections.doc(uid).set({});
                          }
                        });
                  }),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('news')
                    .doc('comment')
                    .collection(data.name)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  final commentCount = snapshot.data?.size ?? 0;
                  return _cardItemBuild(
                      iconData: Icons.comment,
                      title: '$commentCount Comment',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewsDetailComment(data: data),
                          ),
                        );
                      });
                },
              ),
              _cardItemBuild(
                  iconData: Icons.share,
                  title: 'Share',
                  onTap: () async {
                    await Share.share(
                      '${data.name}\n\nhttps://play.google.com/store/apps/details?id=ggn.liru.yang.net',
                      subject: 'TEXT',
                      // sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
                    );
                  }),
              _cardItemBuild(
                iconData: Icons.save,
                title: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardItemBuild({
    required IconData iconData,
    required String title,
    Function? onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Column(
        children: [
          Icon(iconData),
          Text(title),
        ],
      ),
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
        style: const TextStyle(fontSize: 16),
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
          const Text(
            'Source: ',
          ),
          InkWell(
            child: Text(
              sourceName,
              style: const TextStyle(color: Colors.indigo),
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
    required String q,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    const left = 10.0;
    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: left, right: left, top: 14),
            child: Text(
              'Related',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Related(
            q: q,
            left: left,
          )
        ],
      ),
    );
  }
}
