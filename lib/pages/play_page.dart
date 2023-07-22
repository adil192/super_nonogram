import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/api/api.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/api/level_to_board.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/board/tile_state.dart';
import 'package:super_nonogram/board/toolbar.dart';
import 'package:super_nonogram/data/prefs.dart';
import 'package:super_nonogram/games_services/achievement_ids.dart';
import 'package:super_nonogram/games_services/games_services_helper.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({
    super.key,
    required this.query,
    required this.level,
  }) :  assert((query != null) ^ (level != null), 'Either query or level must be provided'),
        assert(level == null || level > 0, 'Level must be greater than 0');

  final String? query;
  final int? level;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  PixabayImage? imageInfo;
  Uint8List? imageBytes;
  BoardState? answerBoard;
  
  TileState currentTileAction = TileState.selected;

  @override
  void initState() {
    super.initState();
    loadBoard();
  }

  void loadBoard() async {
    if (widget.query != null) {
      final encodedQuery = Uri.encodeComponent(widget.query!);
      final ngbContents = await FileManager.readFile<String>('/$encodedQuery.ngb');
      final infoJson = await FileManager.readFile<String>('/$encodedQuery.json');
      imageBytes = await FileManager.readFile<Uint8List>('/$encodedQuery.png');
      imageInfo = infoJson == null ? null : PixabayImage.fromJson(jsonDecode(infoJson));
      answerBoard = Ngb.readNgb(ngbContents!);
      if (mounted) setState(() {});
    } else if (widget.level != null) {
      answerBoard = LevelToBoard.generate(widget.level!);
      setState(() {});
    }
  }

  void onSolved() {
    bool onALevel = widget.level != null;

    if (onALevel) {
      recordLevelCompleteAchievement(widget.level!);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(
            onALevel
                ? t.play.levelCompleted(n: widget.level!)
                : t.play.puzzleCompleted,
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            children: [
              if (imageBytes != null) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Image(
                    image: MemoryImage(imageBytes!),
                  ),
                ),
                const SizedBox(height: 8),
                if (imageInfo != null) RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      t.play.imageAttribution(
                        author: TextSpan(
                          text: imageInfo!.authorName,
                          style: TextStyle(
                            color: colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            launchUrl(Uri.parse(imageInfo!.authorPageUrl));
                          },
                        ),
                        pixabay: TextSpan(
                          text: 'Pixabay',
                          style: TextStyle(
                            color: colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
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
                context.pushReplacement(
                  onALevel
                      ? '/play?level=${Prefs.currentLevel.value}'
                      : '/play?query=${Uri.encodeComponent(widget.query!)}',
                );
              },
              child: Text(
                onALevel
                    ? t.play.restartLevel
                    : t.play.restartPuzzle,
              ),
            ),
            if (onALevel) TextButton(
              onPressed: () {
                Prefs.currentLevel.value = widget.level! + 1;
                context.pushReplacement('/play?level=${Prefs.currentLevel.value}');
              },
              child: Text(t.play.nextLevel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    return FutureBuilder(
      future: imageBytes == null ? null : ColorScheme.fromImageProvider(
        provider: MemoryImage(imageBytes!),
        brightness: parentTheme.brightness,
      ),
      builder: (context, snapshot) {
        final colorScheme = snapshot.data ?? parentTheme.colorScheme;
        return Theme(
          data: parentTheme.copyWith(
            colorScheme: colorScheme,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(t.title.appName),
              // Display level selector
              bottom: widget.level == null ? null : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.level! > 1) IconButton(
                      onPressed: () {
                        Prefs.currentLevel.value = widget.level! - 1;
                        context.pushReplacement('/play?level=${Prefs.currentLevel.value}');
                      },
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(
                      t.play.level(n: widget.level!),
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Prefs.currentLevel.value = widget.level! + 1;
                        context.pushReplacement('/play?level=${Prefs.currentLevel.value}');
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: answerBoard == null
                      ? const CircularProgressIndicator()
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
                if (AdState.adsSupported)
                  const SafeArea(
                    child: BannerAdWidget(
                      adSize: AdSize.largeBanner,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }

  static Future recordLevelCompleteAchievement(int level) async {
    for (int tier in androidAchievements.levels.tiers) {
      await runAfterGamesSignIn(() => GamesServices.unlock(achievement: Achievement(
        androidID: androidAchievements.levels[tier],
        iOSID: iosAchievements.levels[tier],
        percentComplete: min(100, level / tier * 100),
        steps: level,
      )));
    }
  }
}
