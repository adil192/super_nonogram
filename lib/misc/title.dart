import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:super_nonogram/i18n/strings.g.dart';

class TitleText extends StatelessWidget {
  const TitleText({
    super.key,
    this.style,
  });

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: style,
      child: Hero(
        tag: 'title',
        flightShuttleBuilder: flightShuttleBuilder,
        child: Text(
          t.appName,
        ),
      ),
    );
  }

  /// Function that builds the widget to show during the flight transition.
  /// Transitions between the two TextStyles' font sizes and colors.
  static Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final toStyle = DefaultTextStyle.of(toHeroContext).style;
    final fromStyle = DefaultTextStyle.of(fromHeroContext).style;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = switch (flightDirection) {
          HeroFlightDirection.push => animation.value,
          HeroFlightDirection.pop => 1 - animation.value,
        };
        return DefaultTextStyle(
          style: toStyle.copyWith(
            fontSize: lerpDouble(
              fromStyle.fontSize,
              toStyle.fontSize,
              t,
            ),
            color: Color.lerp(
              fromStyle.color,
              toStyle.color,
              t,
            ),
          ),
          overflow: TextOverflow.visible,
          softWrap: false,
          child: toHeroContext.widget,
        );
      },
    );
  }
}
