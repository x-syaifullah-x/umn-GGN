import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/v2/news/presentation/pages/news_detail.dart';

import '../../data/bing_news/data/bing_news_repository.dart';
import '../../data/bing_news/data/response/bing_news_response.dart';
import '../../data/news_catcher/repository.dart';

class Related extends StatefulWidget {
  const Related({
    Key? key,
    required this.q,
    this.left = 10.0,
  }) : super(key: key);

  final String q;
  final double left;

  @override
  State<Related> createState() => _RelatedState();
}

class _RelatedState extends State<Related> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetch(),
      builder: (context, AsyncSnapshot<List<BingNewsResponse>> snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done) {
          if (data != null && data.isNotEmpty) {
            if (data[0].name == widget.q) {
              data.removeAt(0);
              if (data.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  height: 250,
                  // margin: const EdgeInsets.only(top: 14),
                  child: Image.asset('assets/images/aaaa.png'),
                );
              }
            }
            return _items(data);
          }
          return SizedBox(
            width: double.infinity,
            height: 250,
            // margin: const EdgeInsets.only(top: 14),
            child: Image.asset('assets/images/aaaa.png'),
          );
        }

        return const SizedBox(
          height: 150,
          width: double.infinity,
          child: CupertinoActivityIndicator(animating: true),
        );
      },
    );
  }

  Future<List<BingNewsResponse>> _fetch() {
    // if (kDebugMode) {
    //   return Future.value([]);
    // }
    return BingNewsRepository.instance.search(
      q: '${widget.q}&textFormat=RAW&textDecorations=BOLD',
      pageSize: 10,
      freshness: 'Day',
    );
  }

  Widget _items(List<BingNewsResponse> data) {
    final length = data.length;
    final size = length - 1;
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: length,
        itemBuilder: (context, index) {
          final leftItem = index == 0 ? widget.left : 4.0;
          final rightItem = (index == size) ? leftItem : 4.0;
          return InkWell(
            child: Container(
              width: 140,
              height: 140,
              color: Theme.of(context).backgroundColor,
              margin: EdgeInsets.only(
                left: leftItem,
                right: rightItem,
                top: 10,
                bottom: 10,
              ),
              child: CachedNetworkImage(
                imageUrl: data[index].image.contentUrl,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                        child: Text(
                          data[index].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                placeholder: (context, url) => const Center(
                    child: CupertinoActivityIndicator(
                  animating: true,
                )),
                errorWidget: (context, url, error) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(child: Icon(Icons.error)),
                      Container(
                        margin: const EdgeInsets.only(
                          left: 4,
                          right: 4,
                          bottom: 4,
                        ),
                        child: Text(
                          data[index].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewsDetail(article: data[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
