import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';

class SymbolResponse {
  final String code;
  final String currency;

  SymbolResponse({
    required this.code,
    required this.currency,
  });

  static List<SymbolResponse> from(String responseBody) {
    try {
      final dynamic jsonResponseBody = jsonDecode(responseBody);
      // final success = jsonResponseBody['success'];
      final Map<dynamic, dynamic> symbols = jsonResponseBody['symbols'];
      return symbols.entries
          .map((e) => SymbolResponse(code: e.key, currency: e.value))
          .toList();
    } catch (e) {
      onError(e);
      return List.empty();
    }
  }

  @override
  String toString() {
    return code + currency;
  }
}
