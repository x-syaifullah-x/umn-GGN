// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/models/user.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/profile/profile.dart';
import 'package:global_net/pages/chat/simpleworld_chat.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:global_net/data/reaction_data.dart' as reaction;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SuggestedUserTile extends StatefulWidget {
  Map<dynamic, dynamic>? userdoc;

  SuggestedUserTile(this.userdoc, {Key? key}) : super(key: key);

  @override
  State createState() => SuggestedUserTileState(userdoc);
}

class SuggestedUserTileState extends State<SuggestedUserTile> {
  Map<dynamic, dynamic>? userdoc;
  SuggestedUserTileState(this.userdoc);

  final String currentUserId = globalUserId;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersCollection
        .doc(userdoc!['id'])
        .collection('userFollowers')
        .doc(globalUserId)
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
        // color: Colors.white,
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      width: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              final id = userdoc!['id'];
              usersCollection.doc(id).get().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      user: User.fromJson(value.data()),
                      reactions: reaction.reactions,
                      ownerId: currentUserId,
                    ),
                  ),
                ).then((value) => setState(() {}));
              });
            },
            // showProfile(context, profileId: userdoc!['id']),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildUsers()],
            ),
          ),
        ],
      ),
    );
  }

  _buildUsers() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(userdoc!['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;
        final bool isProfileOwner = currentUserId == user!.id;

        return LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  SizedBox(
                      width: double.infinity,
                      height: 240,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: user.photoUrl == null || user.photoUrl.isEmpty
                            ? Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFF003a54),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: Image.asset(
                                  'assets/images/defaultavatar.png',
                                  width: 50,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: user.photoUrl,
                                height: 50.0,
                                width: 50.0,
                                fit: BoxFit.cover,
                              ),
                      )),
                ]),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    user.username.capitalize(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: boxConstraints.maxWidth,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!isProfileOwner)
                        Expanded(
                          child: Container(
                            child: isFollowing
                                ? Container(
                                    margin: const EdgeInsets.only(top: 10.0),
                                    height: 35,
                                    // width: ((boxConstraints.maxWidth - 15) / 2),
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
                                          fontSize: 15,
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
                                    height: 35,
                                    // width: ((boxConstraints.maxWidth - 15) / 2),
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
                                          fontSize: 15,
                                          letterSpacing: 0.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ).onTap(() {
                                    handleFollowUser();
                                  }),
                          ),
                        ),
                      const SizedBox(width: 5),
                      if (!isProfileOwner)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            height: 35,
                            // width: ((boxConstraints.maxWidth - 15) / 2),
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
                                  fontSize: 15,
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
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersCollection
        .doc(userdoc!['id'])
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingCollection
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userdoc!['id'])
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    feedCollection
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

  // handleFollowUser() {
  //   setState(() {
  //     isFollowing = true;
  //   });
  //   followersRef
  //       .doc(userdoc!['id'])
  //       .collection('userFollowers')
  //       .doc(currentUserId)
  //       .set({});
  //   followingRef
  //       .doc(currentUserId)
  //       .collection('userFollowing')
  //       .doc(userdoc!['id'])
  //       .set({});
  //   activityFeedRef
  //       .doc(userdoc!['id'])
  //       .collection('feedItems')
  //       .doc(currentUserId)
  //       .set({
  //     "type": "follow",
  //     "ownerId": userdoc!['id'],
  //     "username": globalName,
  //     "userId": currentUserId,
  //     "userProfileImg": globalImage,
  //     "timestamp": timestamp,
  //     "isSeen": false,
  //   });
  // }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersCollection
        .doc(userdoc!['id'])
        .collection('userFollowers')
        .doc(currentUserId)
        .set({'userId': currentUserId});
    ;
    followingCollection
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userdoc!['id'])
        .set({'userId': userdoc!['id']});
    ;
    feedCollection
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
