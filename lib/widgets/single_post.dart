// ignore_for_file: no_logic_in_create_state, unnecessary_this

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:global_net/data/reaction_data.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/comments_album.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/post_screen.dart';
import 'package:global_net/pages/post_screen_album.dart';
import 'package:global_net/widgets/count/comments_count.dart';
import 'package:global_net/widgets/count/reaction_button.dart';
import 'package:global_net/widgets/count/reactions_count.dart';
import 'package:global_net/widgets/multi_manager/flick_multi_manager.dart';
import 'package:global_net/widgets/pdf_view.dart';
import 'package:global_net/widgets/photo_grid.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:string_validator/string_validator.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'multi_manager/flick_multi_player.dart';

class SinglePost extends StatefulWidget {
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? pdfUrl;
  final String? pdfName;
  final String? pdfsize;
  final String? description;
  final dynamic mediaUrl;
  final String? type;
  final String? timestamp;
  final String? videoUrl;

  const SinglePost({
    Key? key,
    this.postId,
    this.ownerId,
    this.username,
    this.pdfUrl,
    this.pdfName,
    this.pdfsize,
    this.description,
    this.mediaUrl,
    this.type,
    this.timestamp,
    this.videoUrl,
  }) : super(key: key);

  factory SinglePost.fromDocument(DocumentSnapshot doc) {
    return SinglePost(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      pdfUrl: doc['pdfUrl'],
      pdfName: doc['pdfName'],
      pdfsize: doc['pdfsize'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'],
      videoUrl: doc['videoUrl'],
      type: doc['type'],
    );
  }

  factory SinglePost.fromMap(Map<String, dynamic> map) {
    return SinglePost(
        postId: map['postId'] as String? ?? '',
        ownerId: map['ownerId'] as String? ?? '',
        username: map['username'] as String? ?? '',
        pdfUrl: map['pdfUrl'] as String? ?? '',
        pdfName: map['pdfName'] as String? ?? '',
        pdfsize: map['pdfsize'] as String? ?? '',
        description: map['description'] as String? ?? '',
        mediaUrl: map['mediaUrl'] as String? ?? '',
        videoUrl: map['videoUrl'] as String? ?? '',
        type: map['type'] as String? ?? '',
        timestamp: map['timestamp'] as String);
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'ownerId': ownerId,
      'username': username,
      'pdfUrl': pdfUrl,
      'pdfName': pdfName,
      'pdfsize': pdfsize,
      'description': description,
      'mediaUrl': mediaUrl,
      'videoUrl': videoUrl,
      'type': type,
      'timestamp': timestamp,
    };
  }

  @override
  State<SinglePost> createState() => _SinglePostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      pdfUrl: this.pdfUrl,
      pdfName: this.pdfName,
      pdfsize: this.pdfsize,
      description: this.description,
      timestamp: this.timestamp,
      mediaUrl: this.mediaUrl,
      type: this.type,
      videoUrl: this.videoUrl);
}

class _SinglePostState extends State<SinglePost> {
  final String? currentUserId = globalUserId;
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? pdfUrl;
  final String? pdfName;
  final String? pdfsize;
  final String? description;
  final String? timestamp;
  final dynamic mediaUrl;
  final String? videoUrl;
  final String? type;
  late FlickMultiManager flickMultiManager;

  String remotePDFpath = "";

