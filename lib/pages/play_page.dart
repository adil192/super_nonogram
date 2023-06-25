import 'package:flutter/material.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/misc/title.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({
    super.key,
    required this.query,
  });

  final String query;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  BoardState? answerBoard;

  @override
  void initState() {
    super.initState();
    loadBoard();
  }

  void loadBoard() async {
    final ngbContents = await FileManager.readFile('/${Uri.encodeComponent(widget.query)}.ngb');
    if (!mounted) return;
    setState(() {
      answerBoard = Ngb.readNgb(ngbContents);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText(),
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
            ),
      ),
    );
  }
}
