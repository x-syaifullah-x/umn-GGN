import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/followers_tile.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class followersList extends StatefulWidget {
  final String userId;

  followersList({
    required this.userId,
  });

  @override
  _followersListState createState() => _followersListState();
}

class _followersListState extends State<followersList>
    with AutomaticKeepAliveClientMixin<followersList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;

  @override
  void initState() {
    super.initState();

    getfollowers();
  }

  getfollowers() async {
    var querySnapshots = await followersCollection
        .doc(widget.userId)
        .collection('userFollowers')
        .get();
    for (var doc in querySnapshots.docs) {
      await doc.reference.update({
        "userId": doc.id,
      });
    }
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();

    return Scaffold(
      appBar: header(context,
          titleText: AppLocalizations.of(context)!.followers,
          removeBackButton: false),
      body: RefreshIndicator(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.gridView,
            itemBuilder: (context, documentSnapshot, index) {
              final userdoc = documentSnapshot[index].data() as Map?;

              return FollowersTile(userdoc);
            },
            query: followersCollection
                .doc(widget.userId)
                .collection('userFollowers'),
            isLive: true,
          ),
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          }),
    );
  }
}
