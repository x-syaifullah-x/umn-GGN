import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/data/reaction_data.dart' as Reaction;
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/all_videos.dart';
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/pages/chat/simpleworld_chat_main.dart';
import 'package:global_net/pages/comming_soon_page.dart';
import 'package:global_net/pages/edit_profile.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/menu/all_pdfs.dart';
import 'package:global_net/pages/menu/all_stories.dart';
import 'package:global_net/pages/menu/dialogs/vip_dialog.dart';
import 'package:global_net/pages/menu/discover.dart';
import 'package:global_net/pages/menu/help_support.dart';
import 'package:global_net/pages/home/user/users.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/language_picker_widget.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class SettingsPage extends StatefulWidget {
  final String currentUserId;

  const SettingsPage({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late GloabalUser user;
  bool isLoading = false;

  File? imageFileAvatar;
  String? imageFileAvatarUrl;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc =
        await usersCollection.doc(widget.currentUserId).get();
    user = GloabalUser.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('$e');
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = AdaptiveTheme.of(context).mode;
    ScrollController scrollController = ScrollController();
    final bool widthMoreThan_500 = (MediaQuery.of(context).size.width > 500);
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).disabledColor,
        key: _scaffoldKey,
        appBar: header(
          context,
          titleText: AppLocalizations.of(context)!.menu,
          removeBackButton: true,
        ),
        body: isLoading
            ? circularProgress()
            : RawScrollbar(
                controller: scrollController,
                interactive: true,
                thumbVisibility: !kIsWeb && widthMoreThan_500,
                trackVisibility: !kIsWeb && widthMoreThan_500,
                radius: const Radius.circular(20),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    user.photoUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: CachedNetworkImage(
                                              imageUrl: user.photoUrl,
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF003a54),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Image.asset(
                                              'assets/images/defaultavatar.png',
                                              width: 40,
                                            ),
                                          ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      user.displayName.capitalize(),
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              showProfile(context, profileId: user.id);
                            }),
                          ),
                          Expanded(
                              child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: Container(
                              height: 85.0,
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    "assets/images/messenger.svg",
                                    width: 40,
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(AppLocalizations.of(context)!.messenger,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                          ).onTap(() {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => SimpleWorldChat(
                                    userId: widget.currentUserId,
                                  ),
                                ));
                          })),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "assets/images/recent_useers.svg",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                        AppLocalizations.of(context)!
                                            .recent_users,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              final userId = widget.currentUserId;
                              if (userId != null) {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => Users(
                                        userId: userId,
                                      ),
                                    ));
                              }
                            }),
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "assets/images/edit.svg",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                        AppLocalizations.of(context)!
                                            .edit_profile,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => EditProfile(
                                      currentUserId: globalUserId,
                                    ),
                                  ));
                            }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/earth.png",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(AppLocalizations.of(context)!.discover,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        Discover(UserId: globalUserId),
                                  ));
                            }),
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/open_book.png",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(AppLocalizations.of(context)!.stories,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => AllStories(
                                      showappbar: true,
                                    ),
                                  ));
                            }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/play_button.png",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(AppLocalizations.of(context)!.videos,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => AllVideos(
                                      UserId: globalUserId,
                                      reactions: Reaction.reactions,
                                    ),
                                  ));
                            }),
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/documents.png",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                        AppLocalizations.of(context)!.documents,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => AllPdfs(
                                      UserId: globalUserId,
                                      reactions: Reaction.reactions,
                                    ),
                                  ));
                            }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/compliant.png",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                        AppLocalizations.of(context)!
                                            .help_support,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => HelpSupportPage(
                                      currentUserId: widget.currentUserId,
                                    ),
                                  ));
                            }),
                          ),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Container(
                                height: 85.0,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/delete_user.png",
                                      width: 40,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                        AppLocalizations.of(context)!
                                            .deactive_account,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ).onTap(() {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const CommimgSoon(),
                                  ));
                            }),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: ElevatedButton.icon(
                        // style: ElevatedButton.styleFrom(
                        //   shape: new RoundedRectangleBorder(
                        //     borderRadius: new BorderRadius.circular(20.0),
                        //   ),
                        // ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => VipDialog(
                                    credits: user.creditPoints,
                                    photourl: user.photoUrl,
                                    userIsVerified: user.userIsVerified,
                                    no_ads: user.noAds,
                                  ));
                        },
                        icon: const Icon(Icons.star),
                        label: Text('Store'),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFFFD700),
                          minimumSize: const Size(100, 38),
                          maximumSize: const Size(100, 38),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: ElevatedButton.icon(
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
                        label: mode == AdaptiveThemeMode.light
                            ? Text(
                                AppLocalizations.of(context)!.set_dark,
                              )
                            : Text(
                                AppLocalizations.of(context)!.set_light,
                              ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 38),
                          maximumSize: const Size(100, 38),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: LanguagePickerWidget()),
                    ListTile(
                      title: Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        height: 38,
                        width: (MediaQuery.of(context).size.width * 0.4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.logout,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ).onTap(
                        () async {
                          _signOut().then((value) async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences
                                .remove(SharedPreferencesKey.userId)
                                .then((_) async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            });
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        height: 38,
                        width: (MediaQuery.of(context).size.width * 0.4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Delete User",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ).onTap(
                        () async {
                          var user = FirebaseAuth.instance.currentUser!;
                          user.delete();
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences
                              .remove(SharedPreferencesKey.userId)
                              .then((_) async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          });
                        },
                      ),
                    ),
                  ],
                )),
      ),
    );
  }
}
