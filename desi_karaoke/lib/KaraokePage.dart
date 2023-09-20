import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desi_karaoke_lite/lyricBuilder.dart';
import 'package:desi_karaoke_lite/models.dart';
import 'package:desi_karaoke_lite/widgets/fading_background.dart';
import 'package:desi_karaoke_lite/widgets/spinning_logo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_audio_engine/flutter_audio_engine.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:screen/screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utf/utf.dart';

class KaraokePage extends StatefulWidget {
  final Music music;

  KaraokePage({Key key, @required this.music}) : super(key: key);

  @override
  _KaraokePageState createState() => _KaraokePageState();
}

class _KaraokePageState extends State<KaraokePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Constants
  static const platform =
      const EventChannel('desikaraoke.com/bluetooth_connected_devices');
  static const methodChannel =
      const MethodChannel('desikaraoke.com/filedownloader');
  final double _iconSize = Device.get().isTablet ? 72 : 48;

  // Page fields
  AudioEngine audioEngine = AudioEngine();
  Karaoke _karaoke;
  List<KaraokeDevice> deviceList = List();

  // Disposables
  StreamSubscription subBluetooth;
  StreamSubscription plyerStatusSubscription;
  StreamSubscription playerPositionSubscription;

  // Page state fields
  PlayerStatus _playerStatus = PlayerStatus.NOT_INITIALIZED;
  String countDownText = "";
  RichText _lastLyric = RichText(
    text: TextSpan(text: "\n\n"),
  );

  // Page state relate fields

  // Tracking fields
  int _playerSpeedStep = 0;
  int _playerHalfstepDelta = 0;
  int _countdownPosition = 0;
  PlayerStatus statusBeforeBackground;
  bool isFlushbarShown = false;

  // Data fields
  String uid;
  int _lyricPosition;
  bool isMusicTrialExpired;
  bool isTrialAccount;
  bool isValidDeviceConnected;
  bool isFreeModeEnabled = false;
  int trialMillis = 1000 * 1000;

  var flushbar = Flushbar(
    title: "Microphone required",
    message:
        "Please, connect to a RANGS Desi Karaoke microphone to enjoy the full song",
    mainButton: FlatButton(
        child: Text(
          "Call Now",
          style: TextStyle(color: Colors.greenAccent),
        ),
        onPressed: () => launch("tel://+8801748332274")),
    duration: Duration(days: 365),
    isDismissible: false,
  );

  Future<File> downloadFile(Reference ref) async {
    final String url = await ref.getDownloadURL();
    // final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;

    final String name = ref.name;
    final String path = ref.fullPath;
    final File tempFile = File('${systemTempDir.path}/$path');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create(recursive: true);
    final DownloadTask task = ref.writeToFile(tempFile);
    // final int byteCount = (await task.snapshot).totalByteCount;
    // var bodyBytes = downloadData.bodyBytes;
    print('Success!\nDownloaded $name \nUrl: $url'
        // '\npath: $path \nBytes Count :: $byteCount',
        );
    return tempFile;
  }

  @override
  void initState() {
    super.initState();
    Screen.keepOn(true);
    WidgetsBinding.instance.addObserver(this);
    Reference storageReference =
        FirebaseStorage.instance.ref().child(widget.music.storagepath);
    _startDownload(storageReference);

    var stream = audioEngine.getPlayerStatusStream;
    var positionStream = audioEngine.getPlayerPositionStream;
    plyerStatusSubscription = stream.listen((status) {
      setState(() {
        _playerStatus = status;
      });
      if (_playerStatus == PlayerStatus.STOPPED) {
        Navigator.pop(context);
      }
    });
    switch (widget.music.trial) {
      case "none":
        trialMillis = 0;
        break;
      case "short":
        trialMillis = 40 * 1000;
        break;
      case "long":
        trialMillis = 80 * 1000;
        break;
      case "max":
        trialMillis = 8000 * 1000;
        break;
      default:
        trialMillis = 40 * 1000;
    }

    // trialMillis = 7000;

    playerPositionSubscription = positionStream.listen((position) {
      var lyricPosition = _karaoke.timedTextMap
          .lastKeyBefore(position - widget.music.lyricoffset);
      if (lyricPosition != _lyricPosition) {
        setState(() {
          _lastLyric = convertToLyric(_karaoke.timedTextMap[lyricPosition]);
          _lyricPosition = lyricPosition;
        });
      }
      var countdownPosition = _karaoke.countdownTimes.lastKeyBefore(position);
      if (countdownPosition != _countdownPosition) {
        var countdownTime = _karaoke.countdownTimes[countdownPosition];
        if (countdownTime == null || countdownTime == "null") {
          countDownText = "";
        } else {
          countDownText = countdownTime.toString();
        }
        setState(() {
          _countdownPosition = countdownPosition;
        });
      }
      var musicTrialExpired = position > trialMillis;
      if (musicTrialExpired != isMusicTrialExpired) {
        setPlaybackValidity(() {
          isMusicTrialExpired = musicTrialExpired;
        });
      }
    });
    FirebaseDatabase.instance
        .reference()
        .child("isFreeModeEnabled")
        .once()
        .then((value) {
      setPlaybackValidity(() {
        isFreeModeEnabled = value.value;
      });
    });
    var user = FirebaseAuth.instance.currentUser;
    uid = user.uid;
    FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/currenttime")
        .set(ServerValue.timestamp)
        .whenComplete(() {
      FirebaseDatabase.instance
          .reference()
          .child("users/${user.uid}")
          .once()
          .then((data) {
        int currentTime = data.value['currenttime'];
        int signUpTime = data.value['signuptime'];
        if ((currentTime - signUpTime) < 72 * 3600 * 1000) {
          setPlaybackValidity(() {
            isTrialAccount = true;
          });
        } else {
          setPlaybackValidity(() {
            isTrialAccount = false;
          });
        }
        // setPlaybackValidity(() {
        //   isTrialAccount = false;
        // });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: "Desi Karaoke",
      home: Container(
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: FadingBackground()),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 24, bottom: 16),
                  alignment: Alignment.topCenter,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Hero(
                        tag: widget.music,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CupertinoButton(
                              padding: EdgeInsets.all(0),
                              child: Icon(CupertinoIcons.back, size: _iconSize),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  widget.music.effectivetitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .apply(
                                          color: Colors.white,
                                          fontSizeDelta:
                                              Device.get().isTablet ? 10 : 0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(width: _iconSize, height: _iconSize),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.music.effectiveartist,
                          style: Theme.of(context).textTheme.subtitle1.apply(
                              color: Colors.white,
                              fontSizeDelta: Device.get().isTablet ? 8 : 0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SpinningLogo(
                            playerStatus: _playerStatus,
                          ),
                          SizedBox(width: 8),
                        ],
                      )
                    ],
                  ),
                ),
                Spacer(flex: 3),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: countDownText == "" ? 0 : 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(color: Colors.white70),
                          width: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(
                            child: Text(
                              countDownText,
                              style:
                                  Theme.of(context).textTheme.headline3.apply(
                                        color: Colors.red,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Device.get().isTablet ? 16 : 0,
                  ),
                  child: AnimatedSize(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRect(
                            clipBehavior: Clip.hardEdge,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 5.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Container(
                                  color: Colors.white54,
                                  padding: const EdgeInsets.all(8.0),
                                  child: _lastLyric,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: Duration(milliseconds: 1200),
                    vsync: this,
                  ),
                ),
                Spacer(flex: 2),
                Container(
                  width: Device.get().isTablet ? 480 : null,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.all(
                          Radius.circular(Device.get().isTablet ? 16 : 0))),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CupertinoButton(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              child: getPlayPauseWidget(),
                              width: _iconSize,
                              height: _iconSize,
                            ),
                            onPressed:
                                _playerStatus != PlayerStatus.NOT_INITIALIZED
                                    ? _playPauseOnClick
                                    : null,
                          ),
                          Container(width: 16),
                          CupertinoButton(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              child: Icon(
                                Icons.stop,
                                color: Colors.white,
                                size: _iconSize,
                              ),
                              width: _iconSize,
                              height: _iconSize,
                            ),
                            onPressed: _stopOnClick,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CupertinoButton.filled(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "Tempo" +
                                      (_playerSpeedStep != 0
                                          ? " (" +
                                              _playerSpeedStep.toString() +
                                              ")"
                                          : ""),
                                ),
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DiscreteValueChanger(
                                      currentValue: _playerSpeedStep,
                                      valueOnChange: (value) {
                                        setState(() {
                                          _playerSpeedStep = value.toInt();
                                          audioEngine.setPlaybackRate(
                                              getPlaybackRateFromStep(
                                                  _playerSpeedStep));
                                        });
                                      },
                                      title: "Tempo",
                                      maxValue: 12,
                                      minValue: -12,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 25,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CupertinoButton.filled(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "Scale" +
                                      (_playerHalfstepDelta != 0
                                          ? " (" +
                                              _playerHalfstepDelta.toString() +
                                              ")"
                                          : ""),
                                ),
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DiscreteValueChanger(
                                      currentValue: _playerHalfstepDelta,
                                      valueOnChange: (value) {
                                        setState(() {
                                          _playerHalfstepDelta = value.toInt();
                                          audioEngine.setPlaybackPitch(
                                              _playerHalfstepDelta);
                                        });
                                      },
                                      title: "Scale",
                                      maxValue: 6,
                                      minValue: -6,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getPlayPauseWidget() {
    if (_playerStatus == PlayerStatus.NOT_INITIALIZED ||
        _playerStatus == PlayerStatus.INITIALIZED) {
      return CupertinoTheme(
        child: CupertinoActivityIndicator(
          radius: _iconSize / 2 - 8,
        ),
        data: CupertinoThemeData(brightness: Brightness.dark),
      );
    } else {
      return Icon(
        _getPlayPauseIcon(),
        color: Colors.white,
        size: _iconSize,
      );
    }
  }

  IconData _getPlayPauseIcon() {
    var _isPlaying = _playerStatus == PlayerStatus.RESUMED;
    return _isPlaying ? Icons.pause : Icons.play_arrow;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (statusBeforeBackground == PlayerStatus.RESUMED) {
        audioEngine?.startPlaying();
      }
      statusBeforeBackground = null;
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (statusBeforeBackground == null) {
        statusBeforeBackground = _playerStatus;
      }
      audioEngine?.pause();
    }
  }

  @override
  void dispose() {
    plyerStatusSubscription?.cancel();
    audioEngine.stop();
    playerPositionSubscription.cancel();
    subBluetooth?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    Screen.keepOn(false);
    super.dispose();
  }

  _startDownload(Reference storageReference) async {
    String musicDownloadUrl = await methodChannel
        .invokeMethod("getDownloadUrl", {"path": storageReference.fullPath});
    musicDownloadUrl = musicDownloadUrl.replaceAll("(", "%28");
    musicDownloadUrl = musicDownloadUrl.replaceAll(")", "%29");
    musicDownloadUrl = musicDownloadUrl.replaceAll(" ", "%20");
    audioEngine.initPlayer(musicDownloadUrl);
    Uint8List lyricint8 = await methodChannel
        .invokeMethod("getFileFromDo", {"path": widget.music.lyricref});
    var bytes = lyricint8;

    String lyric = "";
    if (hasUtf16leBom(bytes)) {
      lyric = decodeUtf16le(bytes);
    } else
      lyric = decodeUtf8(bytes);
    _karaoke = await buildLyric(lyric);
    FirebaseDatabase.instance.reference().child("devices").once().then((data) {
      data.value.forEach(
        (key, value) {
          KaraokeDevice device = KaraokeDevice.fromMap(value);
          deviceList.add(device);
        },
      );
    }).whenComplete(() {
      subBluetooth = platform.receiveBroadcastStream().listen((mac) {
        var deviceMatches = false;
        deviceList.forEach((device) {
          if (device.mac == mac.toString()) {
            deviceMatches = true;
          }
        });
        setPlaybackValidity(() {
          isValidDeviceConnected = deviceMatches;
          // isValidDeviceConnected = true;
        });
      });
    });
  }

  String convertToLyricTemp(KaraokeTimedText karaokeTimedText) {
    StringBuffer stringBuffer = StringBuffer();
    karaokeTimedText?.lines?.forEach((KaraokeLine it) {
      it?.words?.forEach((word) {
        stringBuffer.write("$word ");
      });
      stringBuffer.write("\n");
    });
    return stringBuffer.toString();
  }

  RichText convertToLyric(KaraokeTimedText karaokeTimedText) {
    List<List<String>> spanText = [
      ["", ""],
      ["", ""]
    ];
    int hightlightwordNumber =
        karaokeTimedText?.lyricHighlightEvent?.wordnumber;

    int highlightLine = 5;
    if (karaokeTimedText != null) {
      if (karaokeTimedText?.lyricHighlightEvent?.line ==
          karaokeTimedText?.lines[0]) {
        highlightLine = 0;
      } else if (karaokeTimedText?.lyricHighlightEvent?.line ==
          karaokeTimedText?.lines[1]) {
        highlightLine = 1;
      }
    }
    karaokeTimedText?.lines?.asMap()?.forEach((lineNum, line) {
      StringBuffer normalBuffer = StringBuffer();
      StringBuffer highlightBuffer = StringBuffer();
      line?.words?.asMap()?.forEach((wordNum, word) {
        if (highlightLine == lineNum && wordNum <= hightlightwordNumber) {
          highlightBuffer.write("$word ");
        } else {
          normalBuffer.write("$word ");
        }
      });
      spanText[lineNum][0] = highlightBuffer.toString();
      spanText[lineNum][1] = normalBuffer.toString().trimRight();
    });
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.headline5.apply(
            color: Colors.blue[700],
            fontWeightDelta: 3,
            fontSizeDelta: Device.get().isTablet ? 25 : 0),
        children: <TextSpan>[
          TextSpan(
              text: "${spanText[0][0]}",
              style: TextStyle(color: Colors.indigo[900])),
          TextSpan(text: "${spanText[0][1]}\n"),
          TextSpan(
              text: "${spanText[1][0]}",
              style: TextStyle(color: Colors.indigo[900])),
          TextSpan(text: "${spanText[1][1]}"),
        ],
      ),
    );
  }

  void _playPauseOnClick() {
    if (_playerStatus == PlayerStatus.RESUMED) {
      audioEngine.pause();
    } else {
      audioEngine.startPlaying();
    }
  }

  void _stopOnClick() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('playHistory')
        .doc()
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'musicKey': widget.music.key,
      'playDurationMiliSec': _lyricPosition,
      'title': widget.music.effectivetitle,
      'artist': widget.music.artist,
      'genre': widget.music.genre,
      'language': widget.music.language,
    });
    Navigator.pop(context);
  }

  double getPlaybackRateFromStep(int playBackStep) {
    return (1.0 + .05 * _playerSpeedStep);
  }

  void setPlaybackValidity(VoidCallback fn) {
    fn();
    if (isTrialAccount != null &&
        isValidDeviceConnected != null &&
        isMusicTrialExpired != null &&
        isFreeModeEnabled != null) {
      var shouldPlayLoud = isTrialAccount ||
          isValidDeviceConnected ||
          !isMusicTrialExpired ||
          isFreeModeEnabled;

      switch (shouldPlayLoud) {
        case false:
          if (!isFlushbarShown) {
            isFlushbarShown = true;
            flushbar.show(context);
          }
          break;
        default:
          if (isFlushbarShown) {
            isFlushbarShown = false;
            flushbar.dismiss();
          }
      }
      audioEngine.setVolume(shouldPlayLoud ? 1.0 : 0.0);
    }
  }
}

