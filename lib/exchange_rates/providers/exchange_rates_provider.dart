import 'package:flutter/cupertino.dart';
import 'package:global_net/exchange_rates/data/repository/exchange_rates_repository.dart';
import 'package:global_net/domain/resources.dart';
import 'package:global_net/exchange_rates/data/repository/response/symbol_response.dart';

class ExchangeRatesProvider with ChangeNotifier {
  Resources? _resources;

  Resources get resources {
    final resourcesFinal = _resources;
    if (resourcesFinal == null) {
      _init();
      return Loading();
    }
    return resourcesFinal;
  }

  void _init() async {
    try {
      final repo = ExchangeratesRepository.instance;
      final symbols = await repo.getSymbols();
      final from = symbols[0];
      final to = symbols[1];
      final convert = await repo.convert(
        from: from.code,
        to: to.code,
        amount: "1",
      );
      final timestamp = convert.info.timestamp;
      final rate = convert.info.rate;
      _resources = Success(
        Data(
          symbols: symbols,
          from: from,
          to: to,
          amount: convert.query.amount,
          result: convert.result,
          rate: rate,
          timestamp: timestamp,
        ),
      );
    } catch (e) {
      _resources = Error(Exception(e));
    } finally {
      notifyListeners();
    }
  }

  void convert(
    SymbolResponse from,
    SymbolResponse to,
    String amount,
  ) async {
    final resourcesFinal = resources;
    if (resourcesFinal is Success<Data>) {
      final repo = ExchangeratesRepository.instance;
      _resources = Loading();
      notifyListeners();
      final convertResult =
          await repo.convert(from: from.code, to: to.code, amount: amount);
      final value = resourcesFinal.value;
      final timestamp = convertResult.info.timestamp;
      final rate = convertResult.info.rate;
      _resources = Success(
        Data(
          symbols: value.symbols,
          from: from,
          to: to,
          amount: convertResult.query.amount,
          result: convertResult.result,
          rate: rate,
          timestamp: timestamp,
        ),
      );
      notifyListeners();
    }
  }

  void convertRevert(
    SymbolResponse from,
    SymbolResponse to,
    String amount,
  ) async {
    final resourcesFinal = resources;
    if (resourcesFinal is Success<Data>) {
      final repo = ExchangeratesRepository.instance;
      _resources = Loading();
      notifyListeners();
      final convertResult =
          await repo.convert(from: from.code, to: to.code, amount: amount);
      final timestamp = convertResult.info.timestamp;
      final rate = convertResult.info.rate;
      _resources = Success(
        resourcesFinal.value.copy(
          from: to,
          to: from,
          amount: convertResult.result,
          result: convertResult.query.amount,
          rate: rate,
          timestamp: timestamp,
        ),
      );
      notifyListeners();
    }
  }

  void calculate(SymbolResponse from, SymbolResponse to, double amount) {
    final resourcesFinal = resources;
    if (resourcesFinal is Success<Data>) {
      final value = resourcesFinal.value;
      if (from == resourcesFinal.value.from) {
        _resources = Success(resourcesFinal.value
            .copy(amount: amount, result: amount * value.rate));
      } else if (from == resourcesFinal.value.to) {
        _resources = Success(
          resourcesFinal.value.copy(
            amount: amount / value.rate,
            result: amount,
          ),
        );
      }
      notifyListeners();
    }
  }
}

class Data {
  Data({
    required this.symbols,
    required this.from,
    required this.to,
    required this.amount,
    required this.result,
    required this.rate,
    required this.timestamp,
  });

  final List<SymbolResponse> symbols;
  final SymbolResponse from;
  final SymbolResponse to;
  final double amount;
  final double result;
  final double rate;
  final int timestamp;

  Data copy({
    List<SymbolResponse>? symbols,
    SymbolResponse? from,
    SymbolResponse? to,
    double? amount,
    double? result,
    double? rate,
    int? timestamp,
  }) =>
      Data(
        amount: amount ?? this.amount,
        from: from ?? this.from,
        rate: rate ?? this.rate,
        result: result ?? this.result,
        symbols: symbols ?? this.symbols,
        timestamp: timestamp ?? this.timestamp,
        to: to ?? this.to,
      );
}
