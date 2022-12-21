// ignore_for_file: no_logic_in_create_state, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/_build_list.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class ReactionButtonAlbumPostsWidget extends StatefulWidget {
  final String? postId;
  final String? ownerId;
  final String? userId;
  final String? mediaUrl;
  final String? photoId;
  final List<Reaction<String>> reactions;

  const ReactionButtonAlbumPostsWidget({
    Key? key,
    this.postId,
    this.ownerId,
    this.userId,
    this.mediaUrl,
    this.photoId,
    required this.reactions,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  ReactionButtonAlbumPostsWidgetState createState() =>
      ReactionButtonAlbumPostsWidgetState(
        postId: postId,
        ownerId: ownerId,
        userId: userId,
        mediaUrl: mediaUrl,
        photoId: photoId,
      );
}

class ReactionButtonAlbumPostsWidgetState
    extends State<ReactionButtonAlbumPostsWidget> {
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];
  final String? postId;
  final String? ownerId;
  final String? userId;
  final String? photoId;

  final String? mediaUrl;
  bool isHappy = false;
  bool isSad = false;
  bool isAngry = false;
  bool isInlove = false;
  bool isSurprised = false;
  bool isLike = false;

  ReactionButtonAlbumPostsWidgetState({
    this.postId,
    this.ownerId,
    this.userId,
    this.mediaUrl,
    this.photoId,
  });

  @override
  void initState() {
    super.initState();
    checkIfHappy();
    checkIfSad();
    checkIfAngry();
    checkIfInlove();
    checkIfSurprised();
    checkIfLike();
  }

  checkIfHappy() async {
    DocumentSnapshot doc = await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection('happy')
        .doc(userId)
        .get();
    setState(() {
      isHappy = doc.exists;
    });
  }

  checkIfSad() async {
    DocumentSnapshot doc = await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection('sad')
        .doc(userId)
        .get();
    setState(() {
      isSad = doc.exists;
    });
  }

  checkIfAngry() async {
    DocumentSnapshot doc = await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection('angry')
        .doc(userId)
        .get();
    setState(() {
      isAngry = doc.exists;
    });
  }

  checkIfInlove() async {
    DocumentSnapshot doc = await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection('inlove')
        .doc(userId)
        .get();
    setState(() {
      isInlove = doc.exists;
    });
  }

  checkIfSurprised() async {
    DocumentSnapshot doc = await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection('surprised')
        .doc(userId)
        .get();
    setState(() {
      isSurprised = doc.exists;
    });
  }

  checkIfLike() async {
    DocumentSnapshot doc = await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection('like')
        .doc(userId)
        .get();
    setState(() {
      isLike = doc.exists;
    });
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = userId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection("feedItems").add({
        "type": "like",
        "username": globalName,
        "userId": userId,
        "userProfileImg": globalImage,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
        "isSeen": false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLike) {
      return Row(
        children: [
          FittedBox(
            child: ReactionButtonToggle<String>(
              onReactionChanged: (String? value, bool isChecked) {
                print('Selected value: $value, isChecked: $isChecked');
                handleLikePost('$value');
              },
              reactions: widget.reactions,
              initialReaction: widget.reactions[0],
              selectedReaction: widget.reactions[0],
            ),
          )
        ],
      );
    } else if (isHappy) {
      return Row(
        children: [
          FittedBox(
            child: ReactionButtonToggle<String>(
              onReactionChanged: (String? value, bool isChecked) {
                print('Selected value: $value, isChecked: $isChecked');
                handleLikePost('$value');
              },
              reactions: widget.reactions,
              initialReaction: widget.reactions[1],
              selectedReaction: widget.reactions[0],
            ),
          )
        ],
      );
    } else if (isSad) {
      return Row(
        children: [
          FittedBox(
            child: ReactionButtonToggle<String>(
              onReactionChanged: (String? value, bool isChecked) {
                print('Selected value: $value, isChecked: $isChecked');
                handleLikePost('$value');
              },
              reactions: widget.reactions,
              initialReaction: widget.reactions[2],
              selectedReaction: widget.reactions[0],
            ),
          )
        ],
      );
    } else if (isAngry) {
      return Row(
        children: [
          FittedBox(
            child: ReactionButtonToggle<String>(
              onReactionChanged: (String? value, bool isChecked) {
                print('Selected value: $value, isChecked: $isChecked');
                handleLikePost('$value');
              },
              reactions: widget.reactions,
              initialReaction: widget.reactions[3],
              selectedReaction: widget.reactions[0],
            ),
          )
        ],
      );
    } else if (isInlove) {
      return Row(
        children: [
          FittedBox(
            child: ReactionButtonToggle<String>(
              onReactionChanged: (String? value, bool isChecked) {
                print('Selected value: $value, isChecked: $isChecked');
                handleLikePost('$value');
              },
              reactions: widget.reactions,
              initialReaction: widget.reactions[4],
              selectedReaction: widget.reactions[0],
            ),
          )
        ],
      );
    } else if (isSurprised) {
      return Row(
        children: [
          FittedBox(
            child: ReactionButtonToggle<String>(
              onReactionChanged: (String? value, bool isChecked) {
                print('Selected value: $value, isChecked: $isChecked');
                handleLikePost('$value');
              },
              reactions: widget.reactions,
              initialReaction: widget.reactions[5],
              selectedReaction: widget.reactions[0],
            ),
          )
        ],
      );
    }

    return Row(
      children: [
        FittedBox(
          child: ReactionButtonToggle<String>(
            onReactionChanged: (String? value, bool isChecked) {
              print('Selected value: $value, isChecked: $isChecked');
              handleLikePost('$value');
            },
            reactions: widget.reactions,
            initialReaction: Reaction<String>(
              value: null,
              icon: Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/thumbs-up.svg",
                    height: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 5.0),
                  Text('Like',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).iconTheme.color,
                      )),
                ],
              ),
            ),
            selectedReaction: widget.reactions[0],
          ),
        ),
      ],
    );
  }

  handleLikePost(String value) {
    if (value == 'Happy') {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('sad')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('angry')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('inlove')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('surprised')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('like')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('happy')
          .doc(userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Sad') {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('happy')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('angry')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('inlove')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('surprised')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('like')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('sad')
          .doc(userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Angry') {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('happy')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('sad')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('inlove')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('surprised')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('like')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('angry')
          .doc(userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'In love') {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('happy')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('sad')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('angry')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('surprised')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('like')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('inlove')
          .doc(userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Surprised') {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('happy')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('sad')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('angry')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('inlove')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('like')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('surprised')
          .doc(userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Like') {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('happy')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('sad')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('angry')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('inlove')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('surprised')
          .doc(userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc(photoId)
          .collection('like')
          .doc(userId)
          .set({});
      addLikeToActivityFeed();
    }
  }
}
