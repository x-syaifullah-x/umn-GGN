// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stories _$StoriesFromJson(Map<String, dynamic> json) {
  return Stories(
    storyId: json['storyId'] as String?,
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
    stories: (json['stories'] as List<dynamic>?)
        ?.map((e) => StoryData.fromJson(e as Map<String, dynamic>))
        .toList(),
    previewImage: json['previewImage'] as String?,
    photoUrl: json['photoUrl'] as String?,
    username: (json['username'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$StoriesToJson(Stories instance) => <String, dynamic>{
      'storyId': instance.storyId,
      'date': instance.date?.toIso8601String(),
      'stories': instance.stories?.map((e) => e.toJson()).toList(),
      'previewImage': instance.previewImage,
      'photoUrl': instance.photoUrl,
      'username': instance.username,
    };
