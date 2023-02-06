import 'package:global_net/v2/news/bing_news/data/response/model/image.dart';
import 'package:global_net/v2/news/bing_news/data/response/model/mention.dart';
import 'package:global_net/v2/news/bing_news/data/response/model/provider.dart';

import '../../../../../domain/result.dart';

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
          final mentions = (element['mention'] as List?)
                  ?.map((e) => Mention(name: e['name'])) ??
              List.empty();
          final providers =
              (element['provider'] as List?)?.map((e) => Provider.from(e)) ??
                  List.empty();
          return BingNewsResponse(
            type: _type,
            datePublished: datePublished,
            description: description,
            name: name,
            url: url,
            image: image,
            mentions: mentions.toList(),
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
}
