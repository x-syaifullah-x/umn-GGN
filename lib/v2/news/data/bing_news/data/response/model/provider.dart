import 'package:global_net/v2/news/bing_news/data/response/model/image.dart';

class Provider {
  Provider({
    required this.name,
    required this.image,
  });

  final String name;
  final ImageBing image;

  static Provider from(Map<String, dynamic> data) {
    final name = data['name'];
    final image = ImageBing.from(data['image']);
    return Provider(name: name, image: image);
  }
}
