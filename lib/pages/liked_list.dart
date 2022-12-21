import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/liked_users_tile.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class UsersLikedMyProfileList extends StatefulWidget {
  final String userId;

  UsersLikedMyProfileList({
    required this.userId,
  });

  @override
  _UsersLikedMyProfileListState createState() =>
      _UsersLikedMyProfileListState();
}

class _UsersLikedMyProfileListState extends State<UsersLikedMyProfileList>
    with AutomaticKeepAliveClientMixin<UsersLikedMyProfileList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;

  @override
  void initState() {
    super.initState();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();

    return Scaffold(
      appBar: header(context, titleText: 'Likes', removeBackButton: false),
      body: RefreshIndicator(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.gridView,
            itemBuilder: (context, documentSnapshot, index) {
              final userdoc = documentSnapshot[index].data() as Map?;

              return LikedUserTile(userdoc);
            },
            query: likedRef.doc(widget.userId).collection('userlikes'),
            isLive: true,
          ),
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          }),
    );
  }
}
