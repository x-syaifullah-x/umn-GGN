// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/config/size_config.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/widgets/full_image_widget.dart';
import 'package:simpleworld/widgets/chat_appbar.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:intl/intl.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  // ignore: use_key_in_widget_constructors
  const Chat(
      {Key? key,
      required this.receiverId,
      required this.receiverAvatar,
      required this.receiverName});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);

    return Scaffold(
        appBar: MyCustomAppBar(
            height: 70,
            receiverId: receiverId,
            receiverAvatar: receiverAvatar,
            receiverName: receiverName),
        body: Column(
          children: [
            Expanded(
              child: ChatScreen(
                  receiverId: receiverId,
                  receiverAvatar: receiverAvatar,
                  receiverName: receiverName),
            ),
          ],
        ));
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverAvatar,
    required this.receiverName,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State createState() => ChatScreenState(
      receiverId: receiverId,
      receiverAvatar: receiverAvatar,
      receiverName: receiverName);
}

class ChatScreenState extends State<ChatScreen> {
  final String? currentUserId = globalID;
  final String? currentUserName = globalDisplayName;
  final String? currentUserPhoto = globalImage;

  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  ChatScreenState({
    Key? key,
    required this.receiverId,
    required this.receiverAvatar,
    required this.receiverName,
  });

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listscrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late bool isDisplaySticker;
  late bool isLoading;

  bool isExpanded = false, showMenu = false;

  File? imageFile;
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();

  String? chatId;
  // ignore: prefer_typing_uninitialized_variables
  var listMessage;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    isDisplaySticker = false;
    isLoading = false;

    chatId = "";

