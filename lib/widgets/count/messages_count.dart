import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/chat/simpleworld_chat_main.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/circle_button.dart';
import 'package:badges/badges.dart' as badges;

class MessagesCount extends StatefulWidget {
  final String currentUserId;

  const MessagesCount({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<MessagesCount> {
  String sum = '0';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.currentUserId;
    return StreamBuilder<QuerySnapshot>(
      stream: messengerCollection
          .doc(currentUserId)
          .collection(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var ds = snapshot.data!.docs;
          int sum = 0;
          for (int i = 0; i < ds.length; i++) {
            sum += (int.parse(ds[i]['badge']));
          }

          IconData iconData =
              isWeb ? Icons.message : MdiIcons.facebookMessenger;

          if (sum > 0) {
            return badges.Badge(
              position: BadgePosition.topEnd(top: 0, end: 3),
              animationDuration: const Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                '$sum',
                style: const TextStyle(color: Colors.white),
              ),
              child: CircleButton(
                icon: iconData,
                iconSize: 25.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SimpleWorldChat(userId: widget.currentUserId),
                    ),
                  );
                },
              ),
            );
          }
          return CircleButton(
            icon: iconData,
            iconSize: 25.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SimpleWorldChat(userId: widget.currentUserId),
                ),
              );
            },
          );
        }
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }
}
