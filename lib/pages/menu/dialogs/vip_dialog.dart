// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/home.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class VipDialog extends StatelessWidget {
  final String photourl;
  final int credits;
  final bool userIsVerified;
  final bool no_ads;

  const VipDialog(
      {Key? key,
      required this.photourl,
      required this.credits,
      required this.userIsVerified,
      required this.no_ads})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    print(credits.toString());
    print('credits');

    getVerifiedBadge() {
      bool noCredit = credits < 1500;
      if (noCredit) {
        simpleworldtoast(
            "Error",
            "Does not have enough credits, please get more then 1500 credits",
            context);
      } else {
        usersRef.doc(globalID).update({
          "credit_points": FieldValue.increment(-1500),
          'userIsVerified': true,
        });
        simpleworldtoast("Purchase Successful",
            "Congratulations!, You have got the verified Badge", context);
      }
    }

    getNoAds() {
      bool noCredit = credits < 600;
      if (noCredit) {
        simpleworldtoast(
            "Error",
            "Does not have enough credits, please get more then 600 credits",
            context);
      } else {
        usersRef.doc(globalID).update({
          "credit_points": FieldValue.increment(-600),
          'no_ads': true,
        });
        simpleworldtoast("Purchase Successful",
            "Congratulations!, You Won't see any more ADS", context);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      /// User image
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.store),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("Store",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: photourl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: photourl,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF003a54),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Image.asset(
                                  'assets/images/defaultavatar.png',
                                  width: 40,
                                ),
                              ),
                        title: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Hello ',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    textAlign: TextAlign.center),
                                Text(globalName!,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                            const Text(
                                '"With your Credits get the benefits below."',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                      icon: const Icon(Icons.cancel,
                          color: Colors.white, size: 35),
                      onPressed: () {
                        /// Close Dialog
                        Navigator.of(context).pop();
                      }),
                )
              ],
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Benefits",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),

                  const Divider(height: 10, thickness: 1),

                  /// Verified account badge
                  userIsVerified == false
                      ? Column(
                          children: [
                            ListTile(
                              leading: Image.asset(
                                  'assets/images/verified_badge.png',
                                  width: 40,
                                  height: 40),
                              title: const Text('verified_account_badge',
                                  style: TextStyle(fontSize: 18)),
                              subtitle: const Text(
                                'let_other_users_know_that_you_are_a_real_person',
                              ),
                              trailing: TextButton(
                                  child: Column(
                                    children: const [
                                      Text('Buy'),
                                      Text(
                                        '(1500 Credits)',
                                        style: TextStyle(fontSize: 11),
                                      )
                                    ],
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    primary: Colors.white,
                                  ),
                                  onPressed: () => getVerifiedBadge()),
                            ),
                            const Divider(height: 10, thickness: 1),
                          ],
                        )
                      : Container(),

                  /// No Ads
                  no_ads == false
                      ? Column(
                          children: [
                            ListTile(
                              leading: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.block, color: Colors.white),
                              ),
                              title: const Text('no_ads',
                                  style: TextStyle(fontSize: 18)),
                              subtitle: const Text('have_a_unique_experience'),
                              trailing: TextButton(
                                  child: Column(
                                    children: const [
                                      Text('Buy'),
                                      Text(
                                        '(600 Credits)',
                                        style: TextStyle(fontSize: 11),
                                      )
                                    ],
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    primary: Colors.white,
                                  ),
                                  onPressed: () => getNoAds()),
                            ),
                            const Divider(height: 10, thickness: 1),
                          ],
                        )
                      : Container(),

                  const SizedBox(height: 15)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
