// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/story/add_image_story.dart';
import 'package:global_net/story/add_video_story.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

// ignore: must_be_immutable
class AddStory extends StatefulWidget {
  @override
  AddStoryState createState() => AddStoryState();
}

class AddStoryState extends State<AddStory>
    with AutomaticKeepAliveClientMixin<AddStory> {
  Color? mainColor = Colors.deepPurple[400];
  final ImagePicker _picker = ImagePicker();
  File? file;
  File? videoFile;
  File? newVideoFile;
  TextEditingController captionController = TextEditingController();

  bool isUploading = false;
  String storyId = const Uuid().v4();

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      file = File(pickedFile.path);
      navigator.pop();
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => AddImageStory(file: file!),
        ),
      );
    } else {
      // print('No image selected.');
    }
    setState(() {});
  }

  Future selectVideoFile() async {
    final navigator = Navigator.of(context);
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (mounted) {
      setState(() async {
        if (pickedFile != null) {
          videoFile = File(pickedFile.path);
          print(videoFile);
          await VideoCompress.setLogLevel(0);
          final MediaInfo? info = await VideoCompress.compressVideo(
            videoFile!.path,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false,
            includeAudio: true,
          );
          print(info!.path);
          setState(() {
            newVideoFile = File(info.path!);
          });
          int size = newVideoFile!.lengthSync();
          double sizeInMb = size / (1024 * 1024);
          if (sizeInMb > 5) {
            simpleworldtoast("", "File Size is larger then 5mb", context);
            return;
          }
          navigator.pop();
          await navigator.push(MaterialPageRoute(
              builder: (context) => CreateVideoStory(
                  currentUser: currentUser,
                  file: videoFile!,
                  videopath: pickedFile.path)));
        } else {
          // print('No image selected.');
        }
      });
    }
  }

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
      {String? stories, String? storymediaUrl, String? storydescription}) {
    storiesCollection.doc(globalUserId).get().then(
          (docSnapshot) async => {
            yourItemList.add({
              "filetype": 'image',
              "url": {"en": storymediaUrl},
              "fileTitle": {"en": storydescription}
            }),
            if (docSnapshot.exists)
              {
                await storiesCollection.doc(globalUserId).update(
                  {
                    "previewImage": storymediaUrl,
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
                  "previewImage": storymediaUrl,
                  "photoUrl": globalImage,
                  "stories": [
                    {
                      "filetype": 'image',
                      "url": {"en": storymediaUrl},
                      "fileTitle": {"en": storydescription}
                    }
                  ],
                  "date": timestamp,
                }) // create the document
              }
          },
        );
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        title: Text(
          AppLocalizations.of(context)!.create_story,
          style: Theme.of(context).textTheme.headline5!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: 250,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            isUploading ? linearProgress() : const Text(""),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 150.0,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFE15288),
                      Color(0xFFAD4AD2),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Center(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: 40,
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(IconlyBold.image_2),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        child: Text(
                          AppLocalizations.of(context)!.image,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ).onTap(
              () => handleChooseFromGallery(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8, right: 8),
              child: Container(
                width: 150.0,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF6141EB),
                      Color(0xFF87D0FE),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Center(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: 40,
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          IconlyBold.video,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        child: Text(
                          AppLocalizations.of(context)!.video,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ).onTap(
              () => selectVideoFile(),
            ),
          ],
        ),
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
