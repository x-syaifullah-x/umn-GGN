import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_net/data/reaction_data.dart' as reaction;
import 'package:global_net/data/user.dart' as data_user;
import 'package:global_net/pages/all_videos.dart';
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/pages/chat/simpleworld_chat_main.dart';
import 'package:global_net/pages/comming_soon_page.dart';
import 'package:global_net/pages/edit_profile.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/home/deactivate_account.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/user/users.dart';
import 'package:global_net/pages/menu/all_pdfs.dart';
import 'package:global_net/pages/menu/all_stories.dart';
import 'package:global_net/pages/menu/dialogs/vip_dialog.dart';
import 'package:global_net/pages/menu/discover.dart';
import 'package:global_net/pages/menu/help_support.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/language_picker_widget.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingsPage extends StatefulWidget {
  final data_user.User user;

  const SettingsPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).disabledColor,
        appBar: header(
          context,
          titleText: AppLocalizations.of(context)!.menu,
          removeBackButton: true,
        ),
        body: _body(context, widget.user),
      ),
    );
  }

  Widget _body(BuildContext context, data_user.User user) {
    final bool widthMoreThan_500 = (MediaQuery.of(context).size.width > 500);
    final mode = AdaptiveTheme.of(context).mode;
    return RawScrollbar(
      controller: _scrollController,
      interactive: true,
      thumbVisibility: !kIsWeb && widthMoreThan_500,
      trackVisibility: !kIsWeb && widthMoreThan_500,
      radius: const Radius.circular(20),
      child: ListView(
        controller: _scrollController,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _profile(user),
                _chat(user.id),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _recentUsers(user.id),
                _editProfile(user.id),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _discover(user.id),
                _stories(user.id),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _videos(user.id),
                _documents(user.id),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _helpAndSupport(user.id),
                _deactiveAccount(user.id),
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
                    user: user,
                  ),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('Store'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
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
            ).onTap(() async {
              _signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            }),
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
              child: const Center(
                child: Text(
                  'Delete User',
                  textAlign: TextAlign.left,
                  style: TextStyle(
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
                preferences.remove(SharedPreferencesKey.userId).then((_) async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('$e');
    }

    try {
      await usersCollection.doc(widget.user.id).update({
        data_user.User.fieldNameTokenNotfaction: '',
      });
      FirebaseAuth.instance.signOut();
      final pref = await SharedPreferences.getInstance();
      await pref.remove(SharedPreferencesKey.userId);
    } catch (e) {
      debugPrint('$e');
    }
  }

  Widget _deactiveAccount(String userId) {
    return _buildField(
      photoUrl: 'assets/images/delete_user.png',
      fieldName: AppLocalizations.of(context)?.deactive_account ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DeactiveAccount(
              userId: userId,
            ),
          ),
        );
      },
    );
  }

  Widget _helpAndSupport(String userId) {
    return _buildField(
      photoUrl: 'assets/images/compliant.png',
      fieldName: AppLocalizations.of(context)?.help_support ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => HelpSupportPage(
              currentUserId: userId,
            ),
          ),
        );
      },
    );
  }

  Widget _documents(String userId) {
    return _buildField(
      photoUrl: 'assets/images/documents.png',
      fieldName: 'Friend List',
      onTap: () {
        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (context) => AllPdfs(
        //       UserId: globalUserId,
        //       reactions: reaction.reactions,
        //     ),
        //   ),
        // );
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const CommimgSoon(),
          ),
        );
      },
    );
  }

  Widget _videos(String userId) {
    return _buildField(
      photoUrl: 'assets/images/play_button.png',
      fieldName: AppLocalizations.of(context)?.videos ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AllVideos(
              UserId: userId,
              reactions: reaction.reactions,
            ),
          ),
        );
      },
    );
  }

  Widget _stories(String userId) {
    return _buildField(
      photoUrl: 'assets/images/open_book.png',
      fieldName: AppLocalizations.of(context)?.stories ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AllStories(
              showappbar: true,
            ),
          ),
        );
      },
    );
  }

  Widget _discover(String userId) {
    return _buildField(
      photoUrl: 'assets/images/earth.png',
      fieldName: AppLocalizations.of(context)?.discover ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => Discover(UserId: userId),
          ),
        );
      },
    );
  }

  Widget _editProfile(String userId) {
    return _buildField(
      photoUrl: 'assets/images/edit.svg',
      fieldName: AppLocalizations.of(context)?.edit_profile ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditProfile(
              currentUserId: userId,
            ),
          ),
        );
      },
    );
  }

  Widget _recentUsers(String userId) {
    return _buildField(
      photoUrl: 'assets/images/recent_useers.svg',
      fieldName: AppLocalizations.of(context)?.recent_users ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => Users(
              userId: userId,
            ),
          ),
        );
      },
    );
  }

  Widget _chat(String userId) {
    return _buildField(
      photoUrl: 'assets/images/messenger.svg',
      fieldName: AppLocalizations.of(context)?.messenger ?? '-',
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SimpleWorldChat(
              userId: userId,
            ),
          ),
        );
      },
    );
  }

  Widget _profile(data_user.User user) {
    final photoUrl = user.photoUrl.isNotEmpty
        ? user.photoUrl
        : 'assets/images/defaultavatar.png';
    return _buildField(
      photoUrl: photoUrl,
      fieldName: user.displayName,
      onTap: () {
        showProfile(context, userId: user.id);
      },
    );
  }

  Widget _buildField({
    required String photoUrl,
    required String fieldName,
    required Function onTap,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          height: 85.0,
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              photoUrl.contains('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: photoUrl,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : photoUrl.contains('svg')
                      ? SvgPicture.asset(
                          photoUrl,
                          width: 40,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF003a54),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Image.asset(
                            photoUrl,
                            width: 40,
                          ),
                        ),
              const SizedBox(height: 5.0),
              Text(
                fieldName.capitalize(),
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ).onTap(onTap),
    );
  }
}
