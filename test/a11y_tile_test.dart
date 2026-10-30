import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/board/tile.dart';
import 'package:super_nonogram/board/tile_state.dart';
import 'package:super_nonogram/theme/theme.dart';

final _matrix = [
  (label: 'Default', onOffSwitchLabels: false, highContrast: false),
  (label: 'On/Off Switch Labels', onOffSwitchLabels: true, highContrast: false),
  (label: 'High Contrast', onOffSwitchLabels: false, highContrast: true),
  (label: 'Both', onOffSwitchLabels: true, highContrast: true),
];

void main() {
  testGoldens('a11y tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('a11y_tile_test'),
            child: Row(
              children: [
                for (final brightness in [Brightness.light, Brightness.dark])
                  Expanded(child: _Showcase(brightness: brightness)),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.loadAssets();
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('a11y_tile_test')),
      matchesGoldenFile('goldens/a11y_tile_test.png'),
    );
  });
}

class _Showcase extends StatelessWidget {
  const _Showcase({required this.brightness});
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final theme = SuperNonogramTheme.createTheme(
      brightness: brightness,
      platform: TargetPlatform.android,
    );
    return Theme(
      data: theme,
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          spacing: 8,
          children: [
            for (final config in _matrix) ...[
              Text(config.label, style: theme.textTheme.bodyMedium),
              Row(
                mainAxisSize: .min,
                spacing: 8,
                children: [
                  for (final tileState in TileState.values)
                    CustomPaint(
                      size: Size(96, 96),
                      painter: TilePainter(
                        tileState: tileState,
                        colorScheme: SuperNonogramTheme.createTheme(
                          brightness: brightness,
                          platform: TargetPlatform.android,
                          highContrast: config.highContrast,
                        ).colorScheme,
                        onOffSwitchLabels: config.onOffSwitchLabels,
                        highContrast: config.highContrast,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
