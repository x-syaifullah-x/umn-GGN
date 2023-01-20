// ignore_for_file: use_key_in_widget_constructors, implementation_imports, unnecessary_this

import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:global_net/data/reaction_data.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/post_layout.dart';

class AllVideos extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String? UserId;
  final List<Reaction<String>> reactions;

  // ignore: non_constant_identifier_names
  const AllVideos({
    Key? key,
    this.UserId,
    required this.reactions,
  }) : super(key: key);

  @override
  _AllVideosState createState() => _AllVideosState(currentUserId: UserId);
}

class _AllVideosState extends State<AllVideos> {
  final String? currentUserId;

  _AllVideosState({
    this.currentUserId,
  });

  @override
  void initState() {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(context, titleText: "Videos", removeBackButton: false),
      body: storyList(currentUserId!),
    );
  }

  Widget storyList(String userData) {
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();
    return RefreshIndicator(
      child: PaginateFirestore(
        onEmpty: Padding(
          padding: EdgeInsets.zero,
          child: Center(
            child: Column(
              children: [
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
        ),
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshot, index) {
          final post = documentSnapshot[index].data() as Map?;
          return PostLayout(
            UserId: widget.UserId,
            ownerId: post!['ownerId'],
            postId: post['postId'],
            username: post['username'],
            pdfUrl: post['pdfUrl'],
            pdfName: post['pdfName'],
            pdfsize: post['pdfsize'],
            description: post['description'],
            mediaUrl: post['mediaUrl'],
            type: post['type'],
            timestamp: post['timestamp'],
            videoUrl: post['videoUrl'],
            reactions: reactions,
          );
        },
        query: timelineRef
            .doc(widget.UserId)
            .collection('timelinePosts')
            .where('type', isEqualTo: 'video')
            .orderBy('timestamp', descending: true),
        isLive: true,
      ),
      onRefresh: () async {
        refreshChangeListener.refreshed = true;
      },
    );
  }
}
