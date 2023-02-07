import 'package:global_net/v2/exchange_rates/data/repository/response/model/rate.dart';

class ExchangeRateResponse {
  ExchangeRateResponse({
    required this.baseCode,
    required this.rates,
    required this.lastUpdate,
    required this.nextUpdate,
  });

  final String baseCode;
  final List<Rate> rates;
  final int lastUpdate;
  final int nextUpdate;

  static ExchangeRateResponse from(Map<dynamic, dynamic> response) {
    final timeMillisNextUpdate =
        (int.tryParse('${response['time_next_update_unix']}') ?? 0) * 1000;
    final timeMillisLastUpdate =
        (int.tryParse('${response['time_last_update_unix']}') ?? 0) * 1000;
    final baseCode = response['base_code'];
    final rates = (response['rates'] as Map?)
        ?.entries
        .map((e) => Rate(
              name: e.key,
              value: double.tryParse('${e.value}') ?? 0.0,
            ))
        .toList();
    return ExchangeRateResponse(
      baseCode: baseCode,
      rates: rates ?? List.empty(),
      lastUpdate: timeMillisLastUpdate,
      nextUpdate: timeMillisNextUpdate,
    );
  }
}
