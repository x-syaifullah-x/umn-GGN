import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/group_chat_list.dart';
import 'package:global_net/pages/menu/all_stories.dart';
import 'package:global_net/pages/chat/simpleworld_messenger.dart';

class SimpleWorldChat extends StatefulWidget {
  final String userId;

  const SimpleWorldChat({Key? key, required this.userId}) : super(key: key);

  @override
  SimpleWorldChatState createState() => SimpleWorldChatState();
}

class SimpleWorldChatState extends State<SimpleWorldChat>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController pageController = PageController(initialPage: 0);
  int pageIndex = 0;
  late TabController _tabController;

  bool isFollowing = false;

  bool showElevatedButtonBadge = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    FirebaseMessaging.instance.getInitialMessage().then((message) {});
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  AnimatedTheme buildAuthScreen() {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          automaticallyImplyLeading: true,
          shape: Border(
            bottom: BorderSide(
              color: Theme.of(context).shadowColor,
              width: 1.0,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Chats',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                ],
              ),
            ],
          ),
          elevation: 0.0,
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 4.0, color: Colors.red.shade800),
            ),
            controller: _tabController,
            unselectedLabelColor:
                Theme.of(context).tabBarTheme.unselectedLabelColor,
            labelColor: Theme.of(context).tabBarTheme.labelColor,
            tabs: const [
              Tab(
                text: 'Chats',
              ),
              Tab(
                text: 'Groups',
              ),
              Tab(
                text: 'Stories',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Messenger(
              userId: widget.userId!,
            ),
            GroupChatList(
              userId: widget.userId,
            ),
            AllStories(
              showappbar: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildAuthScreen();
  }
}
