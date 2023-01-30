import 'package:dio/dio.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/v2/news/bing_news/data/response/bing_news_response.dart';

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
      path: 'news/search',
      queryParameters: params,
    );
    final results = BingNewsResponse.from(result);
    if (results is ResultSuccess) {
      return results.value as List<BingNewsResponse>;
    }
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

      headers['X-BingApis-SDK'] = 'true';
      headers['X-RapidAPI-Key'] =
          'bd54b898f0msh16ad7abb16004b6p1005edjsnb07b4dc4f0d2';
      headers['X-RapidAPI-Host'] = 'bing-news-search1.p.rapidapi.com';

      final dio = Dio();
      dio.options.headers = headers;
      dio.options.queryParameters = queryParameters;
      dio.options.receiveDataWhenStatusError = true;
      return (await dio.get("https://bing-news-search1.p.rapidapi.com/$path"))
          .data;
    } on DioError catch (e) {
      return e.response?.data;
    }
  }
}
