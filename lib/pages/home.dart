import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconly/iconly.dart';
import 'package:simpleworld/data/reaction_data.dart' as Reaction;
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/activity_feed.dart';
import 'package:simpleworld/pages/menu/settings.dart';
import 'package:simpleworld/pages/new_timeline.dart';
import 'package:simpleworld/pages/profile.dart';
import 'package:simpleworld/pages/search.dart';
import 'package:simpleworld/pages/users.dart';
import 'package:simpleworld/widgets/circle_button.dart';
import 'package:simpleworld/widgets/count/feeds_count.dart';
import 'package:simpleworld/widgets/count/messages_count.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

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
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
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
    getUserData();
    getAllUsers();
    getAllStories();

    _tabController = TabController(vsync: this, length: 5);
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

  getAllStories() async {
    QuerySnapshot<Map<String, dynamic>> doc = await storiesRef.get();
    print('storiess');
    // print(doc.s);
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
    print(snapshot.docs);
    List<GloabalUser> users = snapshot.docs
        .map((doc) => GloabalUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    setState(() {
      this.users = users;
    });
  }

  getUserData() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      usersRef.doc(user.uid).get().then((peerData) {
        if (peerData.exists) {
          if (mounted) {
            setState(() {
              globalID = user.uid;
              globalName = peerData['username'];
              globalImage = peerData['photoUrl'];
              globalBio = peerData['bio'];
              globalCover = peerData['coverUrl'];
              globalDisplayName = peerData['displayName'];
              globalCredits = 0.0.toString();
            });
          }
        }
      });
    }
  }

  AnimatedTheme buildAuthScreen() {
    final mode = AdaptiveTheme.of(context).mode;

    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
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
                    'Global  Net',
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // LanguagePickerWidget(),
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
              currentUserId: widget.userId,
            ),
          ],
          elevation: 0.0,
          bottom: TabBar(
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
                userId: widget.userId,
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
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            NewTimeline(
              UserId: widget.userId,
              reactions: Reaction.reactions,
            ),
            UsersList(userId: widget.userId),
            Profile(
              profileId: widget.userId,
              reactions: Reaction.reactions,
            ),
            const ActivityFeed(),
            SettingsPage(currentUserId: widget.userId),
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
