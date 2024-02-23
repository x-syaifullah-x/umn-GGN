import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/user.dart';
import '../v2/news/presentation/app_web_view.dart';

class Payments extends StatefulWidget {
  final User user;

  const Payments({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  int _selectedOption = 0;

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
                  "Buy Credits",
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
                      // color: Colors.white,
                      // border: Border(
                      //   left: BorderSide(
                      //     color: Colors.green,
                      //     width: 3,
                      //   ),
                      // ),
                      // boxShadow: const [
                      //   BoxShadow(color: Colors.blueGrey, spreadRadius: 1),
                      // ],
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
                        stream: firestore.collection("payments").snapshots(),
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
                                    final price = doc?['price'];
                                    final creditPoint = doc?['credit_points'];
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$creditPoint Credits",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "$price",
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
                                Container(
                                  width: finalWidth * .65,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final String? url =
                                          docs?[_selectedOption]['url'];
                                      if (url == null) return;
                                      final user = widget.user;
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
                                    child: const Text("Pay"),
                                  ),
                                )
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
