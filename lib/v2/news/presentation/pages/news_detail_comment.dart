import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as time_ago;

import '../../data/bing_news/data/response/bing_news_response.dart';

class NewsDetailComment extends StatefulWidget {
  const NewsDetailComment({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BingNewsResponse data;

  @override
  State<NewsDetailComment> createState() => _NewsDetailCommentState();
}

class _NewsDetailCommentState extends State<NewsDetailComment> {
  final textEditingController = TextEditingController();

  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.data.name,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final collections = FirebaseFirestore.instance
        .collection('news')
        .doc('comment')
        .collection(widget.data.name);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                collections.orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              final snapshotData = snapshot.data;
              if (snapshotData != null) {
                return ListView.builder(
                  itemCount: snapshotData.size,
                  itemBuilder: (context, index) {
                    final data = snapshotData.docs[index];
                    final uid = data['uid'];
                    final userName = data['userName'];
                    final comment = data['comment'];
                    final timestamp = data['timestamp'];
                    final photoUrl = data['photoUrl'];
                    final dateTime =
                        DateTime.fromMillisecondsSinceEpoch(timestamp);
                    return Card(
                      margin: const EdgeInsets.all(4),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: CachedNetworkImage(
                                imageUrl: photoUrl,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(comment),
                                const SizedBox(height: 8),
                                Text(time_ago.format(dateTime))
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Text('no comment');
              }
            },
          ),
        ),
        Container(
          margin:
              const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 12),
          child: TextFormField(
            onFieldSubmitted: (comment) {
              _sendComment(
                controller: textEditingController,
                focusNode: focusNode,
                collections: collections,
              );
            },
            controller: textEditingController,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              isDense: true,
              hintStyle: Theme.of(context).textTheme.bodyText2,
              suffixIcon: InkWell(
                child: const Icon(Icons.send),
                onTap: () {
                  _sendComment(
                    controller: textEditingController,
                    focusNode: focusNode,
                    collections: collections,
                  );
                },
              ),
              hintText: 'Write Comment',
              contentPadding: const EdgeInsets.only(left: 25),
              filled: true,
              fillColor: Colors.grey[300],
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1.5,
                  color: Colors.grey,
                ), //<-- SEE HERE
                borderRadius: BorderRadius.circular(25.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1.5,
                  color: Colors.grey,
                ), //<-- SEE HERE
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _sendComment({
    required TextEditingController controller,
    required FocusNode focusNode,
    required CollectionReference<Map<String, dynamic>> collections,
  }) async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      final user =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userName = user['username'];
      final photoUrl = user['photoUrl'];
      final comment = controller.text;
      collections.add({
        'photoUrl': photoUrl,
        'uid': uid,
        'userName': userName,
        'comment': comment,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      controller.clear();
      focusNode.requestFocus();
    }
  }
}
