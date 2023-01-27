import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:global_net/news/data/response/news_api_response.dart';

class NewsApiRepository {
  NewsApiRepository._internal();

  static NewsApiRepository get instance => _instance;

  static final NewsApiRepository _instance = NewsApiRepository._internal();

  Future<NewsApiResponse> topHeadlines({
    String country = 'us',
    String? category,
    String? sources,
    String? q,
    int pageSize = 20,
    int page = 1,
  }) async {
    final query = {
      'country': country,
      'category': category,
      'sources': sources,
      'q': q,
      'pageSize': '$pageSize',
      'page': '$page',
    };
    final response =
        await _get(path: "/v2/top-headlines", queryParameters: query);
    if (response['status'] == 'ok') {
      return NewsApiResponse.from(response);
    } else {
      final message = response['message'];
      // final status = data['status'];
      // final code = data['status'];
      log(message);
      return Future.error('$message');
    }
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    Map<String, String>? headers,
    Map<String, String?>? queryParameters,
  }) async {
    try {
      headers ??= {};
      queryParameters ??= {};

      // headers['Authorization'] = '1308ecb5845a45b182afe42aab01461a';
      headers['Authorization'] = '47c9a1ef3e6a4e139fce37ad52735f7d';

      final dio = Dio();
      dio.options.headers = headers;
      dio.options.queryParameters = queryParameters;
      dio.options.receiveDataWhenStatusError = true;
      return (await dio.get("https://newsapi.org$path")).data;
    } on DioError catch (e) {
      return e.response?.data;
    }
  }
}
