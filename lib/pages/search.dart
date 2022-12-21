import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/activity_feed.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/progress.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  bool isLoading = false;
  int usersCount = 0;
  List<GloabalUser> users = [];

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("username", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.search),
              title: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                    hintText: 'Search', border: InputBorder.none),
                onChanged: handleSearch,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: clearSearch,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Center buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/search_new.svg',
            height: orientation == Orientation.portrait ? 150.0 : 100.0,
          ),
          30.height,
          Text("Find Users",
              textAlign: TextAlign.center, style: boldTextStyle(size: 30)),
        ],
      ),
    );
  }

  getUsers() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await usersRef.orderBy('timestamp', descending: true).get();
    setState(() {
      isLoading = false;
      usersCount = snapshot.docs.length;
      users =
          snapshot.docs.map((doc) => GloabalUser.fromDocument(doc)).toList();
    });
  }

  buildSearchResults() {
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          GloabalUser user = GloabalUser.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        }
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(context, titleText: "Search Users"),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                      hintText: 'Search', border: InputBorder.none),
                  onChanged: handleSearch,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: clearSearch,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
          ),
          Expanded(
            child: searchResultsFuture == null
                ? buildNoContent()
                : buildSearchResults(),
          ),
        ],
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final GloabalUser user;

  const UserResult(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: user.photoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CachedNetworkImage(
                        imageUrl: user.photoUrl,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF003a54),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Image.asset(
                        'assets/images/defaultavatar.png',
                        width: 50,
                      ),
                    ),
              title: Text(
                user.displayName,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 16,
                    ),
              ),
              subtitle: Text(
                user.username,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      fontSize: 15,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
