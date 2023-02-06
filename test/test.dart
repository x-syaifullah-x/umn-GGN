import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('description', () async {
    try {
      final Map<String, dynamic> headers = {
        'X-RapidAPI-Key': '2fbb20ec80msh98339922e6c70d4p186758jsnd06f14318862',
        'X-RapidAPI-Host': 'hot-breaking-news-latest-news.p.rapidapi.com'
      };
      final Map<String, dynamic> queryParameters = {
        'page': 1,
        'per_page': 10,
      };
      Dio dio = Dio();
      // dio.options.headers = headers;
      dio.options.queryParameters = queryParameters;
      dio.options.receiveDataWhenStatusError = true;
      //[{lang_id: 1, lang_name: United States, lang_slug: en-US, lang_code: en-US, lang_flag: unitedstates.png, lang_active: 1, lang_sort: 1}, {lang_id: 6, lang_name: China, lang_slug: zh-CN, lang_code: zh-CN, lang_flag: china.png, lang_active: 1, lang_sort: 2}, {lang_id: 5, lang_name: Japan, lang_slug: ja-JP, lang_code: ja-JP, lang_flag: japan.png, lang_active: 1, lang_sort: 3}, {lang_id: 7, lang_name: India, lang_slug: en-IN, lang_code: en-IN, lang_flag: india.png, lang_active: 1, lang_sort: 4}, {lang_id: 4, lang_name: Australia, lang_slug: en-AU, lang_code: en-AU, lang_flag: australia.png, lang_active: 1, lang_sort: 5}, {lang_id: 3, lang_name: United Kingdom, lang_slug: en-GB, lang_code: en-GB, lang_flag: uk.png, lang_active: 1, lang_sort: 6}, {lang_id: 2, lang_name: Canada, lang_slug: en-CA, lang_code: en-CA, lang_flag: canada.png, lang_active: 1, lang_sort: 7}]
      const url = 'https://apps.oddiapps.ru/newsauto/api/mobileapi/liked_news';
      final result = (await dio.get(url)).data;

      print('result: $result');
    } on DioError catch (e) {
      print(e.response?.data);
    }
  });
}
