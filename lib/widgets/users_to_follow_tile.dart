import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class UserToFollowTile extends StatefulWidget {
  final GloabalUser user;

  const UserToFollowTile(this.user, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State createState() => UserToFollowTileState(user);
}

class UserToFollowTileState extends State<UserToFollowTile> {
  final GloabalUser user;

  UserToFollowTileState(this.user);

  final String? currentUserId = globalUserId;
  bool isFollowing = false;
  final kInnerDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.white),
    borderRadius: BorderRadius.circular(32),
  );
  final kGradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.red.shade500, Colors.red.shade900]),
    border: Border.all(
      color: Colors.red.shade900,
    ),
    borderRadius: BorderRadius.circular(32),
  );

  @override
  void initState() {
    super.initState();

    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersCollection
        .doc(user.id)
        .collection('userFollowers')
        .doc(globalUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildUsers(),
                const Divider(
                  height: 2,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildUsers() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;
        final bool isProfileOwner = currentUserId == user!.id;

        return Container(
          margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => showProfile(context, profileId: globalUserId),
                child: ListTile(
                    leading: user.photoUrl.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                            radius: 30.0,
                          )
                        : Image.asset(
                            'assets/images/defaultavatar.png',
                            width: 65,
                          ),
                    title: Text(
                      user.username.capitalize(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    trailing: (!isProfileOwner)
                        ? Container(
                            child: isFollowing
                                ? ClipOval(
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: ClipOval(
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox(
                                            width: 35.0,
                                            height: 35.0,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      decoration: kGradientBoxDecoration,
                                    ),
                                  ).onTap(() {
                                    handleUnfollowUser();
                                  })
                                : ClipOval(
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: ClipOval(
                                          clipBehavior: Clip.antiAlias,
                                          child: Container(
                                            width: 35.0,
                                            height: 35.0,
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.red,
                                            ),
                                            decoration: kInnerDecoration,
                                          ),
                                        ),
                                      ),
                                      decoration: kGradientBoxDecoration,
                                    ),
                                  ).onTap(() {
                                    handleFollowUser();
                                  }),
                          )
                        : const Text(" ")),
              ),
            ],
          ),
        );
      },
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersCollection
        .doc(user.id)
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
        .doc(user.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    feedCollection
        .doc(user.id)
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
  //       .doc(user.id)
  //       .collection('userFollowers')
  //       .doc(currentUserId)
  //       .set({});
  //   followingRef
  //       .doc(currentUserId)
  //       .collection('userFollowing')
  //       .doc(user.id)
  //       .set({});
  //   activityFeedRef
  //       .doc(user.id)
  //       .collection('feedItems')
  //       .doc(currentUserId)
  //       .set({
  //     "type": "follow",
  //     "ownerId": user.id,
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
        .doc(user.id)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({'userId': currentUserId});
    ;
    followingCollection
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(user.id)
        .set({'userId': user.id});
    ;
    feedCollection.doc(user.id).collection('feedItems').doc(currentUserId).set({
      "type": "follow",
      "ownerId": user.id,
      "username": globalName,
      "userId": currentUserId,
      "userProfileImg": globalImage,
      "timestamp": timestamp,
      "isSeen": false,
    });
  }
}
