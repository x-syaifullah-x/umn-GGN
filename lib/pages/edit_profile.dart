import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/home.dart';
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class EditProfile extends StatefulWidget {
  final String? currentUserId;

  const EditProfile({Key? key, this.currentUserId}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  late GloabalUser user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _countryValid = true;
  bool _phoneValid = true;
  final ImagePicker _picker = ImagePicker();
  File? imageFileAvatar;
  File? imageFileCover;
  String? imageFileAvatarUrl;
  String? imageFileCoverUrl;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = GloabalUser.fromDocument(doc);
    displayNameController.text = globalDisplayName!;
    bioController.text = globalBio!;
    countryController.text = globalCountry!;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: displayNameController,
            decoration: InputDecoration(
              hintText: "Update Display Name",
              errorText: _displayNameValid ? null : "Display Name too short",
              border: InputBorder.none,
              label: const Text('Name'),
            ),
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: bioController,
            decoration: InputDecoration(
              hintText: "Update Bio",
              label: const Text('Bio'),
              errorText: _bioValid ? null : "Bio too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: countryController,
            decoration: InputDecoration(
              hintText: "Update Country",
              label: const Text('Country'),
              errorText: _countryValid ? null : "Bio too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildPhonenumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: "Update Phone Number",
              label: const Text('Phone Number'),
              errorText: _phoneValid ? null : "Bio too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
      // phoneController.text.trim().length < 7
      //     ? _displayNameValid = false
      //     : _displayNameValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
        "country": countryController.text
      });

      SnackBar snackbar = const SnackBar(content: Text("Profile updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future getavatarImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFileAvatar = imageFileAvatar;
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
    String? mFileName = globalID;
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

  Future getcoverImage() async {
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
    String? mFileName = globalID;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("cover_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileCover!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileCoverUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef
          .doc(widget.currentUserId)
          .update({"coverUrl": imageFileCoverUrl});

      SnackBar snackbar = const SnackBar(content: Text("Cover Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: Theme.of(context).appBarTheme.iconTheme!.color),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headline5!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () => updateProfileData(),
              child: Text(
                'Save',
                style: TextStyle(
                    color: Colors.red.shade800, fontWeight: FontWeight.bold),
              ))
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        SizedBox(
                          height: 250,
                          child: Stack(
                            children: <Widget>[
                              (imageFileCover == null)
                                  ? (user.coverUrl != "")
                                      ? Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.red),
                                              ),
                                              height: 200.0,
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                            ),
                                            imageUrl: user.coverUrl,
                                            width: double.infinity,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        )
                                      : Image.asset(
                                          'assets/images/defaultcover.png',
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          height: 200,
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
                              Positioned(
                                  bottom: 30,
                                  right: 10,
                                  child: SvgPicture.asset(
                                    'assets/images/photo.svg',
                                    width: 40,
                                  ).onTap(() {
                                    getcoverImage();
                                  }))
                            ],
                          ),
                          width: double.infinity,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                (imageFileAvatar == null)
                                    ? (user.photoUrl != "")
                                        ? Material(
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .deepPurpleAccent),
                                                ),
                                                width: 120.0,
                                                height: 120.0,
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                              ),
                                              imageUrl: user.photoUrl,
                                              width: 120.0,
                                              height: 120.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15.0)),
                                            clipBehavior: Clip.hardEdge,
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF003a54),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Image.asset(
                                              'assets/images/defaultavatar.png',
                                              width: 120,
                                            ),
                                          )
                                    : Material(
                                        child: Image.file(
                                          imageFileAvatar!,
                                          width: 120.0,
                                          height: 120.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0)),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                IconButton(
                                  alignment: Alignment.bottomRight,
                                  color: Colors.red,
                                  icon: SvgPicture.asset(
                                    'assets/images/photo.svg',
                                    width: 40,
                                  ),
                                  onPressed: getavatarImage,
                                  padding: const EdgeInsets.all(0.0),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.grey,
                                  iconSize: 130,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 50,
                            alignment: Alignment.centerLeft,
                            color: Theme.of(context).shadowColor,
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Profile Info',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          buildDisplayNameField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildBioField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildCountryField(),
                          const Divider(
                            thickness: 2,
                          ),
                          // buildPhonenumberField(),
                          // const Divider(
                          //   thickness: 2,
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
