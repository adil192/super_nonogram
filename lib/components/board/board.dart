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

  static void onPanStart() {
    boardBackup = board
        .map((row) => row.map((tileState) => tileState.clone()).toList())
        .toList();
  }
  static void onPanUpdate(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      if (kDebugMode) print('Out of bounds: $x, $y');
      return;
    }

    final tileState = board[y][x];
    final backupTileState = boardBackup![y][x];
    tileState.selected = !backupTileState.selected;
    tileState.notifyListeners();
  }

  /// Handles cases where a one-finger pan turns into a two-finger pan.
  static bool isPanCancelled = false;
  static bool checkIfPanCancelled(ScaleUpdateDetails details) {
    if (isPanCancelled) return true;
    if (details.pointerCount == 1) return false;

    if (kDebugMode) print('Pan cancelled');
    isPanCancelled = true;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        board[y][x].copyFrom(boardBackup![y][x]);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: tileSize * width,
        height: tileSize * height,
        child: InteractiveViewer(
          onInteractionStart: (details) {
            isPanCancelled = false;
            onPanStart();
            final x = details.localFocalPoint.dx ~/ tileSize;
            final y = details.localFocalPoint.dy ~/ tileSize;
            onPanUpdate(x, y);
          },
          onInteractionUpdate: (details) {
            if (checkIfPanCancelled(details)) return;
            final x = details.localFocalPoint.dx ~/ tileSize;
            final y = details.localFocalPoint.dy ~/ tileSize;
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
