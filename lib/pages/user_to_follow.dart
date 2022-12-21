import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/users_to_follow_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UsersToFollowList extends StatefulWidget {
  final String? userId;

  const UsersToFollowList({Key? key, this.userId}) : super(key: key);

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersToFollowList>
    with AutomaticKeepAliveClientMixin<UsersToFollowList> {
  List<GloabalUser>? users;
  String userOrientation = "list";
  bool isFollowing = false;
  bool isLoading = false;
  final String? currentUserId = globalID;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getAllUsers();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(globalID)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getAllUsers() async {
    QuerySnapshot snapshot =
        await usersRef.orderBy('timestamp', descending: true).get();
    List<GloabalUser> users =
        snapshot.docs.map((doc) => GloabalUser.fromDocument(doc)).toList();
    setState(() {
      this.users = users;
    });
  }

  buildUsersResults() {
    if (isLoading) {
      return circularProgress();
    } else if (users == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 150.0,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "No User",
              style: TextStyle(
                color: Colors.red,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (userOrientation == "list") {
      List<GridTile> gridTiles = [];

      users!.forEach((user) {
        final bool isAuthUser = currentUserId == user.id;
        final bool isFollowingUser = followingList.contains(user.id);
        if (isAuthUser) {
          return;
        } else if (isFollowingUser) {
          return;
        } else {
          gridTiles.add(
            GridTile(child: UserToFollowTile(user)),
          );
        }
      });
      return ListView(
        children: gridTiles,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.recent_users,
          style: Theme.of(context).textTheme.headline5!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        centerTitle: false,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) =>
                      // WalkThroughScreen(),
                      Home(userId: widget.userId),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 15, right: 15, left: 15),
              child: Text(
                'Next',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: buildUsersResults(),
    );
  }
}
