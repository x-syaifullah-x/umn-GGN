import 'package:global_net/news/bing_news/data/response/model/image.dart';

class Provider {
  Provider({
    required this.name,
    required this.image,
  });

  final String name;
  final Image image;

  static Provider from(Map<String, dynamic> data) {
    final name = data['name'];
    final image = Image.from(data['image']);
    return Provider(name: name, image: image);
  }
}
