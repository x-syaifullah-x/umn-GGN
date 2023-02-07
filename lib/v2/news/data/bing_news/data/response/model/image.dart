import 'package:global_net/v2/news/data/bing_news/data/response/model/thumbnail.dart';

class ImageBing {
  ImageBing({
    required this.contentUrl,
    required this.thumbnail,
  });

  final String contentUrl;
  final Thumbnail thumbnail;

  static ImageBing from(Map<String, dynamic>? data) {
    if (data != null) {
      final imageContentUrl = data['contentUrl'];
      final imageThumbnailContentUrl = data['thumbnail']['contentUrl'];
      final imageThumbnailWidth =
          double.tryParse('${data['thumbnail']['width']}') ?? 0.0;
      final imageThumbnailHeight =
          double.tryParse('${data['thumbnail']['height']}') ?? 0.0;
      return ImageBing(
        contentUrl: imageContentUrl ?? '',
        thumbnail: Thumbnail(
          contentUrl: imageThumbnailContentUrl ?? '',
          width: imageThumbnailWidth,
          height: imageThumbnailHeight,
        ),
      );
    }
    return ImageBing(
      contentUrl: '',
      thumbnail: Thumbnail(
        contentUrl: '',
        width: 0,
        height: 0,
      ),
    );
  }
}
