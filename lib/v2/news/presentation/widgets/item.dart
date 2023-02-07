import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/bing_news/data/response/bing_news_response.dart';
import '../pages/news_detail.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.item,
  }) : super(key: key);

  final BingNewsResponse item;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, kk:mm a').format(
      DateTime.tryParse(item.datePublished)??DateTime(2021),
    );
    return InkWell(
      child: Container(
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
                  imageUrl: item.image.contentUrl,
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
                              item.name,
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
                                        const Icon(
                                            Icons.calendar_month_rounded),
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
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NewsDetail(article: item),
        ));
      },
    );
  }
}
