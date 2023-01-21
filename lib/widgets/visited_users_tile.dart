// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:global_net/models/user.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/profile/profile.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:global_net/data/reaction_data.dart' as Reaction;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VisitedUsersTile extends StatefulWidget {
  Map<dynamic, dynamic>? userdoc;

  VisitedUsersTile(this.userdoc, {Key? key}) : super(key: key);

  @override
  State createState() => VisitedUsersTileState(userdoc);
}

class VisitedUsersTileState extends State<VisitedUsersTile> {
  Map<dynamic, dynamic>? userdoc;
  VisitedUsersTileState(this.userdoc);

  final String? currentUserId = globalID;
  bool isFollowing = false;

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(
                profileId: userdoc!['id'],
                reactions: Reaction.reactions,
              ),
            ),
          ).then((value) => setState(() {})),
          // showProfile(context, profileId: userdoc!['id']),
          child: buildUsers(),
        ),
      ],
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

        return ListTile(
          leading: user.photoUrl.isNotEmpty
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
          title: Text(
            user.username.capitalize(),
            style:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Text(
                'Visited on: ',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              Text(
                DateFormat('dd MMM kk:mm').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(userdoc!['timestamp']),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          trailing: Container(
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
        );
        // Row(
        //   children: <Widget>[
        //     SizedBox(
        //       // width: double.infinity,
        //       // height: 60,
        //       child: user.photoUrl.isNotEmpty
        //           ? ClipRRect(
        //               borderRadius: BorderRadius.circular(15.0),
        //               child: CachedNetworkImage(
        //                 imageUrl: user.photoUrl,
        //                 height: 50.0,
        //                 width: 50.0,
        //                 fit: BoxFit.cover,
        //               ),
        //             )
        //           : Container(
        //               decoration: BoxDecoration(
        //                 color: const Color(0xFF003a54),
        //                 borderRadius: BorderRadius.circular(15.0),
        //               ),
        //               child: Image.asset(
        //                 'assets/images/defaultavatar.png',
        //                 width: 50,
        //               ),
        //             ),
        //     ),
        //     Text(
        //       user.username.capitalize(),
        //       style:
        //           Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
        //       maxLines: 1,
        //       overflow: TextOverflow.ellipsis,
        //     ),
        //     if (!isProfileOwner)
        //       Container(
        //         margin: const EdgeInsets.only(top: 10.0),
        //         height: 30,
        //         width: (context.width() - (3 * 16)) * 0.2,
        //         decoration: const BoxDecoration(
        //           color: Color(0xffE5E6EB),
        //           borderRadius: BorderRadius.all(
        //             Radius.circular(5.0),
        //           ),
        //         ),
        //         child: Center(
        //           child: Text(
        //             AppLocalizations.of(context)!.message,
        //             textAlign: TextAlign.left,
        //             style: const TextStyle(
        //               fontWeight: FontWeight.w600,
        //               fontSize: 12,
        //               letterSpacing: 0.0,
        //               color: Colors.black,
        //             ),
        //           ),
        //         ),
        //       ).onTap(() {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => Chat(
        //               receiverId: user.id,
        //               receiverAvatar: user.photoUrl,
        //               receiverName: user.username,
        //               key: null,
        //             ),
        //           ),
        //         );
        //       }),
        //     const SizedBox(width: 5),
        //     if (!isProfileOwner)
        //       Container(
        //         child: isFollowing
        //             ? Container(
        //                 margin: const EdgeInsets.only(top: 10.0),
        //                 height: 30,
        //                 width: (context.width() - (3 * 16)) * 0.2,
        //                 decoration: BoxDecoration(
        //                   color: Colors.redAccent[700],
        //                   borderRadius: const BorderRadius.all(
        //                     Radius.circular(5.0),
        //                   ),
        //                 ),
        //                 child: Center(
        //                   child: Text(
        //                     AppLocalizations.of(context)!.unfollow,
        //                     textAlign: TextAlign.left,
        //                     style: const TextStyle(
        //                       fontWeight: FontWeight.w600,
        //                       fontSize: 12,
        //                       letterSpacing: 0.0,
        //                       color: Colors.white,
        //                     ),
        //                   ),
        //                 ),
        //               ).onTap(() {
        //                 handleUnfollowUser();
        //               })
        //             : Container(
        //                 margin: const EdgeInsets.only(top: 10.0),
        //                 height: 30,
        //                 width: (context.width() - (3 * 16)) * 0.2,
        //                 decoration: BoxDecoration(
        //                   color: Colors.blue[700],
        //                   borderRadius: const BorderRadius.all(
        //                     Radius.circular(5.0),
        //                   ),
        //                 ),
        //                 child: Center(
        //                   child: Text(
        //                     AppLocalizations.of(context)!.follow,
        //                     textAlign: TextAlign.left,
        //                     style: const TextStyle(
        //                       fontWeight: FontWeight.w600,
        //                       fontSize: 12,
        //                       letterSpacing: 0.0,
        //                       color: Colors.white,
        //                     ),
        //                   ),
        //                 ),
        //               ).onTap(() {
        //                 handleFollowUser();
        //               }),
        //       ),
        //   ],
        // );
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
