import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_nonogram/components/board/tile.dart';
import 'package:super_nonogram/components/board/tile_state.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  static const width = 10;
  static const height = 10;

  static const tileSize = 50.0;

  static final List<List<TileState>> board = List.generate(
    height,
    (_) => List.generate(
      width,
      (_) => TileState(),
    ),
  );
  static List<List<TileState>>? boardBackup;

  void onPanStart() {
    boardBackup = board
        .map((row) => row.map((tileState) => tileState.clone()).toList())
        .toList();
  }
  void onPanUpdate(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      if (kDebugMode) print('Out of bounds: $x, $y');
      return;
    }

    final tileState = board[y][x];
    final backupTileState = boardBackup![y][x];
    tileState.selected = !backupTileState.selected;
    tileState.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: tileSize * width,
        height: tileSize * height,
        child: GestureDetector(
          onPanStart: (_) => onPanStart(),
          onPanUpdate: (details) {
            final x = details.localPosition.dx ~/ tileSize;
            final y = details.localPosition.dy ~/ tileSize;
            onPanUpdate(x, y);
          },
          child: GridView.builder(
            itemCount: width * height,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final int x = index % width;
              final int y = index ~/ width;
              return AnimatedBuilder(
                animation: board[y][x],
                builder: (context, child) {
                  final tileState = board[y][x];
                  return Tile(
                    tileState: tileState,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
