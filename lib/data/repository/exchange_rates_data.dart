import 'dart:convert';

import 'package:global_net/data/repository/convert_response.dart';
import 'package:global_net/data/repository/symbols_response.dart';
import 'package:http/http.dart' as http;

class ExchangeratesRepository {
  static final ExchangeratesRepository _instance =
      ExchangeratesRepository._internal();

  ExchangeratesRepository._internal();

  static ExchangeratesRepository get instance => _instance;

  Future<dynamic> latest() async {
    // get(
    //   "exchangerates_data/latest",
    //   {"symbols": "GBP,USD", "base": "BTC"},
    // );
  }

  Future<ConvertResponse> convert({
    required String from,
    required String to,
    required String amount,
  }) async {
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
  }

  Future<List<SymbolsResponse>> getSymbols() async {
    // final http.Response response =
    //     await _get(path: "exchangerates_data/symbols");
    // if (response.statusCode == 200) {
    //   final String responseBody = response.body;
    //   return SymbolsResponse.from(responseBody);
    // } else {
    //   return Future.error(jsonDecode(response.body)['message']);
    // }

    await Future.delayed(const Duration(seconds: 5));
    return Future.error("error");

    // return Future.value([
    //   SymbolsResponse(key: "USD", value: "AS"),
    //   SymbolsResponse(key: "IDR", value: "Indonesi"),
    //   SymbolsResponse(key: "CNY", value: "China"),
    // ]);
  }

  Future<http.Response> _get({
    required String path,
    Map<String, String>? queryParameters,
  }) async =>
      http.get(
        Uri.https("api.apilayer.com", path, queryParameters),
        // headers: {"apikey": "XElYLBe4cmyG6zzvfaNZuqNfE0sbWBka"},
        /* api key roottingandroid */
        headers: {"apikey": "oaDScUHSnSHvyWCq0FTsSqqeisg5V14E"},
      );
}
