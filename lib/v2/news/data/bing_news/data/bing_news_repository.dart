import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/v2/news/data/bing_news/data/response/bing_news_response.dart';
import 'package:global_net/v2/news/data/bing_news/data/response/model/image.dart';
import 'package:global_net/v2/news/data/bing_news/data/response/model/thumbnail.dart';

class BingNewsRepository {
  BingNewsRepository._internal();

  static BingNewsRepository get instance => _instance;

  static final BingNewsRepository _instance = BingNewsRepository._internal();

  // en-US (Inggris)
  // zh-CN (Mandarin)
  // es-ES (Spanyol)
  // fr-FR (Perancis)
  // de-DE (Jerman)
  // it-IT (Italia)
  // pt-BR (Portugis Brasil)
  // id-ID (Bahasa Indonesia)
  Future<List<BingNewsResponse>> search({
    String q = 'top news',
    int page = 0,
    int pageSize = 10,
    String mkt = 'en-US',
    String freshness = 'Day',
  }) async {
    final params = {
      'q': q,
      'offset': '$page',
      'count': '$pageSize',
      'freshness': freshness,
      'originalImg': 'true',
      'textFormat': 'Raw',
      'mkt': mkt,
    };
    final result = await _get(
      path: '/v7.0/news/search',
      queryParameters: params,
    );
    final results = BingNewsResponse.from(result);
    if (results is ResultSuccess) {
      return results.value as List<BingNewsResponse>;
    }
    return [
      BingNewsResponse(
        topic: '',
        type: 'type',
        name: 'Navigating Charlotte’s top-ranking real estate market',
        url: 'url',
        image: ImageBing(
          contentUrl: '',
          thumbnail: Thumbnail(contentUrl: 'contentUrl', width: 1, height: 1),
        ),
        description: 'description',
        mentions: [],
        providers: [],
        datePublished: '01',
      )
    ];
    return List.empty();
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    Map<String, String>? headers,
    Map<String, String?>? queryParameters,
  }) async {
    try {
      headers ??= {};
      queryParameters ??= {};

      headers['Ocp-Apim-Subscription-Key'] =
          'dfcf47c820a94caf8be90f8ae3b61419';
      final dio = Dio();
      dio.options.headers = headers;
      dio.options.queryParameters = queryParameters;
      dio.options.receiveDataWhenStatusError = true;
      return (await dio.get("https://api.bing.microsoft.com/$path"))
          .data;
    } on DioError catch (e) {
      debugPrint('${e.response}');
      return e.response?.data;
    }
  }
}
