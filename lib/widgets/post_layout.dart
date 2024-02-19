// ignore_for_file: use_key_in_widget_constructors, implementation_imports, unnecessary_this

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:global_net/data/reaction_data.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/widgets/count/comments_count.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/post_screen.dart';
import 'package:global_net/pages/post_screen_album.dart';
import 'package:global_net/widgets/album_posts.dart';
import 'package:global_net/widgets/count/reaction_button.dart';
import 'package:global_net/widgets/count/reactions_count.dart';
import 'package:global_net/widgets/multi_manager/flick_multi_manager.dart';
import 'package:global_net/widgets/multi_manager/flick_multi_player.dart';
import 'package:global_net/widgets/photo_grid.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:global_net/widgets/single_post.dart';
import 'package:string_validator/string_validator.dart';
import 'package:timeago/timeago.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostLayout extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String? UserId;
  final String? ownerId;
  final String? postId;
  final String? username;
  final String? pdfUrl;
  final String? pdfName;
  final String? pdfsize;
  final String? description;
  final dynamic mediaUrl;
  final String? type;
  final String? timestamp;
  final String? videoUrl;
  final List<Reaction<String>> reactions;

  // ignore: non_constant_identifier_names
  const PostLayout({
    Key? key,
    this.UserId,
    this.ownerId,
    this.postId,
    this.username,
    this.pdfUrl,
    this.pdfName,
    this.pdfsize,
    this.description,
    this.mediaUrl,
    this.type,
    this.timestamp,
    this.videoUrl,
    required this.reactions,
  }) : super(key: key);

  @override
  _PostLayoutState createState() => _PostLayoutState(
      currentUserId: UserId,
      ownerId: ownerId,
      postId: postId,
      username: username,
      pdfUrl: pdfUrl,
      pdfName: pdfName,
      pdfsize: pdfsize,
      description: description,
      timestamp: timestamp,
      mediaUrl: mediaUrl,
      type: type,
      videoUrl: videoUrl);
}

class _PostLayoutState extends State<PostLayout> {
  final String? currentUserId;
  final String? ownerId;
  final String? postId;
  final String? username;
  final String? pdfUrl;
  final String? pdfName;
  final String? pdfsize;
  final String? description;
  final dynamic mediaUrl;
  final String? type;
  final String? timestamp;
  final String? videoUrl;
  bool isFollowing = false;
  bool showHeart = false;
  bool isGlobal = false;
  bool isLoading = false;
  late FlickMultiManager flickMultiManager;
  List<AlbumPosts> posts = [];
  List<String> _simpleChoice = [
    "Hide Post",
    "Report Post",
  ];

  _PostLayoutState({
    this.currentUserId,
    this.ownerId,
    this.postId,
    this.username,
    this.pdfUrl,
    this.pdfName,
    this.pdfsize,
    this.description,
    this.mediaUrl,
    this.type,
    this.timestamp,
    this.videoUrl,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
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

  Widget buildPostHeader() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(ownerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;
        bool isPostOwner = widget.UserId == ownerId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: <Widget>[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: user!.photoUrl == null || user.photoUrl.isEmpty
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
                            imageUrl: user.photoUrl,
                            height: 50.0,
                            width: 50.0,
                            fit: BoxFit.cover,
                          ),
                  )
                ],
              ).onTap(() {
                showProfile(context, profileId: user.id);
              }),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => showProfile(context, profileId: user.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username.capitalize(),
                        style: const TextStyle(
                          fontSize: 15,
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
                    ],
                  ),
                ),
              ),
              isPostOwner
                  ? GestureDetector(
                      onTap: () => handleDeletePosts(context),
                      child: Row(
                        children: const [
                          Icon(Icons.more_horiz),
                        ],
                      ))
                  : PopupMenuButton(
                      color: Theme.of(context).dialogTheme.backgroundColor,
                      icon: Icon(
                        Icons.more_horiz,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Hide Post'),
                          onTap: () => handleHidePosts(
                            context,
                          ),
                        ),
                        PopupMenuItem(
                          child: const Text('Report Post'),
                          onTap: () => handleReportPosts(
                            context,
                          ),
                        ),
                      ],
                    )
            ],
          ),
        );
      },
    );
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

      matches.forEach((match) {
        print(textData.substring(match.start, match.end));
        textData = textData.substring(match.start, match.end);
      });
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
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PostScreen(postId: postId, userId: ownerId))),
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
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey)),
                child: ListTile(
                  leading: SvgPicture.asset(
                    'assets/images/pdf_file.svg',
                    height: 45,
                    color: Colors.grey,
                  ),
                  title: Text(
                    pdfName!,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    pdfsize!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostScreen(postId: postId, userId: ownerId))),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey)),
          child: ListTile(
            leading: SvgPicture.asset(
              'assets/images/pdf_file.svg',
              height: 45,
              color: Colors.grey,
            ),
            title: Text(
              pdfName!,
              style:
                  Theme.of(context).textTheme.caption!.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              pdfsize!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
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
              ReactionsCount(
                postId: postId,
                ownerId: ownerId,
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => showCommentsforalbum(
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
                  const SizedBox(width: 5.0),
                ],
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => showCommentsforalbum(
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

  void deleteNestedSubcollections() {
    Future<QuerySnapshot> photos = postsCollection
        .doc(ownerId)
        .collection("userPosts")
        .doc(postId)
        .collection("albumposts")
        .get();
    photos.then((value) {
      value.docs.forEach((element) {
        postsCollection
            .doc(ownerId)
            .collection("userPosts")
            .doc(postId)
            .collection("albumposts")
            .doc(element.id)
            .delete()
            .then((value) => print("success"));
      });
      FirebaseStorage.instance.refFromURL(mediaUrl!).delete();
    });
  }

  deletePost() async {
    bool isPdf = type == 'pdf';
    bool isVide = type == 'video';
    bool isPhoto = type == 'photo';
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

    deleteNestedSubcollections();
    if (isPdf) {
      FirebaseStorage.instance.refFromURL(pdfUrl!).delete();
    } else if (isVide) {
      FirebaseStorage.instance.refFromURL(videoUrl!).delete();
    } else {
      FirebaseStorage.instance.refFromURL(mediaUrl!).delete();
    }

    // storageRef.child("post_$postId.jpg").delete();

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

  hidePost() async {
    timelineCollection
        .doc(widget.UserId)
        .collection('timelinePosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  _onShare(BuildContext context) async {
    bool hasdesc = description?.isNotEmpty == true;
    bool isPdf = type == 'pdf';
    bool isVide = type == 'video';
    bool isPhoto = type == 'photo';
    bool isText = type == 'text';
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (isPhoto) {
      await Share.share(mediaUrl[0],
          subject: description,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else if (isPdf) {
      // _downloadFile(pdfUrl'.);
      await Share.share(pdfUrl!,
          subject: description,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else if (isVide) {
      await Share.share(videoUrl!,
          subject: description,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(description!,
          subject: description,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
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

  handleHidePosts(
    BuildContext parentConext,
  ) {
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Hide this Post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  hidePost();
                },
                child: const Text(
                  'Hide',
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

  handleReportPosts(
    BuildContext parentConext,
  ) {
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Are you sure you want to Report this Post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  reportPost();
                },
                child: const Text(
                  'Report',
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

  reportPost() async {
    reportsCollection.doc(postId).set({});
    simpleworldtoast("", "Post was reported to Admin", context);
  }
}
