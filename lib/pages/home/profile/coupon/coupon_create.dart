import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/main.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class CouponCreate extends StatefulWidget {
  final User user;
  final bool isAppBarEnable;

  const CouponCreate({
    Key? key,
    required this.user,
    this.isAppBarEnable = true,
  }) : super(key: key);

  @override
  State<CouponCreate> createState() => _CouponCreateState();
}

class _CouponCreateState extends State<CouponCreate> {
  final _inputNameController = TextEditingController();
  final _inputCreditController = TextEditingController();
  String _usd = '0.00';
  String? _errorMessageInputName;
  String? _errorMessageInputCredits;
  bool _isCreateCoupon = false;

  @override
  Widget build(BuildContext context) {
    final userId = widget.user.id;
    final isAppBarEnable = widget.isAppBarEnable;
    int creditPoints = widget.user.creditPoints;

    return SafeArea(
      child: Scaffold(
        appBar: isAppBarEnable ? _appbar(context) : null,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Credits:\t',
                        style: GoogleFonts.portLligatSans(
                          textStyle: Theme.of(context).textTheme.headlineMedium,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: usersCollection.doc(userId).snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data();
                          if (data == null) {
                            return const CupertinoActivityIndicator();
                          }
                          final newCreditPoints =
                              data[User.fieldNameCreditPoints];
                          creditPoints = newCreditPoints;
                          return Text(
                            '$newCreditPoints',
                            style: GoogleFonts.portLligatSans(
                              textStyle:
                                  Theme.of(context).textTheme.headlineMedium,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Coupon Name',
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextField(
                    controller: _inputNameController
                      ..addListener(() {
                        if (!_errorMessageInputName.isEmptyOrNull) {
                          setState(() {
                            _errorMessageInputName = null;
                          });
                        }
                      }),
                    decoration: InputDecoration(
                      hintText: 'Enter the name of the coupon',
                      errorText: _errorMessageInputName,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Credits',
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextField(
                    controller: _inputCreditController
                      ..addListener(() {
                        if (!_errorMessageInputCredits.isEmptyOrNull) {
                          setState(() {
                            _errorMessageInputCredits = null;
                          });
                        }
                        final input = _inputCreditController.text;
                        if (input.isEmpty) {
                          setState(() {
                            _usd = '0.00';
                          });
                        } else if (input.isNotEmpty && input[0] == '0') {
                          _inputCreditController.clear();
                        } else if (_inputCreditController.text.toInt() >
                            creditPoints) {
                          setState(() {
                            _errorMessageInputCredits =
                                'Credits are not enough';
                          });
                        } else {
                          setState(() {
                            final usd =
                                _inputCreditController.text.toInt() / 100;
                            _usd = usd.toStringAsFixed(2);
                          });
                        }
                      }),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter the amount of credits you want to use',
                      errorText: _errorMessageInputCredits,
                      suffix: GestureDetector(
                        onTap: () {
                          _inputCreditController.text = '$creditPoints';
                        },
                        child: Text(
                          'Max',
                          style: GoogleFonts.portLligatSans(
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'USD \$$_usd',
                          style: GoogleFonts.portLligatSans(
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  createButton(userId: userId)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createButton({required String userId}) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .5,
        child: _isCreateCoupon
            ? const CupertinoActivityIndicator()
            : ElevatedButton(
                onPressed: () async {
                  final inputName = _inputNameController.text;
                  if (inputName.isEmptyOrNull) {
                    setState(() {
                      _errorMessageInputName =
                          'Please enter the name of the coupon';
                    });
                    return;
                  }
                  final inputCreditPoints = _inputCreditController.text;
                  if (inputCreditPoints.isEmptyOrNull) {
                    setState(() {
                      _errorMessageInputCredits =
                          'Please enter the number of credits';
                    });
                    return;
                  }

                  if (!_errorMessageInputName.isEmptyOrNull) {
                    return;
                  }

                  if (!_errorMessageInputCredits.isEmptyOrNull) {
                    return;
                  }

                  try {
                    setState(() {
                      _isCreateCoupon = true;
                    });
                    final uri = useEmulator
                        ? Uri.http(
                            host,
                            '/globelgirl-2c269/us-central1/stripe/coupon/create',
                          )
                        : Uri.https(
                            'us-central1-globelgirl-2c269.cloudfunctions.net',
                            '/stripe/coupon/create',
                          );
                    final response = await http.post(
                      uri,
                      body: {
                        'user_id': userId,
                        'name': inputName,
                        User.fieldNameCreditPoints:
                            '${inputCreditPoints.toInt()}',
                      },
                    );

                    final statusCode = response.statusCode;
                    final body = jsonDecode(response.body);
                    if (statusCode == 200 || statusCode < 300) {
                      _inputCreditController.clear();
                      toast('Coupon created');
                    } else {
                      toast('${body['message']}');
                    }
                  } catch (e) {
                    toast('$e');
                  } finally {
                    setState(() {
                      _isCreateCoupon = false;
                    });
                  }
                },
                child: Text(
                  'Create Coupon',
                  style: GoogleFonts.portLligatSans(
                    textStyle: Theme.of(context).textTheme.headlineMedium,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).shadowColor,
          width: 1,
        ),
      ),
      title: Text(
        'Create Coupon',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
