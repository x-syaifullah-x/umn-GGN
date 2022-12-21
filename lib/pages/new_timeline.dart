// ignore_for_file: use_key_in_widget_constructors, implementation_imports, unnecessary_this, no_logic_in_create_state, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:share/share.dart';
import 'package:simpleworld/data/reaction_data.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/activity_feed.dart';
import 'package:simpleworld/widgets/count/comments_count.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/pages/create_post/post_box.dart';
import 'package:simpleworld/pages/post_screen.dart';
import 'package:simpleworld/pages/post_screen_album.dart';
import 'package:simpleworld/pages/story_list.dart';
import 'package:simpleworld/pages/suggested_users.dart';
import 'package:simpleworld/widgets/album_posts.dart';
import 'package:simpleworld/widgets/count/reaction_button.dart';
import 'package:simpleworld/widgets/count/reactions_count.dart';
import 'package:simpleworld/widgets/inline_adaptive_ads.dart';
import 'package:simpleworld/widgets/multi_manager/flick_multi_manager.dart';
import 'package:simpleworld/widgets/multi_manager/flick_multi_player.dart';
import 'package:simpleworld/widgets/photo_grid.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/single_post.dart';
import 'package:string_validator/string_validator.dart';
import 'package:timeago/timeago.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewTimeline extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String? UserId;
  final List<Reaction<String>> reactions;

  // ignore: non_constant_identifier_names
  const NewTimeline({
    Key? key,
    this.UserId,
    required this.reactions,
  }) : super(key: key);

  @override
  _NewTimelineState createState() => _NewTimelineState(currentUserId: UserId);
}

class _NewTimelineState extends State<NewTimeline> {
  final String? currentUserId;

  bool isGlobal = false;
  bool isLoading = false;
  late FlickMultiManager flickMultiManager;
  List<AlbumPosts> posts = [];

  var reportPostData;

  _NewTimelineState({
    this.currentUserId,
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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: followersPostList(currentUserId!),
    );
  }

