import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simpleworld/pages/home.dart';

class ProfileHeader extends StatefulWidget {
  final String? profileId;

  const ProfileHeader({
    Key? key,
    this.profileId,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  ProfileHeaderState createState() => ProfileHeaderState(
        profileId: profileId,
      );
}

class ProfileHeaderState extends State<ProfileHeader> {
  final String? profileId;

  ProfileHeaderState({
    this.profileId,
  });

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> requestCount() {
    return commentsRef.doc(profileId).collection('comments').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: requestCount(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!.size.toString(),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).iconTheme.color,
                ));
          }
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }
}
