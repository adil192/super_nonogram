import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatefulWidget {
  const SettingsItem({
    super.key,
    required this.onTap,
    required this.children,
  });

  final VoidCallback onTap;
  final List<Widget> children;

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> with AutomaticKeepAliveClientMixin {
  static final _r = Random();
  static (Color bg, Color fg) generateColors(Color primary) {
    final randomPrimary = Colors.primaries[_r.nextInt(Colors.primaries.length)];
    final background = randomPrimary.harmonizeWith(primary);
    final backgroundHsl = HSLColor.fromColor(background);
    final foregroundHsl = HSLColor.fromAHSL(
      1,
      backgroundHsl.hue,
      backgroundHsl.saturation,
      backgroundHsl.lightness > 0.5 ? 0.2 : 0.95,
    );
    return (background, foregroundHsl.toColor());
  }

  /// If the parent color scheme's primary color changes, we need to regenerate the background color
  Color lastParentPrimary = Colors.transparent;
  ColorScheme? colorScheme;

  /// Keep the widget alive if we've generated a background color
  @override
  bool get wantKeepAlive => colorScheme != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final parentColorScheme = Theme.of(context).colorScheme;
    if (parentColorScheme.primary != lastParentPrimary) {
      lastParentPrimary = parentColorScheme.primary;
      final colors = generateColors(parentColorScheme.primary);
      colorScheme = ColorScheme.fromSeed(
        seedColor: colors.$1,
        primary: colors.$1,
        onPrimary: colors.$2,
      );
    }

    return Center(
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: colorScheme,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 64,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
