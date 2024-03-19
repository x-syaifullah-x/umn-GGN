import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_net/data/user.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot<Map<String, dynamic>>>? searchResultsFuture;
  bool isLoading = false;
  int usersCount = 0;
  List<GloabalUser> users = [];

  _handleSearch(String query) {
    Future<QuerySnapshot<Map<String, dynamic>>> users = usersCollection
        .where(User.fieldNameUsername, isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  _clearSearch() {
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
                onChanged: _handleSearch,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _clearSearch,
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
          Text(
            'Find Users',
            textAlign: TextAlign.center,
            style: boldTextStyle(size: 30),
          ),
        ],
      ),
    );
  }

  getUsers() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await usersCollection.orderBy('timestamp', descending: true).get();
    setState(() {
      isLoading = false;
      usersCount = snapshot.docs.length;
      users =
          snapshot.docs.map((doc) => GloabalUser.fromDocument(doc)).toList();
    });
  }

  buildSearchResults() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          final user = User.fromJson(doc.data());
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
                  onChanged: _handleSearch,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _clearSearch,
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
  final User user;

  const UserResult(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !user.active
        ? Container()
        : Container(
            margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => showProfile(context, userId: user.id),
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
