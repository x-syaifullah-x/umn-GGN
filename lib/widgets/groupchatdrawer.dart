import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/activity_feed.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class DrawerMenu extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;
  final String admin;
  final String groupIcon;
  final List members;

  const DrawerMenu({
    Key? key,
    required this.groupId,
    required this.userName,
    required this.groupName,
    required this.admin,
    required this.groupIcon,
    required this.members,
  }) : super(key: key);

  @override
  State<DrawerMenu> createState() =>
      _DrawerMenuState(groupId, userName, groupName, admin, groupIcon);
}

class _DrawerMenuState extends State<DrawerMenu> {
  final String groupId;
  final String userName;
  final String groupName;
  final String admin;
  final String groupIcon;

  final ImagePicker _picker = ImagePicker();
  File? imageFileCover;
  String? imageFileCoverUrl;
  bool isLoading = false;

  _DrawerMenuState(
      this.groupId, this.userName, this.groupName, this.admin, this.groupIcon);

  void deleteNestedSubcollections() {
    Future<QuerySnapshot> photos =
        groupsRef.doc(groupId).collection("messages").get();
    photos.then((value) {
      value.docs.forEach((element) {
        groupsRef
            .doc(groupId)
            .collection("messages")
            .doc(element.id)
            .delete()
            .then((value) => print("success"));
      });
    });
  }

  DocumentReference userDocRef = usersRef.doc(globalID);
  deleteGroup() async {
    groupsRef.doc(groupId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await userDocRef.update({
      'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
    });

    deleteNestedSubcollections();
    FirebaseStorage.instance.refFromURL(groupIcon).delete();
  }

  handleDeleteGroup(BuildContext parentConext) {
    Navigator.pop(context);
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Delete this Group?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deleteGroup();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  handleleaveGroup(BuildContext parentConext) {
    Navigator.pop(context);
    return showDialog(
        context: parentConext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Leave this Group?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  leaveGroup();
                },
                child: const Text(
                  'Leave',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  leaveGroup() async {
    await groupsRef.doc(groupId).update({
      'members': FieldValue.arrayRemove([globalID! + '_' + globalName!])
    });
    await userDocRef.update({
      'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
    });
  }

  Future getgroupIcon() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFileCover = imageFileCover;
      if (newImageFile != null) {
        imageFileCover = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadCover(imageFileCover);
  }

  Future uploadCover(imageFileCover) async {
    String mFileName = groupId;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("cover_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileCover!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileCoverUrl = downloadUrl;
    setState(() {
      isLoading = false;
      groupsRef.doc(groupId).update({"groupIcon": imageFileCoverUrl});

      SnackBar snackbar = const SnackBar(content: Text("Group Icon updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  String _destructureId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  membersList() {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(left: 15),
      child: ListView.builder(
        itemBuilder: (context, int index) {
          int reqIndex = widget.members.length - index - 1;
          final userId = _destructureId(widget.members[reqIndex]);
          final userName = _destructureName(widget.members[reqIndex]);

          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<GloabalUser?>(
                  future: GloabalUser.fetchUser(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }
                    final user = snapshot.data;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 5),
                      child: Row(
                        children: <Widget>[
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: user!.photoUrl == null ||
                                        user.photoUrl.isEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF003a54),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Image.asset(
                                          'assets/images/defaultavatar.png',
                                          width: 40,
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: user.photoUrl,
                                        height: 40.0,
                                        width: 40.0,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            ],
                          ).onTap(() {
                            showProfile(context, profileId: userId);
                          }),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  showProfile(context, profileId: userId),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.username.capitalize(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }));
        },
        itemCount: widget.members.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  child: (imageFileCover == null)
                      ? groupIcon.isNotEmpty
                          ? ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: groupIcon,
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF003a54),
                              ),
                              child: Text(
                                groupName.substring(0, 1).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )
                      : Material(
                          child: Image.file(
                            imageFileCover!,
                            width: double.infinity,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                ),
                admin == globalName
                    ? Positioned(
                        bottom: 5,
                        right: 5,
                        child: SvgPicture.asset(
                          'assets/images/photo.svg',
                          width: 40,
                        ).onTap(
                          () {
                            getgroupIcon();
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Admin'),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  alignment: Alignment.centerLeft,
                  child: Text((admin != null || admin.isNotEmpty)
                      ? admin.capitalize()
                      : ''),
                ),
                const ListTile(
                  title: Text('Members'),
                ),
                membersList()
              ],
            ),
          ),
          Container(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                children: <Widget>[
                  const Divider(),
                  admin == globalName
                      ? ListTile(
                          title: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            height: 38,
                            width: (MediaQuery.of(context).size.width * 0.4),
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.red.shade500,
                                      Colors.red.shade900
                                    ])),
                            child: const Center(
                              child: Text(
                                'Delete Group',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ).onTap(
                            () async {
                              Navigator.pop(context);
                              handleDeleteGroup(context);
                            },
                          ),
                        )
                      : ListTile(
                          title: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            height: 38,
                            width: (MediaQuery.of(context).size.width * 0.4),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.red.shade500,
                                  Colors.red.shade900
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Leave Group',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ).onTap(
                            () async {
                              Navigator.pop(context);
                              handleleaveGroup(context);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
