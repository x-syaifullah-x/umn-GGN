// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';

// ignore: library_prefixes
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddImageStory extends StatefulWidget {
  File file;

  AddImageStory({required this.file});

  @override
  AddImageStoryState createState() => AddImageStoryState();
}

class AddImageStoryState extends State<AddImageStory>
    with AutomaticKeepAliveClientMixin<AddImageStory> {
  Color? mainColor = Colors.deepPurple[400];
  TextEditingController captionController = TextEditingController();

  bool isUploading = false;
  String storyId = const Uuid().v4();

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = storageRef
        .child("Stories")
        .child("story_$storyId.jpg")
        .putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  List yourItemList = [];

  createPostInFirestore(
      {String? stories, String? storyMediaURL, String? storyDescription}) {
    storiesCollection.doc(globalUserId).get().then((docSnapshot) async => {
          yourItemList.add({
            "filetype": 'image',
            "url": {"en": storyMediaURL},
            "fileTitle": {"en": storyDescription}
          }),
          if (docSnapshot.exists)
            {
              await storiesCollection.doc(globalUserId).update(
                {
                  "previewImage": storyMediaURL,
                  "photoUrl": globalImage,
                  "stories": FieldValue.arrayUnion(yourItemList),
                },
              )
            }
          else
            {
              storiesCollection.doc(globalUserId).set({
                "storyId": storyId,
                "storyownerId": globalUserId,
                "username": {"en": globalName},
                "previewImage": storyMediaURL,
                "photoUrl": globalImage,
                "stories": [
                  {
                    "filetype": 'image',
                    "url": {"en": storyMediaURL},
                    "fileTitle": {"en": storyDescription}
                  }
                ],
                "date": timestamp,
              })
            }
        });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    String storyMediaURL = await uploadImage(widget.file);
    createPostInFirestore(
        storyMediaURL: storyMediaURL, storyDescription: captionController.text);
    if (mounted) {
      setState(() {
        isUploading = false;
        storyId = const Uuid().v4();
        Navigator.of(context).pop();
      });
    }
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar:
          header(context, titleText: "Create Story", showMessengerButton: true),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : const Text(""),
          ListTile(
            leading: globalImage!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(globalImage!),
                    radius: 20.0,
                  )
                : Image.asset(
                    'assets/images/defaultavatar.png',
                    width: 40,
                  ),
            title: Text(
              globalName!.capitalize(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0),
            width: 250.0,
            child: TextField(
              controller: captionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade300.withOpacity(0.3),
              boxShadow: const [
                BoxShadow(spreadRadius: 3),
              ],
            ),
            alignment: Alignment.center,
            width: double.infinity,
            margin: const EdgeInsets.all(20.0),
            child: Center(
              child: Stack(
                children: <Widget>[
                  // ignore: unnecessary_null_comparison
                  (widget.file == null)
                      ? Container()
                      : Material(
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(
                            widget.file,
                            width: MediaQuery.of(context).size.width,
                            height: 220.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red[600],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.red[600]!.withOpacity(0.5),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 5.0),
              ],
            ),
            child: const Center(
              child: Text(
                'SHARE',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ).onTap(() {
            isUploading ? null : handleSubmit();
          }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildUploadForm();
  }
}
