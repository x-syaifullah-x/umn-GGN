import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:simpleworld/config/size_config.dart';
import 'package:simpleworld/services/database_service.dart';
import 'package:simpleworld/widgets/groupchatdrawer.dart';
import 'package:simpleworld/widgets/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;
  final String admin;
  final String groupIcon;
  final List members;

  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.userName,
      required this.groupName,
      required this.admin,
      required this.groupIcon,
      required this.members})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? _chats;
  TextEditingController messageEditingController = TextEditingController();
  bool isExpanded = false, showMenu = false;
  final ScrollController listscrollController = ScrollController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _chatMessages() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: StreamBuilder(
        stream: _chats,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  reverse: true,
                  controller: listscrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      index: index,
                      message: snapshot.data!.docs[index]["message"],
                      sender: snapshot.data!.docs[index]["sender"],
                      sentByMe: widget.userName ==
                          snapshot.data!.docs[index]["sender"],
                      time: snapshot.data!.docs[index]["time"],
                    );
                  })
              : Container();
        },
      ),
    );
  }

  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
        'type': 0
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        _chats = val;
      });
    });
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
                    // getImage();
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
                        _sendMessage();
                      },
                      controller: messageEditingController,
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
                      _sendMessage();
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
          ],
        ),
      ),
    );
  }

  buildProfileDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Container(
              child: widget.groupIcon.isNotEmpty
                  ? ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl: widget.groupIcon,
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF003a54),
                      ),
                      child: Text(
                        widget.groupName.substring(0, 1).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.message),
            title: Text('members'),
          ),
          const ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Delete Group'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            MdiIcons.chevronLeft,
          ),
        ),
        leadingWidth: 15,
        title: Row(
          children: [
            Container(
              margin: Spacing.left(8),
              child: widget.groupIcon.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.groupIcon,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF003a54),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Image.asset(
                        'assets/images/defaultavatar.png',
                        width: 40,
                      ),
                    ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 16,
                      ),
                ),
                Text(
                  widget.members.length.toString() + ' members',
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _key.currentState!.openEndDrawer();
            },
            icon: const Icon(
              MdiIcons.dotsVertical,
            ),
          ),
        ],
        elevation: 0.0,
      ),
      endDrawer: DrawerMenu(
        groupId: widget.groupId,
        groupName: widget.groupName,
        userName: widget.userName,
        admin: widget.admin,
        groupIcon: widget.groupIcon,
        members: widget.members,
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatMessages(),
          ),
          Container(
            child: createInput(),
          ),
        ],
      ),
    );
  }
}
