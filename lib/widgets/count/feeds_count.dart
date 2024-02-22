import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:global_net/pages/home/home.dart';

class TabFeedsCount extends StatefulWidget {
  final String userId;
  final TabController? tabController;

  const TabFeedsCount({
    Key? key,
    required this.userId,
    this.tabController,
  }) : super(key: key);

  @override
  State<TabFeedsCount> createState() => _TabFeedsCountState();
}

class _TabFeedsCountState extends State<TabFeedsCount> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: feedCollection
            .doc(widget.userId)
            .collection('feedItems')
            .where('isSeen', isEqualTo: false)
            .snapshots(),
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
                      : const Icon(
                          IconlyLight.activity,
                        ));
            } else {
              return Tab(
                icon: badges.Badge(
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
                      : const Icon(IconlyLight.activity),
                ),
              );
            }
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }
}
