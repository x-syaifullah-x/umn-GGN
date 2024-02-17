import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/_build_list.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
  final String? photoId;

  const Comments(
      {Key? key,
      this.postId,
      this.postOwnerId,
      this.postMediaUrl,
      this.photoId})
      : super(key: key);

  factory Comments.fromDocument(DocumentSnapshot doc) {
    return Comments(
        postId: doc['postId'],
        postOwnerId: doc['postOwnerId'],
        postMediaUrl: doc['postMediaUrl'],
        photoId: doc['photoId']);
  }

  Future<List<Comment>> getAllcoments() async =>
      commentsCollection.get().then((result) {
        List<Comment> comments = [];
        for (DocumentSnapshot comment in result.docs) {
          comments.add(Comment.fromDocument(comment));
        }
        return comments;
      });

  @override
  // ignore: no_logic_in_create_state
  CommentsState createState() => CommentsState(
        postId: postId,
        postOwnerId: postOwnerId,
        postMediaUrl: postMediaUrl,
        photoId: photoId,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
  final String? photoId;

  CommentsState(
      {this.postId, this.postOwnerId, this.postMediaUrl, this.photoId});

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
        stream: postsCollection
            .doc(globalID)
            .collection('userPosts')
            .doc(postId)
            .collection("albumposts")
            .doc(photoId)
            .collection("comments")
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: circularProgress(),
            );
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['comment']),
                  leading: doc['avatarUrl'].isNotEmpty
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
                  subtitle: Text(timeago.format(doc['timestamp'].toDate())),
                );
              }).toList(),
            );
          }
        });
  }

  addComment() {
    postsCollection
        .doc(globalID)
        .collection('userPosts')
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .collection("comments")
        .add({
      "username": globalName,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": globalImage,
      "userId": globalID,
    });
    bool isNotPostOwner = postOwnerId != globalID;
    if (isNotPostOwner) {
      feedCollection.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timestamp,
        "postId": postId,
        "userId": globalID,
        "username": globalName,
        "userProfileImg": globalImage,
        "mediaUrl": postMediaUrl,
      });
    }
    commentController.clear();
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
          Expanded(child: buildComments()),
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
                if (commentController.text != '') {
                  addComment();
                } else {
                  simpleworldtoast("", "Please Enter a comment", context);
                }
              },
              controller: commentController,
              textCapitalization: TextCapitalization.sentences,
            ),
            trailing: IconButton(
              icon: Icon(Icons.send,
                  size: 20, color: Theme.of(context).iconTheme.color),
              alignment: Alignment.center,
              onPressed: (() {
                if (commentController.text != '') {
                  addComment();
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

  static final commentsCol = commentsCollection.withConverter<Comment>(
    fromFirestore: (m, _) => Comment.fromJson(m.data()!),
    toFirestore: (m, _) => m.toJson(),
  );
  static DocumentReference<Comment> commentDoc(String? commentID) =>
      commentsCol.doc(commentID);

  static Stream<List<Comment>> commentsStream(String postId, int offset) {
    return commentsCol
        .where('postId', isEqualTo: postId)
        .orderBy('timestamp', descending: true)
        .limit(offset)
        .snapshots()
        .map(
          (s) => [for (final d in s.docs) d.data()],
        );
  }

  static Stream<Comment> singleCommentStream(String id) {
    return commentDoc(id).snapshots().map(
          (s) => s.data()!,
        );
  }
}
