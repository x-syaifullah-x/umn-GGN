import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpleworld/story/story_view.dart';
import 'dart:convert';
import 'stories.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoriesData {
  String? languageCode;

  StoriesData({
    this.languageCode,
  });

  final int _cacheDepth = 4;
  final List<String> _storiesIdsList = [];

  final storyController = StoryController();
  List<StoryItem> storyItems = [];

  List<String> get storiesIdsList => _storiesIdsList;

  List<Stories> parseStoriesPreview(var stories) {
    List<Stories> storyWidgets = [];
    for (QueryDocumentSnapshot story in stories) {
      final Stories storyData = Stories.fromJson({
        'storyId': story.id,
        'date': DateTime.fromMillisecondsSinceEpoch(story['date'].seconds)
            .toIso8601String(),
        'stories': jsonDecode(jsonEncode(story['stories'])),
        'previewImage': story['previewImage'],
        'photoUrl': story['photoUrl'],
        'username': jsonDecode(jsonEncode(story['username'])),
      });
      if (storyData.stories != null) {
        storyWidgets.add(storyData);
        _storiesIdsList.add(story.id);

//         preliminary caching
        var i = 0;
        for (var file in storyData.stories!) {
          if (file.filetype == 'image' && i < _cacheDepth) {
            DefaultCacheManager().getSingleFile(file.url![languageCode!]!);
            i += 1;
          }
        }
      }
    }
    return storyWidgets;
  }

  void parseStories(
    Map<String, dynamic> toPass,
    imageStoryDuration,
    TextStyle? captionTextStyle,
    EdgeInsets? captionMargin,
    EdgeInsets? captionPadding,
  ) {
    Map<String, dynamic> temp = {
      'storyId': toPass['pressedStoryId'],
      'stories': toPass['snapshotData']['stories'],
      'username': toPass['snapshotData']['username'],
      'previewImage': toPass['snapshotData']['previewImage'],
      'photoUrl': toPass['snapshotData']['photoUrl'],
    };
    Stories stories = Stories.fromJson(jsonDecode(jsonEncode(temp)));
    stories.stories!.asMap().forEach((index, storyInsideImage) {
      if (storyInsideImage.filetype != 'video') {
        storyItems.add(StoryItem.pageImage(
          CachedNetworkImageProvider(storyInsideImage.url![languageCode!]!),
          duration: Duration(seconds: imageStoryDuration),
          photoUrl: stories.photoUrl,
          username: stories.username!['en']!,
          caption: storyInsideImage.fileTitle != null
              ? storyInsideImage.fileTitle![languageCode!]
              : null,
        ));
      } else {
        storyItems.add(
          StoryItem.pageVideo(
            storyInsideImage.url![languageCode!],
            controller: storyController,
            photoUrl: stories.photoUrl,
            username: stories.username!['en']!,
            caption: storyInsideImage.fileTitle != null
                ? storyInsideImage.fileTitle![languageCode!]
                : null,
            captionTextStyle: captionTextStyle,
            captionPadding: captionPadding,
            captionMargin: captionMargin,
          ),
        );
      }
      if (index < stories.stories!.length - 1) {
        DefaultCacheManager()
            .getSingleFile(stories.stories![index + 1].url![languageCode!]!);
      }
    });
  }
}
