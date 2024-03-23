import 'package:flutter/material.dart';
import 'package:global_net/pages/home/user/users.dart';

class FriendList extends StatefulWidget {
  final String userId;

  const FriendList({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Users(
          userId: widget.userId,
          title: 'Friend List',
        ),
      ),
    );
  }
}
