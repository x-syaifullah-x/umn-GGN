import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/followers_tile.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class followingList extends StatefulWidget {
  final String userId;

  followingList({
    required this.userId,
  });

  @override
  _followingListState createState() => _followingListState();
}

class _followingListState extends State<followingList>
    with AutomaticKeepAliveClientMixin<followingList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;

  @override
  void initState() {
    super.initState();
    getfollowingusers();
  }

  bool get wantKeepAlive => true;

  getfollowingusers() async {
    var querySnapshots =
        await followingRef.doc(widget.userId).collection('userFollowing').get();
    for (var doc in querySnapshots.docs) {
      await doc.reference.update({
        "userId": doc.id,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();

    return Scaffold(
      appBar: header(context,
          titleText: AppLocalizations.of(context)!.following,
          removeBackButton: false),
      body: RefreshIndicator(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.gridView,
            itemBuilder: (context, documentSnapshot, index) {
              final userdoc = documentSnapshot[index].data() as Map?;

              return FollowersTile(userdoc);
            },
            query: followingRef.doc(widget.userId).collection('userFollowing'),
            isLive: true,
          ),
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          }),
    );
  }
}
