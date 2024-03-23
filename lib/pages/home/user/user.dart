import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/data/reaction_data.dart' as reaction;
import 'package:global_net/data/user.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/chat/simpleworld_chat.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/profile/profile.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class UserWidget extends StatelessWidget {
  static const fieldUserId = 'userId';
  static const fieldCreateAt = 'createAt';
  static const fieldUpdateAt = 'updateAt';
  static const fieldValue = 'value';
  static const collectionPathUserFollowing = 'userFollowing';

  final String currentUserId;
  final String userId;

  const UserWidget({
    Key? key,
    required this.currentUserId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
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
        // width: 160,
        child: _buildUsers(
          currentUserId: currentUserId,
          userId: userId,
        ),
      ),
      onTap: () {
        usersCollection.doc(userId).get().then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(
                user: User.fromJson(value.data()),
                reactions: reaction.reactions,
                ownerId: currentUserId,
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildUsers({
    required String currentUserId,
    required String userId,
  }) {
    return StreamBuilder<DocumentSnapshot<GloabalUser>>(
      stream: GloabalUser.userDoc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data!.data()!;
        final bool isProfileOwner = (currentUserId == user.id);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                user.coverUrl.isEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/defaultcover_new.jpg',
                          alignment: Alignment.center,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          height: 60,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: user.coverUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                user.username.isNotEmpty
                    ? Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
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
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              user.username,
              style:
                  Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: followingCollection
                    .doc(currentUserId)
                    .collection(collectionPathUserFollowing)
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data == null) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  bool isFollowing = data.data()?[fieldValue] == true;
                  return Row(
                    children: [
                      if (!isProfileOwner)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 10.0,
                              left: 4,
                              right: 4,
                            ),
                            height: 30,
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
                        ),
                      if (!isProfileOwner)
                        Expanded(
                          child: isFollowing
                              ? Container(
                                  margin: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 4,
                                    right: 4,
                                  ),
                                  height: 30,
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
                                  handleUnfollowUser(
                                    currentUserId: currentUserId,
                                    userDoc: userId,
                                  );
                                })
                              : Container(
                                  margin: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 4,
                                    right: 4,
                                  ),
                                  height: 30,
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
                                  handleFollowUser(
                                    currentUserId: currentUserId,
                                    userId: userId,
                                  );
                                }),
                        ),
                    ],
                  );
                }),
          ],
        );
      },
    );
  }

   handleUnfollowUser({
    required String currentUserId,
    required String userDoc,
  }) {
    followingCollection
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final date = DateTime.now();
        doc.reference.update({
          fieldValue: false,
          fieldUpdateAt: date.millisecondsSinceEpoch,
        });
      }
    });
  }

  handleFollowUser({
    required String currentUserId,
    required String userId,
  }) {
    final userFollowingRef = followingCollection
        .doc(currentUserId)
        .collection(collectionPathUserFollowing)
        .doc(userId);
    final date = DateTime.now();
    userFollowingRef.get().then((value) {
      final createAt = value.data()?[fieldCreateAt];
      if (createAt != null) {
        userFollowingRef.update({
          fieldUserId: currentUserId,
          fieldUpdateAt: date.millisecondsSinceEpoch,
          fieldValue: true,
        });
      } else {
        userFollowingRef.set({
          fieldUserId: currentUserId,
          fieldCreateAt: date.millisecondsSinceEpoch,
          fieldUpdateAt: date.millisecondsSinceEpoch,
          fieldValue: true,
        });
      }
    });

    // send notification to user
    feedCollection.doc(userId).collection('feedItems').doc(currentUserId).set({
      'type': 'follow',
      'ownerId': userId,
      'username': globalName,
      fieldUserId: currentUserId,
      'userProfileImg': globalImage,
      'timestamp': date,
      'isSeen': false,
    });
  }
}
