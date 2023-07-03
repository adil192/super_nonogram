import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/api/level_to_board.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/data/prefs.dart';
import 'package:super_nonogram/i18n/strings.g.dart';

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
  Uint8List? srcImage;
  BoardState? answerBoard;

  @override
  void initState() {
    super.initState();
    loadBoard();
  }

  void loadBoard() async {
    if (widget.query != null) {
      final ngbContents = await FileManager.readFile<String>('/${Uri.encodeComponent(widget.query!)}.ngb');
      srcImage = await FileManager.readFile<Uint8List>('/${Uri.encodeComponent(widget.query!)}.png');
      answerBoard = Ngb.readNgb(ngbContents);
      if (mounted) setState(() {});
    } else if (widget.level != null) {
      answerBoard = LevelToBoard.generate(widget.level!);
      setState(() {});
    }
  }

  void onSolved() {
    bool onALevel = widget.level != null;

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
          content: srcImage == null ? null : Image(
            image: MemoryImage(srcImage!),
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
      future: srcImage == null ? null : ColorScheme.fromImageProvider(
        provider: MemoryImage(srcImage!),
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
                          srcImage: srcImage,
                          onSolved: onSolved,
                        ),
                  ),
                ),
                if (AdState.adsSupported)
                  const BannerAdWidget(
                    adSize: AdSize.largeBanner,
                  ),
              ],
            ),
          ),
        );
      }
    );
  }
}
