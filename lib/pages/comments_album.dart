import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/_build_list.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class AlbumComments extends StatefulWidget {
  final String userId;
  final String? postId;
  final String? postOwnerId;

  const AlbumComments({
    Key? key,
    required this.userId,
    this.postId,
    this.postOwnerId,
  }) : super(key: key);

  @override
  State<AlbumComments> createState() => _CommentsState();
}

class _CommentsState extends State<AlbumComments> {
  final TextEditingController _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final List<Comment> comments = [];
  final ScrollController _scrollController = ScrollController();
  final bool _isReverse = false;

  _getDateFromMilliseconds(int milliseconds) {
    try {
      final a = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return timeago.format(a);
    } catch (e) {
      return timeago.format(DateTime.now());
    }
  }

  final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    primary: Colors.black87,
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildComments()),
          // const Divider(),
          ListTile(
            title: TextFormField(
              style: Theme.of(context).textTheme.bodyText2,
              decoration: InputDecoration(
                hintText: "Type here",
                hintStyle: Theme.of(context).textTheme.bodyText2,
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(40),
                  ),
                  borderSide: BorderSide(
                      color: Theme.of(context).shadowColor, width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(40),
                  ),
                  borderSide: BorderSide(
                      color: Theme.of(context).shadowColor, width: 0),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                filled: true,
                fillColor: Theme.of(context).canvasColor,
              ),
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (message) {
                if (_commentController.text != '') {
                  _addComment(
                    userId: widget.userId,
                    postOwnerId: widget.postOwnerId,
                    postId: widget.postId,
                  );
                } else {
                  simpleworldtoast("", "Please Enter a comment", context);
                }
              },
              focusNode: _commentFocusNode,
              controller: _commentController,
              textCapitalization: TextCapitalization.sentences,
            ),
            trailing: IconButton(
              icon: Icon(Icons.send,
                  size: 20, color: Theme.of(context).iconTheme.color),
              alignment: Alignment.center,
              onPressed: (() {
                if (_commentController.text != '') {
                  _addComment(
                    userId: widget.userId,
                    postOwnerId: widget.postOwnerId,
                    postId: widget.postId,
                  );
                } else {
                  simpleworldtoast("", "Please Enter a comment", context);
                }
              }),
            ),
          )
        ],
      ),
    );
  }

  void _addComment({
    required String userId,
    required String? postOwnerId,
    required String? postId,
  }) {
    DateTime date = DateTime.now();
    usersCollection.doc(userId).get().then((value) {
      final data = value.data();
      String username = data?['username'];
      String userId = data?['id'];
      String photoUrl = data?['photoUrl'];
      commentsCollection.doc(postId).collection("comments").add({
        "postOwnerId": postOwnerId,
        "username": username,
        "comment": _commentController.text,
        "createAt": date.millisecondsSinceEpoch,
        "avatarUrl": photoUrl,
        "userId": userId,
      }).then((value) {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        if (_scrollController.offset == 0.0) {
          maxScrollExtent += 100;
        }
        _scrollController.animateTo(
          _isReverse ? 0.0 : maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
        _commentFocusNode.requestFocus();
        _commentController.clear();
      });
    });
  }

  Widget _buildComments() {
    return StreamBuilder<QuerySnapshot>(
        stream: commentsCollection
            .doc(widget.postId)
            .collection('comments')
            .orderBy("createAt", descending: _isReverse)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: circularProgress(),
            );
          } else {
            final docs = snapshot.data?.docs;
            if (docs == null) {
              return Container();
            }
            return ListView.builder(
              padding: const EdgeInsets.only(left: 12, right: 12),
              reverse: _isReverse,
              controller: _scrollController,
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    doc['avatarUrl'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: CachedNetworkImage(
                              imageUrl: doc['avatarUrl'],
                              height: 40,
                              width: 40,
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
                              width: 40,
                            ),
                          ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 4,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['username'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              doc['comment'],
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              _getDateFromMilliseconds(doc['createAt']),
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          }
        });
  }

  // static final commentsCol = commentsCollection.withConverter<Comment>(
  //   fromFirestore: (m, _) => Comment.fromJson(m.data()!),
  //   toFirestore: (m, _) => m.toJson(),
  // );

  // static DocumentReference<Comment> commentDoc(String? commentID) =>
  //     commentsCol.doc(commentID);

  // static Stream<List<Comment>> commentsStream(String postId, int offset) {
  //   return commentsCol
  //       .where('postId', isEqualTo: postId)
  //       .orderBy('createAt', descending: true)
  //       .limit(offset)
  //       .snapshots()
  //       .map(
  //         (s) => [for (final d in s.docs) d.data()],
  //       );
  // }

  // static Stream<Comment> singleCommentStream(String id) {
  //   return commentDoc(id).snapshots().map(
  //         (s) => s.data()!,
  //       );
  // }
}
