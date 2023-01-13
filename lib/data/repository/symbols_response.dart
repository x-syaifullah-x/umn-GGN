import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';

class SymbolsResponse {
  final String key;
  final String value;

  SymbolsResponse({
    required this.key,
    required this.value,
  });

  static List<SymbolsResponse> from(String responseBody) {
    try {
      final dynamic jsonResponseBody = jsonDecode(responseBody);
      // final success = jsonResponseBody['success'];
      final Map<dynamic, dynamic> symbols = jsonResponseBody['symbols'];
      return symbols.entries
          .map((e) => SymbolsResponse(key: e.key, value: e.value))
          .toList();
    } catch (e) {
      onError(e);
      return List.empty();
    }
  }

  @override
  String toString() {
    return key + value;
  }
}