  Widget followersPostList(String userData) {
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();
    return RefreshIndicator(
      child: PaginateFirestore(
        onEmpty: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              PostBox(currentUser: currentUser),
              const SizedBox(
                height: 210,
                child: StoryList(),
              ),
             SvgPicture.asset(
                'assets/images/no_content.svg',
                height: 260.0,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "No Posts",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        header: SliverToBoxAdapter(
            child: Column(
          children: [
            PostBox(currentUser: currentUser),
            const SizedBox(
              height: 210,
              child: StoryList(),
            ),
          ],
        )),
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshots, index) {
          final post = documentSnapshots[index].data() as Map?;
          print(post);

          if ((index + 1) % 5 == 0) {
            return Column(
              children: [
                Container(
                  height: 370,
                  color: Colors.yellow,
                  child: const SuggestedUsersList(),
                ),
                InlineAdaptiveAds(),
              ],
            );
          } else {
            return Container(
              margin: const EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              color: Theme.of(context).cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildPostHeader(post),
                  buildPostImage(post),
                  buildPostFooter(post),
                ],
              ),
            );
          }
        },
        query: timelineRef
            .doc(widget.UserId)
            .collection('timelinePosts')
            .orderBy('timestamp', descending: true),
        isLive: true,
      ),
      onRefresh: () async {
        refreshChangeListener.refreshed = true;
      },
    );
  }

  Widget buildPostHeader(post) {
    bool haslocation = post['location']?.isNotEmpty == true;
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(post['ownerId']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;

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
                      Row(
                        children: [
                          Text(
                            user.username.capitalize(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (haslocation)
                            Text(
                              ' is at ',
                              style:
                                  Theme.of(context).textTheme.caption!.copyWith(
                                        fontSize: 12.0,
                                      ),
                            ),
                          if (haslocation)
                            SizedBox(
                              width: 150,
                              child: Text(
                                '${post['location']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        format(
                            DateTime.fromMillisecondsSinceEpoch(int.parse(
                              post['timestamp'],
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
              Padding(
                padding: const EdgeInsets.only(right: 05),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        reportPostData = null;
                        reportSheet(context, post);
                      },
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPostImage(post) {
    print(post['description']);
    bool hasdesc = post['description']?.isNotEmpty == true;
    bool isPdf = post['type'] == 'pdf';
    bool isVide = post['type'] == 'video';
    bool isPhoto = post['type'] == 'photo';
    bool isText = post['type'] == 'text';
    String convertStringToLink(String textData) {
      final urlRegExp =
          RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      Iterable<RegExpMatch> matches = urlRegExp.allMatches(textData);

      matches.forEach((match) {
        textData = textData.substring(match.start, match.end);
      });
      return textData;
    }

    String userInput = convertStringToLink(post['description']!);
    bool isValid = isURL(userInput);

    if (isPhoto) {
      if (hasdesc) {
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostScreenAlbum(
                  postId: post['postId'],
                  userId: post['ownerId'],
                ),
              )),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10, left: 10),
                child: Text(
                  post['description']!,
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
                      imageUrls: post['mediaUrl'],
                      onImageClicked: (i) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreenAlbum(
                            postId: post['postId'],
                            userId: post['ownerId'],
                          ),
                        ),
                      ),
                      onExpandClicked: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreenAlbum(
                            postId: post['postId'],
                            userId: post['ownerId'],
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
              postId: post['postId'],
              userId: post['ownerId'],
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
                    imageUrls: post['mediaUrl'],
                    onImageClicked: (i) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostScreenAlbum(
                          postId: post['postId'],
                          userId: post['ownerId'],
                        ),
                      ),
                    ),
                    onExpandClicked: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostScreenAlbum(
                          postId: post['postId'],
                          userId: post['ownerId'],
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
              child: Text(post['description']!),
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
                    url: post['videoUrl']!,
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
              url: post['videoUrl']!,
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
                builder: (context) => PostScreen(
                    postId: post['postId'], userId: post['ownerId']))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(width: 10.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Linkify(text: post['description']!, softWrap: true),
                ),
                isValid
                    ? Container(
                        margin: const EdgeInsets.all(5.0),
                        child: LinkPreviewGenerator(
                          bodyMaxLines: 3,
                          borderRadius: 0,
                          link: convertStringToLink(post['description']!),
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
                  builder: (context) => PostScreen(
                      postId: post['postId'], userId: post['ownerId']))),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10, left: 10),
                child: Text(
                  post['description']!,
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
                    post['pdfName']!,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    post['pdfsize']!,
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
                builder: (context) => PostScreen(
                    postId: post['postId'], userId: post['ownerId']))),
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
              post['pdfName']!,
              style:
                  Theme.of(context).textTheme.caption!.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              post['pdfsize']!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget buildPostFooter(post) {
    bool isPhoto = post['type'] == 'photo';
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              reactionsCount(
                postId: post['postId'],
                ownerId: post['ownerId'],
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => showCommentsforalbum(
                            context,
                            postId: post['postId'],
                            ownerId: post['ownerId'],
                            // mediaUrl: post['mediaUrl'][0],
                          ),
                      child: Row(
                        children: [
                          SizedBox(
                            child: CommentsCount(
                              postId: post['postId'],
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Text(AppLocalizations.of(context)!.comments,
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
              isPhoto
                  ? Row(
                      children: <Widget>[
                        ReactionButtonWidget(
                          postId: post['postId'],
                          ownerId: post['ownerId'],
                          userId: currentUserId,
                          reactions: reactions,
                          mediaUrl: post['mediaUrl'][0],
                        ),
                        const SizedBox(width: 5.0),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        ReactionButtonWidget(
                          postId: post['postId'],
                          ownerId: post['ownerId'],
                          userId: currentUserId,
                          reactions: reactions,
                          // mediaUrl: post['mediaUrl'],
                        ),
                        const SizedBox(width: 5.0),
                      ],
                    ),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () => showCommentsforalbum(
                            context,
                            postId: post['postId'],
                            ownerId: post['ownerId'],
                            // mediaUrl: post['mediaUrl'][0],
                          ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/comment.svg",
                            height: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 5.0),
                          Text(AppLocalizations.of(context)!.comment,
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
                      onTap: () => _onShare(post, context),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/share.svg",
                            height: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 5.0),
                          Text(AppLocalizations.of(context)!.share,
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

  reportSheet(BuildContext context, post) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: radius(4)),
                      height: 4,
                      width: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              post['ownerId'] == widget.UserId
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        handleDeletePosts(context, post);
                      },
                      title: const Text(
                        "Delete Post",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15.0),
                      ),
                    )
                  : Container(),
              post['ownerId'] != widget.UserId
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        handleReportPosts(context, post);
                      },
                      title: const Text(
                        "Report",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15.0),
                      ),
                    )
                  : Container(),
              post['ownerId'] != widget.UserId
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        handleHidePosts(context, post);
                      },
                      title: const Text(
                        "Hide",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15.0),
                      ),
                    )
                  : Container(),
              post['ownerId'] != widget.UserId
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: const Text(
                        "Block User",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15.0),
                      ),
                    )
                  : Container(),
              post['ownerId'] != widget.UserId
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: const Text(
                        "Save Post",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15.0),
                      ),
                    )
                  : Container(),
            ],
          );
        });
      },
    );
  }

  void deleteNestedSubcollections(post) {
    Future<QuerySnapshot> photos = postsRef
        .doc(post['ownerId'])
        .collection("userPosts")
        .doc(post['postId'])
        .collection("albumposts")
        .get();
    photos.then((value) {
      value.docs.forEach((element) {
        postsRef
            .doc(post['ownerId'])
            .collection("userPosts")
            .doc(post['postId'])
            .collection("albumposts")
            .doc(element.id)
            .delete()
            .then((value) => print("success"));
      });
      FirebaseStorage.instance.refFromURL(post['mediaUrl']!).delete();
    });
  }

  deletePost(post) async {
    bool isPdf = post['type'] == 'pdf';
    bool isVide = post['type'] == 'video';
    bool isPhoto = post['type'] == 'photo';
    postsRef
        .doc(post['ownerId'])
        .collection('userPosts')
        .doc(post['postId'])
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    deleteNestedSubcollections(post);
    if (isPdf) {
      FirebaseStorage.instance.refFromURL(post['pdfUrl']!).delete();
    } else if (isVide) {
      FirebaseStorage.instance.refFromURL(post['videoUrl']!).delete();
    } else {
      FirebaseStorage.instance.refFromURL(post['mediaUrl']!).delete();
    }

    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(post['ownerId'])
        .collection("feedItems")
        .where('postId', isEqualTo: post['postId'])
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(post['postId']).collection('comments').get();
    commentsSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  hidePost(post) async {
    timelineRef
        .doc(widget.UserId)
        .collection('timelinePosts')
        .doc(post['postId'])
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  _onShare(post, BuildContext context) async {
    bool hasdesc = post['description']?.isNotEmpty == true;
    bool isPdf = post['type'] == 'pdf';
    bool isVide = post['type'] == 'video';
    bool isPhoto = post['type'] == 'photo';
    bool isText = post['type'] == 'text';
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (isPhoto) {
      await Share.share(post['mediaUrl'][0],
          subject: post['description'],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else if (isPdf) {
      // _downloadFile(post['pdfUrl'.);
      await Share.share(post['pdfUrl'],
          subject: post['description'],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else if (isVide) {
      await Share.share(post['videoUrl'],
          subject: post['description'],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(post['description']!,
          subject: post['description'],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  handleDeletePosts(BuildContext parentConext, post) {
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Remove this Post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost(post);
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

  handleHidePosts(BuildContext parentConext, post) {
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Hide this Post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  hidePost(post);
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

  handleReportPosts(BuildContext parentConext, post) {
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Are you sure you want to Report this Post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  reportPost(post);
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

  reportPost(post) async {
    reportsRef.doc(post['postId']).set({});
    simpleworldtoast("", "Post was reported to Admin", context);
  }
}
