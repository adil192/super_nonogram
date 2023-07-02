import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/api/level_to_board.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/ngb.dart';
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

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    return FutureBuilder(
      future: srcImage == null ? null : ColorScheme.fromImageProvider(
        provider: MemoryImage(srcImage!),
        brightness: parentTheme.brightness,
      ),
      builder: (context, snapshot) {
        return Theme(
          data: parentTheme.copyWith(
            colorScheme: snapshot.data ?? parentTheme.colorScheme,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(t.appName),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: Center(
              child: answerBoard == null
                ? const CircularProgressIndicator()
                : Board(
                    answerBoard: answerBoard!,
                    srcImage: srcImage!,
                  ),
            ),
          ),
        );
      }
    );
  }
}
