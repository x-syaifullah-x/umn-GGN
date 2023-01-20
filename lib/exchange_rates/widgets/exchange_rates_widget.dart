import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/exchange_rates/data/repository/response/symbol_response.dart';
import 'package:global_net/exchange_rates/providers/exchange_rates_provider.dart';
import 'package:global_net/domain/resources.dart';
import 'package:provider/provider.dart';

typedef OnDropDownChange = Function(SymbolResponse);
typedef OnTextChange = Function(String);

class ExchangeRatesWidget extends StatelessWidget {
  ExchangeRatesWidget({Key? key}) : super(key: key);

  final TextEditingController _textEditingControllerOne =
      TextEditingController();
  final TextEditingController _textEditingControllerTwo =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.amber,
          child: Column(
            children: [
              _title(),
              ChangeNotifierProvider(
                create: (context) => ExchangeRatesProvider(),
                builder: (context, child) {
                  return _content(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() => const Text(
        'EXCHANGE RATES',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _subTitle() => Text("Subtitle");

  Widget _content(BuildContext context) {
    final provider = Provider.of<ExchangeRatesProvider>(context, listen: true);
    final resources = provider.resources;
    if (resources is Loading) {
      return const CupertinoActivityIndicator(
        animating: true,
      );
    } else if (resources is Success<Data>) {
      final value = resources.value;
      final symbols = value.symbols;
      final from = value.from;
      final to = value.to;
      final amount = value.amount;
      final result = value.result;
      if (_textEditingControllerOne.text.isEmpty) {
        _textEditingControllerOne.text = "$amount";
      }
      if (_textEditingControllerTwo.text.isEmpty) {
        _textEditingControllerTwo.text = "$result";
      }
      return Column(
        children: [
          Text("$amount ${from.currency} equals"),
          Text("$result ${to.currency}"),
          _input(
            context: context,
            items: symbols,
            textEditingController: _textEditingControllerOne,
            dropDownValue: from,
            onDropDownChange: (value) {
              final amount = _textEditingControllerOne.text;
              provider.convert(value, to, amount);
            },
            onTextChange: (value) {
              final amount = double.tryParse(value);
              if (amount != null) {
                _textEditingControllerTwo.text = "";
                provider.calculate(from, to, amount);
              }
            },
          ),
          _input(
            context: context,
            items: symbols,
            textEditingController: _textEditingControllerTwo,
            dropDownValue: to,
            onDropDownChange: (value) {
              final amount = _textEditingControllerTwo.text;
              provider.convertRevert(value, from, amount);
            },
            onTextChange: (value) {
              final amount = double.tryParse(value);
              if (amount != null) {
                _textEditingControllerOne.text = "";
                provider.calculate(to, from, amount);
              }
            },
          )
        ],
      );
    } else if (resources is Error) {
      return Text(resources.value.toString());
    }
    throw Exception();
  }

  Widget _input({
    required BuildContext context,
    TextEditingController? textEditingController,
    required List<SymbolResponse> items,
    required SymbolResponse dropDownValue,
    OnDropDownChange? onDropDownChange,
    OnTextChange? onTextChange,
  }) {
    return Container(
      // margin: EdgeInsets.only(
      //   left: marginLeft,
      //   right: marginRight,
      //   top: marginTop,
      //   bottom: marginBottom,
      // ),
      // padding: const EdgeInsets.only(
      //   left: 8,
      //   right: 1,
      //   top: 0,
      //   bottom: 0,
      // ),
      // width: width - marginLeft - marginRight,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          // color: color,
        ),
        // borderRadius: BorderRadius.all(
        // Radius.circular(radius),
        // ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                    // selectionColor: color,
                    ),
              ),
              child: TextFormField(
                controller: textEditingController,
                // cursorColor: color,
                decoration: const InputDecoration(
                  hintText: ' e.g 100',
                  border: InputBorder.none,
                ),
                onChanged: onTextChange,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              // focusColor: color.withOpacity(0.1),
              alignment: Alignment.centerRight,
              value: dropDownValue,
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.code,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value is SymbolResponse) {
                  onDropDownChange?.call(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
