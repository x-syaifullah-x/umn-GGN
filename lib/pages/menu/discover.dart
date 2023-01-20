// ignore_for_file: use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/post_screen_album.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/photo_grid.dart';

import '../../widgets/simple_world_widgets.dart';

class Discover extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String? UserId;

  // ignore: non_constant_identifier_names
  const Discover({Key? key, this.UserId}) : super(key: key);

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  final String? currentUserId = globalID;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(context, titleText: "Discover", removeBackButton: false),
      body: storyList(currentUserId!),
    );
  }

  Widget storyList(String userData) {
    return StreamBuilder(
      stream: timelineRef
          .doc(widget.UserId)
          .collection('timelinePosts')
          .where('type', isEqualTo: 'photo')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: snapshot.data!.docs.isNotEmpty
                ? StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    staggeredTileBuilder: (index) => StaggeredTile.count(
                        (index % 6 == 0) ? 2 : 1, (index % 6 == 0) ? 2 : 1),
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, int index) {
                      List stories = snapshot.data!.docs;
                      return buildItem(stories, index);
                    },
                  )
                : Center(
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
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: const <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  Widget buildItem(List stories, int index) {
    bool hasImage = stories[index]['mediaUrl']?.isNotEmpty == true;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: hasImage
          ? GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostScreenAlbum(
                          postId: stories[index]['postId'],
                          userId: stories[index]['ownerId']))),
              child: PhotoGrid(
                imageUrls: stories[index]['mediaUrl'],
                onImageClicked: (i) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostScreenAlbum(
                      postId: stories[index]['postId'],
                      userId: stories[index]['ownerId'],
                    ),
                  ),
                ),
                onExpandClicked: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostScreenAlbum(
                      postId: stories[index]['postId'],
                      userId: stories[index]['ownerId'],
                    ),
                  ),
                ),
                maxImages: 4,
              ),
            )
          : GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostScreenAlbum(
                          postId: stories[index]['postId'],
                          userId: stories[index]['ownerId']))),
              child: Container(
                color: const Color(0xfff3f3f4),
                height: 120,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    stories[index]['description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
