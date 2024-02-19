// ignore_for_file: unnecessary_null_comparison, unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:uuid/uuid.dart';

class PdfUpload extends StatefulWidget {
  final GloabalUser? currentUser;
  File file;
  String pdfpath;
  String pdfname;
  String pdfsize;

  PdfUpload({
    this.currentUser,
    required this.file,
    required this.pdfpath,
    required this.pdfname,
    required this.pdfsize,
  });

  @override
  _PdfUploadState createState() => _PdfUploadState();
}

class _PdfUploadState extends State<PdfUpload>
    with AutomaticKeepAliveClientMixin<PdfUpload> {
  Color? mainColor = Colors.deepPurple[400];
  TextEditingController captionController = TextEditingController();

  File? file;
  bool isUploading = false;
  String postId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  clearImage() {
    if (mounted) {
      setState(() {
        file = null;
      });
    }
  }

  Future<String> uploadVideo(videoFile) async {
    UploadTask uploadTask = storageRef
        .child("Pdf")
        .child("pdf_post_$postId.pdf")
        .putFile(videoFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String? pdfUrl,
      String? pdfName,
      String? pdfsize,
      String? description,
      int? type}) {
    postsCollection.doc(globalUserId).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": globalUserId,
      "username": globalName,
      "mediaUrl": [],
      "description": description,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "videoUrl": '',
      "pdfUrl": pdfUrl,
      "pdfsize": pdfsize,
      "pdfName": pdfName,
      "location": '',
      "type": 'pdf',
    });
  }

  handleSubmit() async {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    String pdfUrl = await uploadVideo(widget.file);
    createPostInFirestore(
        pdfUrl: pdfUrl,
        pdfsize: filesize(widget.pdfsize),
        pdfName: widget.pdfname,
        description: captionController.text);
    captionController.clear();
    if (mounted) {
      setState(() {
        isUploading = false;
        postId = const Uuid().v4();
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
              builder: (context) => Home(
                    userId: globalUserId,
                  )),
        );
      });
    }
  }

  final ButtonStyle postButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.white,
    primary: Colors.purpleAccent[300],
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
  );

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar:
          header(context, titleText: "Create Post", showMessengerButton: true),
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
            alignment: Alignment.center,
            child: Center(
              child: Stack(
                children: <Widget>[
                  (widget.file == null)
                      ? Container()
                      : Material(
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(color: Colors.grey)),
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  'assets/images/pdf_file.svg',
                                  height: 40,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  widget.pdfname,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(fontSize: 16),
                                ),
                                subtitle: Text(filesize(widget.pdfsize)),
                              ))),
                ],
              ),
            ),
            width: double.infinity,
            margin: const EdgeInsets.all(20.0),
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
          ).onTap(
            () => isUploading ? null : handleSubmit(),
          ),
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
