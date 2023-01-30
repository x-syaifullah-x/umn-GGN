import 'package:flutter_test/flutter_test.dart';
import 'package:global_net/v2/exchange_rates/data/repository/exchange_rates_repository.dart';

void main() {
  final repo = ExchangeratesRepository.instance;
  test("convert", () async {
    final result = await repo.convert(from: "USD", to: "IDR", amount: "2.1");
  });
}
