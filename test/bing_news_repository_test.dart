import 'package:flutter_test/flutter_test.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/v2/news/data/bing_news/data/bing_news_repository.dart';

void main() {
  final repo = BingNewsRepository.instance;
  test('description', () async {
    final result = await repo.search(pageSize: 1);
    // if (result is ResultSuccess) {
    //   print((result).length);
    // } else {
    //   print((result as ResultError?)?.value);
    // }
  });
}