  _SinglePostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.pdfUrl,
      this.pdfName,
      this.pdfsize,
      this.description,
      this.mediaUrl,
      this.timestamp,
      this.videoUrl,
      this.type});

  @override
  void initState() {
    super.initState();
    flickMultiManager = FlickMultiManager();
    flickMultiManager.pause();
  }

  @override
  void dispose() {
    flickMultiManager = FlickMultiManager();
    super.dispose();
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
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    storageRef.child("post_$postId.jpg").delete();

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

    QuerySnapshot commentsSnapshot =
        await commentsCollection.doc(postId).collection('comments').get();
    commentsSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Widget buildPostImage() {
    bool hasdesc = description?.isNotEmpty == true;
    bool isPdf = type == 'pdf';
    bool isVide = type == 'video';
    bool isPhoto = type == 'photo';
    bool isText = type == 'text';
    String convertStringToLink(String textData) {
      final urlRegExp =
          RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      Iterable<RegExpMatch> matches = urlRegExp.allMatches(textData);

      for (var match in matches) {
        log(textData.substring(match.start, match.end));
        textData = textData.substring(match.start, match.end);
      }
      return textData;
    }

    String userInput = convertStringToLink(description!);
    bool isValid = isURL(userInput);

    if (isPhoto) {
      if (hasdesc) {
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostScreenAlbum(
                  postId: postId,
                  userId: ownerId,
                ),
              )),
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
                      child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: PhotoGrid(
                      imageUrls: mediaUrl,
                      onImageClicked: (i) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreenAlbum(
                            postId: postId,
                            userId: ownerId,
                          ),
                        ),
                      ),
                      onExpandClicked: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreenAlbum(
                            postId: postId,
                            userId: ownerId,
                          ),
                        ),
                      ),
                      maxImages: 4,
                    ),
                  )),
                ],
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostScreenAlbum(
              postId: postId,
              userId: ownerId,
            ),
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Center(
                    child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: PhotoGrid(
                    imageUrls: mediaUrl,
                    onImageClicked: (i) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostScreenAlbum(
                          postId: postId,
                          userId: ownerId,
                        ),
                      ),
                    ),
                    onExpandClicked: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostScreenAlbum(
                          postId: postId,
                          userId: ownerId,
                        ),
                      ),
                    ),
                    maxImages: 4,
                  ),
                )),
              ],
            ),
          ],
        ),
      );
    } else if (isVide) {
      if (hasdesc) {
        return Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 10, left: 10),
              child: Text(description!),
            ),
            VisibilityDetector(
              key: ObjectKey(flickMultiManager),
              onVisibilityChanged: (visibility) {
                if (visibility.visibleFraction == 0 && this.mounted) {
                  flickMultiManager.pause();
                }
              },
              child: SizedBox(
                height: 500,
                child: ClipRRect(
                  child: FlickMultiPlayer(
                    url: videoUrl!,
                    flickMultiManager: flickMultiManager,
                  ),
                ),
              ),
            ),
          ],
        );
      }
      return VisibilityDetector(
        key: ObjectKey(flickMultiManager),
        onVisibilityChanged: (visibility) {
          if (visibility.visibleFraction < 1 && this.mounted) {
            flickMultiManager.pause();
          }
        },
        child: SizedBox(
          height: 500,
          child: ClipRRect(
            child: FlickMultiPlayer(
              url: videoUrl!,
              flickMultiManager: flickMultiManager,
            ),
          ),
        ),
      );
    } else if (isText) {
      return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostScreen(postId: postId, userId: ownerId))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(width: 10.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Linkify(text: description!, softWrap: true),
                ),
                isValid
                    ? Container(
                        margin: const EdgeInsets.all(5.0),
                        child: LinkPreviewGenerator(
                          bodyMaxLines: 3,
                          borderRadius: 0,
                          link: convertStringToLink(description!),
                          linkPreviewStyle: LinkPreviewStyle.large,
                          showGraphic: true,
                        ),
                      )
                    : const Text('')
              ],
            ),
          ],
        ),
      );
    } else if (isPdf) {
      if (hasdesc) {
        return GestureDetector(
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
              SizedBox(
                height: 500,
                child: PDFScreen(path: widget.pdfUrl),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        height: 500,
        child: PDFScreen(path: widget.pdfUrl),
      );
    }
    return Container();
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  Widget buildPostFooter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ReactionsCount(
                postId: postId,
                ownerId: ownerId,
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => _showCommentsforalbum(
                            context,
                            postId: postId,
                            ownerId: ownerId,
                            // mediaUrl: mediaUrl[0],
                          ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: CommentsCount(
                              postId: postId,
                            ),
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
                  ReactionButtonWidget(
                    postId: postId,
                    ownerId: ownerId,
                    userId: currentUserId,
                    reactions: reactions,
                  ),
                  SizedBox(width: 5.0),
                ],
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => _showCommentsforalbum(
                            context,
                            postId: postId,
                            ownerId: ownerId,
                            // mediaUrl: mediaUrl[0],
                          ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  void _showCommentsforalbum(
    BuildContext context, {
    String? postId,
    String? ownerId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AlbumComments(
            userId: globalUserId,
            postId: postId,
            postOwnerId: ownerId,
          );
        },
      ),
    );
  }
}
