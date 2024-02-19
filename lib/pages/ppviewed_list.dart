import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:global_net/widgets/visited_users_tile.dart';

class UsersViewedMyProfileList extends StatefulWidget {
  final String userId;

  UsersViewedMyProfileList({
    required this.userId,
  });

  @override
  _UsersViewedMyProfileListState createState() =>
      _UsersViewedMyProfileListState();
}

class _UsersViewedMyProfileListState extends State<UsersViewedMyProfileList>
    with AutomaticKeepAliveClientMixin<UsersViewedMyProfileList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalUserId;

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
      appBar: header(context, titleText: 'Visits', removeBackButton: false),
      body: RefreshIndicator(
          child: PaginateFirestore(
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (context, documentSnapshot, index) {
              final userdoc = documentSnapshot[index].data() as Map?;

              return VisitedUsersTile(userdoc);
            },
            query: ppviewsCollection
                .doc(widget.userId)
                .collection('userviews')
                .orderBy('timestamp', descending: true),
            isLive: true,
          ),
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          }),
    );
  }
}