class DiscreteValueChanger extends StatefulWidget {
  final Function valueOnChange;
  final int currentValue;
  final String title;
  final int minValue;
  final int maxValue;
  final int divisions;
  final bool disabled;

  DiscreteValueChanger(
      {Key key,
      @required this.valueOnChange,
      @required this.currentValue,
      @required this.title,
      @required this.minValue,
      @required this.maxValue,
      bool disabled})
      : this.divisions = maxValue - minValue,
        this.disabled = disabled ?? false,
        super(key: key);

  @override
  _DiscreetValueChangerState createState() => _DiscreetValueChangerState();
}

class _DiscreetValueChangerState extends State<DiscreteValueChanger> {
  double _newValue;

  get newValue => _newValue;

  set newValue(newValue) {
    if (!widget.disabled &&
        newValue >= widget.minValue &&
        newValue <= widget.maxValue) {
      _newValue = newValue;
      widget.valueOnChange(_newValue);
    }
  }

  @override
  void initState() {
    _newValue = widget.currentValue.toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
              child: Text(widget.title,
                  style: Theme.of(context).textTheme.headline6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(newValue.toInt().toString()),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CupertinoButton(
                child: Icon(CupertinoIcons.minus_circled),
                onPressed: () => setState(() => newValue--),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: CupertinoSlider(
                    onChanged: (double value) {
                      setState(() {
                        newValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        newValue = value.toInt().toDouble();
                      });
                    },
                    value: newValue,
                    min: widget.minValue.toDouble(),
                    max: widget.maxValue.toDouble(),
                    divisions: widget.divisions,
                  ),
                ),
              ),
              CupertinoButton(
                child: Icon(CupertinoIcons.add_circled),
                onPressed: () => setState(() => newValue++),
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: !widget.disabled
                  ? null
                  : Text("Not available for this song",
                      textAlign: TextAlign.end)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                child: Text("Cancel"),
                onPressed: () {
                  widget.valueOnChange(widget.currentValue);
                  Navigator.pop(context);
                },
              ),
              CupertinoButton(
                child: Text("Done"),
                onPressed: () {
                  widget.valueOnChange(newValue);
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
