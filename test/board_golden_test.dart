import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/data/game_mode.dart';
import 'package:super_nonogram/pages/play_page.dart';
import 'package:super_nonogram/theme/theme.dart';

import 'util/mock_channel_handlers.dart';

void main() {
  group('Board goldens', () {
    setUpAll(() async {
      setupMockPathProvider();
      await loadAppFonts(); // Fonts are needed before first layout
    });

    for (final level in const [1, 10, 20, 50, 99, 143]) {
      group('Level $level', () {
        for (final device in <GoldenScreenshotDevices>[.androidTablet, .ipad]) {
          testGoldens(
            'on ${device.name}',
            (tester) => _testBoard(tester, level, device),
          );
        }
      });
    }
  });
}

Future<void> _testBoard(
  WidgetTester tester,
  int level,
  GoldenScreenshotDevices device,
) async {
  final widget = ScreenshotApp(
    device: device.device,
    theme: SuperNonogramTheme.createTheme(
      brightness: .light,
      platform: device.device.platform,
    ),
    home: PlayPage(LevelGameMode(level)),
  );
  await tester.pumpWidget(widget);
  await tester.loadAssets();
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/board_level_${level}_${device.name}.png'),
  );
}
