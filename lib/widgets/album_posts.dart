// ignore_for_file: no_logic_in_create_state, unnecessary_this

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:global_net/data/reaction_data.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/comments.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/count/reaction_button_album_posts.dart';
import 'package:global_net/widgets/count/reactions_count_album_posts.dart';
import 'package:global_net/widgets/full_image_widget.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:timeago/timeago.dart';

class AlbumPosts extends StatefulWidget {
  Map<dynamic, dynamic>? post;
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? photoId;
  final String? description;
  final String? mediaUrl;

  final String? type;

  final String? timestamp;

  AlbumPosts(
      {Key? key,
      this.post,
      this.postId,
      this.ownerId,
      this.username,
      this.description,
      this.mediaUrl,
      this.type,
      this.timestamp,
      this.photoId})
      : super(key: key);

  factory AlbumPosts.fromDocument(DocumentSnapshot doc) {
    return AlbumPosts(
      postId: doc['postId'],
      photoId: doc['photoId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'],
      type: doc['type'],
    );
  }

  factory AlbumPosts.fromMap(Map<String, dynamic> map) {
    return AlbumPosts(
        postId: map['postId'] as String? ?? '',
        ownerId: map['ownerId'] as String? ?? '',
        photoId: map['photoId'] as String? ?? '',
        username: map['username'] as String? ?? '',
        description: map['description'] as String? ?? '',
        mediaUrl: map['mediaUrl'] as String? ?? '',
        type: map['type'] as String? ?? '',
        timestamp: map['timestamp'] as String);
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'photoId': photoId,
      'ownerId': ownerId,
      'username': username,
      'description': description,
      'mediaUrl': mediaUrl,
      'type': type,
      'timestamp': timestamp,
    };
  }

  @override
  _AlbumPostsState createState() => _AlbumPostsState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        photoId: this.photoId,
        description: this.description,
        timestamp: this.timestamp,
        mediaUrl: this.mediaUrl,
        type: this.type,
      );
}

class _AlbumPostsState extends State<AlbumPosts> {
  final String? currentUserId = globalUserId;
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? photoId;
  final String? description;
  final String? timestamp;
  final String? mediaUrl;

  final String? type;
  bool showHeart = false;

  late final Timer timer;

  String remotePDFpath = "";

  _AlbumPostsState({
    this.postId,
    this.ownerId,
    this.username,
    this.description,
    this.mediaUrl,
    this.timestamp,
    this.type,
    this.photoId,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<QuerySnapshot> requestCount() {
    return postsCollection
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection("comments")
        .snapshots();
  }

  Widget commentsCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: requestCount(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!.size.toString(),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).iconTheme.color,
                ));
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  buildPostHeader() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(ownerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;
        bool isPostOwner = currentUserId == ownerId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: <Widget>[
              user!.photoUrl.isNotEmpty
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
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => showProfile(context, userId: user.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username.capitalize(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        format(
                            DateTime.fromMillisecondsSinceEpoch(int.parse(
                              timestamp!,
                            )),
                            locale: 'en_short'),
                        style: Theme.of(context).textTheme.caption!.copyWith(
                              fontSize: 12.0,
                            ),
                      ),
                      // Text(
                      //   timeago.format(timestamp!.toDate()),
                      //   style: Theme.of(context).textTheme.caption!.copyWith(
                      //         fontSize: 12.0,
                      //       ),
                      // ),
                    ],
                  ),
                ),
              ),
              isPostOwner
                  ? IconButton(
                      onPressed: () => handleDeletePosts(context),
                      icon: const Icon(Icons.more_horiz),
                    )
                  : const Icon(Icons.more_horiz),
            ],
          ),
        );
      },
    );
  }

  handleDeletePosts(BuildContext parentConext) {
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Remove this Post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  deletePost() async {
    postsCollection
        .doc(ownerId)
        .collection("userPosts")
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    FirebaseStorage.instance.refFromURL(mediaUrl!).delete();

    QuerySnapshot activityFeedSnapshot = await feedCollection
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Widget buildPostImage() {
    bool hasdesc = description?.isNotEmpty == true;
    bool isPhoto = type == 'photo';
    bool isText = type == 'text';

    if (isText) {
      return GestureDetector(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 10, left: 10),
              child: Text(description!),
            ),
          ],
        ),
      );
    } else if (isPhoto) {
      if (hasdesc) {
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullPhoto(url: mediaUrl!))),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10, left: 10),
                child: Text(
                  description!,
                  style: GoogleFonts.roboto(),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: mediaUrl!,
                      placeholder: (context, url) => const Padding(
                          child: CupertinoActivityIndicator(),
                          padding: EdgeInsets.all(20.0)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  showHeart
                      ? Container(
                          margin: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.favorite,
                            size: 80.0,
                            color: Colors.red,
                          ))
                      : const Text(""),
                ],
              ),
            ],
          ),
        );
      }
      return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => FullPhoto(url: mediaUrl!))),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Center(
                  child: CachedNetworkImage(
                    imageUrl: mediaUrl!,
                    width: MediaQuery.of(context).size.width,
                    placeholder: (context, url) => const Padding(
                        child: CupertinoActivityIndicator(),
                        padding: EdgeInsets.all(20.0)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                showHeart
                    ? Container(
                        margin: const EdgeInsets.all(5.0),
                        child: const Icon(
                          Icons.favorite,
                          size: 80.0,
                          color: Colors.red,
                        ))
                    : const Text(""),
              ],
            ),
          ],
        ),
      );
    }

    return Container();
  }

  Widget buildPostFooter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              reactionsCountAlbumPosts(
                postId: postId,
                ownerId: ownerId,
                photoId: photoId,
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => showComments(context,
                          postId: postId,
                          ownerId: ownerId,
                          mediaUrl: mediaUrl,
                          photoId: photoId),
                      child: Row(
                        children: [
                          SizedBox(
                            child: commentsCount(),
                          ),
                          const SizedBox(width: 5.0),
                          Text('Comments',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context).iconTheme.color,
                              )),
                        ],
                      )),
                  const SizedBox(width: 5.0),
                ],
              ),
            ],
          ),
          const Divider(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ReactionButtonAlbumPostsWidget(
                    postId: postId,
                    ownerId: ownerId,
                    userId: currentUserId,
                    reactions: reactions,
                    photoId: photoId,
                    mediaUrl: mediaUrl,
                  ),
                  const SizedBox(width: 5.0),
                ],
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => showComments(context,
                          postId: postId,
                          ownerId: ownerId,
                          mediaUrl: mediaUrl,
                          photoId: photoId),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/comment.svg",
                            height: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 5.0),
                          Text('Comment',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context).iconTheme.color,
                              )),
                        ],
                      )),
                  const SizedBox(width: 5.0),
                ],
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => _onShare(
                            context,
                          ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/share.svg",
                            height: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 5.0),
                          Text('Share',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context).iconTheme.color,
                              )),
                        ],
                      )),
                  const SizedBox(width: 5.0),
                ],
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10.0))
        ],
      ),
    );
  }

  _onShare(BuildContext context) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (mediaUrl!.isNotEmpty) {
      await Share.share(mediaUrl!,
          subject: description,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(description!,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}

showComments(
  BuildContext context, {
  String? postId,
  String? ownerId,
  String? mediaUrl,
  String? photoId,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
        postId: postId,
        postOwnerId: ownerId,
        postMediaUrl: mediaUrl,
        photoId: photoId);
  }));
}
