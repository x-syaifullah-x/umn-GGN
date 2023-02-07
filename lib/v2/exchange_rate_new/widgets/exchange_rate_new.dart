import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/domain/resources.dart';
import 'package:global_net/v2/exchange_rates/data/repository/response/exchange_rate_response.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../exchange_rates/data/repository/response/model/rate.dart';
import '../providers/exchange_rate_provider.dart';

class ExchangeRate extends StatelessWidget {
  const ExchangeRate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ExchangeRateProvider(),
      builder: (context, child) {
        return _ExchangeRate();
      });
}

// class _ExchangeRate extends StatefulWidget {
//   const _ExchangeRate({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }

class _ExchangeRate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDropdownOneChange = false;
    bool isDropdownTwoChange = false;
    final TextEditingController textEditingControllerOne =
        TextEditingController();
    final TextEditingController textEditingControllerTwo =
        TextEditingController();

    final FocusNode focusNodeOne = FocusNode();
    final FocusNode focusNodeTow = FocusNode();

    return Consumer<ExchangeRateProvider>(
      builder: (context, exchangeRateProvider, child) {
        final resources = exchangeRateProvider.resources;
        if (resources is ResourcesLoading) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: CupertinoActivityIndicator(
              animating: true,
            ),
          );
        } else if (resources is ResourcesError) {
          return _error(double.infinity, '${resources.value}', onRetry: () {
            exchangeRateProvider.retry();
          });
        } else if (resources is ResourcesSuccess<ExchangeRateResponse>) {
          final amount = exchangeRateProvider.amount;
          final result = exchangeRateProvider.result;

          final response = resources.value;

          final rates = response.rates;

          final rateOne = exchangeRateProvider.rateOne;
          final rateTwo = exchangeRateProvider.rateTwo;

          if (focusNodeTow.hasFocus) {
            textEditingControllerOne.text = '$amount';
          }
          if (focusNodeOne.hasFocus) {
            textEditingControllerTwo.text = '$result';
          }

          if (isDropdownOneChange) {
            textEditingControllerOne.text = '$amount';
            textEditingControllerTwo.text = '$result';
            isDropdownOneChange = false;
          }

          if (isDropdownTwoChange) {
            textEditingControllerOne.text = '$amount';
            textEditingControllerTwo.text = '$result';
            isDropdownTwoChange = false;
          }

          return SizedBox(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _title()),
                    Text(
                      '$amount ${rateOne.name} equals',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$result ${rateTwo.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('MMM d, kk:mm a UTC').format(
                        DateTime.fromMillisecondsSinceEpoch(response.lastUpdate)
                            .toUtc(),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    _input(
                      context,
                      rates,
                      rateOne,
                      textEditingController: textEditingControllerOne,
                      focusNode: focusNodeOne,
                      onDropdownChange: (Rate rate) {
                        isDropdownOneChange = true;
                        exchangeRateProvider.dropdownChangeOne(
                          name: rate.name,
                          amount: textEditingControllerOne.text,
                        );
                      },
                      onTextChange: (value) {
                        final amount = double.tryParse(value);
                        if (amount != null) {
                          exchangeRateProvider.calculateOne(amount);
                        }
                      },
                    ),
                    _input(
                      context,
                      rates,
                      rateTwo,
                      textEditingController: textEditingControllerTwo,
                      focusNode: focusNodeTow,
                      onDropdownChange: (Rate rate) {
                        isDropdownTwoChange = true;
                        exchangeRateProvider.dropdownChangeTwo(
                          name: rate.name,
                          result: textEditingControllerTwo.text,
                        );
                      },
                      onTextChange: (value) {
                        final result = double.tryParse(value);
                        if (result != null) {
                          exchangeRateProvider.calculateTwo(result);
                        }
                      },
                    ),
                    const SizedBox(height: 14)
                  ],
                ),
              ),
            ),
          );
        }
        throw UnimplementedError();
      },
    );
  }

  Widget _error(double width, String message, {Function? onRetry}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 4,
      ),
      child: Card(
        child: Column(
          children: [
            _title(),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 12,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(width: 1, color: Colors.red),
                ),
                onPressed: () => onRetry?.call(),
                child: const Text(
                  'RETRY',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 18),
      child: const Text(
        'EXCHANGE RATES',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context,
    List<Rate> rates,
    Rate rate, {
    TextEditingController? textEditingController,
    FocusNode? focusNode,
    Function? onDropdownChange,
    Function? onTextChange,
  }) {
    final color = Colors.grey.withOpacity(0.6);
    return Container(
      margin: EdgeInsets.only(
        // left: 4,
        // right: marginRight,
        top: 8,
        // bottom: 4,
      ),
      padding: const EdgeInsets.only(
        left: 8,
        right: 1,
        top: 0,
        bottom: 0,
      ),
      // width: width - marginLeft - marginRight,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: color,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: color,
                ),
              ),
              child: TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                cursorColor: color,
                decoration: const InputDecoration(
                  hintText: ' e.g 100',
                  border: InputBorder.none,
                ),
                onChanged: (value) => onTextChange?.call(value),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              focusColor: color.withOpacity(0.1),
              alignment: Alignment.centerRight,
              value: rate,
              items: rates
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                onDropdownChange?.call(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
