import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:global_net/ads/a.dart';
import 'package:global_net/widgets/anchored_adaptive_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconly/iconly.dart';
import 'package:global_net/data/reaction_data.dart' as reaction;
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/activity_feed.dart';
import 'package:global_net/pages/menu/settings.dart';
import 'package:global_net/pages/new_timeline.dart';
import 'package:global_net/pages/profile.dart';
import 'package:global_net/pages/search.dart';
import 'package:global_net/pages/users.dart';
import 'package:global_net/widgets/circle_button.dart';
import 'package:global_net/widgets/count/feeds_count.dart';
import 'package:global_net/widgets/count/messages_count.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final likedRef = FirebaseFirestore.instance.collection('likedpp');
final dislikedRef = FirebaseFirestore.instance.collection('dislikedpp');
final ppviewsRef = FirebaseFirestore.instance.collection('ppviews');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final msgRef = FirebaseFirestore.instance.collection('messages');
final messengerRef = FirebaseFirestore.instance.collection('messenger');
final groupsRef = FirebaseFirestore.instance.collection('groups');
final storiesRef = FirebaseFirestore.instance.collection('stories');
final reportsRef = FirebaseFirestore.instance.collection('reports');
final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {
  final String? userId;

  const Home({Key? key, this.userId}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController pageController = PageController(initialPage: 0);
  int pageIndex = 0;
  late TabController _tabController;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;
  bool isFollowing = false;
  late List<GloabalUser> users;
  bool showElevatedButtonBadge = true;

  @override
  void initState() {
    super.initState();
    getAllUsers();
    getAllStories();

    _tabController = TabController(vsync: this, length: 5);
    FirebaseMessaging.instance.getInitialMessage().then((message) {});
    _tabController.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = widget.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception("need user id");
    }
    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        return NotificationListener(
          child: AnimatedTheme(
            duration: const Duration(milliseconds: 300),
            data: Theme.of(context),
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              key: _scaffoldKey,
              appBar: _appBar(context, userId),
              body: _body(context, userId, _tabController),
            ),
          ),
        );
      },
    );
  }

  getUserData() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final peerData = await usersRef.doc(user.uid).get();
      if (peerData.exists) {
        globalID = user.uid;
        globalName = peerData['username'];
        globalImage = peerData['photoUrl'];
        globalBio = peerData['bio'];
        globalCover = peerData['coverUrl'];
        globalDisplayName = peerData['displayName'];
        globalCredits = 0.0.toString();
      }
    }
  }

  PreferredSizeWidget _appBar(BuildContext context, String userId) {
    final AdaptiveThemeMode mode = AdaptiveTheme.of(context).mode;
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
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
                'Global Net',
                style: GoogleFonts.portLligatSans(
                  textStyle: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          alignment: Alignment.center,
          width: 40,
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              if (mode == AdaptiveThemeMode.light) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
            icon: mode == AdaptiveThemeMode.light
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
          ),
        ),
        CircleButton(
          icon: Icons.search,
          iconSize: 25.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Search()),
            );
          },
        ),
        MessagesCount(
          currentUserId: userId,
        ),
      ],
      elevation: 0.0,
      bottom: TabBar(
        // padding: EdgeInsets.only(left: a, right: a),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 4.0, color: Colors.red.shade800),
        ),
        controller: _tabController,
        unselectedLabelColor:
            Theme.of(context).tabBarTheme.unselectedLabelColor,
        labelColor: Theme.of(context).tabBarTheme.labelColor,
        tabs: [
          Tab(
            icon: _tabController.index == 0
                ? const Icon(
                    IconlyBold.home,
                    color: Color(0xFFC62828),
                  )
                : const Icon(IconlyLight.home),
          ),
          Tab(
            icon: _tabController.index == 1
                ? const Icon(
                    IconlyBold.plus,
                    color: Color(0xFFC62828),
                  )
                : const Icon(IconlyLight.plus),
          ),
          Tab(
            icon: _tabController.index == 2
                ? const Icon(
                    IconlyBold.profile,
                    color: Color(0xFFC62828),
                  )
                : const Icon(IconlyLight.profile),
          ),
          FeedsCount(
            userId: userId,
            tabController: _tabController,
          ),
          Tab(
            icon: _tabController.index == 4
                ? const Icon(
                    IconlyBold.category,
                    color: Color(0xFFC62828),
                  )
                : const Icon(IconlyLight.category),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext c, String userId, TabController tabController) {
    final Size size = MediaQuery.of(c).size;
    final double width = size.width;

    final double widthContentRight;
    final double widthContentLeft;
    bool widthMoreThan_600 = width > 600;
    if (widthMoreThan_600) {
      widthContentRight = width * 0.25;
      widthContentLeft = width * 0.25;
    } else {
      widthContentRight = 0;
      widthContentLeft = 0;
    }
    final double widthContentCenter =
        width - widthContentLeft - widthContentRight;
    final List<String> dataSideLeft = [
      AppLocalizations.of(context)!.shop,
      AppLocalizations.of(context)!.channel,
      AppLocalizations.of(context)!.email,
      AppLocalizations.of(context)!.news,
      AppLocalizations.of(context)!.iptv,
      AppLocalizations.of(context)!.chat,
      AppLocalizations.of(context)!.group,
      AppLocalizations.of(context)!.apps,
      AppLocalizations.of(context)!.go_dark,
      AppLocalizations.of(context)!.credit_lines,
      AppLocalizations.of(context)!.crow_funding,
      AppLocalizations.of(context)!.business_structure
    ];

    ScrollController scrollController = ScrollController();
    return Row(
      children: [
        if (widthMoreThan_600)
          RawScrollbar(
            controller: scrollController,
            interactive: true,
            thumbVisibility: (context.width() > 500),
            trackVisibility: (context.width() > 500),
            radius: const Radius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(10),
                //   topRight: Radius.circular(10),
                //   bottomLeft: Radius.circular(10),
                //   bottomRight: Radius.circular(10),
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 8,
                    // spreadRadius: 5,
                    // blurRadius: 7,
                    // offset: const Offset(4, 8), // changes position of shadow
                  ),
                ],
              ),
              margin: const EdgeInsets.only(right: 8),
              width: widthContentLeft - 8,
              height: double.infinity,
              child: ListView.builder(
                controller: scrollController,
                itemCount: dataSideLeft.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        dataSideLeft[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      toastLong(
                        "${dataSideLeft[index]} will be available soon",
                      );
                    },
                  );
                },
              ),
            ),
          ),
        SizedBox(
          width: widthContentCenter,
          height: double.infinity,
          child: _tabBarView(tabController, userId),
        ),
        if (widthMoreThan_600)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 8,
                  // blurRadius: 7,
                  // offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 8),
            width: widthContentRight - 8,
            height: double.infinity,
            child: const Ads(),
          ),
      ],
    );
  }

  Widget _tabBarView(TabController tabController, String userId) {
    return TabBarView(
      controller: tabController,
      children: [
        NewTimeline(
          userId: userId,
          reactions: reaction.reactions,
        ),
        UsersList(userId: userId),
        Profile(
          profileId: userId,
          reactions: reaction.reactions,
        ),
        const ActivityFeed(),
        SettingsPage(currentUserId: userId),
      ],
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  getAllStories() async {
    await storiesRef.get();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(globalID)
        .collection('userFollowers')
        .doc(globalID)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getAllUsers() async {
    QuerySnapshot snapshot =
        await usersRef.orderBy('timestamp', descending: true).get();
    List<GloabalUser> users = snapshot.docs
        .map((doc) => GloabalUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    setState(() {
      this.users = users;
    });
  }
}
