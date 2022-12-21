import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/_build_list.dart';

class FeedsCount extends StatefulWidget {
  final String? userId;
  final TabController? tabController;

  const FeedsCount({
    Key? key,
    this.userId,
    this.tabController,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  FeedsCountState createState() => FeedsCountState(
        userId: userId,
      );
}

class FeedsCountState extends State<FeedsCount> {
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];
  final String? userId;

  FeedsCountState({
    this.userId,
  });

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> requestCount() {
    return activityFeedRef
        .doc(userId)
        .collection('feedItems')
        .where('isSeen', isEqualTo: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: requestCount(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool hideFeedsCount = (snapshot.data!.size.toString()) == '0';
            if (hideFeedsCount) {
              return Tab(
                  icon: widget.tabController!.index == 3
                      ? const Icon(
                          IconlyBold.activity,
                          color: Color(0xFFC62828),
                        )
                      : const Icon(IconlyLight.activity));
            } else {
              return Tab(
                icon: Badge(
                    badgeColor: const Color(0xFFC62828),
                    badgeContent: Text(
                      snapshot.data!.size.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: widget.tabController!.index == 3
                        ? const Icon(
                            IconlyBold.activity,
                            color: Color(0xFFC62828),
                          )
                        : const Icon(IconlyLight.activity)),
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }
}
