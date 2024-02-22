import 'package:applovin_max/applovin_max.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/config/palette.dart';
import 'package:global_net/data/reaction_data.dart' as reaction;
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/profile/profile.dart';
import 'package:global_net/pages/post_screen.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as time_ago;

import '../../ads/applovin_ad_unit_id.dart';

class ActivityFeed extends StatefulWidget {
  final String userId;

  const ActivityFeed({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ActivityFeedState createState() => ActivityFeedState();
}

class ActivityFeedState extends State<ActivityFeed>
    with AutomaticKeepAliveClientMixin<ActivityFeed> {
  List<ActivityFeedItem> feedItem = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _updateFeed(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(
        context,
        titleText: AppLocalizations.of(context)?.notifications,
        removeBackButton: true,
      ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
              ),
              child: Container(
                child: _activityFeedList(widget.userId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityFeedList(String? userData) {
    final ScrollController scrollController = ScrollController();

    Widget child = const Center(
      child: Text("Currently you don't have any messages"),
    );

    if (userData?.isEmpty == true) {
      return child;
    }

    return StreamBuilder(
      stream: feedCollection
          .doc(userData)
          .collection('feedItems')
          .orderBy('createAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          QuerySnapshot<Object?>? data = snapshot.data;
          if (data != null && data.docs.isNotEmpty) {
            final bool widthMoreThan_500 =
                (MediaQuery.of(context).size.width > 500);
            child = Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: RawScrollbar(
                    controller: scrollController,
                    interactive: true,
                    thumbVisibility: !kIsWeb && widthMoreThan_500,
                    trackVisibility: !kIsWeb && widthMoreThan_500,
                    radius: const Radius.circular(20),
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: data.docs.length,
                      itemBuilder: (context, int index) {
                        QueryDocumentSnapshot<Object?> feedItem =
                            data.docs[index];
                        return _buildItem(
                          context: context,
                          feedItem: feedItem,
                          currentUserId: widget.userId,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    ),
                  ),
                ),
                // const AnchoredAd(),
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
            );
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: child,
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: const <Widget>[
              CupertinoActivityIndicator(),
            ],
          ),
        );
      },
    );
  }

  Future _updateFeed(String userId) async {
    QuerySnapshot activityFeedSnapshot = await feedCollection
        .doc(userId)
        .collection("feedItems")
        .where("isSeen", isEqualTo: false)
        .get();
    for (var doc in activityFeedSnapshot.docs) {
      if (doc.exists) {
        doc.reference.update({
          "isSeen": true,
        });
      }
    }
  }

  Widget _buildItem({
    required String currentUserId,
    required BuildContext context,
    required QueryDocumentSnapshot<Object?> feedItem,
  }) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              String type = feedItem['type'];
              String userID;
              if (type == 'message') {
                userID = feedItem['fromId'];
              } else {
                userID = feedItem['userId'];
              }
              usersCollection.doc(userID).get().then((value) {
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
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Palette.simpleWorldText,
                  ),
                  children: [
                    TextSpan(
                      text: feedItem['username'],
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontSize: 16),
                    ),
                    TextSpan(
                      text: feedItem['type'] != null &&
                              feedItem['type'] == 'like'
                          ? " reacted to your post"
                          : feedItem['type'] != null &&
                                  feedItem['type'] == 'follow'
                              ? " is following you"
                              : feedItem['type'] != null &&
                                      feedItem['type'] == 'comment'
                                  ? " Commented on your post: ${feedItem['commentData']}"
                                  : feedItem['type'] != null &&
                                          feedItem['type'] == 'message'
                                      ? " Sent you a message: ${feedItem['contentMessage']}"
                                      : " Error: Unknown type ${feedItem['type']}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(fontSize: 15),
                    ),
                  ]),
            ),
          ),
          subtitle: Text(
            time_ago.format(
              DateTime.fromMillisecondsSinceEpoch(
                feedItem['createAt'],
              ),
            ),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.0,
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              final aa = feedItem['userId'];
              usersCollection.doc(aa).get().then((value) {
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: feedItem['userProfileImg'] == null ||
                      feedItem['userProfileImg'].isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF003a54),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Image.asset(
                        'assets/images/defaultavatar.png',
                        width: 50,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: feedItem['userProfileImg'],
                      height: 50.0,
                      width: 50.0,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          trailing: feedItem['type'] == 'like' || feedItem['type'] == 'comment'
              ? feedItem['mediaUrl'] != null
                  ? SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  feedItem['mediaUrl']),
                            ),
                          ),
                        ),
                      ),
                    ).onTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            userId: currentUserId,
                            postId: feedItem['postId'],
                          ),
                        ),
                      );
                    })
                  : mediaPreview = const Text('')
              : mediaPreview = const Text(''),
        ));
  }
}

Widget? mediaPreview;
String? activityItemText;

class ActivityFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  final String? username;
  final String? userId;
  final String? type;
  final String? mediaUrl;
  final String? postId;
  final String? userProfileImg;
  final String? commentData;
  final Timestamp? timestamp;

  const ActivityFeedItem({
    Key? key,
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  }) : super(key: key);

  // factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
  //   return ActivityFeedItem(
  //     username: doc['username'],
  //     userId: doc['userId'],
  //     type: doc['type'],
  //     postId: doc['postId'],
  //     userProfileImg: doc['userProfileImg'],
  //     commentData: doc['commentData'],
  //     timestamp: doc['timestamp'],
  //     mediaUrl: doc['mediaUrl'],
  //   );
  // }
}

showProfile(BuildContext context, {required String userId}) async {
  usersCollection.doc(userId).get().then((value) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          user: User.fromJson(value.data()),
          reactions: reaction.reactions,
          ownerId: globalUserId,
        ),
      ),
    );
  });
}
