import "package:flutter/material.dart";
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/progress.dart';

class TermofUsePage extends StatefulWidget {
  final String? currentUserId;

  const TermofUsePage({Key? key, this.currentUserId}) : super(key: key);

  @override
  _TermofUsePageState createState() => _TermofUsePageState();
}

class _TermofUsePageState extends State<TermofUsePage> {
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
        appBar:
            header(context, titleText: "Terms of Use", removeBackButton: false),
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
                        'Write your Terms Of Use here',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis sdnostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
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
