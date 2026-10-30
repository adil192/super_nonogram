import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/api/api.dart';
import 'package:super_nonogram/api/classic_puzzles.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/api/level_to_board.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/board/tile_state.dart';
import 'package:super_nonogram/board/toolbar.dart';
import 'package:super_nonogram/data/game_mode.dart';
import 'package:super_nonogram/data/stows.dart';
import 'package:super_nonogram/games_services/achievement_ids.dart';
import 'package:super_nonogram/games_services/games_services_helper.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayPage extends StatefulWidget {
  const PlayPage(this.gameMode, {super.key});

  final GameMode gameMode;

  @override
  PlayPageState createState() => PlayPageState();
}

@visibleForTesting
class PlayPageState extends State<PlayPage> {
  PixabayImage? imageInfo;
  Uint8List? imageBytes;
  BoardState? answerBoard;
  final colorSchemeFromImage = ValueNotifier<ColorScheme?>(null);

  TileState currentTileAction = TileState.selected;

  @override
  void initState() {
    super.initState();
    loadBoard();
  }

  void loadBoard() async {
    switch (widget.gameMode) {
      case (ImageGameMode gameMode):
        final encodedQuery = Uri.encodeComponent(gameMode.query);
        final ngbContents = await FileManager.readFile<String>(
          '/$encodedQuery.ngb',
        );
        final infoJson = await FileManager.readFile<String>(
          '/$encodedQuery.json',
        );
        imageBytes = await FileManager.readFile<Uint8List>(
          '/$encodedQuery.png',
        );
        _loadColorSchemeFromImage();
        imageInfo = infoJson == null
            ? null
            : PixabayImage.fromJson(jsonDecode(infoJson));
        answerBoard = Ngb.readNgb(ngbContents!);
      case (LevelGameMode gameMode):
        answerBoard = LevelToBoard.generate(gameMode.level);
      case (ClassicGameMode gameMode):
        answerBoard = ClassicPuzzles.generate(seed: gameMode.seed);
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (imageBytes != null) {
      final brightness = Theme.of(context).brightness;
      if (brightness != colorSchemeFromImage.value?.brightness) {
        _loadColorSchemeFromImage();
      }
    }
  }

  @override
  void dispose() {
    colorSchemeFromImage.dispose();
    super.dispose();
  }

  void _loadColorSchemeFromImage() async {
    if (imageBytes == null) return;
    final parentTheme = Theme.of(context);
    colorSchemeFromImage.value = await ColorScheme.fromImageProvider(
      provider: MemoryImage(imageBytes!),
      dynamicSchemeVariant: .fidelity,
      brightness: parentTheme.brightness,
      contrastLevel: MediaQuery.highContrastOf(context) ? 0.7 : 0.0,
    );
  }

  void onSolved() {
    final gameMode = widget.gameMode;
    if (gameMode is LevelGameMode) {
      recordLevelCompleteAchievement(gameMode.level);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _SolvedDialog(
          gameMode: gameMode,
          imageBytes: imageBytes,
          imageInfo: imageInfo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final gameMode = widget.gameMode;
    return ValueListenableBuilder(
      valueListenable: colorSchemeFromImage,
      builder: (context, colorSchemeFromImage, child) {
        return Theme(
          data: parentTheme.copyWith(colorScheme: colorSchemeFromImage),
          child: child!,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(child: Text('${t.title.appName} ')),
              _GameModeChip(
                gameMode: gameMode,
                // keep the same colors as home screen
                theme: parentTheme,
              ),
            ],
          ),
          // Display level selector
          bottom: gameMode is LevelGameMode
              ? _LevelSelectionBar(gameMode: gameMode)
              : null,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: answerBoard == null
                    ? const CircularProgressIndicator.adaptive()
                    : Board(
                        answerBoard: answerBoard!,
                        srcImage: imageBytes,
                        onSolved: onSolved,
                        currentTileAction: currentTileAction,
                      ),
              ),
            ),
            SafeArea(
              child: Toolbar(
                currentTileAction: currentTileAction,
                setTileAction: (tileAction) => setState(() {
                  currentTileAction = tileAction;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> recordLevelCompleteAchievement(int level) async {
    /// The largest tier that the user has completed
    final completedTier = androidAchievements.levels.tiers.lastWhere(
      (tier) => level >= tier,
    );
    await runAfterGamesSignIn(() async {
      // Unlock the achievement for the completed tier first
      // because of an Android bug where subsequent achievements aren't recorded
      await GamesServices.unlock(
        achievement: Achievement(
          androidID: androidAchievements.levels[completedTier],
          iOSID: iosAchievements.levels[completedTier],
          percentComplete: 100,
          steps: completedTier,
        ),
      );

      for (final tier in androidAchievements.levels.tiers) {
        if (tier == completedTier) continue;
        await GamesServices.unlock(
          achievement: Achievement(
            androidID: androidAchievements.levels[tier],
            iOSID: iosAchievements.levels[tier],
            percentComplete: min(100, level / tier * 100),
            steps: level,
          ),
        );
      }
    });
  }
}

class _LevelSelectionBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _LevelSelectionBar({required this.gameMode});

  final LevelGameMode gameMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gameMode.level > 1)
          IconButton(
            onPressed: () {
              stows.currentLevel.value = gameMode.level - 1;
              context.pushReplacement(
                '/play?level=${stows.currentLevel.value}',
              );
            },
            icon: const Icon(Icons.arrow_left),
          ),
        Text(
          t.play.level(n: gameMode.level),
          style: TextTheme.of(context).titleLarge,
        ),
        IconButton(
          onPressed: () {
            stows.currentLevel.value = gameMode.level + 1;
            context.pushReplacement('/play?level=${stows.currentLevel.value}');
          },
          icon: const Icon(Icons.arrow_right),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _GameModeChip extends StatelessWidget {
  const _GameModeChip({required this.gameMode, required this.theme});

  final GameMode gameMode;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Chip(
      label: Text(
        switch (gameMode) {
          (LevelGameMode _) => t.gameModes.level,
          (ClassicGameMode _) => t.gameModes.classic,
          (ImageGameMode _) => t.gameModes.image,
        },
        style: TextStyle(
          fontSize: 12,
          color: switch (gameMode) {
            (LevelGameMode _) => colorScheme.onPrimaryContainer,
            (ClassicGameMode _) => colorScheme.onSecondaryContainer,
            (ImageGameMode _) => colorScheme.onTertiaryContainer,
          },
        ),
        textAlign: .center,
      ),
      backgroundColor: switch (gameMode) {
        (LevelGameMode _) => colorScheme.primaryContainer,
        (ClassicGameMode _) => colorScheme.secondaryContainer,
        (ImageGameMode _) => colorScheme.tertiaryContainer,
      },
      padding: const .all(6),
      labelPadding: .zero,
      side: MediaQuery.highContrastOf(context) ? null : BorderSide.none,
    );
  }
}

class _SolvedDialog extends StatelessWidget {
  const _SolvedDialog({
    required this.gameMode,
    required this.imageBytes,
    required this.imageInfo,
  });

  final GameMode gameMode;
  final Uint8List? imageBytes;
  final PixabayImage? imageInfo;

  @override
  Widget build(BuildContext context) {
    final gameMode = this.gameMode;
    final colorScheme = ColorScheme.of(context);
    return AlertDialog(
      title: Text(switch (gameMode) {
        (LevelGameMode gameMode) => t.play.levelCompleted(n: gameMode.level),
        _ => t.play.puzzleCompleted,
      }),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageBytes != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Image(image: MemoryImage(imageBytes!)),
            ),
            const SizedBox(height: 8),
            if (imageInfo != null)
              RichText(
                text: TextSpan(
                  style: TextStyle(color: colorScheme.onSurface),
                  children: [
                    t.play.imageAttribution(
                      author: TextSpan(
                        text: imageInfo!.authorName,
                        style: TextStyle(color: colorScheme.primary),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(imageInfo!.authorPageUrl));
                          },
                      ),
                      pixabay: TextSpan(
                        text: 'Pixabay',
                        style: TextStyle(color: colorScheme.primary),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(imageInfo!.pageUrl));
                          },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pushReplacement('/');
          },
          child: Text(t.play.backToTitlePage),
        ),
        TextButton(
          onPressed: () {
            switch (gameMode) {
              case (LevelGameMode gameMode):
                context.pushReplacement('/play?level=${gameMode.level}');
              case (ImageGameMode gameMode):
                context.pushReplacement(
                  '/play?query=${Uri.encodeComponent(gameMode.query)}',
                );
              case (ClassicGameMode _):
                context.pushReplacement('/play?classic');
            }
          },
          child: Text(switch (gameMode) {
            (LevelGameMode _) => t.play.restartLevel,
            (ImageGameMode _) => t.play.restartPuzzle,
            (ClassicGameMode _) => t.play.playAgain,
          }),
        ),
        if (gameMode is LevelGameMode)
          TextButton(
            onPressed: () {
              stows.currentLevel.value = gameMode.level + 1;
              context.pushReplacement(
                '/play?level=${stows.currentLevel.value}',
              );
            },
            child: Text(t.play.nextLevel),
          ),
      ],
    );
  }
}