    readLocal();
    removeBadge();
  }

  removeBadge() async {
    await messengerRef
        .doc(currentUserId)
        .collection(currentUserId!)
        .doc(receiverId)
        .get()
        .then((doc) async {
      if (doc.exists) {
        await messengerRef
            .doc(currentUserId)
            .collection(currentUserId!)
            .doc(receiverId)
            .update({'badge': '0'});
      }
    });
  }

  readLocal() {
    if (currentUserId.hashCode <= receiverId.hashCode) {
      chatId = '$currentUserId-$receiverId';
    } else {
      chatId = '$receiverId-$currentUserId';
    }

    usersRef.doc(currentUserId).update({'chattingWith': receiverId});
    setState(() {});
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: createListMessages(),
          ),
          (isDisplaySticker ? createStickers() : Container()),
          Container(
            child: createInput(),
          ),
        ],
      ),
    );
  }

  createLoading() {
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createStickers() {
    return Container(
      decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Theme.of(context).scaffoldBackgroundColor),
      padding: const EdgeInsets.all(5.0),
      height: 210.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi1", 2),
                child: Image.asset(
                  "assets/images/mimi1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi2", 2),
                child: Image.asset(
                  "assets/images/mimi2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi3", 2),
                child: Image.asset(
                  "assets/images/mimi3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi4", 2),
                child: Image.asset(
                  "assets/images/mimi4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi5", 2),
                child: Image.asset(
                  "assets/images/mimi5.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi6", 2),
                child: Image.asset(
                  "assets/images/mimi6.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi7", 2),
                child: Image.asset(
                  "assets/images/mimi7.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi8", 2),
                child: Image.asset(
                  "assets/images/mimi8.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () => onSendMessage("mimi9", 2),
                child: Image.asset(
                  "assets/images/mimi9.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  createListMessages() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: chatId == ""
          ? Center(child: circularProgress())
          : StreamBuilder<QuerySnapshot>(
              stream: msgRef
                  .doc(chatId)
                  .collection(chatId!)
                  .orderBy("timestamp", descending: true)
                  // .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: circularProgress(),
                  );
                } else {
                  listMessage = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    controller: listscrollController,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, int index) {
                      return createItem(index, snapshot.data!.docs[index]);
                    },
                  );
                }
              }),
    );
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] == currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] != currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot doc) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    //My messages - Right Side
    if (doc["idFrom"] == currentUserId) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          doc["type"] == 0
              //Text
              ? Container(
                  width: cWidth,
                  margin: Spacing.only(top: 6, bottom: 4).add(EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.02)),
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: Spacing.fromLTRB(16, 10, 16, 10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        doc["content"],
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                        overflow: TextOverflow.fade,
                      )),
                )
              : doc["type"] == 1
                  //Image Msg
                  ? Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: <Widget>[
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FullPhoto(url: doc["content"])));
                              },
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: circularProgress(),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: const EdgeInsets.all(70.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    "assets/images/img_not_available.jpeg",
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: doc["content"],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  //Sticker
                  : Container(
                      child: Image.asset(
                        "assets/images/${doc['content']}.gif",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
      );
    }
//Receiver Messages - Left Side
    else {
      return Container(
        width: cWidth,
        margin: Spacing.only(top: 6, bottom: 4).add(
            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                //display messages
                doc["type"] == 0
                    //Text
                    ? Container(
                        constraints:
                            BoxConstraints(minWidth: 40, maxWidth: cWidth),
                        padding: Spacing.fromLTRB(16, 10, 16, 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          doc["content"],
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontSize: 15),
                        ),
                      )
                    : doc["type"] == 1
                        //Image Msg
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0.0),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhoto(
                                                url: doc["content"])));
                                  },
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: circularProgress(),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: const EdgeInsets.all(70.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Material(
                                      child: Image.asset(
                                        "assets/images/img_not_available.jpeg",
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    imageUrl: doc["content"],
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          )
                        //Sticker
                        : Container(
                            child: Image.asset(
                              "assets/images/${doc['content']}.gif",
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: const EdgeInsets.only(left: 10.0),
                          ),
              ],
            ),
            // Msg time
            isLastMsgLeft(index)
                ? Center(
                    child: Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(doc['timestamp']),
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin: const EdgeInsets.only(
                        top: 10.0,
                      ),
                    ),
                  )
                : Container(),
            // Msg time
            isLastMsgRight(index)
                ? Center(
                    child: Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(doc['timestamp']),
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin: const EdgeInsets.only(
                        top: 10.0,
                      ),
                    ),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  createInput() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: Spacing.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        onEnd: () {
          setState(() {
            showMenu = isExpanded;
          });
        },
        height: isExpanded ? 250 : 43,
        child: ListView(
          padding: Spacing.zero,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    getImage();
                  },
                  child: Container(
                      padding: Spacing.all(8),
                      child: const Icon(Ionicons.camera_outline)),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                      if (!showMenu) showMenu = true;
                    });
                  },
                  child: Container(
                      padding: Spacing.all(8),
                      child: const Icon(Ionicons.happy_outline)),
                ),
                Expanded(
                  child: Container(
                    margin: Spacing.left(16),
                    child: TextFormField(
                      style: Theme.of(context).textTheme.bodyText2,
                      decoration: InputDecoration(
                        hintText: "Type here",
                        hintStyle: Theme.of(context).textTheme.bodyText2,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(MySize.size40!),
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).shadowColor, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(MySize.size40!),
                          ),
                          borderSide: BorderSide(
                              color: Theme.of(context).shadowColor, width: 0),
                        ),
                        isDense: true,
                        contentPadding: Spacing.fromLTRB(16, 12, 16, 12),
                        filled: true,
                        fillColor: Theme.of(context).canvasColor,
                      ),
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (message) {
                        onSendMessage(textEditingController.text, 0);
                      },
                      controller: textEditingController,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: Spacing.left(16),
                  width: MySize.size38,
                  height: MySize.size38,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red[800]),
                  child: InkWell(
                    onTap: () {
                      onSendMessage(textEditingController.text, 0);
                    },
                    child: SvgPicture.asset(
                      'assets/images/chat_send.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                )
              ],
            ),
            showMenu ? createStickers() : Container()
          ],
        ),
      ),
    );
  }

  void onSendMessage(String contentMsg, int type)async {
    int badgeCount = 0;
    if (contentMsg != "") {
      textEditingController.clear();

      var docRef = msgRef
          .doc(chatId)
          .collection(chatId!)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docRef, {
          "idFrom": currentUserId,
          "idTo": receiverId,
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": contentMsg,
          "type": type,
        });
      }).then((onValue) async {
        await messengerRef
            .doc(currentUserId)
            .collection(currentUserId!)
            .doc(receiverId)
            .set({
          'id': receiverId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': contentMsg,
          'badge': '0',
          'name': receiverName,
          'profileImage': receiverAvatar,
          'type': type
        });
      }).then((onValue) async {
        try {
          await messengerRef
              .doc(receiverId)
              .collection(receiverId)
              .doc(currentUserId)
              .get()
              .then((doc) async {
            debugPrint(doc["badge"]);
            if (doc["badge"] != null) {
              badgeCount = int.parse(doc["badge"]);
              await messengerRef
                  .doc(receiverId)
                  .collection(receiverId)
                  .doc(currentUserId)
                  .set({
                'id': currentUserId,
                'name': currentUserName,
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                'content': contentMsg,
                'badge': '${badgeCount + 1}',
                'profileImage': currentUserPhoto,
                'type': type
              }).then((onValue) {
                activityFeedRef.doc(receiverId).collection('feedItems').add({
                  "type": "message",
                  "contentMessage": contentMsg,
                  "timestamp": timestamp,
                  "fromId": currentUserId,
                  "toId": receiverId,
                  "username": globalName,
                  "userProfileImg": globalImage,
                  "Msgtype": type,
                  "isSeen": false,
                });
              });
            }
          });
        } catch (e) {
          await messengerRef
              .doc(receiverId)
              .collection(receiverId)
              .doc(currentUserId)
              .set({
            'id': currentUserId,
            'name': currentUserName,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': contentMsg,
            'badge': '${badgeCount + 1}',
            'profileImage': currentUserPhoto,
            'type': type
          }).then((onValue) {
            activityFeedRef.doc(receiverId).collection('feedItems').add({
              "type": "message",
              "contentMessage": contentMsg,
              "timestamp": timestamp,
              "fromId": currentUserId,
              "toId": receiverId,
              "username": globalName,
              "userProfileImg": globalImage,
              "Msgtype": type,
              "isSeen": false,
            });
          });
          print(e);
        }
      });

      listscrollController.animateTo(0.0,
          duration: const Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty Message. can not be send");
    }
