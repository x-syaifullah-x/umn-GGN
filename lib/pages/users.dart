import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/users_tile.dart';

class UsersList extends StatefulWidget {
  final String? userId;

  UsersList({
    this.userId,
  });

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList>
    with AutomaticKeepAliveClientMixin<UsersList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;

  @override
  void initState() {
    super.initState();

    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.userId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();

    return Scaffold(
      appBar: header(context,
          titleText: AppLocalizations.of(context)!.recent_users,
          removeBackButton: false),
      body: RefreshIndicator(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.gridView,
            itemBuilder: (context, documentSnapshot, index) {
              final userdoc = documentSnapshot[index].data() as Map?;

              return UserTile(userdoc);
            },
            query: usersRef.orderBy('timestamp', descending: true),
            isLive: true,
          ),
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          }),
    );
  }
}
