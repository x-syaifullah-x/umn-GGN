import 'dart:convert';

class ConvertResponse {
  ConvertResponse({
    required this.query,
    required this.info,
    required this.date,
    required this.result,
  });

  final Query query;
  final Info info;
  final String date;
  final double result;

  factory ConvertResponse.from(String responseBody) {
    final dynamic jsonResponseBoddy = jsonDecode(responseBody);
    // final historical = jsonResponseBoddy['historical'];
    // final success = jsonResponseBoddy['success'];
    final info = jsonResponseBoddy['info'];
    final query = jsonResponseBoddy['query'];
    final date = jsonResponseBoddy['date'];
    final result = jsonResponseBoddy['result'];
    return ConvertResponse(
      query: Query.from(query),
      info: Info.from(info),
      date: date,
      result: double.parse("$result"),
    );
  }
}

class Query {
  Query({
    required this.from,
    required this.to,
    required this.amount,
  });

  final String from;
  final String to;
  final double amount;

  factory Query.from(query) {
    final from = query['from'];
    final to = query['to'];
    final amount = double.parse('${query['amount']}');
    return Query(from: from, to: to, amount: amount);
  }
}

class Info {
  Info({
    required this.timestamp,
    required this.rate,
  });

  final int timestamp;
  final double rate;

  factory Info.from(info) {
    final timestamp = info['timestamp'] * 1000;
    final rate = double.parse("${info['rate']}");
    return Info(
      timestamp: timestamp,
      rate: rate,
    );
  }
}
