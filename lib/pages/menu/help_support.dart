import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/menu/about_us.dart';
import 'package:global_net/pages/menu/privacy_policy.dart';
import 'package:global_net/pages/menu/we_are_hiring.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';

class HelpSupportPage extends StatefulWidget {
  final String? currentUserId;

  const HelpSupportPage({Key? key, this.currentUserId}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<HelpSupportPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            titleText: "Help & Support", removeBackButton: false),
        body: isLoading
            ? circularProgress()
            : ListView(children: [
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
                              Text('About Us',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AboutUsPage(
                                currentUserId: widget.currentUserId,
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
                            children: const <Widget>[
                              Text('Privacy Policy',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => PrivacyPolicyPage(
                                currentUserId: widget.currentUserId,
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
                            children: const <Widget>[
                              Text('WE ARE HIRING',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => WeAreHiring(
                                currentUserId: widget.currentUserId,
                              ),
                            ));
                      }),
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}
