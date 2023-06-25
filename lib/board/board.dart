import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/board/tile.dart';
import 'package:super_nonogram/board/tile_state.dart';

typedef BoardState = List<List<TileState>>;
typedef Coordinate = ({int x, int y});

class Board extends StatelessWidget {
  const Board({super.key});

  static const double tileSize = 100;

  static late int width;
  static late int height;
  static late BoardLabels answer;
  static BoardState board = List.generate(
    height,
    (_) => List.generate(
      width,
      (_) => TileState(),
    ),
  );
  static BoardState boardBackup = List.generate(
    height,
    (_) => List.generate(
      width,
      (_) => TileState(),
    ),
  );

  static Future importUsb() async {
    final usbNgb = await rootBundle.load('assets/board_images/usb.ngb');
    final usbNgbString = String.fromCharCodes(usbNgb.buffer.asUint8List());
    final board = Ngb.readNgb(usbNgbString);
    answer = BoardLabels.fromBoardState(board, width, height);
  }

  static Coordinate panStartCoordinate = (x: 0, y: 0);

  static Coordinate getCoordinateOfPosition(Offset position) {
    final x = position.dx ~/ tileSize - 1;
    final y = position.dy ~/ tileSize - 1;
    return (x: x, y: y);
  }
  static TileRelation getTileRelation(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return TileRelation.outOfBounds;
    }
    if (x != panStartCoordinate.x && y != panStartCoordinate.y) {
      return TileRelation.notInSameRowOrColumn;
    }
    return TileRelation.valid;
  }

  static void onPanStart() {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        boardBackup[y][x].copyFrom(board[y][x]);
      }
    }
  }
  static void onPanUpdate(int x, int y) {
    final tileState = board[y][x];
    final backupTileState = boardBackup[panStartCoordinate.y][panStartCoordinate.x];
    tileState.selected = !backupTileState.selected;
    tileState.notifyListeners();
  }

  /// Handles cases where a one-finger pan turns into a two-finger pan.
  static bool isPanCancelled = false;
  static bool checkIfPanCancelled(ScaleUpdateDetails details) {
    if (isPanCancelled) return true;
    if (details.pointerCount == 1 && details.scale == 1.0) return false;

    if (kDebugMode) print('Pan cancelled');
    isPanCancelled = true;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        board[y][x].copyFrom(boardBackup[y][x]);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: tileSize * (width + 1),
        height: tileSize * (height + 1),
        child: InteractiveViewer(
          onInteractionStart: (details) {
            isPanCancelled = false;
            onPanStart();
            final (:x, :y) = getCoordinateOfPosition(details.localFocalPoint);
            panStartCoordinate = (x: x, y: y);
            switch (getTileRelation(x, y)) {
              case TileRelation.valid:
                panStartCoordinate = (x: x, y: y);
                onPanUpdate(x, y);
              case TileRelation.outOfBounds:
              case TileRelation.notInSameRowOrColumn:
                panStartCoordinate = (x: 0, y: 0);
                isPanCancelled = true;
            }
          },
          onInteractionUpdate: (details) {
            if (checkIfPanCancelled(details)) return;
            final (:x, :y) = getCoordinateOfPosition(details.localFocalPoint);
            if (getTileRelation(x, y) == TileRelation.valid) {
              onPanUpdate(x, y);
            }
          },
          child: GridView.builder(
            itemCount: width * height + width + height + 1,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width + 1,
              mainAxisSpacing: tileSize * 0.1,
              crossAxisSpacing: tileSize * 0.1,
            ),
            padding: const EdgeInsets.all(tileSize * 0.2),
            itemBuilder: (context, index) {
              final int x = index % (width + 1) - 1;
              final int y = index ~/ (width + 1) - 1;
              late final colorScheme = Theme.of(context).colorScheme;
              return switch ((x, y)) {
                (-1, -1) => const SizedBox(),
                (-1, _) => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    answer.labelRow(y),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: tileSize * 0.2,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),
                (_, -1) => Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    answer.labelColumn(x),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.2,
                      fontSize: tileSize * 0.2,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),
                _ => AnimatedBuilder(
                  animation: board[y][x],
                  builder: (context, child) {
                    final tileState = board[y][x];
                    return Tile(
                      tileState: tileState,
                    );
                  },
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
enum TileRelation {
  valid,
  outOfBounds,
  notInSameRowOrColumn,
}
