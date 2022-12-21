// ignore_for_file: unnecessary_this

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/user_to_follow.dart';
import 'package:simpleworld/widgets/bezier_container.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class GetAvatar extends StatefulWidget {
  final String? currentUserId;

  const GetAvatar({Key? key, this.currentUserId}) : super(key: key);

  @override
  _GetAvatarState createState() => _GetAvatarState();
}

class _GetAvatarState extends State<GetAvatar> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  File? imageFileAvatar;
  File? imageFileCover;
  String? imageFileAvatarUrl;
  String? imageFileCoverUrl;

  @override
  void initState() {
    super.initState();
  }

  Future getavatarImage() async {
    final newImageFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      this.imageFileAvatar = imageFileAvatar;
      if (newImageFile != null) {
        imageFileAvatar = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadAvatar(imageFileAvatar);
  }

  Future uploadAvatar(imageFileAvatar) async {
    String mFileName = globalID!;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("avatar_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileAvatar!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileAvatarUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef
          .doc(widget.currentUserId)
          .update({"photoUrl": imageFileAvatarUrl});

      SnackBar snackbar =
          const SnackBar(content: Text("Profile Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Global Net',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        Container(
          child: Center(
            child: Stack(
              children: <Widget>[
                (imageFileAvatar == null)
                    ? (globalImage != "")
                        ? Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.deepPurpleAccent),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: const EdgeInsets.all(20.0),
                              ),
                              imageUrl: globalImage!,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(125.0)),
                            clipBehavior: Clip.hardEdge,
                          )
                        : Icon(Icons.account_circle,
                            size: 200.0, color: Colors.red[400])
                    : Material(
                        child: Image.file(
                          imageFileAvatar!,
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                IconButton(
                  alignment: Alignment.bottomRight,
                  icon: SvgPicture.asset(
                    'assets/images/photo.svg',
                    width: 60,
                  ),
                  onPressed: getavatarImage,
                  padding: const EdgeInsets.all(0.0),
                  splashColor: Colors.transparent,
                  highlightColor: const Color(0xfff3f3f4),
                  iconSize: 200.0,
                )
              ],
            ),
          ),
          width: double.infinity,
          margin: const EdgeInsets.all(20.0),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.red.shade500, Colors.red.shade900])),
      child: const Text(
        'Next',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => UsersToFollowList(
            userId: widget.currentUserId,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
