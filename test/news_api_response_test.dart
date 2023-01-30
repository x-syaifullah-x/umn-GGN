import 'package:flutter_test/flutter_test.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/v2/news/news_api/data/response/news_api_response.dart';

void main() {
  test("status error", () async {
    final response = {
      'status': 'error',
      'message': 'response_error',
    };

    print(NewsApiResponse.from(response) is ResultError);
  });

  test("status ok", () async {
    final List articles = [];
    final response = {
      'status': 'ok',
      'totalResults': articles.length,
      'articles': articles,
    };

    final result = NewsApiResponse.from(response);
    if (result is ResultSuccess<NewsApiResponse>) {
      print(result.value);
    }
  });

  test("status error field", () async {
    final List articles = [];
    final response = {
      'a': '',
    };

    final result = NewsApiResponse.from(response);
    if (result is ResultError) {
      print(result.value);
    }
  });
}
