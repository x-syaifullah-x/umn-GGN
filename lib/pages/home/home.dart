import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/data/reaction_data.dart' as reaction;
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/home/business_structure/business_structure.dart';
import 'package:global_net/pages/home/new_timeline.dart';
import 'package:global_net/pages/home/profile/profile.dart';
import 'package:global_net/pages/home/settings.dart';
import 'package:global_net/pages/home/user/users.dart';
import 'package:global_net/pages/search.dart';
import 'package:global_net/v2/news/presentation/app_web_view.dart';
import 'package:global_net/v2/news/presentation/pages/news.dart';
import 'package:global_net/widgets/circle_button.dart';
import 'package:global_net/widgets/count/feeds_count.dart';
import 'package:global_net/widgets/count/messages_count.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconly/iconly.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ads/applovin_ad_unit_id.dart';
import '../../v2/exchange_rate_new/widgets/exchange_rate_new.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

final Reference storageRef = FirebaseStorage.instance.ref();

final firestore = FirebaseFirestore.instance;
final usersCollection = firestore.collection('users');
final postsCollection = firestore.collection('posts');
final commentsCollection = firestore.collection('comments');
final feedCollection = firestore.collection('feed');
final followersCollection = firestore.collection('followers');
final likedDppCollection = firestore.collection('likedpp');
final dislikedppCollection = firestore.collection('dislikedpp');
final ppviewsCollection = firestore.collection('ppviews');
final followingCollection = firestore.collection('following');
final timelineCollection = firestore.collection('timeline');
final messagesCollection = firestore.collection('messages');
final messengerCollection = firestore.collection('messenger');
final groupsCollection = firestore.collection('groups');
final storiesCollection = firestore.collection('stories');
final reportsCollection = firestore.collection('reports');

final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {
  const Home({
    Key? key,
    this.userId,
  }) : super(key: key);

  final String? userId;

  @override
  State<Home> createState() => _HomeState();
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
    getAllUsers();
    getAllStories();

    _tabController = TabController(vsync: this, length: 5);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      log("_HomeState.getInitialMessage(): $message");
    });
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
      final peerData = await usersCollection.doc(user.uid).get();
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

  Widget _body(
    BuildContext context,
    String userId,
    TabController tabController,
  ) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    final double widthContentRight;
    final double widthContentLeft;
    bool widthMoreThan_700 = width > 700;
    if (widthMoreThan_700) {
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
      AppLocalizations.of(context)!.media,
      AppLocalizations.of(context)!.iptv,
      AppLocalizations.of(context)!.chat,
      AppLocalizations.of(context)!.group,
      AppLocalizations.of(context)!.apps,
      AppLocalizations.of(context)!.accounting,
      AppLocalizations.of(context)!.go_dark,
      AppLocalizations.of(context)!.credit_lines,
      AppLocalizations.of(context)!.crow_funding,
      AppLocalizations.of(context)!.business_structure,
      AppLocalizations.of(context)!.cryptocurrency
    ];

    ScrollController scrollController = ScrollController();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widthMoreThan_700)
          _leftSide(
            scrollController,
            context,
            widthContentLeft,
            dataSideLeft,
          ),
        SizedBox(
          width: widthContentCenter,
          height: double.infinity,
          child: Column(children: [
            Expanded(child: _tabBarView(tabController, userId)),
            // HomeAds(tabController: tabController)
          ]),
        ),
        if (widthMoreThan_700)
          Expanded(
            child: _rightSide(
              widthContentRight,
            ),
          )
      ],
    );
  }

  SingleChildScrollView _rightSide(double widthContentRight) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ExchangeratesDataWidget(
          //   widthParent: (widthContentRight),
          // ),
          const ExchangeRate(),
          // Ads(space: widthContentRight),
          if (!kIsWeb)
            MaxAdView(
              adUnitId: AppLovin.adUnitId,
              adFormat: AdFormat.banner,
              listener: AdViewAdListener(
                onAdLoadedCallback: (ad) {},
                onAdLoadFailedCallback: (adUnitId, error) {},
                onAdClickedCallback: (ad) {},
                onAdExpandedCallback: (ad) {},
                onAdCollapsedCallback: (ad) {},
              ),
            )
        ],
      ),
    );
  }

  RawScrollbar _leftSide(
      ScrollController scrollController,
      BuildContext context,
      double widthContentLeft,
      List<String> dataSideLeft) {
    return RawScrollbar(
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
                final item = dataSideLeft[index];
                if (AppLocalizations.of(context)!.email == item) {
                  const url = 'http://xsender.globalgnet.net';
                  if (kIsWeb) {
                    launchUrl(Uri.parse(url));
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return const AppWebView(url: url, title: 'Email');
                      }),
                    );
                  }
                  return;
                }
                if (AppLocalizations.of(context)!.business_structure == item) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const BusinessStructure();
                    }),
                  );
                  return;
                }
                if (AppLocalizations.of(context)!.accounting == item) {
                  const url = 'https://account.globalgnet.net';
                  if (kIsWeb) {
                    launchUrl(Uri.parse(url));
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return const AppWebView(url: url, title: 'Accounting');
                      }),
                    );
                  }
                  return;
                }
                if (AppLocalizations.of(context)!.media == item) {
                  const url = 'https://www.douyin.com';
                  if (kIsWeb) {
                    launchUrl(Uri.parse(url));
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return const AppWebView(url: url, title: 'Media');
                      }),
                    );
                  }
                  return;
                }
                if (AppLocalizations.of(context)!.shop == item) {
                  const url = 'http://globalgnet.net';
                  if (kIsWeb) {
                    launchUrl(Uri.parse(url));
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return const AppWebView(url: url, title: 'Shop');
                      }),
                    );
                  }
                  return;
                } else if (AppLocalizations.of(context)!.news == item) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const News();
                    }),
                  );
                  return;
                }
                toastLong(
                  "${dataSideLeft[index]} will be available soon",
                );
              },
            );
          },
        ),
      ),
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
        Users(userId: userId),
        Profile(
          profileId: userId,
          reactions: reaction.reactions,
          isProfileOwner: true,
        ),
        ActivityFeed(
          userId: userId,
        ),
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
    await storiesCollection.get();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersCollection
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
        await usersCollection.orderBy('timestamp', descending: true).get();
    List<GloabalUser> users = snapshot.docs
        .map((doc) => GloabalUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    setState(() {
      this.users = users;
    });
  }
}
