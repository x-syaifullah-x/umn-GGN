// ignore_for_file: unnecessary_null_comparison, unnecessary_this

import 'dart:async';
import 'dart:io' as i;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final GloabalUser? currentUser;
  final String? location;

  List<XFile>? imageFileList = [];

  Upload({this.currentUser, this.imageFileList, this.location});

  @override
  _UploadState createState() => _UploadState(imageFileList!);
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  Color? mainColor = Colors.deepPurple[400];
  TextEditingController captionController = TextEditingController();

  final List<XFile> _imageFileList;

  _UploadState(this._imageFileList);

  static List<int> get buffer =>
      List.generate(32, (int index) => index * index);

  set _imageFile(XFile? value) {
    widget.imageFileList = value == null ? null : [value];
  }

  dynamic _pickImageError;
  String? _retrieveDataError;

  bool isUploading = false;
  String postId = const Uuid().v4();
  String photoId = const Uuid().v1();
  bool uploading = false;
  double val = 0;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> uploadFiles(List<XFile> _images) async {
    var imageUrls =
        await Future.wait(_images.map((_image) => uploadFile(_image)));
    print(imageUrls);
    return imageUrls;
  }

  Future<String> uploadFile(XFile _image) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('posts/${_image.path}');
    UploadTask uploadTask = storageReference.putFile(i.File(_image.path));
    // await uploadTask.onComplete;
    TaskSnapshot storageSnap = await uploadTask;

    int it = 1;

    for (var img in _imageFileList) {
      setState(() {
        val = it / _imageFileList.length;
      });

      var photoId = postsRef
          .doc(globalID)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .doc()
          .id
          .toString();
      return await storageSnap.ref.getDownloadURL().then((value) {
        postsRef
            .doc(globalID)
            .collection("userPosts")
            .doc(postId)
            .collection("albumposts")
            .doc(photoId)
            .set({
          'mediaUrl': value,
          "postId": postId,
          "ownerId": globalID,
          "username": globalName,
          "location": widget.location,
          "description": '',
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "type": 'photo',
          "photoId": photoId,
        });
        it++;
        return value;
      });
    }

    return await storageSnap.ref.getDownloadURL();
  }

  createPostInFirestore({List? mediaUrls, String? description, int? type}) {
    postsRef.doc(globalID).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": globalID,
      "username": globalName,
      "mediaUrl": mediaUrls,
      "description": description,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "location": widget.location != null
          ? widget.location
          : _currentAddress != null
              ? _currentAddress
              : '',
      "videoUrl": '',
      "pdfUrl": '',
      "pdfsize": '',
      "pdfName": '',
      "type": 'photo',
    });
  }

  createtextPostsInFirestore({
    String? mediaUrl,
    String? description,
    int? type,
  }) {
    postsRef
        .doc(globalID)
        .collection("userPosts")
        .doc(postId)
        .collection("albumposts")
        .doc(photoId)
        .set({
      "postId": postId,
      "ownerId": globalID,
      "username": globalName,
      "mediaUrl": '',
      "description": description,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "type": 'text',
      "photoId": photoId,
    });
  }

  handleSubmit() async {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }

    // await compressImage();
    List<String> mediaUrls = (await uploadFiles(_imageFileList));

    if (captionController.text.isNotEmpty) {
      createtextPostsInFirestore(description: captionController.text);
    }

    createPostInFirestore(
      mediaUrls: mediaUrls,
      description: captionController.text,
    );
    captionController.clear();
    if (mounted) {
      setState(() {
        isUploading = false;
        postId = const Uuid().v4();
        // Navigator.of(context).pop();
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).shadowColor,
            width: 1.0,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * 0.25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.red.shade500, Colors.red.shade900])),
            child: const Text(
              'Post',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ).onTap(
            () => isUploading ? null : handleSubmit(),
          )
        ],
        elevation: 0.0,
      ),
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
            subtitle: (widget.location != null)
                ? Text('at ${widget.location}')
                : (_currentAddress != null)
                    ? Text('at ${_currentAddress}')
                    : const Text(''),
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
            alignment: Alignment.center,
            child: Center(child: _previewImages()),
            width: double.infinity,
            margin: const EdgeInsets.all(20.0),
          ),
          Column(
            children: [
              const Divider(height: 1.0, thickness: 0.5),
              _getActionMenu(
                AppLocalizations.of(context)!.check_in,
                Icons.location_on,
                Colors.redAccent,
                () => _getCurrentLocation(),
              ),
              const Divider(height: 1.0, thickness: 0.5),
            ],
          )
        ],
      ),
    );
  }

  ListTile _getActionMenu(
      String text, IconData icon, Color color, Function() onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: Theme.of(context).textTheme.button,
      ),
      onTap: onTap,
      minLeadingWidth: 1,
    );
  }

  _getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (widget.imageFileList != null) {
      return Semantics(
          child: GridView.builder(
              itemCount: widget.imageFileList!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return Image.file(
                  i.File(widget.imageFileList![index].path),
                  fit: BoxFit.cover,
                );
              }),
          label: 'image_picker_example_picked_images');
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildUploadForm();
  }
}
