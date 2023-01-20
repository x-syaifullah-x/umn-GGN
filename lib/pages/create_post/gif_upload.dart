// ignore_for_file: unnecessary_null_comparison, unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class gifUpload extends StatefulWidget {
  final GloabalUser? currentUser;
  GiphyGif file;
  String gifpath;

  gifUpload(
      {this.currentUser,
      required this.file,
      required this.gifpath,
      String? location});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<gifUpload>
    with AutomaticKeepAliveClientMixin<gifUpload> {
  Color? mainColor = Colors.deepPurple[400];
  TextEditingController captionController = TextEditingController();
  late VideoPlayerController _controller;

  File? file;
  bool isUploading = false;
  String postId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.gifpath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
        .child("Videos")
        .child("video_post_$postId.mp4")
        .putFile(videoFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future CompressVideo(videoFile) async {
    if (file == null) {
      return;
    }
    await VideoCompress.setLogLevel(0);
    final MediaInfo? info = await VideoCompress.compressVideo(
      widget.gifpath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    print(info!.path);
  }

  createPostInFirestore(
      {String? videoUrl, String? location, String? description, int? type}) {
    postsRef.doc(globalID).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": globalID,
      "username": globalName,
      "mediaUrl": [],
      "description": description,
      "location": location,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "videoUrl": videoUrl,
      "pdfUrl": '',
      "pdfsize": '',
      "pdfName": '',
      "type": 'video',
    });
  }

  handleSubmit() async {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    String videoUrl = await uploadVideo(widget.file);
    createPostInFirestore(
        videoUrl: videoUrl, description: captionController.text);
    captionController.clear();
    if (mounted) {
      setState(() {
        isUploading = false;
        postId = const Uuid().v4();
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
              builder: (context) => Home(
                    userId: globalID,
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
            height: 450.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade300.withOpacity(0.3),
              boxShadow: const [
                BoxShadow(spreadRadius: 3),
              ],
            ),
            alignment: Alignment.center,
            child: Center(
              child: Stack(
                children: <Widget>[
                  (widget.file == null)
                      ? Container()
                      : Material(
                          child: SizedBox(
                          height: 450.0,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                VideoPlayer(_controller),
                                ClosedCaption(
                                    text: _controller.value.caption.text),
                                _ControlsOverlay(controller: _controller),
                                VideoProgressIndicator(_controller,
                                    allowScrubbing: true),
                              ],
                            ),
                          ),
                        )),
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

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
