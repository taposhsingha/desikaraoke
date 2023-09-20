import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_engine/flutter_audio_engine.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPosition = 0;
  var currentStatus;
  StreamSubscription statusSub;
  StreamSubscription positionSub;
  AudioEngine audioEngine;
  var url =
      "https://firebasestorage.googleapis.com/v0/b/desikaraoke-staging.appspot.com/o/music%2FAbdul%20Hadi%20Achen%20Amar%20Muktar.mp3?alt=media&token=2e48aa4c-4877-401f-a022-4645fd3a9cf2";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    positionSub?.cancel();
    statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text("Player Position"),
                    Text(currentPosition.toString()),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text("Player Status"),
                    Text(currentStatus.toString())
                  ],
                )
              ],
            ),
            Wrap(
              direction: Axis.horizontal,
              children: <Widget>[
                MaterialButton(
                  child: Text("Create"),
                  onPressed: () => audioEngine = AudioEngine(),
                ),
                MaterialButton(
                  child: Text("getStream"),
                  onPressed: () {
                    positionSub =
                        audioEngine?.getPlayerPositionStream?.listen((data) {
                      setState(() {
                        currentPosition = data;
                      });
                    });
                    statusSub =
                        audioEngine?.getPlayerStatusStream?.listen((data) {
                      setState(() {
                        currentStatus = data;
                      });
                    });
                  },
                ),
                MaterialButton(
                  child: Text("Init"),
                  onPressed: () => audioEngine.initPlayer(url),
                ),
                MaterialButton(
                    child: Text("Play"),
                    onPressed: () {
                      audioEngine.startPlaying();
                    }),
                MaterialButton(
                  child: Text("Pause"),
                  onPressed: () => audioEngine.pause(),
                ),
                MaterialButton(
                  child: Text("Stop"),
                  onPressed: () => audioEngine.stop(),
                ),
                MaterialButton(
                  child: Text("Release"),
                  onPressed: () => audioEngine.release(),
                ),
                MaterialButton(
                  child: Text("Nullify"),
                  onPressed: () => audioEngine = null,
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
