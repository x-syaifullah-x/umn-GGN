import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/wallet/search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

const transactionsFieldSender = 'sender';
const transactionsFieldReceiver = 'receiver';
const transactionsFieldCreateAt = 'createAt';
const transactionsFieldType = 'type';
const transactionsFieldAmount = 'amount';

class Transfer extends StatefulWidget {
  final String userId;
  const Transfer({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  final _inputWalletIdController = TextEditingController();
  final _inputAmountController = TextEditingController();

  final _focusNodeWalletId = FocusNode();
  final _focusNodeAmount = FocusNode();

  String? _errorMessageInputWalletId;
  String? _errorMessageInputAmount;

  bool _isSendCredit = false;

  @override
  void dispose() {
    super.dispose();
    _inputWalletIdController.dispose();
    _inputAmountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId;

    return SafeArea(
      child: Scaffold(
        appBar: _appbar(context),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  48.height,
                  Text(
                    'Wallet ID',
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: const Icon(
                          Icons.person_search_rounded,
                          size: 32,
                        ),
                        onTap: () async {
                          // final clipboardData =
                          //     await Clipboard.getData(Clipboard.kTextPlain);
                          // String? clipboardText = clipboardData?.text;
                          // _inputWalletIdController.text =
                          //     'DLx5y52DHvBC4ygYOWLNnwvfUeBw';
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const SearchUser();
                              },
                            ),
                          ).then((value) {
                            if (value.toString().contains('uid')) {
                              _inputWalletIdController.clear();
                              _inputWalletIdController.text = '${value['uid']}';
                            }
                          });
                        },
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNodeWalletId,
                          controller: _inputWalletIdController
                            ..addListener(() {
                              if (!_errorMessageInputWalletId.isEmptyOrNull) {
                                setState(() {
                                  _errorMessageInputWalletId = null;
                                });
                              }
                            }),
                          decoration: InputDecoration(
                            hintText: 'Enter wallet ID',
                            errorText: _errorMessageInputWalletId,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Amount',
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: const Icon(
                          Icons.credit_card,
                          size: 32,
                        ),
                        onTap: () async {},
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNodeAmount,
                          controller: _inputAmountController
                            ..addListener(() {
                              if (!_errorMessageInputAmount.isEmptyOrNull) {
                                setState(() {
                                  _errorMessageInputAmount = null;
                                });
                              }
                            }),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorText: _errorMessageInputAmount,
                            hintText: 'Minimum 2000 credits',
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.height,
                  Row(
                    children: [
                      40.width,
                      Text(
                        'Available',
                        style: GoogleFonts.portLligatSans(
                          textStyle: Theme.of(context).textTheme.headlineMedium,
                          fontSize: 14,
                        ),
                      ),
                      4.width,
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: usersCollection.doc(userId).snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data();
                          if (data == null) {
                            return const CupertinoActivityIndicator();
                          }
                          return Text(
                            '${User.fromJson(data).creditPoints}',
                            style: GoogleFonts.portLligatSans(
                              textStyle:
                                  Theme.of(context).textTheme.headlineMedium,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _isSendCredit
                      ? const Center(
                          child: SizedBox(
                            height: 70,
                            child: CupertinoActivityIndicator(),
                          ),
                        )
                      : _sendCreditsWidget(
                          context,
                          onPressed: () async {
                            final inputWalletId = _inputWalletIdController.text;
                            if (inputWalletId.isEmptyOrNull) {
                              setState(() {
                                _errorMessageInputWalletId =
                                    'Oops! Wallet ID is not provided. Please enter your Wallet ID to proceed.';
                                _focusNodeWalletId.requestFocus();
                              });
                              return;
                            }

                            if (inputWalletId == userId) {
                              setState(() {
                                _errorMessageInputWalletId =
                                    'Wallet ID is invalid';
                                _focusNodeWalletId.requestFocus();
                              });
                              return;
                            }
                            final inputAmount = _inputAmountController.text;
                            if (inputAmount.isEmptyOrNull) {
                              setState(() {
                                _errorMessageInputAmount =
                                    'Oops! The amount is missing. Please enter a valid credits amount.';
                                _focusNodeAmount.requestFocus();
                              });
                              return;
                            }

                            if (!inputAmount.isDigit()) {
                              setState(() {
                                _errorMessageInputAmount =
                                    'Whoops! Invalid input. Please enter a valid amount.';
                                _focusNodeAmount.requestFocus();
                              });
                              return;
                            }

                            const minimalAmount = 2000;
                            final amount = inputAmount.toInt();
                            if (amount < minimalAmount) {
                              setState(() {
                                _errorMessageInputAmount =
                                    'Oops! The entered amount is less than $minimalAmount. Please input a minimum of $minimalAmount credits.';
                                _focusNodeAmount.requestFocus();
                              });
                              return;
                            }

                            try {
                              setState(() {
                                _isSendCredit = true;
                              });
                              final userRef = usersCollection.doc(userId);
                              final userSnap = await userRef.get();
                              final user = User.fromJson(userSnap.data());
                              if (user.creditPoints < amount) {
                                _errorMessageInputAmount =
                                    'Oops! Not enough credit balance.';
                              } else {
                                await firestore
                                    .collection('wallets')
                                    .doc(userId)
                                    .collection('transactions')
                                    .add({
                                  transactionsFieldType: 'transfer',
                                  transactionsFieldAmount: amount,
                                  transactionsFieldSender: userId,
                                  transactionsFieldReceiver: inputWalletId,
                                  transactionsFieldCreateAt:
                                      DateTime.now().millisecondsSinceEpoch
                                });
                                toast('Transfer successful');
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            } catch (e) {
                              toast('$e');
                            } finally {
                              setState(() {
                                _isSendCredit = false;
                              });
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sendCreditsWidget(BuildContext context, {Function? onPressed}) {
    return Center(
      child: SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width * .7,
        child: ElevatedButton(
          onPressed: () => onPressed?.call(),
          child: const Text('Send'),
        ),
      ),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      // automaticallyImplyLeading: false,
      // shape: Border(
      //   bottom: BorderSide(
      //     color: Theme.of(context).shadowColor,
      //     width: 1,
      //   ),
      // ),
      title: Text(
        'Transfer',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
