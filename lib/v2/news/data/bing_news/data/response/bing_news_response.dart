import 'package:global_net/v2/news/data/bing_news/data/response/model/thumbnail.dart';

import '../../../../../../domain/result.dart';
import 'model/image.dart';
import 'model/mention.dart';
import 'model/provider.dart';

class BingNewsResponse {
  BingNewsResponse({
    required this.type,
    required this.name,
    required this.url,
    required this.image,
    required this.description,
    required this.mentions,
    required this.providers,
    required this.datePublished,
    required this.topic,
    // required this.video,
  });

  final String type;
  final String name;
  final String url;
  final ImageBing image;
  final String description;
  final List<Mention> mentions;
  final List<Provider> providers;
  final String datePublished;
  final String topic;

  // final Video video;

  static Result from(Map<String, dynamic> response) {
    try {
      final errors = response['errors'] as List?;
      final _type = response['_type'];
      final value = response['value'] as List;
      if (errors == null) {
        final results = value.map((element) {
          final datePublished = element['datePublished'];
          final description = element['description'];
          final name = element['name'];
          final url = element['url'];
          final image = ImageBing.from(element['image']);
          // final mentions = (element['mention'] as List?)
          //         ?.map((e) => Mention(name: e['name'])) ??
          //     List.empty();
          final providers =
              (element['provider'] as List?)?.map((e) => Provider.from(e)) ??
                  List.empty();
          return BingNewsResponse(
            type: _type,
            topic: '',
            datePublished: datePublished,
            description: description,
            name: name,
            url: url,
            image: image,
            mentions: [],
            providers: providers.toList(),
            // video: ,
          );
        }).toList();
        return ResultSuccess(results);
      }
      return ResultError(errors);
    } catch (e) {
      return ResultError(e);
    }
  }

  static Result fromNewsCatcher(Map<String, dynamic> response) {
    try {
      print('page: ${response['page']}');
      print('page_size: ${response['page_size']}');
      print('total_pages: ${response['total_pages']}');

      final status = response['status'];
      if (status == 'ok') {
        final value = response['articles'] as List;
        final results = value.map((element) {
          final datePublished = element['published_date'];
          final description = element['summary'];
          final name = element['title'];
          final url = element['link'];
          final image = ImageBing(
            contentUrl: element['media'],
            thumbnail: Thumbnail(
              contentUrl: '',
              width: 0,
              height: 0,
            ),
          );
          final providers = [
            Provider(name: element['clean_url'], image: image),
          ];
          final topic = element['topic'];
          return BingNewsResponse(
            type: 'News',
            topic: topic,
            datePublished: datePublished,
            description: description,
            name: name,
            url: url,
            image: image,
            mentions: [],
            providers: providers.toList(),
            // video: ,
          );
        }).toList();
        return ResultSuccess(results);
      }
      return ResultError(response['message']);
    } catch (e) {
      return ResultError(e);
    }
  }
}
