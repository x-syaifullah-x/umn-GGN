import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/group_chat_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/pages/comming_soon_page.dart';
import 'package:google_fonts/google_fonts.dart';

class Groups extends StatefulWidget {
  final String userId;
  const Groups({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController pageController = PageController(initialPage: 0);
  int pageIndex = 0;
  late TabController _tabController;

  bool isFollowing = false;

  bool showElevatedButtonBadge = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shape: Border(
            bottom: BorderSide(
              color: Theme.of(context).shadowColor,
              width: 1.0,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)?.group ?? '',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
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
                text: 'Chat With Groups',
              ),
              Tab(
                text: 'Groups With Lossons',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            GroupChatList(userId: widget.userId),
            const CommimgSoon(),
          ],
        ),
      ),
    );
  }
}