var user =  await usersRef.doc(receiverId).get();
    var current =await usersRef.doc(currentUserId).get();

    //currentUserId
    print(user.data()!["androidNotificationToken"]);

    //displayName
   getapi(user.data()!["androidNotificationToken"], current.data()!["displayName"], contentMsg);
  }

  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFile = imageFile;
      if (pickedFile != null) {
        isLoading = true;
        imageFile = File(pickedFile.path);
        // print(imageFile!.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadImageFile();
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child("Chat Images").child(fileName);
    UploadTask storageUploadTask = storageReference.putFile(imageFile!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageUrl = downloadUrl;
    setState(() {
      isLoading = false;
      onSendMessage(imageUrl!, 1);
    });
  }


}


getapi(
    String token, String username , String msg
    ) async {
  var dio = Dio();
  final response = await dio.post("https://fcm.googleapis.com/fcm/send",
      data: {
        "to":token,
        "priority":"HIGH",
        "notification": {
          "title": "$username sent you Message",
          "body": "$msg",
        },
        "data": {

          "title": "Hello",
          "notification": {
            "title": "$username sent you Message",
            "body": "$msg",
          },

          "android": "",
          "apple":"",
        }
      },
      options: Options(headers: {

        "authorization": 'key=AAAAvXer5r4:APA91bGggY3wt1_z6GlcKyi-6PXLLf03oMqs6SYjRVrHW5NsF1Eq1TkUOmIVqCYany-eA_8DHxzpucyypO2FYsowMlwNIeqmuusXtOr1bATNinWw-MBAJoXip2gZZ3Aso-EUp1i7g2BV',
        "Content-Type": "application/json",
      },

      ));

  print(response.statusCode!);
  print(response.data);
}