import 'package:global_net/v2/news/bing_news/data/response/model/thumbnail.dart';

class Video {
  Video(this.name, this.motionThumbnailUrl, this.thumbnail);

  final String name;
  final String motionThumbnailUrl;
  final Thumbnail thumbnail;
}
