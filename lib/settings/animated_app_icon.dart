import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:super_nonogram/settings/settings_item.dart';

class AnimatedAppIcon extends StatefulWidget {
  const AnimatedAppIcon({super.key});

  @override
  State<AnimatedAppIcon> createState() => _AnimatedAppIconState();
}

class _AnimatedAppIconState extends State<AnimatedAppIcon>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int numTaps = 0;
  static const int _numTapsToTriggerAnimation = 5;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = _ScaleHeartBeatTween().animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      onTap: () {
        numTaps++;
        if (numTaps < _numTapsToTriggerAnimation) return;
        numTaps = 0;
        if (_controller.isAnimating) return;
        _controller.reset();
        _controller.forward();
      },
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final scale = _controller.isAnimating ? _animation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: const Image(
            image: AssetImage('assets/icon/resized/icon-512x512.png'),
            width: 128,
            height: 128,
          ),
        ),
      ],
    );
  }
}

class _ScaleHeartBeatTween extends Tween<double> {
  _ScaleHeartBeatTween({
    // ignore: unused_element
    this.minScale = 0.8,
  }) : super(begin: 1, end: 1);

  final double minScale;

  /// The heart should beat twice as [t] goes from 0 to 1.
  /// This is done in 4 stages: shrink, grow, shrink, grow.
  @override
  double lerp(double t) {
    if (t < 0.25) {
      return lerpDouble(1, minScale, t / 0.25)!;
    } else if (t < 0.5) {
      return lerpDouble(minScale, 1, (t - 0.25) / 0.25)!;
    } else if (t < 0.75) {
      return lerpDouble(1, minScale, (t - 0.5) / 0.25)!;
    } else {
      return lerpDouble(minScale, 1, (t - 0.75) / 0.25)!;
    }
  }
}
