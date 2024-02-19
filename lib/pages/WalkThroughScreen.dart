import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/data/onboarding_data.dart';
import 'package:global_net/models/onboarding_model.dart';
import 'package:global_net/pages/auth/login_page.dart';

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
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        onNotification: ((notification) {
          return true;
        }),
        child: SafeArea(child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double a = (width > 750) ? (width / 5) : 0;
    final bool isLastPage = currentPage == pages.length - 1;

    return Stack(
      children: [
        PageView(
          controller: pageController,
          children: List.generate(pages.length, (index) {
            return Container(
              padding: EdgeInsets.only(left: a, right: a),
              child: Column(
                children: [
                  Image.asset(
                    pages[index].image!,
                    width: context.width(),
                    height: context.height() * 0.5,
                    fit: context.isDesktop() ? BoxFit.fill : BoxFit.cover,
                  ),
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
              ),
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
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: Text('Skip', style: boldTextStyle(color: grey)),
              ),
              DotIndicator(
                pages: pages,
                pageController: pageController!,
                indicatorColor: Theme.of(context).primaryColor,
              ),
              AppButton(
                color: Theme.of(context).primaryColor,
                onTap: () async {
                  if (isLastPage) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  } else {
                    pageController?.animateToPage(
                      ++currentPage,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.bounceInOut,
                    );
                  }
                },
                child: isLastPage
                    ? Text(
                        'Get Started',
                        style: boldTextStyle(color: white),
                      )
                    : const Icon(
                        Icons.navigate_next,
                        color: white,
                        size: 30,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
