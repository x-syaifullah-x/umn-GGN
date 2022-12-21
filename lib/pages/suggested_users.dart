import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/suggested_users_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SuggestedUsersList extends StatefulWidget {
  final GloabalUser? currentUser;

  const SuggestedUsersList({
    Key? key,
    this.currentUser,
  }) : super(key: key);

  @override
  _SuggestedUsersListState createState() => _SuggestedUsersListState();
}

class _SuggestedUsersListState extends State<SuggestedUsersList>
    with AutomaticKeepAliveClientMixin<SuggestedUsersList> {
  String userOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: Theme.of(context).appBarTheme.iconTheme!.color),
        title: Text(
          AppLocalizations.of(context)!.people_you_may_know,
          style: Theme.of(context).textTheme.headline5!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
        ),
      ),
      body: PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, documentSnapshot, index) {
          final userdoc = documentSnapshot[index].data() as Map?;
          final bool isAuthUser = currentUserId == userdoc!['id'];

          if (isAuthUser) {
            return const Text('');
          }

          return SuggestedUserTile(userdoc);
        },
        query: usersRef.orderBy('timestamp', descending: true),
        isLive: true,
      ),
    );
  }
}
