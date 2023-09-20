import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAudioEngine {
  static const MethodChannel _channel =
      const MethodChannel('flutter_audio_engine');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class AudioEngine {
  static const MethodChannel platform =
      const MethodChannel('flutter_audio_engine');
  static const playerStatusChannel = const EventChannel("borhnn/playerStatus");
  static const playerPositionChannel =
      const EventChannel("borhnn/playerPosition");

  Stream<PlayerStatus> _playerStatusStream;
  Stream<int> _playerPositionStream;

  Future stop() async {
    try {
      await platform.invokeMethod("stop");
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Stream<PlayerStatus> get getPlayerStatusStream {
    return _playerStatusStream ??= playerStatusChannel
        .receiveBroadcastStream("forStatus")
        .map<PlayerStatus>((value) => fromCode(value));
  }

  Stream<int> get getPlayerPositionStream {
    return _playerPositionStream ??= playerPositionChannel
        .receiveBroadcastStream("forPosition")
        .map<int>((value) => value);
  }

  Future setVolume(double volume) async {
    try {
      await platform.invokeMethod("setVolume", {"volume": volume});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<int> getCurrentPosition() async {
    try {
      int result = await platform.invokeMethod("getCurrentPosition");
      return result;
    } on PlatformException catch (e) {
      print(e.message);
    }
    return null;
  }

  Future<void> initPlayer(String url) async {
    try {
      await platform.invokeMethod('initPlayer', {"fileURL": url});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> startPlaying() async {
    try {
      await platform.invokeMethod('play');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> pause() async {
    try {
      await platform.invokeMethod("pause");
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> setPlaybackPitch(int playerHalfstepDelta) async {
    try {
      await platform.invokeMethod(
          "setPlayerPitch", {"halfstepDelta": playerHalfstepDelta});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> setPlaybackRate(double playbackRate) async {
    try {
      await platform
          .invokeMethod("setPlayerSpeed", {"playbackRate": playbackRate});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> release() async {
    try {
      await platform.invokeMethod("release");
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}

enum PlayerStatus {
  NOT_INITIALIZED,
  INITIALIZED,
  READY,
  STOPPED,
  PAUSED,
  RESUMED,
}

PlayerStatus fromCode(status) {
  switch (status) {
    case -4:
      return PlayerStatus.NOT_INITIALIZED;
    case -3:
      return PlayerStatus.INITIALIZED;
    case -2:
      return PlayerStatus.READY;
    case -1:
      return PlayerStatus.STOPPED;
    case 0:
      return PlayerStatus.PAUSED;
    case 1:
      return PlayerStatus.RESUMED;
    default:
      return PlayerStatus.NOT_INITIALIZED;
      break;
  }
}
