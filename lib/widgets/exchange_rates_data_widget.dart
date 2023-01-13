import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/repository/convert_response.dart';
import 'package:global_net/data/repository/exchange_rates_data.dart';
import 'package:global_net/data/repository/symbols_response.dart';
import 'package:intl/intl.dart';

class ExchangeratesDataWidget extends StatefulWidget {
  final double widthParent;

  const ExchangeratesDataWidget({
    Key? key,
    required this.widthParent,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

typedef OnDropDownChange = Function(SymbolsResponse);
typedef OnTextChange = Function(String);

class _State extends State<ExchangeratesDataWidget> {
  final TextEditingController textEditController = TextEditingController();

  late Future<List<SymbolsResponse>> _symbls;
  late SymbolsResponse _dropDownValueOne;
  late SymbolsResponse _dropDownValueTwo;
  late String date;
  late double rate;

  final TextEditingController _textEditingControllerOne =
      TextEditingController();
  final TextEditingController _textEditingControllerTwo =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _symbls = _getSymbols();
  }

  Future<List<SymbolsResponse>> _getSymbols() async {
    final ExchangeratesRepository repo = ExchangeratesRepository.instance;
    final List<SymbolsResponse> resultSymbols = await repo.getSymbols();
    _dropDownValueOne =
        resultSymbols.firstWhere((element) => element.key == "USD");
    _dropDownValueTwo =
        resultSymbols.firstWhere((element) => element.key == "CNY");
    String amount = "1";
    _textEditingControllerOne.text = amount;
    final ConvertResponse resultConvert = await repo.convert(
      from: _dropDownValueOne.key,
      to: _dropDownValueTwo.key,
      amount: amount,
    );
    _textEditingControllerTwo.text = "${resultConvert.result}";
    rate = resultConvert.rate;
    date = _dateFormat(resultConvert.timestamp);
    return resultSymbols;
  }

  String _dateFormat(int timestamp) {
    return DateFormat('MMM d, kk:mm a UTC').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _symbls,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container(
                width: widget.widthParent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: CupertinoActivityIndicator(
                  animating: true,
                  radius: widget.widthParent * 0.05,
                ),
              );
            default:
              if (snapshot.hasError) {
                return _error(widget.widthParent, '${snapshot.error}');
              }

              final List<SymbolsResponse> result =
                  snapshot.data as List<SymbolsResponse>;
              const double cardMargin = 6;
              final double cardWidth = widget.widthParent - (cardMargin * 2);
              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(cardMargin),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _title(),
                        Container(
                          width: cardWidth - 25,
                          margin: EdgeInsets.only(left: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _textEditingControllerOne.text +
                                    " " +
                                    _dropDownValueOne.value +
                                    " equals",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                _textEditingControllerTwo.text +
                                    " " +
                                    _dropDownValueTwo.value,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        _date(width: cardWidth - 25, value: date),
                        _input(
                          width: cardWidth,
                          marginTop: 6,
                          dropDownValue: _dropDownValueOne,
                          items: result,
                          textEditingController: _textEditingControllerOne,
                          onDropDownChange: (value) {
                            if (value == _dropDownValueOne) return;
                            final convert =
                                ExchangeratesRepository.instance.convert(
                              from: value.key,
                              to: _dropDownValueTwo.key,
                              amount: _textEditingControllerOne.text,
                            );
                            convert.then((response) {
                              setState(() {
                                _dropDownValueOne = value;
                                rate = response.rate;
                                date = _dateFormat(response.timestamp);
                                _textEditingControllerTwo.text =
                                    "${response.result}";
                              });
                            });
                          },
                          onTextChange: (value) {
                            try {
                              setState(() {
                                _textEditingControllerTwo.text =
                                    "${double.parse(value) * rate}";
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                        _input(
                          width: cardWidth,
                          marginBottom: 16,
                          dropDownValue: _dropDownValueTwo,
                          items: result,
                          textEditingController: _textEditingControllerTwo,
                          onDropDownChange: (value) {
                            if (value == _dropDownValueTwo) return;
                            final amount = _textEditingControllerTwo.text;
                            final convert =
                                ExchangeratesRepository.instance.convert(
                              from: value.key,
                              to: _dropDownValueOne.key,
                              amount: amount,
                            );
                            convert.then((response) {
                              try {
                                _dropDownValueTwo = value;
                                rate = double.parse(amount) / response.result;
                                date = _dateFormat(response.timestamp);
                                setState(() {
                                  _textEditingControllerOne.text =
                                      "${response.result}";
                                });
                              } catch (e) {}
                            });
                          },
                          onTextChange: (value) {
                            try {
                              setState(() {
                                _textEditingControllerOne.text =
                                    "${double.parse(value) / rate}";
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
          }
        });
  }

  Widget _error(double width, String message) {
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
                onPressed: () {
                  setState(() {
                    _symbls = _getSymbols();
                  });
                },
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

  Widget _date({
    required String value,
    required double width,
    TextAlign align = TextAlign.start,
    double fontSize = 12,
    EdgeInsets margin = const EdgeInsets.only(top: 10),
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Container(
      width: width - margin.left - margin.right - margin.bottom - margin.top,
      margin: margin,
      padding: padding,
      child: Text(
        // "Jan 11, 11:18 PM UTC",
        value,
        textAlign: align,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _input({
    required width,
    required SymbolsResponse dropDownValue,
    required List<SymbolsResponse> items,
    TextEditingController? textEditingController,
    OnDropDownChange? onDropDownChange,
    OnTextChange? onTextChange,
    double marginLeft = 8,
    double marginTop = 4.0,
    double marginRight = 8,
    double marginBottom = 4.0,
    double radius = 8.0,
  }) {
    final Color color = Colors.grey.withOpacity(0.6);
    return Container(
      margin: EdgeInsets.only(
        left: marginLeft,
        right: marginRight,
        top: marginTop,
        bottom: marginBottom,
      ),
      padding: const EdgeInsets.only(
        left: 8,
        right: 1,
        top: 0,
        bottom: 0,
      ),
      width: width - marginLeft - marginRight,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: color,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(radius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                cursorColor: color,
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
              focusColor: color.withOpacity(0.1),
              alignment: Alignment.centerRight,
              value: dropDownValue,
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.key,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value is SymbolsResponse) {
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
