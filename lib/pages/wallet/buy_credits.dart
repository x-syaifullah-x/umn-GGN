import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/v2/news/presentation/app_web_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyCredits extends StatefulWidget {
  final User user;

  const BuyCredits({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<BuyCredits> createState() => _BuyCreditsState();
}

class _BuyCreditsState extends State<BuyCredits> {
  int _selectedOption = 0;
  bool _isCheck = false;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isLarge = width > 650;
    final double finalWidth = isLarge ? 500 : width;
    return SafeArea(
      child: AnimatedTheme(
        duration: const Duration(milliseconds: 100),
        data: Theme.of(context),
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: Container(
                margin: const EdgeInsets.all(18),
                child: const Text(
                  'Buy Credits',
                  style: TextStyle(
                    // color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(8),
              height:
                  isLarge ? (MediaQuery.of(context).size.height * 0.80) : null,
              width: finalWidth,
              decoration: isLarge
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Card(
                elevation: isLarge ? 8 : 0,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Flexible(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: firestore
                            .collection('stripe')
                            .doc('payment')
                            .collection('links')
                            .orderBy('metadata.order_id')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: CupertinoActivityIndicator(),
                            );
                          }
                          final docs = snapshot.data?.docs;
                          final datLength = docs?.length ?? 0;
                          return Column(
                            children: [
                              Flexible(
                                child: ListView.builder(
                                  itemCount: datLength,
                                  itemBuilder: (context, index) {
                                    final doc = docs?[index];
                                    final metadata = doc?['metadata'] ?? {};
                                    final price =
                                        (int.parse(metadata['price']) / 100)
                                            .toStringAsFixed(2);
                                    final name = metadata['name'];
                                    if (datLength - 1 == index) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '\$$price',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            leading: Radio(
                                              value: index,
                                              groupValue: _selectedOption,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedOption =
                                                      value as int;
                                                });
                                              },
                                            ),
                                          ),
                                          35.height,
                                          SizedBox(
                                            height: 280,
                                            width: 300,
                                            child: Image.asset(
                                              'assets/images/buy_credit_1.png',
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        ],
                                      );
                                    }
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '\$$price',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      leading: Radio(
                                        value: index,
                                        groupValue: _selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption = value as int;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (datLength > 0)
                                Column(
                                  children: const [
                                    SizedBox(
                                      height: 12,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              if (datLength > 0)
                                SizedBox(
                                  width: finalWidth * .65,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!_isCheck) {
                                        setState(() {
                                          _isError = true;
                                        });
                                        return;
                                      }
                                      final user = widget.user;
                                      final a = docs?[_selectedOption]['url'];
                                      if (a == null) return;
                                      final String url =
                                          '$a?client_reference_id=${user.id}';
                                      if (kIsWeb) {
                                        launchUrl(Uri.parse(url));
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return AppWebView(
                                              url: url,
                                              title: 'Pay',
                                            );
                                          }),
                                        ).then((value) {
                                          usersCollection
                                              .doc(user.id)
                                              .get()
                                              .then((value) {
                                            final oldCredit = user.creditPoints;
                                            final newCredit = value[
                                                User.fieldNameCreditPoints];
                                            final bool isPurchased =
                                                newCredit > oldCredit;
                                            if (isPurchased) {
                                              Navigator.of(context).pop();
                                            }
                                          });
                                        });
                                      }
                                    },
                                    child: const Text('Pay'),
                                  ),
                                ),
                              if (datLength > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24.0,
                                      width: 24.0,
                                      child: Checkbox(
                                        value: _isCheck,
                                        onChanged: (v) {
                                          setState(() {
                                            _isCheck = v as bool;
                                            if (v) {
                                              if (_isError) {
                                                _isError = false;
                                              }
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        const String url =
                                            'https://docs.google.com/document/d/e/2PACX-1vSVsg1yyLr-VC9yJ04vB-BtVoo3TGGrL8PRGzXgbb6QOaiZBiV9WLOKRuTlDzSUEgr_xOXVhax-_T2X/pub';
                                        if (kIsWeb) {
                                          launchUrl(Uri.parse(url));
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return const AppWebView(
                                                url: url,
                                                title: 'Terms and Condition',
                                              );
                                            }),
                                          );
                                        }
                                      },
                                      child: const Text('Terms and Condition'),
                                    )
                                  ],
                                ),
                              if (datLength > 0 && _isError)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: const Text(
                                    'Please accept the Terms and Conditions to pay',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
