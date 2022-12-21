// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpleworld/models/user.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/profile.dart';
import 'package:simpleworld/pages/chat/simpleworld_chat.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/data/reaction_data.dart' as Reaction;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FollowersTile extends StatefulWidget {
  Map<dynamic, dynamic>? userdoc;

  FollowersTile(this.userdoc, {Key? key}) : super(key: key);

  @override
  State createState() => FollowersTileState(userdoc);
}

class FollowersTileState extends State<FollowersTile> {
  Map<dynamic, dynamic>? userdoc;
  FollowersTileState(this.userdoc);

  final String? currentUserId = globalID;
  bool isFollowing = false;
  String userid = '';

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(userdoc!['userId'])
        .collection('userFollowers')
        .doc(globalID)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).shadowColor,
        ),
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      width: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profile(
                  profileId: userdoc!['userId'],
                  reactions: Reaction.reactions,
                ),
              ),
            ).then((value) => setState(() {})),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [buildUsers()],
            ),
          ),
        ],
      ),
    );
  }

  buildUsers() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(userdoc!['userId']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;
        final bool isProfileOwner = currentUserId == user!.id;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(children: <Widget>[
              user.coverUrl.isEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      child: Image.asset(
                        'assets/images/defaultcover.png',
                        alignment: Alignment.center,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 60,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: user.coverUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  // image: DecorationImage(
                  //     image: CachedNetworkImageProvider(user.coverUrl,
                  //         scale: 1.0),
                  //     fit: BoxFit.cover)
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Container(
                    alignment: const Alignment(0.0, 5.5),
                    child: user.photoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: CachedNetworkImage(
                              imageUrl: user.photoUrl,
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF003a54),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Image.asset(
                              'assets/images/defaultavatar.png',
                              width: 50,
                            ),
                          ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 30),
            Text(
              user.username.capitalize(),
              style:
                  Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!isProfileOwner)
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    height: 30,
                    width: (context.width() - (3 * 16)) * 0.2,
                    decoration: const BoxDecoration(
                      color: Color(0xffE5E6EB),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.message,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ).onTap(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          receiverId: user.id,
                          receiverAvatar: user.photoUrl,
                          receiverName: user.username,
                          key: null,
                        ),
                      ),
                    );
                  }),
                const SizedBox(width: 5),
                if (!isProfileOwner)
                  Container(
                    child: isFollowing
                        ? Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            height: 30,
                            width: (context.width() - (3 * 16)) * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.redAccent[700],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.unfollow,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).onTap(() {
                            handleUnfollowUser();
                          })
                        : Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            height: 30,
                            width: (context.width() - (3 * 16)) * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.follow,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).onTap(() {
                            handleFollowUser();
                          }),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .doc(userdoc!['id'])
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userdoc!['id'])
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .doc(userdoc!['id'])
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .doc(userdoc!['id'])
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userdoc!['id'])
        .set({});
    activityFeedRef
        .doc(userdoc!['id'])
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": userdoc!['id'],
      "username": globalName,
      "userId": currentUserId,
      "userProfileImg": globalImage,
      "timestamp": timestamp,
      "isSeen": false,
    });
  }
}
