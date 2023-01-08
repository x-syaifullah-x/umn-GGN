import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/group_chat_page.dart';
import 'package:global_net/pages/home.dart';
import 'package:global_net/services/database_service.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class SearchPage extends StatefulWidget {
  final String? userId;

  const SearchPage({Key? key, this.userId}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // data
  TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot? searchResultSnapshot;
  QuerySnapshot? groupResultSnapshot;
  bool isLoading = false;
  bool hasUserSearched = false;
  bool _isJoined = false;
  String _userName = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // initState()
  @override
  void initState() {
    super.initState();
    _getCurrentUserNameAndUid();
  }

  // functions
  _getCurrentUserNameAndUid() async {
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      _userName = globalName!;
    });
  }

  _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        setState(() {
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  void _showScaffold(String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: const Duration(milliseconds: 1500),
      content: Text(message,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 17.0)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // _scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  _joinValueInGroup(
      String userName, String groupId, String groupName, String admin) async {
    bool value = await DatabaseService(uid: globalID)
        .isUserJoined(groupId, groupName, userName);
    setState(() {
      _isJoined = value;
    });
  }

  Widget groupsListnew() {
    return StreamBuilder(
      stream: groupsRef.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
              child: snapshot.data!.docs.length > 0
                  ? ListView.separated(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, int index) {
                        List messenger = snapshot.data!.docs;

                        return grouplistTile(
                          globalName!,
                          messenger[index]['groupId'],
                          messenger[index]['groupName'],
                          messenger[index]['admin'],
                          messenger[index]['groupIcon'],
                          messenger[index]['members'],
                        );
                      },
                      separatorBuilder: (context, int index) {
                        return const Divider();
                      },
                    )
                  : Container());
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: const <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  // widgets
  Widget groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                _userName,
                searchResultSnapshot!.docs[index]["groupId"],
                searchResultSnapshot!.docs[index]["groupName"],
                searchResultSnapshot!.docs[index]["admin"],
                searchResultSnapshot!.docs[index]["groupIcon"],
                searchResultSnapshot!.docs[index]['members'],
              );
            })
        : groupsListnew();
  }

  Widget groupTile(String userName, String groupId, String groupName,
      String admin, String groupIcon, List members) {
    _joinValueInGroup(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: groupIcon.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                imageUrl: groupIcon,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF003a54),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Admin: $admin"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: globalID)
              .togglingGroupJoin(groupId, groupName, userName);
          if (_isJoined) {
            setState(() {
              _isJoined = !_isJoined;
            });
            _showScaffold('Successfully joined the group "$groupName"');
            Future.delayed(const Duration(milliseconds: 2000), () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    groupId: groupId,
                    userName: userName,
                    groupName: groupName,
                    admin: admin,
                    groupIcon: groupIcon,
                    members: members,
                  ),
                ),
              );
            });
          } else {
            setState(() {
              _isJoined = !_isJoined;
            });
            _showScaffold('Left the group "$groupName"');
          }
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.black87,
                    border: Border.all(color: Colors.white, width: 1.0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child:
                    const Text('Joined', style: TextStyle(color: Colors.white)),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.blueAccent,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child:
                    const Text('Join', style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }

  Widget grouplistTile(String userName, String groupId, String groupName,
      String admin, String groupIcon, List members) {
    _joinValueInGroup(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: groupIcon.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                imageUrl: groupIcon,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF003a54),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Admin: $admin"),
      trailing: members.contains((globalID! + '_' + globalName!))
          ? InkWell(
              onTap: () async {
                await DatabaseService(uid: globalID)
                    .togglingGroupJoin(groupId, groupName, userName);

                setState(() {
                  _isJoined = !_isJoined;
                });
                _showScaffold('Left the group "$groupName"');
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.black87,
                    border: Border.all(color: Colors.white, width: 1.0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child:
                    const Text('Joined', style: TextStyle(color: Colors.white)),
              ))
          : InkWell(
              onTap: () async {
                await DatabaseService(uid: globalID)
                    .togglingGroupJoin(groupId, groupName, userName);
                setState(() {
                  _isJoined = !_isJoined;
                });
                _showScaffold('Successfully joined the group "$groupName"');
                Future.delayed(const Duration(milliseconds: 2000), () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        groupId: groupId,
                        userName: userName,
                        groupName: groupName,
                        admin: admin,
                        groupIcon: groupIcon,
                        members: members,
                      ),
                    ),
                  );
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.blueAccent,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child:
                    const Text('Join', style: TextStyle(color: Colors.white)),
              ),
            ),
    );
  }

  // building the search page widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(context, titleText: "Search Groups"),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchEditingController,
                          style: const TextStyle(),
                          decoration: const InputDecoration(
                              hintText: "Search groups...",
                              hintStyle: TextStyle(
                                fontSize: 16,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            _initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.red.shade500,
                                      Colors.red.shade900
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(40)),
                              child: const Icon(Icons.search,
                                  color: Colors.white)))
                    ],
                  ),
                ),
                isLoading
                    ? Container(
                        child: const Center(child: CircularProgressIndicator()))
                    : groupList()
              ],
            ),
    );
  }
}
