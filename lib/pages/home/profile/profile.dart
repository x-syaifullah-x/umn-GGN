import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:global_net/pages/chat/simpleworld_chat.dart';
import 'package:global_net/pages/comming_soon_page.dart';
import 'package:global_net/pages/coupon/coupon.dart';
import 'package:global_net/pages/create_post/post_box.dart';
import 'package:global_net/pages/disliked_list.dart';
import 'package:global_net/pages/edit_profile.dart';
import 'package:global_net/pages/followers_list.dart';
import 'package:global_net/pages/following_users_list.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/liked_list.dart';
import 'package:global_net/pages/ppviewed_list.dart';
import 'package:global_net/pages/wallet/wallet.dart';
import 'package:global_net/story/add_story.dart';
import 'package:global_net/widgets/header.dart';
import 'package:global_net/widgets/multi_manager/flick_multi_manager.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:global_net/widgets/single_post.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../data/user.dart';
import '../user/user.dart';

class Profile extends StatelessWidget {
  final User user;
  final List<Reaction<String>> reactions;
  final String ownerId;

  const Profile({
    Key? key,
    required this.user,
    required this.reactions,
    required this.ownerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final bool widthMoreThan_500 = (MediaQuery.of(context).size.width > 500);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: header(
        context,
        titleText: AppLocalizations.of(context)!.profile,
      ),
      body: Column(
        children: [
          Expanded(
            child: RawScrollbar(
              controller: scrollController,
              interactive: true,
              thumbVisibility: !kIsWeb && widthMoreThan_500,
              trackVisibility: !kIsWeb && widthMoreThan_500,
              radius: const Radius.circular(20),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Profile2(
                    reactions: reactions,
                    ownerId: ownerId,
                    user: user,
                  ),
                ),
              ),
            ),
          ),
          // const AdsWidget(),
        ],
      ),
    );
  }
}

class Profile2 extends StatefulWidget {
  final List<Reaction<String>> reactions;
  final String ownerId;
  final User user;

  const Profile2({
    Key? key,
    required this.reactions,
    required this.ownerId,
    required this.user,
  }) : super(key: key);

  @override
  State<Profile2> createState() => _ProfileState();
}

class _ProfileState extends State<Profile2> {
  String postOrientation = 'list';
  bool isLoading = false;
  int postCount = 0;
  final ImagePicker _picker = ImagePicker();
  File? storyFile;
  File? imageFileAvatar;
  File? imageFileCover;
  String? imageFileAvatarUrl;
  String? imageFileCoverUrl;
  bool showHeart = false;
  late FlickMultiManager flickMultiManager;
  List<SinglePost> posts = [];

  @override
  void initState() {
    super.initState();
    _getProfilePosts();
    flickMultiManager = FlickMultiManager();
    _viewMyProfile();
  }

  _viewMyProfile() {
    if (widget.user.id != widget.ownerId) {
      ppviewsCollection
          .doc(widget.user.id)
          .collection('userviews')
          .doc(widget.ownerId)
          .set({
        'userId': widget.ownerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    }
  }

  _getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsCollection
        .doc(widget.user.id)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) {
        return SinglePost.fromDocument(doc);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileHeader(widget.user);
  }

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (mounted) {
      setState(() async {
        if (pickedFile != null) {
          storyFile = File(pickedFile.path);

          await navigator
              .push(MaterialPageRoute(builder: (context) => AddStory()));
        } else {
          // print('No image selected.');
        }
      });
    }
  }

