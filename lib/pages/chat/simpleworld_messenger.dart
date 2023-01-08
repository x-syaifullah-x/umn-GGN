import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/simpleworld_chat.dart';
import 'package:global_net/pages/home.dart';
import 'package:timeago/timeago.dart';

class Messenger extends StatefulWidget {
  final String userId;

  const Messenger({required this.userId, Key? key}) : super(key: key);

  @override
  MessengerState createState() => MessengerState();
}

class MessengerState extends State<Messenger> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                ),
                child: chatListToMessage(widget.userId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatListToMessage(String userData) {
    return StreamBuilder(
      stream: messengerRef
          .doc(userData)
          .collection(userData)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // ignore: prefer_is_empty
            child: snapshot.data!.docs.length > 0
                ? ListView.separated(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, int index) {
                      List messenger = snapshot.data!.docs;
                      return buildItem(messenger, index);
                    },
                    separatorBuilder: (context, int index) {
                      return const Divider();
                    },
                  )
                : const Center(
                    child: Text("Currently you don't have any messages"),
                  ),
          );
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

  Widget buildItem(List messenger, int index) {
    return ListTile(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => Chat(
                      receiverId: messenger[index]['id'],
                      receiverAvatar: messenger[index]['profileImage'],
                      receiverName: messenger[index]['name'])));
        },
        leading: messenger[index]['profileImage'].isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: messenger[index]['profileImage'],
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
        title: Text(messenger[index]['name'],
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 16,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(
            messenger[index]['type'] != null && messenger[index]['type'] == 1
                ? "📷 Image"
                : messenger[index]['content'],
            style:
                Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(format(
                DateTime.fromMillisecondsSinceEpoch(int.parse(
                  messenger[index]['timestamp'],
                )),
                locale: 'en_short')),
            int.parse(messenger[index]['badge']) > 0
                ? Badge(
                    elevation: 0,
                    shape: BadgeShape.circle,
                    padding: const EdgeInsets.all(7),
                    badgeContent: Text(
                      messenger[index]['badge'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const Text(''),
          ],
        ));
  }
}
