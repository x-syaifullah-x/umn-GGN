import 'package:rxdart/rxdart.dart';

enum PlaybackState { pause, play }

class StoryController {
  final playbackNotifier = BehaviorSubject<PlaybackState>();

  /// Notify listeners with a [PlaybackState.pause] state
  void pause() {
    playbackNotifier.add(PlaybackState.pause);
  }

  /// Notify listeners with a [PlaybackState.play] state
  void play() {
    playbackNotifier.add(PlaybackState.play);
  }

  void dispose() {
    playbackNotifier.close();
  }
}
