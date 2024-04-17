import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/models/user.dart';
import 'package:global_net/pages/create_post/add_post.dart';
import 'package:global_net/pages/create_post/pdf_upload.dart';
import 'package:global_net/pages/create_post/upload.dart';
import 'package:global_net/pages/create_post/video_upload.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';

class PostBox extends StatefulWidget {
  final User user;

  const PostBox({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox>
    with AutomaticKeepAliveClientMixin<PostBox> {
  Color? mainColor = Colors.deepPurple[400];
  final ImagePicker _picker = ImagePicker();
  TextEditingController captionController = TextEditingController();
  bool isLoading = false;
  File? newvediofile;
  File? pdffile;
  File? file;
  bool isUploading = false;
  String postId = const Uuid().v4();
  List<XFile>? _imageFileList;

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);

    final pickedFileList = await _picker.pickMultiImage(imageQuality: 50);

    if (mounted) {
      setState(() async {
        _imageFileList = pickedFileList;
        if (pickedFileList != null) {
          final userDoc = await usersCollection.doc(widget.user.id).get();
          final data = userDoc.data();
          if (data != null) {
            await navigator.push(
              MaterialPageRoute(
                builder: (context) => Upload(
                  currentUser: GloabalUser.fromMap(data),
                  imageFileList: _imageFileList,
                ),
              ),
            );
          }
        } else {
          log('No image selected.');
        }
      });
    }
  }

  Future _selectVideoFile(BuildContext context) async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    final length = (await xFile?.length()) ?? 0;

    if (mounted) {
      setState(() async {
        if (xFile != null) {
          double sizeInMb = length / (1024 * 1024);
          const maxSize = 50;
          if (sizeInMb > maxSize) {
            simpleworldtoast(
                '', 'File Size is larger then ${maxSize}mb', context);
            return;
          }

          final navigator = Navigator.of(context);
          await navigator.push(
            MaterialPageRoute(
              builder: (context) => VideoUpload(
                userId: widget.user.id,
                xFile: xFile,
              ),
            ),
          );
        } else {
          log('No image selected.');
        }
      });
    }
    // if (mounted) {
    //   setState(() async {
    //     _videoFile = _videoFile;
    //     if (xFile != null) {
    //       _videoFile = File(xFile.path);
    //       await VideoCompress.setLogLevel(0);
    //       final info = await VideoCompress.compressVideo(
    //         _videoFile!.path,
    //         quality: VideoQuality.LowQuality,
    //         deleteOrigin: false,
    //         includeAudio: true,
    //       );
    //       if (info != null) {
    //         setState(() {
    //           newvediofile = File(info.path!);
    //         });
    //       }
    //       int size = newvediofile!.lengthSync();
    //       double sizeInMb = size / (1024 * 1024);
    //       if (sizeInMb > 5) {
    //         simpleworldtoast('', 'File Size is larger then 5mb', context);
    //         return;
    //       }

    //       final userDoc = await usersCollection.doc(widget.user.id).get();
    //       final data = userDoc.data();
    //       if (data != null) {
    //         final navigator = Navigator.of(context);
    //         await navigator.push(
    //           MaterialPageRoute(
    //             builder: (context) => VideoUpload(
    //               currentUser: GloabalUser.fromMap(data),
    //               file: newvediofile!,
    //               videopath: xFile.path,
    //             ),
    //           ),
    //         );
    //       }
    //     } else {
    //       log('No image selected.');
    //     }
    //   });
    // }
  }

  Future selectPDFFile() async {
    final navigator = Navigator.of(context);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;
    final path = result.files.single.path!;

    String fileName = result.files.first.name;

    setState(() async {
      pdffile = File(path);
      if (result != null) {
        pdffile = File(path);
        int size = pdffile!.lengthSync();
        String pdfsize = "$size";
        double sizeInMb = size / (1024 * 1024);
        if (sizeInMb > 5) {
          simpleworldtoast("", "File Size is larger then 5mb", context);
          return;
        }
        final userDoc = await usersCollection.doc(widget.user.id).get();
        final data = userDoc.data();
        if (data != null) {
          await navigator.push(
            MaterialPageRoute(
              builder: (context) => PdfUpload(
                currentUser: GloabalUser.fromMap(data),
                file: pdffile!,
                pdfpath: path,
                pdfname: fileName,
                pdfsize: pdfsize,
              ),
            ),
          );
        }
      } else {
        // print('No image selected.');
      }
    });
  }

  createPostInFirestore({List? mediaUrl, String? description, int? type}) {
    postsCollection.doc(globalUserId).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": globalUserId,
      "username": globalName,
      "mediaUrl": mediaUrl,
      "description": description,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "videoUrl": '',
      "pdfUrl": '',
      "pdfsize": '',
      "location": '',
      "pdfName": '',
      "type": 'text',
    });
  }

  handleSubmitontext() async {
    createPostInFirestore(mediaUrl: [], description: captionController.text);
    captionController.clear();

    if (mounted) {
      setState(() {
        postId = const Uuid().v4();
        FocusScope.of(context).unfocus();
      });
    }
  }

  Widget _buildPostBox() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      elevation: 0.0,
      shape: isDesktop
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: widget.user.photoUrl.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF003a54),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Image.asset(
                            'assets/images/defaultavatar.png',
                            width: 50,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.user.photoUrl,
                          height: 50.0,
                          width: 50.0,
                          fit: BoxFit.cover,
                        ),
                  // child: globalImage == null || globalImage!.isEmpty
                  //     ? Container(
                  //         decoration: BoxDecoration(
                  //           color: const Color(0xFF003a54),
                  //           borderRadius: BorderRadius.circular(15.0),
                  //         ),
                  //         child: Image.asset(
                  //           'assets/images/defaultavatar.png',
                  //           width: 50,
                  //         ),
                  //       )
                  //     : CachedNetworkImage(
                  //         imageUrl: globalImage!,
                  //         height: 50.0,
                  //         width: 50.0,
                  //         fit: BoxFit.cover,
                  //       ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    child: IgnorePointer(
                      child: TextField(
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.whats_on_mind,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 25),
                          // border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          filled: false,
                        ),
                      ),
                    ),
                  ).onTap(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPost(
                          userId: widget.user.id,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
            const Divider(height: 10.0, thickness: 0.5),
            SizedBox(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => handleChooseFromGallery(),
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.green,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.photo,
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  const VerticalDivider(width: 8.0),
                  TextButton.icon(
                    onPressed: () => _selectVideoFile(context),
                    icon: const Icon(
                      Icons.videocam,
                      color: Colors.red,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.video,
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  const VerticalDivider(width: 8.0),
                  TextButton.icon(
                    onPressed: () => selectPDFFile(),
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.purpleAccent,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.pdf,
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ],
              ),
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

    return _buildPostBox();
  }
}
