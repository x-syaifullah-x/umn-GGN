import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/home/home.dart';

class ReactionsCount extends StatefulWidget {
  final String? postId;
  final String? ownerId;

  const ReactionsCount({
    Key? key,
    this.postId,
    this.ownerId,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  ReactionsCountState createState() => ReactionsCountState(
        postId: postId,
        ownerId: ownerId,
      );
}

class ReactionsCountState extends State<ReactionsCount> {
  final String? postId;
  final String? ownerId;
  bool showHappy = false;
  bool showSad = false;
  bool showAngry = false;
  bool showInlove = false;
  bool showSurprised = false;
  bool showMad = false;

  ReactionsCountState({
    this.postId,
    this.ownerId,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (showHappy) {
      return Row(
        children: <Widget>[
          const SizedBox(width: 5),
          Image.asset('assets/images/haha2.png', height: 20),
          const SizedBox(width: 3),
          SizedBox(
            child: happyCount(),
          ),
          const SizedBox(width: 5),
        ],
      );
    }
    return Row(
      children: <Widget>[
        likeCount(),
        happyCount(),
        sadCount(),
        angryCount(),
        loveCount(),
        suprisedCount(),
      ],
    );
  }

  Widget likeCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(ownerId)
            .collection('userPosts')
            .doc(postId)
            .collection('like')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool showLike = (snapshot.data!.size.toString()) == '0';
            // ignore: unrelated_type_equality_checks
            if (showLike) {
              return const SizedBox();
            } else {
              return Row(
                children: <Widget>[
                  Image.asset('assets/images/like.gif', height: 20),
                  const SizedBox(width: 3),
                  SizedBox(
                    child: Text(snapshot.data!.size.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).iconTheme.color,
                        )),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  Widget happyCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(ownerId)
            .collection('userPosts')
            .doc(postId)
            .collection('happy')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool showhappy = (snapshot.data!.size.toString()) == '0';
            // ignore: unrelated_type_equality_checks
            if (showhappy) {
              return const SizedBox();
            } else {
              return Row(
                children: <Widget>[
                  Image.asset('assets/images/haha2.png', height: 20),
                  const SizedBox(width: 3),
                  SizedBox(
                    child: Text(snapshot.data!.size.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).iconTheme.color,
                        )),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  Widget sadCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(ownerId)
            .collection('userPosts')
            .doc(postId)
            .collection('sad')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool showSad = (snapshot.data!.size.toString()) == '0';
            // ignore: unrelated_type_equality_checks
            if (showSad) {
              return const SizedBox();
            } else {
              return Row(
                children: <Widget>[
                  Image.asset('assets/images/sad2.png', height: 20),
                  const SizedBox(width: 3),
                  SizedBox(
                    child: Text(snapshot.data!.size.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).iconTheme.color,
                        )),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  Widget angryCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(ownerId)
            .collection('userPosts')
            .doc(postId)
            .collection('angry')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool showangry = (snapshot.data!.size.toString()) == '0';
            // ignore: unrelated_type_equality_checks
            if (showangry) {
              return const SizedBox();
            } else {
              return Row(
                children: <Widget>[
                  Image.asset('assets/images/angry2.png', height: 20),
                  const SizedBox(width: 3),
                  SizedBox(
                    child: Text(snapshot.data!.size.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).iconTheme.color,
                        )),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  Widget loveCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(ownerId)
            .collection('userPosts')
            .doc(postId)
            .collection('inlove')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool showinlove = (snapshot.data!.size.toString()) == '0';
            // ignore: unrelated_type_equality_checks
            if (showinlove) {
              return const SizedBox();
            } else {
              return Row(
                children: <Widget>[
                  Image.asset('assets/images/love2.png', height: 20),
                  const SizedBox(width: 3),
                  SizedBox(
                    child: Text(snapshot.data!.size.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).iconTheme.color,
                        )),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  Widget suprisedCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(ownerId)
            .collection('userPosts')
            .doc(postId)
            .collection('surprised')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool showsurprised = (snapshot.data!.size.toString()) == '0';
            // ignore: unrelated_type_equality_checks
            if (showsurprised) {
              return const SizedBox();
            } else {
              return Row(
                children: <Widget>[
                  Image.asset('assets/images/wow2.png', height: 20),
                  const SizedBox(width: 3),
                  SizedBox(
                    child: Text(snapshot.data!.size.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).iconTheme.color,
                        )),
                  ),
                  const SizedBox(width: 5),
                ],
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }
}
