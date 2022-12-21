import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpleworld/config/palette.dart';
import 'package:simpleworld/story/add_story.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

import 'models/stories.dart';
import 'models/stories_list_with_pressed.dart';
import 'components//stories_list_skeleton.dart';
import 'models/stories_data.dart';
import 'grouped_stories_view.dart';

export 'grouped_stories_view.dart';

class AllSimpleWorldStories extends StatefulWidget {
  final String collectionDbName;
  final String languageCode;
  final bool lastIconHighlight;
  final Color lastIconHighlightColor;
  final Radius lastIconHighlightRadius;
  final double? iconWidth;
  final double? iconHeight;
  final bool showTitleOnIcon;
  final TextStyle? iconTextStyle;
  final BoxDecoration? iconBoxDecoration;
  final BorderRadius? iconImageBorderRadius;
  final EdgeInsets textInIconPadding;
  final TextStyle captionTextStyle;
  final EdgeInsets captionMargin;
  final EdgeInsets captionPadding;
  final int imageStoryDuration;
  final Color backgroundColorBetweenStories;
  final Icon? closeButtonIcon;
  final Color? closeButtonBackgroundColor;
  final bool sortingOrderDesc;
  final VoidCallback? backFromStories;
  final ProgressPosition progressPosition;
  final bool repeat;
  final bool inline;

  AllSimpleWorldStories(
      {required this.collectionDbName,
      this.lastIconHighlight = false,
      this.lastIconHighlightColor = Colors.deepOrange,
      this.lastIconHighlightRadius = const Radius.circular(15.0),
      this.iconWidth,
      this.iconHeight,
      this.showTitleOnIcon = true,
      this.iconTextStyle,
      this.iconBoxDecoration,
      this.iconImageBorderRadius,
      this.textInIconPadding =
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      this.captionTextStyle = const TextStyle(
        fontSize: 15,
        color: Colors.white,
      ),
      this.captionMargin = const EdgeInsets.only(
        bottom: 24,
      ),
      this.captionPadding = const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      this.imageStoryDuration = 5,
      this.backgroundColorBetweenStories = Colors.black,
      this.closeButtonIcon,
      this.closeButtonBackgroundColor,
      this.sortingOrderDesc = true,
      this.backFromStories,
      this.progressPosition = ProgressPosition.top,
      this.repeat = true,
      this.inline = false,
      this.languageCode = 'en'});

  @override
  _AllSimpleWorldStoriesStoriesState createState() =>
      _AllSimpleWorldStoriesStoriesState();
}

