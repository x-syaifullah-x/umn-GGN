import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:simpleworld/models/onboarding_model.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/data/onboarding_data.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  const WalkThroughScreen({Key? key}) : super(key: key);

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController? pageController;
  int currentPage = 0;
  List<WalkThroughItemModel> pages = getWalkThroughItems();

  @override
  void initState() {
    super.initState();
    init();
    // updateusers();
  }

  Future<void> init() async {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //Uncomment to add new fields to existing users

  // updateusers() async {
  //   var collection = FirebaseFirestore.instance.collection('users');
  //   var querySnapshots = await collection.get();
  //   for (var doc in querySnapshots.docs) {
  //     await doc.reference.update({
  //       "userIsVerified": false,
  //       "credit_points": 500,
  //       "no_ads": false,
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: pageController,
              children: List.generate(pages.length, (index) {
                return Column(
                  children: [
                    Image.asset(pages[index].image!,
                        width: context.width(),
                        height: context.height() * 0.5,
                        fit: BoxFit.cover),
                    50.height,
                    Column(
                      children: [
                        Text(pages[index].title!,
                                style: boldTextStyle(size: 30),
                                textAlign: TextAlign.center)
                            .paddingOnly(left: 30, right: 30),
                        30.height,
                        Text(
                          pages[index].subTitle!,
                          textAlign: TextAlign.center,
                        ).paddingOnly(left: 30, right: 30),
                      ],
                    ),
                    16.height,
                  ],
                );
              }),
              onPageChanged: (value) {
                currentPage = value;
                setState(() {});
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                    child: Text('Skip', style: boldTextStyle(color: grey)),
                  ),
                  DotIndicator(
                    pages: pages,
                    pageController: pageController!,
                    indicatorColor: Theme.of(context).primaryColor,
                  ),
                  AppButton(
                    child: currentPage != 3
                        ? const Icon(Icons.navigate_next, color: white, size: 30)
                        : Text('Get Started', style: boldTextStyle(color: white)),
                    color: Theme.of(context).primaryColor,
                    onTap: () async {
                      if (currentPage != 3) {
                        pageController!.animateToPage(++currentPage,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.bounceInOut);
                      } else {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
