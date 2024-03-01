import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class Coupons extends StatefulWidget {
  final User _user;
  final Function? _onAddCoupon;

  const Coupons({
    Key? key,
    required User user,
    Function? onAddCoupon,
  })  : _onAddCoupon = onAddCoupon,
        _user = user,
        super(key: key);

  @override
  State<Coupons> createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> {
  @override
  Widget build(BuildContext context) {
    final user = widget._user;
    final collectionRef =
        firestore.collection('stripe').doc('coupons').collection(user.id);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collectionRef
          .orderBy(
            'coupon.created',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        final state = snapshot.connectionState;
        if (state == ConnectionState.waiting) {
          return const CupertinoActivityIndicator();
        }

        final docs = snapshot.data?.docs ?? [];
        final docsLength = docs.length;
        // final docsLength = 0;
        return docsLength == 0
            ? Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'There are no coupon in this list',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.portLligatSans(
                        textStyle: Theme.of(context).textTheme.headlineMedium,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget._onAddCoupon != null)
                      ElevatedButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 24),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Create Coupon',
                              style: GoogleFonts.portLligatSans(
                                color: Colors.white,
                                textStyle:
                                    Theme.of(context).textTheme.headlineMedium,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        onPressed: () {
                          widget._onAddCoupon?.call();
                        },
                      )
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: docsLength,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final docId = doc.id;
                        final coupon = doc['coupon'];
                        final couponId = coupon['id'];
                        final name = coupon['name'];
                        final amountOff = coupon['amount_off'];
                        final currency = coupon['currency'];
                        final created = coupon['created'];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$name'.capitalize(),
                                  style: GoogleFonts.portLligatSans(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'COUPON: $couponId',
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text('Credit Points: $amountOff'),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${currency.toString().toUpperCase()} \$${amountOff / 100}',
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Created ${DateTime.fromMillisecondsSinceEpoch(created * 1000)}',
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await Clipboard.setData(
                                            ClipboardData(
                                              text: couponId,
                                            ),
                                          );
                                          toast(
                                            'Coupon has been successfully copied',
                                          );
                                        } catch (e) {
                                          log('$e');
                                        }
                                      },
                                      child: const Text('Copy Coupon'),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        collectionRef.doc(docId).delete();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget._onAddCoupon != null)
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .8,
                        child: ElevatedButton(
                          onPressed: () {
                            widget._onAddCoupon?.call();
                          },
                          child: const Text('Create Coupon'),
                        ),
                      ),
                    )
                ],
              );
      },
    );
  }
}