class _AllSimpleWorldStoriesStoriesState extends State<AllSimpleWorldStories> {
  late StoriesData _storiesData;
  final _firestore = FirebaseFirestore.instance;
  bool _backStateAdditional = false;
  final ImagePicker _picker = ImagePicker();
  File? file;
  bool isLoading = false;
  // late GloabalUser user;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _storiesData = StoriesData(languageCode: widget.languageCode);
    super.initState();
  }

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (mounted) {
      setState(() async {
        // ignore: unnecessary_this
        this.file = file;
        if (pickedFile != null) {
          file = File(pickedFile.path);
          // print(file);
          await navigator.push(
            MaterialPageRoute(
              builder: (context) => AddStory(
                  // file: file!,
                  ),
            ),
          );
        } else {
          // print('No image selected.');
        }
      });
    }
  }

  Widget addstorybutton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: (globalImage != "")
                ? CachedNetworkImage(
                    imageUrl: globalImage!,
                    height: double.infinity,
                    width: 100.0,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: double.infinity,
                    color: const Color(0xFF003a54),
                    child: Image.asset(
                      'assets/images/defaultavatar.png',
                      width: 100,
                    ),
                  ),
          ),
          GestureDetector(
            child: Container(
              height: double.infinity,
              width: 100.0,
              decoration: BoxDecoration(
                gradient: Palette.storyGradient,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddStory(
                    // file: file!,
                    ),
              ),
            ),
          ),
          Positioned(
              top: 8.0,
              left: 8.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add),
                  iconSize: 30.0,
                  color: Colors.red[800],
                  onPressed: () => handleChooseFromGallery(),
                ),
              )),
          const Positioned(
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
            child: Text(
              'Add to Story',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? res = ModalRoute.of(context)!.settings.arguments as String?;
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      color: Theme.of(context).cardColor,
      // height: widget.iconHeight! + 15,

      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(widget.collectionDbName)
            .orderBy('date', descending: widget.sortingOrderDesc)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return StaggeredGridView.countBuilder(
              scrollDirection: Axis.vertical,
              primary: false,
              crossAxisCount: 3,
              staggeredTileBuilder: (index) => StaggeredTile.count(
                  (index % 5 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: Container(
                    width: widget.iconWidth,
                    height: widget.iconHeight,
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: widget.iconImageBorderRadius,
                          child: StoriesListSkeletonAlone(
                            width: widget.iconWidth!,
                            height: widget.iconHeight!,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return addstorybutton();
          }
          List<QueryDocumentSnapshot> stories = snapshot.data!.docs;

          final List<Stories> storyWidgets =
              _storiesData.parseStoriesPreview(stories);

          final List<String> storiesIdsList = _storiesData.storiesIdsList;

          // _buildFuture(res);

          return StaggeredGridView.countBuilder(
              scrollDirection: Axis.vertical,
              primary: false,
              crossAxisCount: 3,
              staggeredTileBuilder: (index) => StaggeredTile.count(
                  (index % 5 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              itemCount: storyWidgets == null ? 0 : stories.length,
              itemBuilder: (BuildContext context, int index) {
                Stories story = storyWidgets[index];
                story.username!.putIfAbsent(widget.languageCode, () => '');

                return InkWell(
                  child: Container(
                    decoration: widget.iconBoxDecoration,
                    width: widget.iconWidth,
                    height: widget.iconHeight,
                    child: Stack(children: <Widget>[
                      ClipRRect(
                        borderRadius: widget.iconImageBorderRadius,
                        child: CachedNetworkImage(
                          imageUrl: story.previewImage!,
                          width: widget.iconWidth,
                          height: widget.iconHeight,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              StoriesListSkeletonAlone(
                            width: widget.iconWidth!,
                            height: widget.iconHeight!,
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Container(
                        width: widget.iconWidth,
                        height: widget.iconHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: widget.textInIconPadding,
                              child: Text(
                                story.username![widget.languageCode]!,
                                style: widget.iconTextStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          top: 8.0,
                          left: 8.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: story.photoUrl == null ||
                                    story.photoUrl!.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003a54),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Image.asset(
                                      'assets/images/defaultavatar.png',
                                      width: 40,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: story.photoUrl!,
                                    height: 40.0,
                                    width: 40.0,
                                    fit: BoxFit.cover,
                                  ),
                          )),
                    ]),
                  ),
                  onTap: () async {
                    _backStateAdditional = true;
                    Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(
                        builder: (context) => GroupedStoriesView(
                          collectionDbName: widget.collectionDbName,
                          languageCode: widget.languageCode,
                          imageStoryDuration: widget.imageStoryDuration,
                          progressPosition: widget.progressPosition,
                          repeat: widget.repeat,
                          inline: widget.inline,
                          backgroundColorBetweenStories:
                              widget.backgroundColorBetweenStories,
                          closeButtonIcon: widget.closeButtonIcon,
                          closeButtonBackgroundColor:
                              widget.closeButtonBackgroundColor,
                          sortingOrderDesc: widget.sortingOrderDesc,
                          captionTextStyle: widget.captionTextStyle,
                          captionPadding: widget.captionPadding,
                          captionMargin: widget.captionMargin,
                        ),
                        settings: RouteSettings(
                          arguments: StoriesListWithPressed(
                              pressedStoryId: story.storyId,
                              storiesIdsList: storiesIdsList),
                        ),
                      ),
//
                    );
                  },
                );
              });
        },
      ),
    );
  }

  // _buildFuture(String? res) async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   if (res == 'back_from_stories_view' && !_backStateAdditional) {
  //     widget.backFromStories!();
  //   }
  // }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
