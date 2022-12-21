import "package:flutter/material.dart";
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/progress.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final String? currentUserId;

  const PrivacyPolicyPage({Key? key, this.currentUserId}) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
            titleText: "Privacy Policy", removeBackButton: false),
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
                        'What information do we collect?',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Specify the types of personal information you collect, eg names, addresses, user names, etc. You should include specific details on: how you collect data (eg when a user registers, purchases or uses your services, completes a contact form, signs up to a newsletter, etc) what specific data you collect through each of the data collection method if you collect data from third parties, you must specify categories of data and source if you process sensitive personal data or financial information, and how you handle this. You may want to provide the user with relevant definitions in relation to personal data and sensitive personal data.',
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
