import 'dart:convert';

class ConvertResponse {
  final String date;
  final double result;
  final int timestamp;
  final double rate;

  ConvertResponse({
    required this.date,
    required this.result,
    required this.timestamp,
    required this.rate,
  });

  static ConvertResponse from(String responseBody) {
    final dynamic jsonResponseBoddy = jsonDecode(responseBody);

    return ConvertResponse(
      date: jsonResponseBoddy['date'],
      result: double.parse("${jsonResponseBoddy['result']}"),
      timestamp: (jsonResponseBoddy['info']['timestamp']) * 1000,
      rate: double.parse("${jsonResponseBoddy['info']['rate']}"),
    );
  }
}
