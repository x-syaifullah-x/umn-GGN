import 'package:global_net/v2/news/news_api/data/response/model/article.dart';

import '../../../../../domain/result.dart';

class NewsApiResponse {
  NewsApiResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  String status;
  int totalResults;
  List<Article> articles;

  static Result from(Map<String, dynamic> response) {
    try {
      final status = response['status'];
      if (status == 'ok') {
        final totalResults = response['totalResults'];
        final articles = (response['articles'] as List?)
                ?.map((e) => Article.from(e))
                .toList() ??
            List.empty();

        final NewsApiResponse result = NewsApiResponse(
          status: status,
          totalResults: totalResults,
          articles: articles,
        );

        return ResultSuccess(result);
      }

      final message = response['message'] ?? 'no message response';
      return ResultError(message);
    } catch (e) {
      return ResultError(e);
    }
  }
}
