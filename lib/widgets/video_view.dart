import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoView extends StatefulWidget {
  final String url;
  final bool? play;
  final String? id;

  const VideoView({Key? key, required this.url, this.play, this.id})
      : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VideoView> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
        widget.url,
      ),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager.flickControlManager?.autoResume();
        }
      },
      child: FlickVideoPlayer(
        flickManager: flickManager,
        flickVideoWithControls: const FlickVideoWithControls(
          controls: FlickPortraitControls(),
        ),
        flickVideoWithControlsFullscreen: const FlickVideoWithControls(
          controls: FlickLandscapeControls(),
        ),
      ),
    );
  }
}
