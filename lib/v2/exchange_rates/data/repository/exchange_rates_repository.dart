import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:global_net/v2/exchange_rates/data/repository/response/convert_response.dart';
import 'package:global_net/v2/exchange_rates/data/repository/response/symbol_response.dart';
import 'package:http/http.dart' as http;

class ExchangeratesRepository {
  ExchangeratesRepository._internal();

  static ExchangeratesRepository get instance => _instance;

  static final ExchangeratesRepository _instance =
      ExchangeratesRepository._internal();

  Future<ConvertResponse> convert({
    required String from,
    required String to,
    required String amount,
  }) async {
    if (kReleaseMode) {
      final response = await _get(
        path: "exchangerates_data/convert",
        queryParameters: {
          "from": from,
          "to": to,
          "amount": amount,
        },
      );
      if (response.statusCode == 200) {
        return ConvertResponse.from(response.body);
      } else {
        return Future.error(jsonDecode(response.body)['message']);
      }
    } else {
      return ConvertResponse(
        query: Query(from: from, to: to, amount: double.parse(amount)),
        info: Info(timestamp: 1673949625868, rate: 10000),
        date: "11-11-11",
        result: 10000 * double.parse(amount),
      );
    }
  }

  Future<List<SymbolResponse>> getSymbols() async {
    if (kReleaseMode) {
      final http.Response response =
          await _get(path: "exchangerates_data/symbols");
      if (response.statusCode == 200) {
        final String responseBody = response.body;
        return SymbolResponse.from(responseBody);
      } else {
        return Future.error(jsonDecode(response.body)['message']);
      }
    }
    await Future.delayed(const Duration(seconds: 3));
    // return Future.error("error");

    return Future.value([
      SymbolResponse(code: "USD", currency: "United States Dollar"),
      SymbolResponse(code: "IDR", currency: "Indonesian Rupiah"),
      SymbolResponse(code: "CNY", currency: "Chinese Yuan"),
    ]);
  }

  // Future<dynamic> latest() async {
  // get(
  //   "exchangerates_data/latest",
  //   {"symbols": "GBP,USD", "base": "BTC"},
  // );
  // }

  Future<http.Response> _get({
    required String path,
    Map<String, String>? queryParameters,
  }) async =>
      http.get(
        Uri.https("api.apilayer.com", path, queryParameters),
        // headers: {"apikey": "XElYLBe4cmyG6zzvfaNZuqNfE0sbWBka"},
        /* api key roottingandroid */
        // headers: {"apikey": "oaDScUHSnSHvyWCq0FTsSqqeisg5V14E"},
        /* api key x.19.02.1992.x */
        // headers: {"apikey": "2HkXQBeWIJHu04yuohicZZONhqda3y6v"},
        /* api key x.syaifullah.x */
        headers: {"apikey": "6MpKCBQJpvn3llVKLLwIqrVZTWd263Tt"},
      );
}
