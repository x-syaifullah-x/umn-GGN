import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/hire_chat_list.dart';
import 'package:global_net/pages/menu/about_us.dart';
import 'package:global_net/pages/menu/privacy_policy.dart';
import 'package:global_net/pages/menu/we_are_hiring.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  final String userId;

  const HelpSupportPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<HelpSupportPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            titleText: 'Help & Support', removeBackButton: false),
        body: isLoading
            ? circularProgress()
            : ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1 - 40,
                            height: 50.0,
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Text(
                                  'About Us',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ).onTap(() {
                          launchUrl(Uri.parse('https://youtu.be/3g2KUTL_6Gs'));
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //       builder: (context) => AboutUsPage(
                          //         currentUserId: widget.userId,
                          //       ),
                          //     ));
                        }),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1 - 40,
                            height: 50.0,
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ).onTap(() {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => PrivacyPolicyPage(
                                  currentUserId: widget.userId,
                                ),
                              ));
                        }),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1 - 40,
                            height: 50.0,
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'WE ARE HIRING',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ).onTap(() {
                          // Navigator.push(
                          //     context,
                          //     CupertinoPageRoute(
                          //       builder: (context) => HireChatList(
                          //         userId: widget.userId,
                          //       ),
                          //     ));
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => WeAreHiring(
                                  currentUserId: widget.userId,
                                ),
                              ));
                        }),
                        4.height,
                        Image.asset(
                          'assets/images/customersr.webp',
                          height: MediaQuery.of(context).size.height * .55,
                          width: MediaQuery.of(context).size.width * .8,
                          fit: BoxFit.fill,
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