  Widget buildCountColumn(String label, int count, Function() onTap) {
    double maxWidth = MediaQuery.of(context).size.width *
        (isWeb || (MediaQuery.of(context).size.width > 600) ? 0.11 : 0.2);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            width: maxWidth,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).onTap(onTap);
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId: widget.user.id),
      ),
    );
  }

  Widget _buildProfileButton() {
    double maxWidth;
    if (isWeb || (MediaQuery.of(context).size.width > 600)) {
      maxWidth = MediaQuery.of(context).size.width * 0.22;
    } else {
      maxWidth = MediaQuery.of(context).size.width * 0.4;
    }

    final bool isOwner = widget.ownerId == widget.user.id;
    if (isOwner) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: maxWidth,
            decoration: BoxDecoration(
              color: Colors.red[600],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.add_story,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ).onTap(() {
            handleChooseFromGallery();
          }),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: maxWidth,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.edit_profile,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  color: Colors.black,
                ),
              ),
            ),
          ).onTap(() {
            editProfile();
          })
        ],
      );
    } else {
      final collection = followingCollection
          .doc(widget.ownerId)
          .collection('userFollowing')
          .doc(widget.user.id);
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          final bool isFollowing = snapshot.data?.data()?['value'] ?? false;
          return Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: (context.width() - (3 * 16)) * 0.4,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.redAccent[700] : Colors.blue[700],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Center(
              child: Text(
                isFollowing
                    ? AppLocalizations.of(context)!.unfollow
                    : AppLocalizations.of(context)!.follow,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ).onTap(() {
            final milliseconds = DateTime.now().millisecondsSinceEpoch;
            if (isFollowing) {
              collection.update({
                'updateAt': milliseconds,
                'value': false,
              });
            } else {
              collection.get().then((value) {
                if (value.exists) {
                  collection.update({
                    'updateAt': milliseconds,
                    'userId': widget.ownerId,
                    'value': true,
                  });
                } else {
                  collection.set({
                    'createAt': milliseconds,
                    'updateAt': milliseconds,
                    'userId': widget.ownerId,
                    'value': true,
                  });
                }
              });
            }
          });
        },
      );
    }
  }

  void _onClickButtonLike(bool value) {
    if (value) {
      likedDppCollection
          .doc(widget.user.id)
          .collection('userlikes')
          .doc(widget.ownerId)
          .set({'userId': widget.ownerId});
      dislikedppCollection
          .doc(widget.user.id)
          .collection('userDislikes')
          .doc(widget.ownerId)
          .delete();
    } else {
      likedDppCollection
          .doc(widget.user.id)
          .collection('userlikes')
          .doc(widget.ownerId)
          .delete();
    }
  }

  void _onClickButtonDislike(bool value) {
    if (value) {
      dislikedppCollection
          .doc(widget.user.id)
          .collection('userDislikes')
          .doc(widget.ownerId)
          .set({'userId': widget.ownerId});
      likedDppCollection
          .doc(widget.user.id)
          .collection('userlikes')
          .doc(widget.ownerId)
          .delete();
    } else {
      dislikedppCollection
          .doc(widget.user.id)
          .collection('userDislikes')
          .doc(widget.ownerId)
          .delete();
    }
  }

  Future getAvatarImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFileAvatar = imageFileAvatar;
      if (newImageFile != null) {
        imageFileAvatar = File(newImageFile.path);
      } else {}
    });

    uploadAvatar(imageFileAvatar);
  }

  Future uploadAvatar(imageFileAvatar) async {
    String mFileName = widget.user.id;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('avatar_$mFileName.jpg');
    UploadTask storageUploadTask = storageReference.putFile(imageFileAvatar!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileAvatarUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersCollection
          .doc(widget.user.id)
          .update({'photoUrl': imageFileAvatarUrl});

      SnackBar snackbar =
          const SnackBar(content: Text('Profile Photo updated!'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  Future getcoverImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFileCover = imageFileCover;
      if (newImageFile != null) {
        imageFileCover = File(newImageFile.path);
      }
    });

    uploadCover(imageFileCover);
  }

  Future uploadCover(imageFileCover) async {
    String mFileName = widget.user.id;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('cover_$mFileName.jpg');
    UploadTask storageUploadTask = storageReference.putFile(imageFileCover!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileCoverUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersCollection
          .doc(widget.user.id)
          .update({'coverUrl': imageFileCoverUrl});

      SnackBar snackbar = const SnackBar(content: Text('Cover Photo updated!'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  consentSheet(
      BuildContext context, String title, String subtitle, Function() accept) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: radius(4)),
                      height: 4,
                      width: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15.0),
                ),
              ),
              ListTile(
                title: Text(
                  subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15.0),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton(
                    onPressed: accept,
                    child: Text(
                      AppLocalizations.of(context)!.accept,
                    ),
                  )
                ],
              )
            ],
          );
        });
      },
    );
  }

  Widget _buildProfileHeader(User user) {
    final bool isOwner = widget.ownerId == widget.user.id;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: <Widget>[
            (imageFileCover == null)
                ? user.coverUrl.isEmpty
                    ? Image.asset(
                        'assets/images/defaultcover_new.jpg',
                        alignment: Alignment.center,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 200,
                      )
                    : SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: user.coverUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                : Material(
                    clipBehavior: Clip.hardEdge,
                    child: Image.file(
                      imageFileCover!,
                      width: double.infinity,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
            if (!isOwner)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: likedDppCollection
                    .doc(widget.user.id)
                    .collection('userlikes')
                    .doc(widget.ownerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final isLike = snapshot.data?.exists == true;
                  return SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Container(
                      alignment: const Alignment(-0.8, 1.5),
                      child: Stack(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              isLike
                                  ? 'assets/images/likedpp.png'
                                  : 'assets/images/likepp.png',
                              width: 40,
                            ),
                          ).onTap(() {
                            _onClickButtonLike(!isLike);
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Container(
                alignment: const Alignment(0.0, 2.5),
                child: Stack(
                  children: [
                    (imageFileAvatar == null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: user.photoUrl.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003a54),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Image.asset(
                                      'assets/images/defaultavatar.png',
                                      width: 120,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: user.photoUrl,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : Material(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15.0)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.file(
                              imageFileAvatar!,
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                    widget.ownerId == widget.user.id
                        ? SvgPicture.asset(
                            'assets/images/photo.svg',
                            width: 40,
                          ).onTap(() {
                            getAvatarImage();
                          })
                        : const Text(''),
                  ],
                ),
              ),
            ),
            if (!isOwner)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: dislikedppCollection
                    .doc(widget.user.id)
                    .collection('userDislikes')
                    .doc(widget.ownerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final isDislike = snapshot.data?.exists == true;
                  return SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Container(
                      alignment: const Alignment(0.8, 1.5),
                      child: Stack(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              isDislike
                                  ? 'assets/images/dislikedpp.png'
                                  : 'assets/images/dislikepp.png',
                              width: 40,
                            ),
                          ).onTap(() {
                            _onClickButtonDislike(!isDislike);
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (isOwner)
              Positioned(
                bottom: 0,
                right: 0,
                child: SvgPicture.asset(
                  'assets/images/photo.svg',
                  width: 40,
                ).onTap(() {
                  getcoverImage();
                }),
              ),
          ],
        ),
        const SizedBox(height: 70),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.username.capitalize(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 16),
            ),

            /// Show verified badge
            user.userIsVerified
                ? Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: Image.asset(
                      'assets/images/verified_badge.png',
                      width: 25,
                      height: 25,
                    ),
                  )
                : const SizedBox(width: 0, height: 0),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          user.bio,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14),
        ),
        if (widget.ownerId == widget.user.id)
          Column(
            children: [
              LayoutBuilder(
                builder: (buildContext, constraint) {
                  final width = constraint.biggest.width;
                  return Card(
                    elevation: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      width: width * .85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet ID',
                                style: GoogleFonts.portLligatSans(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              InkWell(
                                child: const Icon(
                                  Icons.copy_all_sharp,
                                  size: 18,
                                ),
                                onTap: () async {
                                  try {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: widget.user.id,
                                      ),
                                    );
                                    toast(
                                        'Wallet ID has been successfully copied');
                                  } catch (e) {
                                    log('$e');
                                  }
                                },
                              ),
                              Text(
                                user.id,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Total Balance',
                            style: GoogleFonts.portLligatSans(
                              textStyle:
                                  Theme.of(context).textTheme.headlineMedium,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Credits ${user.creditPoints} = USD \$${(user.creditPoints / 100.00).toStringAsFixed(2)}',
                            style: GoogleFonts.portLligatSans(
                              textStyle:
                                  Theme.of(context).textTheme.headlineMedium,
                              fontSize: 18,
                            ),
                          ),
                          8.height,
                          Center(
                            child: SizedBox(
                              height: 32,
                              width: width * .65,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Wallet(user: user);
                                      },
                                    ),
                                  );
                                },
                                child: const Text('Buy Credits'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Text(
              //   '${AppLocalizations.of(context)!.you_have} ${user.creditPoints} ${AppLocalizations.of(context)!.credits}',
              //   style: Theme.of(context)
              //       .textTheme
              //       .titleLarge!
              //       .copyWith(fontSize: 14),
              // ),
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: <Widget>[
              //     Container(
              //       margin: const EdgeInsets.only(top: 10.0, left: 10),
              //       padding: const EdgeInsets.only(left: 10, right: 10),
              //       height: 38,
              //       decoration: const BoxDecoration(
              //         color: Color(0xffE5E6EB),
              //         borderRadius: BorderRadius.all(
              //           Radius.circular(5.0),
              //         ),
              //       ),
              //       child: Center(
              //         child: Text(
              //           AppLocalizations.of(context)!.buy_credits,
              //           textAlign: TextAlign.left,
              //           style: const TextStyle(
              //             fontWeight: FontWeight.w700,
              //             fontSize: 16,
              //             letterSpacing: 0.0,
              //             color: Colors.black,
              //           ),
              //         ),
              //       ),
              //     ).onTap(() {
              //       Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) {
              //             return Wallet(user: user);
              //           },
              //         ),
              //       );
              //     }),
              //   ],
              // ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildProfileButton(),
            const SizedBox(width: 10),
            if (widget.ownerId != widget.user.id)
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    height: 38,
                    width: (context.width() - (3 * 16)) * 0.4,
                    decoration: const BoxDecoration(
                      color: Color(0xffE5E6EB),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.message,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ).onTap(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          receiverId: user.id,
                          receiverAvatar: user.photoUrl,
                          receiverName: user.username,
                          key: null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
        20.height,
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildCountColumn(
                AppLocalizations.of(context)!.posts,
                postCount,
                () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const CommimgSoon(),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: followersCollection
                    .doc(widget.user.id)
                    .collection('userFollowers')
                    .snapshots(),
                builder: (context, snapshot) {
                  int followerCount = 0;
                  snapshot.data?.docs.forEach((e) {
                    try {
                      if (e[UserWidget.fieldValue] == true) {
                        followerCount += 1;
                      }
                    } catch (e) {
                      log(e);
                    }
                  });
                  return buildCountColumn(
                    AppLocalizations.of(context)!.followers,
                    followerCount,
                    () {
                      if (widget.ownerId == widget.user.id) {
                        bool noCredit = user.creditPoints < 10;
                        consentSheet(
                          context,
                          AppLocalizations.of(context)!.followed_consent1,
                          AppLocalizations.of(context)!.followed_consent2,
                          () async {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              simpleworldtoast(
                                  AppLocalizations.of(context)!.error,
                                  AppLocalizations.of(context)!
                                      .not_enough_credit_10,
                                  context);
                            } else {
                              Navigator.of(context).pop();
                              usersCollection.doc(widget.user.id).update({
                                User.fieldNameCreditPoints:
                                    FieldValue.increment(-10),
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => followersList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        bool noCredit = user.creditPoints < 20;
                        consentSheet(
                          context,
                          AppLocalizations.of(context)!.followed_consent3,
                          AppLocalizations.of(context)!.followed_consent4,
                          () async {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              simpleworldtoast(
                                  AppLocalizations.of(context)!.error,
                                  AppLocalizations.of(context)!
                                      .not_enough_credit_20,
                                  context);
                            } else {
                              Navigator.of(context).pop();

                              usersCollection.doc(widget.user.id).update({
                                User.fieldNameCreditPoints:
                                    FieldValue.increment(-20),
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => followersList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                },
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: followingCollection
                    .doc(widget.user.id)
                    .collection('userFollowing')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  snapshot.data?.docs.forEach((e) {
                    try {
                      if (e[UserWidget.fieldValue] == true) {
                        count += 1;
                      }
                    } catch (e) {
                      log(e);
                    }
                  });
                  return buildCountColumn(
                    AppLocalizations.of(context)!.following,
                    count,
                    () {
                      if (widget.ownerId == widget.user.id) {
                        bool noCredit = user.creditPoints < 10;
                        consentSheet(
                          context,
                          AppLocalizations.of(context)!.following_consent1,
                          AppLocalizations.of(context)!.following_consent2,
                          () async {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              simpleworldtoast(
                                  AppLocalizations.of(context)!.error,
                                  AppLocalizations.of(context)!
                                      .not_enough_credit_10,
                                  context);
                            } else {
                              Navigator.of(context).pop();
                              usersCollection.doc(widget.user.id).update({
                                User.fieldNameCreditPoints:
                                    FieldValue.increment(-10),
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowingList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        bool noCredit = user.creditPoints < 20;
                        consentSheet(
                          context,
                          AppLocalizations.of(context)!.following_consent3,
                          AppLocalizations.of(context)!.following_consent4,
                          () async {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              simpleworldtoast(
                                  AppLocalizations.of(context)!.error,
                                  AppLocalizations.of(context)!
                                      .not_enough_credit_20,
                                  context);
                            } else {
                              Navigator.of(context).pop();

                              usersCollection.doc(widget.user.id).update({
                                User.fieldNameCreditPoints:
                                    FieldValue.increment(-20),
                                // 'userIsVerified': true,
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowingList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ppviewsCollection
                    .doc(widget.user.id)
                    .collection('userviews')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return buildCountColumn(
                    'Views',
                    count,
                    () {
                      if (widget.ownerId == widget.user.id) {
                        bool noCredit = user.creditPoints < 10;
                        consentSheet(
                          context,
                          'Would you like to see users who viewed your Profile?',
                          'Spent 10 Credits to see users who viewed your Profile',
                          () {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              simpleworldtoast(
                                  'Error',
                                  'Does not have enough credits, please get more then 10 credits',
                                  context);
                            } else {
                              Navigator.of(context).pop();
                              usersCollection.doc(widget.user.id).update({
                                User.fieldNameCreditPoints:
                                    FieldValue.increment(-10),
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UsersViewedMyProfileList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        bool noCredit = user.creditPoints < 20;
                        consentSheet(
                          context,
                          'Would you like to see users who viewed  this Profile?',
                          'Spent 20 Credits to see users who viewed this Profile',
                          () {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              simpleworldtoast(
                                  'Error',
                                  'Does not have enough credits, please get more then 20 credits',
                                  context);
                            } else {
                              Navigator.of(context).pop();

                              usersCollection.doc(widget.user.id).update({
                                User.fieldNameCreditPoints:
                                    FieldValue.increment(-20),
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UsersViewedMyProfileList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                },
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: likedDppCollection
                    .doc(widget.user.id)
                    .collection('userlikes')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return buildCountColumn('Likes', count, () {
                    if (isOwner) {
                      bool noCredit = user.creditPoints < 10;
                      consentSheet(
                        context,
                        'Would you like to see users who liked your Profile?',
                        'Spent 10 Credits to see users who liked your Profile',
                        () {
                          if (noCredit) {
                            Navigator.of(context).pop();
                            simpleworldtoast(
                                'Error',
                                'Does not have enough credits, please get more then 10 credits',
                                context);
                          } else {
                            Navigator.of(context).pop();
                            usersCollection.doc(widget.user.id).update({
                              User.fieldNameCreditPoints:
                                  FieldValue.increment(-10),
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UsersLikedMyProfileList(
                                  userId: user.id,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      bool noCredit = user.creditPoints < 20;
                      consentSheet(
                        context,
                        'Would you like to see users who liked  this Profile?',
                        'Spent 20 Credits to see users who liked this Profile',
                        () {
                          if (noCredit) {
                            Navigator.of(context).pop();
                            simpleworldtoast(
                                'Error',
                                'Does not have enough credits, please get more then 20 credits',
                                context);
                          } else {
                            Navigator.of(context).pop();

                            usersCollection.doc(widget.user.id).update({
                              User.fieldNameCreditPoints:
                                  FieldValue.increment(-20),
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UsersLikedMyProfileList(
                                  userId: user.id,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  });
                },
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: dislikedppCollection
                    .doc(widget.user.id)
                    .collection('userDislikes')
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return buildCountColumn('Dislikes', count, () {
                    if (widget.ownerId == widget.user.id) {
                      bool noCredit = user.creditPoints < 10;
                      consentSheet(
                        context,
                        'Would you like to see users who Disliked your Profile?',
                        'Spent 10 Credits to see users who Disliked your Profile',
                        () {
                          if (noCredit) {
                            Navigator.of(context).pop();
                            simpleworldtoast(
                              'Error',
                              'Does not have enough credits, please get more then 10 credits',
                              context,
                            );
                          } else {
                            Navigator.of(context).pop();
                            usersCollection.doc(widget.user.id).update({
                              User.fieldNameCreditPoints:
                                  FieldValue.increment(-10),
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UsersDisLikedMyProfileList(
                                  userId: user.id,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      bool noCredit = user.creditPoints < 20;
                      consentSheet(
                        context,
                        'Would you like to see users who Disliked  this Profile?',
                        'Spent 20 Credits to see users who Disliked this Profile',
                        () {
                          if (noCredit) {
                            Navigator.of(context).pop();
                            simpleworldtoast(
                                'Error',
                                'Does not have enough credits, please get more then 20 credits',
                                context);
                          } else {
                            Navigator.of(context).pop();

                            usersCollection.doc(widget.user.id).update({
                              User.fieldNameCreditPoints:
                                  FieldValue.increment(-20),
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UsersDisLikedMyProfileList(
                                  userId: user.id,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: usersCollection.doc(widget.user.id).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CupertinoActivityIndicator();
            }
            final data = snapshot.data?.data();
            final user = User.fromJson(data);
            return PostBox(user: user);
          },
        ),
        const Divider(),
        _buildProfilePosts()
      ],
    );
  }

  _buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 260.0,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'No Posts',
              style: TextStyle(
                color: Colors.red,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }
}
