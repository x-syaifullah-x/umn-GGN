import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/widgets/header.dart';
import 'package:nb_utils/nb_utils.dart';

import '../home/home.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({Key? key}) : super(key: key);

  @override
  State<SearchUser> createState() => _SearchState();
}

class _SearchState extends State<SearchUser> {
  // with AutomaticKeepAliveClientMixin<SearchUser> {

  final TextEditingController searchController = TextEditingController();

  final streamController = StreamController<String?>(sync: true);

  // @override
  // bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(context, titleText: 'Search Users'),
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
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                  onChanged: (String? value) {
                    streamController.sink.add(value);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
          ),
          Expanded(
            child: StreamBuilder<String?>(
              initialData: '',
              stream: streamController.stream,
              builder: (context, snapshot) {
                final query = snapshot.data;
                if (query.isEmptyOrNull) {
                  return _buildNoContent();
                }
                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: usersCollection
                      .where('username', isGreaterThanOrEqualTo: '$query')
                      .get(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final length = docs.length;
                    return ListView.builder(
                      itemCount: length,
                      itemBuilder: (context, index) {
                        final user = User.fromJson(docs[index].data());
                        return Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop({
                                  'uid': user.id,
                                });
                              },
                              child: ListTile(
                                leading: user.photoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Image.asset(
                                          'assets/images/defaultavatar.png',
                                          width: 50,
                                        ),
                                      ),
                                title: Text(
                                  user.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 16,
                                      ),
                                ),
                                subtitle: Text(
                                  user.username,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Center _buildNoContent() {
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
}
