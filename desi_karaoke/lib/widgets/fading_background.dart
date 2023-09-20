import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

class FadingBackground extends StatefulWidget {
  @override
  _FadingBackgroundState createState() => _FadingBackgroundState();
}

class _FadingBackgroundState extends State<FadingBackground>
    with SingleTickerProviderStateMixin {
  Timer _timer;
  static Random _random = Random();
  String wallNext = getRandomWallpaper();
  int wallCycleState = 4;
  static String getRandomWallpaper() {
    return "assets/backgrounds/wall_${(1 + _random.nextInt(26)).toString().padLeft(4, '0')}.webp";
  }

  AnimationController controller;
  Animation<double> animation;

  String _l1background = getRandomWallpaper();
  String _l2background = getRandomWallpaper();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      switch (wallCycleState) {
        case 1:
          controller.forward();
          wallCycleState = 2;
          break;
        case 2:
          setState(() {
            wallNext = getRandomWallpaper();
            _l1background = wallNext;
          });
          wallCycleState = 3;
          break;
        case 3:
          controller.reverse();
          wallCycleState = 4;
          break;
        case 4:
          setState(() {
            _l2background = wallNext;
          });
          wallCycleState = 1;
          break;
      }
    });
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear)
      ..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(_l1background),
        fit: BoxFit.cover,
      )),
      child: Image.asset(_l2background,
          fit: BoxFit.cover,
          color: Color.fromRGBO(255, 255, 255, animation.value),
          colorBlendMode: BlendMode.modulate),
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    controller.dispose();
    super.dispose();
  }
}
