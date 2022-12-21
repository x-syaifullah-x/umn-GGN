import 'package:flutter/material.dart';
import 'package:simpleworld/story/simpleworld_stories.dart';

class StoryList extends StatefulWidget {
  const StoryList({Key? key}) : super(key: key);

  @override
  _StoryListState createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  static String collectionDbName = 'stories';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: ListView(
          children: [
            SimpleWorldStories(
              collectionDbName: collectionDbName,
              showTitleOnIcon: true,
              iconTextStyle: const TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
              iconImageBorderRadius: BorderRadius.circular(15.0),
              iconWidth: 100.0,
              iconHeight: 180,
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
          ],
        ));
  }
}
