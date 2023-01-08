import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/group_chat_page.dart';

class GroupTile extends StatelessWidget {
  final String userName;
  final String groupId;
  final String groupName;
  final String admin;
  final String groupIcon;
  final List members;

  const GroupTile(
      {Key? key,
      required this.userName,
      required this.groupId,
      required this.groupName,
      required this.admin,
      required this.groupIcon,
      required this.members})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: ListTile(
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
          title: Text(groupName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Join the conversation as $userName",
              style: const TextStyle(fontSize: 13.0)),
        ),
      ),
    );
  }
}
