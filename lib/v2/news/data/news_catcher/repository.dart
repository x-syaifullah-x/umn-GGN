import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/v2/news/data/bing_news/data/response/bing_news_response.dart';

class NewsCatcherRepository {
  NewsCatcherRepository._internal();

  static NewsCatcherRepository get instance => _instance;

  static final NewsCatcherRepository _instance =
      NewsCatcherRepository._internal();

  Future<List<BingNewsResponse>> search({
    required String q,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = {
      'q': q,
      'page': '$page',
      'page_size': '$pageSize',
    };
    final response =
        await _get(path: '/v2/search', queryParameters: queryParams);
    final result = BingNewsResponse.fromNewsCatcher(response);
    if (result is ResultSuccess) {
      return result.value as List<BingNewsResponse>;
    }
    return [];
  }

  Future<List<BingNewsResponse>> latestHeadlines({
    int page = 1,
    int pageSize = 20,
    String lang = 'en',
  }) async {
    final queryParams = {
      'page': '$page',
      'page_size': '$pageSize',
      'lang': lang,
    };
    final response =
        await _get(path: '/v2/latest_headlines', queryParameters: queryParams);
    final result = BingNewsResponse.fromNewsCatcher(response);
    if (result is ResultSuccess) {
      return result.value as List<BingNewsResponse>;
    }
    return [];
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    Map<String, String>? headers,
    Map<String, String?>? queryParameters,
  }) async {
    try {
      headers ??= {};
      queryParameters ??= {};

      headers['x-api-key'] = 'DnKYlCTa7I-LSJ6hppm5FNeE_x5EyOjuR8JpDa3ik8U';
      final dio = Dio();
      dio.options.headers = headers;
      dio.options.queryParameters = queryParameters;
      dio.options.receiveDataWhenStatusError = true;
      return (await dio.get("https://api.newscatcherapi.com/$path")).data;
    } on DioError catch (e) {
      debugPrint('${e.response}');
      return e.response?.data;
    }
  }
}
