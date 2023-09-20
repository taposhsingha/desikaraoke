import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_audio_engine/flutter_audio_engine.dart';

class SpinningLogo extends StatefulWidget {
  SpinningLogo({
    Key key,
    this.playerStatus,
  }) : super(key: key);

  final PlayerStatus playerStatus;
  @override
  _SpinningLogoState createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo>
    with SingleTickerProviderStateMixin {
  Animation<double> logoAnimation;
  AnimationController logoController;
  @override
  void initState() {
    super.initState();

    logoController =
        AnimationController(duration: Duration(seconds: 8), vsync: this);
    logoAnimation =
        CurvedAnimation(parent: logoController, curve: Curves.linear)
          ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(SpinningLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    switch (widget.playerStatus) {
      case PlayerStatus.RESUMED:
        logoController.repeat();
        break;
      default:
        logoController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      child: Image(
          image:
              AssetImage("assets/backgrounds/DesiKaraokeLogoBothCircled.webp"),
          height: 56),
      angle: logoAnimation.value * 2 * pi,
    );
  }

  @override
  void dispose() {
    logoController.dispose();
    super.dispose();
  }
}
