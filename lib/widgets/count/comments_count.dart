import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/_build_list.dart';

class CommentsCount extends StatefulWidget {
  final String? postId;

  const CommentsCount({
    Key? key,
    this.postId,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  CommentsState createState() => CommentsState(
        postId: postId,
      );
}

class CommentsState extends State<CommentsCount> {
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];
  final String? postId;

  CommentsState({
    this.postId,
  });

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> requestCount() {
    return commentsRef.doc(postId).collection('comments').snapshots();
  }

  @override
  Widget build(BuildContext context) {
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
      },
    );
  }
}
