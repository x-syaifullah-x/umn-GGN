import 'package:flutter/material.dart';
import 'package:simpleworld/story/all_simpleworld_stories.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class AllStories extends StatefulWidget {
  final String? userId;
  bool showappbar = true;

  AllStories({
    Key? key,
    this.userId,
    required this.showappbar,
  }) : super(key: key);

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<AllStories>
    with AutomaticKeepAliveClientMixin<AllStories> {
  bool isLoading = false;
  final String? currentUserId = globalID;
  static String collectionDbName = 'stories';

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showappbar
          ? header(context, titleText: "All Stories", removeBackButton: false)
          : null,
      body: AllSimpleWorldStories(
        collectionDbName: collectionDbName,
        showTitleOnIcon: true,
        iconTextStyle: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
        ),
        iconImageBorderRadius: BorderRadius.circular(15.0),
        iconWidth: 300.0,
        iconHeight: 300,
        textInIconPadding:
            const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        imageStoryDuration: 7,
        progressPosition: ProgressPosition.top,
        repeat: true,
        inline: false,
        languageCode: 'en',
        backgroundColorBetweenStories: Colors.black,
        closeButtonIcon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 28.0,
        ),
        closeButtonBackgroundColor: const Color(0x11000000),
        sortingOrderDesc: true,
        lastIconHighlight: true,
        lastIconHighlightColor: Colors.deepOrange,
        lastIconHighlightRadius: const Radius.circular(15.0),
        captionTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
        captionMargin: const EdgeInsets.only(
          bottom: 50,
        ),
        captionPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
      ),
    );
  }
}
