import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/_build_list.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReactionButtonWidget extends StatefulWidget {
  const ReactionButtonWidget({
    Key? key,
    this.postId,
    this.ownerId,
    this.userId,
    this.mediaUrl,
    required this.reactions,
    this.color,
  }) : super(key: key);

  final String? postId;
  final String? ownerId;
  final String? userId;
  final String? mediaUrl;
  final List<Reaction<String>> reactions;
  final Color? color;

  @override
  ReactionButtonWidgetState createState() => ReactionButtonWidgetState();
}

class ReactionButtonWidgetState extends State<ReactionButtonWidget> {
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];
  bool isHappy = false;
  bool isSad = false;
  bool isAngry = false;
  bool isInlove = false;
  bool isSurprised = false;
  bool isLike = false;

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
    try {
      DocumentSnapshot doc = await postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .get();
      setState(() {
        isHappy = doc.exists;
      });
    } catch (e) {}
  }

  checkIfSad() async {
    try {
      DocumentSnapshot doc = await postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .get();
      setState(() {
        isSad = doc.exists;
      });
    } catch (e) {}
  }

  checkIfAngry() async {
    try {
      DocumentSnapshot doc = await postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .get();
      setState(() {
        isAngry = doc.exists;
      });
    } catch (e) {}
  }

  checkIfInlove() async {
    try {
      DocumentSnapshot doc = await postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .get();
      setState(() {
        isInlove = doc.exists;
      });
    } catch (e) {}
  }

  checkIfSurprised() async {
    try {
      DocumentSnapshot doc = await postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .get();
      setState(() {
        isSurprised = doc.exists;
      });
    } catch (e) {}
  }

  checkIfLike() async {
    try {
      DocumentSnapshot doc = await postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .get();
      try {
        setState(() {
          isLike = doc.exists;
        });
      } catch (e) {
        print(e);
      }
    } catch (e) {}
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = widget.userId != widget.ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(widget.ownerId)
          .collection("feedItems")
          .doc(widget.postId)
          .set({
        "type": "like",
        "username": globalName,
        "userId": widget.userId,
        "userProfileImg": globalImage,
        "postId": widget.postId,
        "mediaUrl": widget.mediaUrl,
        "timestamp": timestamp,
        "isSeen": false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLike) {
      return FittedBox(
        child: ReactionButtonToggle<String>(
          onReactionChanged: (String? value, bool isChecked) {
            handleLikePost('$value');
          },
          reactions: widget.reactions,
          initialReaction: widget.reactions[0],
          selectedReaction: widget.reactions[0],
        ),
      );
    } else if (isHappy) {
      return FittedBox(
        child: ReactionButtonToggle<String>(
          onReactionChanged: (String? value, bool isChecked) {
            print('Selected value: $value, isChecked: $isChecked');
            handleLikePost('$value');
          },
          reactions: widget.reactions,
          initialReaction: widget.reactions[1],
          selectedReaction: widget.reactions[0],
        ),
      );
    } else if (isSad) {
      return FittedBox(
        child: ReactionButtonToggle<String>(
          onReactionChanged: (String? value, bool isChecked) {
            print('Selected value: $value, isChecked: $isChecked');
            handleLikePost('$value');
          },
          reactions: widget.reactions,
          initialReaction: widget.reactions[2],
          selectedReaction: widget.reactions[0],
        ),
      );
    } else if (isAngry) {
      return FittedBox(
        child: ReactionButtonToggle<String>(
          onReactionChanged: (String? value, bool isChecked) {
            print('Selected value: $value, isChecked: $isChecked');
            handleLikePost('$value');
          },
          reactions: widget.reactions,
          initialReaction: widget.reactions[3],
          selectedReaction: widget.reactions[0],
        ),
      );
    } else if (isInlove) {
      return FittedBox(
        child: ReactionButtonToggle<String>(
          onReactionChanged: (String? value, bool isChecked) {
            print('Selected value: $value, isChecked: $isChecked');
            handleLikePost('$value');
          },
          reactions: widget.reactions,
          initialReaction: widget.reactions[4],
          selectedReaction: widget.reactions[0],
        ),
      );
    } else if (isSurprised) {
      return FittedBox(
        child: ReactionButtonToggle<String>(
          onReactionChanged: (String? value, bool isChecked) {
            print('Selected value: $value, isChecked: $isChecked');
            handleLikePost('$value');
          },
          reactions: widget.reactions,
          initialReaction: widget.reactions[5],
          selectedReaction: widget.reactions[0],
        ),
      );
    }

    return FittedBox(
      child: ReactionButtonToggle<String>(
        onReactionChanged: (String? value, bool isChecked) {
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
                color: widget.color,
              ),
              const SizedBox(width: 5.0),
              Text(AppLocalizations.of(context)!.like,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: widget.color,
                  )),
            ],
          ),
        ),
        selectedReaction: widget.reactions[0],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (isLike) {
  //     return Row(
  //       children: [
  //         FittedBox(
  //           child: ReactionButtonToggle<String>(
  //             onReactionChanged: (String? value, bool isChecked) {
  //               print('Selected value: $value, isChecked: $isChecked');
  //               handleLikePost('$value');
  //             },
  //             reactions: widget.reactions,
  //             initialReaction: widget.reactions[0],
  //             selectedReaction: widget.reactions[0],
  //           ),
  //         )
  //       ],
  //     );
  //   } else if (isHappy) {
  //     return Row(
  //       children: [
  //         FittedBox(
  //           child: ReactionButtonToggle<String>(
  //             onReactionChanged: (String? value, bool isChecked) {
  //               print('Selected value: $value, isChecked: $isChecked');
  //               handleLikePost('$value');
  //             },
  //             reactions: widget.reactions,
  //             initialReaction: widget.reactions[1],
  //             selectedReaction: widget.reactions[0],
  //           ),
  //         )
  //       ],
  //     );
  //   } else if (isSad) {
  //     return Row(
  //       children: [
  //         FittedBox(
  //           child: ReactionButtonToggle<String>(
  //             onReactionChanged: (String? value, bool isChecked) {
  //               print('Selected value: $value, isChecked: $isChecked');
  //               handleLikePost('$value');
  //             },
  //             reactions: widget.reactions,
  //             initialReaction: widget.reactions[2],
  //             selectedReaction: widget.reactions[0],
  //           ),
  //         )
  //       ],
  //     );
  //   } else if (isAngry) {
  //     return Row(
  //       children: [
  //         FittedBox(
  //           child: ReactionButtonToggle<String>(
  //             onReactionChanged: (String? value, bool isChecked) {
  //               print('Selected value: $value, isChecked: $isChecked');
  //               handleLikePost('$value');
  //             },
  //             reactions: widget.reactions,
  //             initialReaction: widget.reactions[3],
  //             selectedReaction: widget.reactions[0],
  //           ),
  //         )
  //       ],
  //     );
  //   } else if (isInlove) {
  //     return Row(
  //       children: [
  //         FittedBox(
  //           child: ReactionButtonToggle<String>(
  //             onReactionChanged: (String? value, bool isChecked) {
  //               print('Selected value: $value, isChecked: $isChecked');
  //               handleLikePost('$value');
  //             },
  //             reactions: widget.reactions,
  //             initialReaction: widget.reactions[4],
  //             selectedReaction: widget.reactions[0],
  //           ),
  //         )
  //       ],
  //     );
  //   } else if (isSurprised) {
  //     return Row(
  //       children: [
  //         FittedBox(
  //           child: ReactionButtonToggle<String>(
  //             onReactionChanged: (String? value, bool isChecked) {
  //               print('Selected value: $value, isChecked: $isChecked');
  //               handleLikePost('$value');
  //             },
  //             reactions: widget.reactions,
  //             initialReaction: widget.reactions[5],
  //             selectedReaction: widget.reactions[0],
  //           ),
  //         )
  //       ],
  //     );
  //   }

  //   return Row(
  //     children: [
  //       FittedBox(
  //         child: ReactionButtonToggle<String>(
  //           onReactionChanged: (String? value, bool isChecked) {
  //             print('Selected value: $value, isChecked: $isChecked');
  //             handleLikePost('$value');
  //           },
  //           reactions: widget.reactions,
  //           initialReaction: Reaction<String>(
  //             value: null,
  //             icon: Row(
  //               children: [
  //                 SvgPicture.asset(
  //                   "assets/images/thumbs-up.svg",
  //                   height: 20,
  //                   color: Theme.of(context).iconTheme.color,
  //                 ),
  //                 const SizedBox(width: 5.0),
  //                 Text(AppLocalizations.of(context)!.like,
  //                     style: TextStyle(
  //                       fontSize: 14.0,
  //                       color: Theme.of(context).iconTheme.color,
  //                     )),
  //               ],
  //             ),
  //           ),
  //           selectedReaction: widget.reactions[0],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  handleLikePost(String value) {
    if (value == 'Happy') {
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Sad') {
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Angry') {
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'In love') {
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Surprised') {
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .set({});
      addLikeToActivityFeed();
    } else if (value == 'Like') {
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('happy')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('sad')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('angry')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('inlove')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('surprised')
          .doc(widget.userId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      postsRef
          .doc(widget.ownerId)
          .collection('userPosts')
          .doc(widget.postId)
          .collection('like')
          .doc(widget.userId)
          .set({});
      addLikeToActivityFeed();
    }
  }
}
