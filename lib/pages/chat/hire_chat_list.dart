import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/hire_search_page.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/services/database_service.dart';
import 'package:global_net/widgets/hire_tile.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class HireChatList extends StatefulWidget {
  final String userId;
  const HireChatList({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<HireChatList> createState() => _HireChatListState();
}

class _HireChatListState extends State<HireChatList> {
  String? _groupName;
  final String _userName = globalName!;
  Stream? _groups;

  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  // widgets
  Widget noGroupWidget() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  _popupDialog(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.red.shade500, Colors.red.shade900],
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 75.0),
                )),
            const SizedBox(height: 20.0),
            const Text(
                "You've not joined any hire, tap on the 'add' icon to create a hire or search for hires by tapping on the search button."),
          ],
        ));
  }

  Widget groupsList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            try {
              if (snapshot.data['hires'].length != 0) {
                return _groupsListnew(
                  snapshot.data['hires'],
                );
              } else {
                return noGroupWidget();
              }
            } catch (e) {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _groupsListnew(data) {
    return StreamBuilder(
      stream: hiresCollection
          .where('members', arrayContains: '${globalUserId}_${globalName!}')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: snapshot.data!.docs.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, int index) {
                        List messenger = snapshot.data!.docs;
                        return HireTile(
                          groupIcon: messenger[index]['icon'],
                          admin: messenger[index]['admin'],
                          userName: globalName!,
                          groupId: messenger[index]['id'],
                          groupName: messenger[index]['name'],
                          members: messenger[index]['members'],
                        );
                      },
                      separatorBuilder: (context, int index) {
                        return const Divider();
                      },
                    )
                  : noGroupWidget());
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

  // functions
  _getUserAuthAndJoinedGroups() async {
    DatabaseService(uid: globalUserId).getUser().then((snapshots) {
      setState(() {
        _groups = snapshots;
      });
    });
  }

  void _popupDialog(BuildContext context) {
    Widget cancelButton = TextButton(
        child: const Text("Cancel"),
        onPressed: () =>
            Navigator.of(context, rootNavigator: true).pop('dialog'));
    Widget createButton = TextButton(
      child: const Text("Create"),
      onPressed: () async {
        if (_groupName != null) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          DatabaseService(uid: widget.userId)
              .createHire(_userName, _groupName!);
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Create a hires"),
      content: TextField(
          onChanged: (val) {
            _groupName = val;
          },
          style: const TextStyle(
              fontSize: 15.0, height: 2.0, color: Colors.black)),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Building the GroupChatList widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              icon: Icon(Icons.search,
                  color: Theme.of(context).iconTheme.color, size: 25.0),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HireSearchPage(
                      userId: widget.userId,
                    ),
                  ),
                );
              })
        ],
      ),
      body: groupsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        elevation: 0.0,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.red.shade500, Colors.red.shade900],
            ),
          ),
          child: const Icon(
            Icons.add,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
