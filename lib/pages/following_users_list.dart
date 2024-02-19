import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/followers_tile.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class FollowingList extends StatefulWidget {
  final String userId;

  FollowingList({
    required this.userId,
  });

  @override
  _FollowingListState createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList>
    with AutomaticKeepAliveClientMixin<FollowingList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalUserId;

  @override
  void initState() {
    super.initState();
    getfollowingusers();
  }

  bool get wantKeepAlive => true;

  getfollowingusers() async {
    var querySnapshots = await followingCollection
        .doc(widget.userId)
        .collection('userFollowing')
        .get();
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
            query: followingCollection
                .doc(widget.userId)
                .collection('userFollowing'),
            isLive: true,
          ),
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          }),
    );
  }
}
