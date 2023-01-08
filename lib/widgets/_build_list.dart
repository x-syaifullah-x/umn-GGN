import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_net/pages/home.dart';

class Comment {
  // final CommentModel not;

  final String? username;
  final String? userId;
  final String? avatarUrl;
  final String? comment;
  final Timestamp? timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      username: json['username'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      timestamp: json['timestamp'],
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "userId": userId,
        "comment": comment,
        "timestamp": timestamp,
        "avatarUrl": avatarUrl,
      };

  Future<List<Comment>> getAllcoments() async =>
      commentsRef.get().then((result) {
        List<Comment> comments = [];
        for (DocumentSnapshot comment in result.docs) {
          comments.add(Comment.fromDocument(comment));
        }
        return comments;
      });
}
