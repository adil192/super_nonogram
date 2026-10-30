/// This file contains the tests that take screenshots of the app.
///
/// Run it with `flutter test --update-goldens` to generate the screenshots
/// or `flutter test` to compare the screenshots to the golden files.
library;

import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:super_nonogram/api/api.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/api/image_to_board.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/board/tile_state.dart';
import 'package:super_nonogram/data/game_mode.dart';
import 'package:super_nonogram/pages/play_page.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/settings_page.dart';
import 'package:super_nonogram/pages/title_page.dart';
import 'package:super_nonogram/theme/theme.dart';

import 'util/mock_channel_handlers.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    setUpAll(_createPrismaticHeartPuzzle);

    _screenshot('1-title', home: TitlePage());

    _screenshot(
      '2-search',
      home: SearchPage(showPreviousPuzzles: false),
      beforeScreenshot: (tester) async {
        await tester.enterText(find.byType(TextField), 'prismatic heart');
        await tester.pump();
      },
    );

    _screenshot(
      '3-heart',
      home: PlayPage(ImageGameMode('prismatic heart')),
      beforeScreenshot: (tester) async {
        final playPageState = tester.state<PlayPageState>(
          find.byType(PlayPage),
        );
        // Wait for the board to load.
        while (playPageState.colorSchemeFromImage.value == null) {
          await tester.runAsync(
            () => Future.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
        }
      },
    );

    _screenshot('4-level-1', home: PlayPage(LevelGameMode(1)));

    _screenshot(
      '5-level-21-incomplete',
      home: PlayPage(LevelGameMode(21)),
      beforeScreenshot: (tester) async {
        final playPageState = tester.state<PlayPageState>(
          find.byType(PlayPage),
        );
        final boardState = tester.state<BoardWidgetState>(find.byType(Board));
        for (int y = 0; y < boardState.height; y++) {
          for (int x = 0; x < boardState.width; x++) {
            if (x >= boardState.width - 1 && y >= boardState.height - 5) break;
            final answer = playPageState.answerBoard![y][x].value;
            if (answer == TileState.selected) {
              boardState.board[y][x].value = TileState.selected;
            } else if (answer == TileState.empty) {
              boardState.board[y][x].value = TileState.crossed;
            }
          }
        }
        boardState.currentAnswers.value = BoardLabels.fromBoardState(
          boardState.board,
          boardState.width,
          boardState.height,
        );
        await tester.pump();
      },
    );

    _screenshot(
      '6-level-21-complete',
      home: PlayPage(LevelGameMode(21)),
      beforeScreenshot: (tester) async {
        final playPageState = tester.state<PlayPageState>(
          find.byType(PlayPage),
        );
        final boardState = tester.state<BoardWidgetState>(find.byType(Board));
        for (int y = 0; y < boardState.height; y++) {
          for (int x = 0; x < boardState.width; x++) {
            final answer = playPageState.answerBoard![y][x].value;
            if (answer == TileState.selected) {
              boardState.board[y][x].value = TileState.selected;
            } else if (answer == TileState.empty) {
              boardState.board[y][x].value = TileState.crossed;
            }
          }
        }
        boardState.currentAnswers.value = BoardLabels.fromBoardState(
          boardState.board,
          boardState.width,
          boardState.height,
        );
        await tester.pump();
      },
    );

    _screenshot('9-settings', home: SettingsPage());
  });
}

void _screenshot(
  String description, {
  required Widget home,
  Future<void> Function(WidgetTester tester)? beforeScreenshot,
}) {
  group(description, () {
    for (final goldenDevice in GoldenScreenshotDevices.values) {
      testGoldens('for ${goldenDevice.name}', (tester) async {
        final device = goldenDevice.device;

        await tester.pumpWidget(
          ScreenshotApp.withConditionalTitlebar(
            device: device,
            title: 'Super Nonogram',
            theme: SuperNonogramTheme.createTheme(
              brightness: Brightness.light,
              platform: device.platform,
            ),
            home: home,
          ),
        );

        // One of our tests needs to interact with the UI before taking the screenshot.
        await beforeScreenshot?.call(tester);

        // Precache the images and fonts so they're ready for the screenshot.
        await tester.loadAssets();

        // Pump the widget for a second to ensure animations are complete.
        await tester.pumpFrames(
          tester.widget(find.byType(ScreenshotApp)),
          const Duration(seconds: 1),
        );

        // Take the screenshot and compare it to the golden file.
        await tester.expectScreenshot(device, description);
      });
    }
  });
}

Future<void> _createPrismaticHeartPuzzle([
  String query = 'prismatic heart',
]) async {
  final baseFilename = Uri.encodeComponent(query);
  final fileNgb = '/$baseFilename.ngb';
  final filePng = '/$baseFilename.png';
  final fileJson = '/$baseFilename.json';

  final srcImage = File(
    'test/test_assets/prismatic_heart.png',
  ).readAsBytesSync();
  final board = await ImageToBoard.importFromBytes(srcImage);
  final info = PixabayImage(
    id: 1237242,
    pageUrl:
        'https://pixabay.com/vectors/colorful-prismatic-chromatic-1237242/',
    previewUrl: '_',
    previewSize: const Size(150, 150),
    webformatUrl: '_',
    webformatSize: const Size(640, 640),
    authorId: 1086657,
    authorName: 'GDJ',
    authorImageUrl: '_',
  );

  final ngb = Ngb.writeNgb(board!);
  await FileManager.writeFile(fileNgb, string: ngb);
  await FileManager.writeFile(filePng, bytes: srcImage);
  await FileManager.writeFile(fileJson, string: jsonEncode(info));
  PreviousPuzzles.recordPuzzle(query);
}
