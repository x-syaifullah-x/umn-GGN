import 'package:flutter/cupertino.dart';
import 'package:global_net/domain/resources.dart';
import 'package:global_net/v2/exchange_rate_new/exchange_rate_repository_new.dart';

import '../../exchange_rates/data/repository/response/model/rate.dart';

class ExchangeRateProvider with ChangeNotifier {
  ExchangeRateProvider() {
    _init();
  }

  Resources _resources = ResourcesLoading();

  Resources get resources {
    return _resources;
  }

  double amount = 1;
  double result = 0.0;

  late Rate rateOne;
  late Rate rateTwo;

  _init() async {
    try {
      final result = await ExchangeRateRepositoryNew.instance.latest('USD');
      rateOne = result.rates[0];
      rateTwo = result.rates.firstWhere((element) => element.name == 'CNY');
      this.result = (amount * rateTwo.value);
      _resources = ResourcesSuccess(result);
    } catch (e) {
      _resources = ResourcesError(e);
    } finally {
      notifyListeners();
    }
  }

  void dropdownChangeOne({required String name, required String amount}) async {
    try {
      final result = await ExchangeRateRepositoryNew.instance.latest(name);
      rateOne = result.rates[0];
      rateTwo =
          result.rates.firstWhere((element) => element.name == rateTwo.name);
      this.result = ((double.tryParse(amount) ?? 0) * rateTwo.value);
      _resources = ResourcesSuccess(result);
    } catch (e) {
      _resources = ResourcesError(e);
    } finally {
      notifyListeners();
    }
  }

  void dropdownChangeTwo({
    required String name,
    required String result,
  }) async {
    try {
      final response =
          await ExchangeRateRepositoryNew.instance.latest(rateOne.name);
      rateOne = response.rates[0];
      rateTwo = response.rates.firstWhere((element) => element.name == name);
      this.result = (amount * rateTwo.value);
      // this.result = double.tryParse(result) ?? 0.0;
      _resources = ResourcesSuccess(response);
    } catch (e) {
      _resources = ResourcesError(e);
    } finally {
      notifyListeners();
    }
  }

  void calculateOne(double amount) {
    this.amount = amount;
    result = this.amount * rateTwo.value;
    notifyListeners();
  }

  void calculateTwo(double result) {
    this.result = result;
    amount = result / rateTwo.value;
    notifyListeners();
  }

  retry() {
    _init();
  }
}
