import 'package:global_net/v2/news/news_api/data/response/model/source.dart';

class Article {
  Article({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  final Source source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;

  factory Article.from(dynamic e) {
    final sourceResponse = e['source'];
    return Article(
      source: Source(
        id: sourceResponse['id'] ?? "",
        name: sourceResponse['name'] ?? "",
      ),
      author: e['author'] ?? "",
      content: e['content'] ?? "",
      description: e['description'] ?? "",
      publishedAt: e['publishedAt'] ?? "",
      title: e['title'] ?? "",
      url: e['url'] ?? "",
      urlToImage: e['urlToImage'] ?? "",
    );
  }
}
