import 'dart:convert';

import 'package:global_net/v2/exchange_rates/data/repository/response/exchange_rate_response.dart';
import 'package:http/http.dart' as http;

class ExchangeRateRepositoryNew {
  ExchangeRateRepositoryNew._internal();

  static ExchangeRateRepositoryNew get instance => _instance;

  static final ExchangeRateRepositoryNew _instance =
      ExchangeRateRepositoryNew._internal();

  Future<ExchangeRateResponse> latest(String baseCode) async {
    final path = 'rapid/latest/$baseCode';
    final result = await _get(path: path);
    return ExchangeRateResponse.from(jsonDecode(result.body));
  }

  Future<http.Response> _get({
    required String path,
    Map<String, String>? queryParameters,
  }) async =>
      http.get(
        Uri.https(
          "exchangerate-api.p.rapidapi.com",
          path,
          queryParameters,
        ),
        headers: {
          'X-RapidAPI-Key':
              'bd54b898f0msh16ad7abb16004b6p1005edjsnb07b4dc4f0d2',
          'X-RapidAPI-Host': 'exchangerate-api.p.rapidapi.com',
        },
      );
}
