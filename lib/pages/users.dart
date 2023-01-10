import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:global_net/pages/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:global_net/widgets/users_tile.dart';

class UsersList extends StatefulWidget {
  final String? userId;

  const UsersList({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  UsersListState createState() => UsersListState();
}

class UsersListState extends State<UsersList>
    with AutomaticKeepAliveClientMixin<UsersList> {
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;

  @override
  void initState() {
    super.initState();

    _checkIfFollowing();
  }

  _checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.userId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();

    return Scaffold(
      appBar: header(
        context,
        titleText: AppLocalizations.of(context)!.recent_users,
        removeBackButton: false,
      ),
      body: RefreshIndicator(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.gridView,
            itemBuilder: (context, documentSnapshot, index) {
              final userDoc = documentSnapshot[index].data() as Map?;
              return UserTile(userDoc);
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
