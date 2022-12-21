import 'package:json_annotation/json_annotation.dart';
import 'story_data.dart';

part 'stories.g.dart';

@JsonSerializable(explicitToJson: true)
class Stories {
  String? storyId;
  DateTime? date;
  List<StoryData>? stories;
  String? previewImage;
  String? photoUrl;
  // caption on the each story, can be null
  Map<String, String>? username;

  Stories({
    this.storyId,
    this.date,
    this.stories,
    this.previewImage,
    this.photoUrl,
    this.username,
  });

  factory Stories.fromJson(Map<String, dynamic> json) =>
      _$StoriesFromJson(json);
  Map<String, dynamic> toJson() => _$StoriesToJson(this);
}
