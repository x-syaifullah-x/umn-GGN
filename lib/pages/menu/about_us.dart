import "package:flutter/material.dart";
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutUsPage extends StatefulWidget {
  final String? currentUserId;

  const AboutUsPage({Key? key, this.currentUserId}) : super(key: key);

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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
            titleText: AppLocalizations.of(context)!.about_us,
            removeBackButton: false),
        body: isLoading
            ? circularProgress()
            : ListView(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Write about your website here.',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}
