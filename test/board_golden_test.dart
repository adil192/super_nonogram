import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:super_nonogram/data/game_mode.dart';
import 'package:super_nonogram/pages/play_page.dart';
import 'package:super_nonogram/theme/theme.dart';

void main() {
  group('Board goldens', () {
    setUpAll(loadAppFonts); // Fonts are needed before first layout

    for (final level in const [1, 10, 20, 50, 99]) {
      testGoldens('Level $level', (tester) async {
        final widget = ScreenshotApp(
          device: GoldenScreenshotDevices.androidPhone.device,
          theme: SuperNonogramTheme.createTheme(
            brightness: Brightness.light,
            platform: TargetPlatform.android,
          ),
          home: PlayPage(LevelGameMode(level)),
        );
        await tester.pumpWidget(widget);
        await tester.loadAssets();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/board_level_$level.png'),
        );
      });
    }
  });
}
