import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/suggested_users_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SuggestedUsersList extends StatefulWidget {
  const SuggestedUsersList({
    Key? key,
    required this.userId,
    this.scrollController,
  }) : super(key: key);

  final String userId;
  final ScrollController? scrollController;

  @override
  State createState() => _SuggestedUsersListState();
}

class _SuggestedUsersListState extends State<SuggestedUsersList>
    with AutomaticKeepAliveClientMixin<SuggestedUsersList> {
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ScrollController controller = ScrollController();
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
      body: RawScrollbar(
        controller: controller,
        interactive: true,
        // thumbVisibility: true,
        // trackVisibility: true,
        radius: const Radius.circular(20),
        child: PaginateFirestore(
          scrollController: controller,
          itemBuilderType: PaginateBuilderType.listView,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, documentSnapshot, index) {
            final userdoc = documentSnapshot[index].data() as Map?;
            final bool isAuthUser = widget.userId == userdoc!['id'];
            if (isAuthUser) {
              return const Text('');
            }
            return SuggestedUserTile(userdoc);
          },
          query: usersRef.orderBy('timestamp', descending: true),
          isLive: true,
        ),
      ),
    );
  }
}
