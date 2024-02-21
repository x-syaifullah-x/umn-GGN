// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/comming_soon_page.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class VipDialog extends StatelessWidget {
  final User user;

  const VipDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  static const _noAdsCredit = 600;
  static const _verifyBadgeCredit = 1500;

  @override
  Widget build(BuildContext context) {
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
                        child: Text(
                          "Store",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: user.photoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: user.photoUrl,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "With your Credits get the benefits below.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Benefits",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                const Divider(height: 10, thickness: 1),

                if (!user.userIsVerified)
                  Column(
                    children: [
                      ListTile(
                        leading: Image.asset('assets/images/verified_badge.png',
                            width: 40, height: 40),
                        title: const Text('verified_account_badge',
                            style: TextStyle(fontSize: 18)),
                        subtitle: const Text(
                          'let_other_users_know_that_you_are_a_real_person',
                        ),
                        trailing: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              primary: Colors.white,
                            ),
                            onPressed: () => _getVerifiedBadge(context, user),
                            child: Column(
                              children: const [
                                Text('Buy'),
                                Text(
                                  '($_verifyBadgeCredit Credits)',
                                  style: TextStyle(fontSize: 11),
                                )
                              ],
                            )),
                      ),
                      const Divider(height: 10, thickness: 1),
                    ],
                  ),

                /// No Ads
                if (!user.noAds)
                  Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.block, color: Colors.white),
                        ),
                        title: const Text(
                          'no_ads',
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: const Text('have_a_unique_experience'),
                        trailing: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              primary: Colors.white,
                            ),
                            onPressed: () => _getNoAds(context, user),
                            child: Column(
                              children: const [
                                Text('Buy'),
                                Text(
                                  '($_noAdsCredit Credits)',
                                  style: TextStyle(fontSize: 11),
                                )
                              ],
                            )),
                      ),
                      const Divider(height: 10, thickness: 1),
                    ],
                  ),

                const SizedBox(height: 15),

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CommimgSoon(),
                        ));
                      },
                      child: const Text("BUY CREDIT"),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _getVerifiedBadge(BuildContext context, User user) {
    bool noCredit = user.creditPoints < _verifyBadgeCredit;
    if (noCredit) {
      simpleworldtoast(
        "Error",
        "Does not have enough credits, please get more then $_verifyBadgeCredit credits",
        context,
      );
    } else {
      usersCollection.doc(user.id).update({
        "credit_points": FieldValue.increment(-_verifyBadgeCredit),
        'userIsVerified': true,
      }).then((value) {
        Navigator.of(context).pop();
        simpleworldtoast(
          "Purchase Successful",
          "Congratulations!, You have got the verified Badge",
          context,
        );
      });
    }
  }

  void _getNoAds(BuildContext context, User user) {
    bool noCredit = user.creditPoints < _noAdsCredit;
    if (noCredit) {
      simpleworldtoast(
        "Error",
        "Does not have enough credits, please get more then $_noAdsCredit credits",
        context,
      );
    } else {
      usersCollection.doc(user.id).update({
        "credit_points": FieldValue.increment(-_noAdsCredit),
        'no_ads': true,
      }).then((value) {
        Navigator.of(context).pop();
        simpleworldtoast(
          "Purchase Successful",
          "Congratulations!, You Won't see any more ADS",
          context,
        );
      });
    }
  }
}
