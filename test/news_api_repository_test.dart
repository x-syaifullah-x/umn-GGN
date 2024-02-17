import 'package:flutter_test/flutter_test.dart';
import 'package:global_net/v2/news/data/news_api/data/news_api_repository.dart';

void main() {
  final repo = NewsApiRepository.instance;
  test("topHeadlines", () async {
    const pageSize = 2;
    final result = await repo.topHeadlines(
      page: 1,
      pageSize: pageSize,
      country: 'cn',
    );
    print('result.totalResults: ${result.totalResults}');
    print('result.articles.length: ${result.articles.length}');
    // print('result.articles: ${result.articles.map((e) => e.ti)}');
  });
}
