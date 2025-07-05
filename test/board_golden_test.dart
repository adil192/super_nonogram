import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/pages/play_page.dart';

void main() {
  group('Board goldens', () {
    AdState.init();

    for (final level in const [1, 10, 20, 50, 99]) {
      testGoldens('Level $level', (tester) async {
        final widget = ScreenshotApp(
          device: GoldenScreenshotDevices.android.device,
          child: PlayPage(level: level, query: null),
        );
        await tester.pumpWidget(widget);
        await tester.precacheImagesInWidgetTree();
        await tester.loadFonts();
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(PlayPage),
          matchesGoldenFile('goldens/board_level_$level.png'),
        );
      });
    }
  });
}
