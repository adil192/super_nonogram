import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:super_nonogram/board/board_grid.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/tile_state.dart';

typedef BoardState = List<List<ValueNotifier<TileState>>>;
typedef Coordinate = ({int x, int y});

class Board extends StatefulWidget {
  const Board({
    super.key,
    required this.answerBoard,
    required this.srcImage,
    required this.onSolved,
    required this.currentTileAction,
  }) : assert(currentTileAction != TileState.empty);

  final BoardState answerBoard;
  final Uint8List? srcImage;
  final VoidCallback onSolved;
  final TileState currentTileAction;

  static const double tileSize = 100;
  static const double tileSpacing = Board.tileSize * 0.1;
  static const double labelFontSize = tileSize * 0.2;

  @override
  State<Board> createState() => BoardWidgetState();
}

@visibleForTesting
class BoardWidgetState extends State<Board> {
  @visibleForTesting
  static const double colLabelLineHeight = 1.2;

  late final int width = widget.answerBoard[0].length;
  late final int height = widget.answerBoard.length;
  late final BoardLabels answer =
      BoardLabels.fromBoardState(widget.answerBoard, width, height);
  late ValueNotifier<BoardLabels> currentAnswers =
      ValueNotifier(BoardLabels.fromBoardState(board, width, height));
  bool get isSolved => currentAnswers.value == answer;

  /// Whether secondary input is currently active
  /// (right-click or stylus button)
  bool secondaryInput = false;

  /// If the player holds down at the start of a pan for 1s,
  /// secondary input is activated.
  Timer? tapHoldTimer;

  late final BoardState board = List.generate(
    height,
    (_) => List.generate(
      width,
      (_) => ValueNotifier(TileState.empty),
    ),
  );
  late final BoardState boardBackup = List.generate(
    height,
    (_) => List.generate(
      width,
      (_) => ValueNotifier(TileState.empty),
    ),
  );

  Coordinate panStartCoordinate = (x: 0, y: 0);

  Coordinate getCoordinateOfPosition(Offset position) {
    final columnLabelsHeight = getColumnLabelsHeight(answer);
    final x = ((position.dx - Board.tileSize) / Board.tileSize).floor();
    final y = ((position.dy - columnLabelsHeight) / Board.tileSize).floor();
    return (x: x, y: y);
  }

  TileRelation getTileRelation(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return TileRelation.outOfBounds;
    }
    if (x != panStartCoordinate.x && y != panStartCoordinate.y) {
      return TileRelation.notInSameRowOrColumn;
    }
    return TileRelation.valid;
  }

  void onPanStart(int x, int y) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        boardBackup[y][x].value = board[y][x].value;
      }
    }

    tapHoldTimer?.cancel();
    tapHoldTimer = Timer(const Duration(seconds: 1), () {
      secondaryInput = true;
      board[y][x].value = TileState.crossed;
      onPanUpdate(x, y);
    });
  }

  void onPanUpdate(int x, int y) {
    if (x != panStartCoordinate.x || y != panStartCoordinate.y) {
      tapHoldTimer?.cancel();
    }

    final TileState targetTileState =
        secondaryInput ? TileState.crossed : widget.currentTileAction;

    /// This tile is either in the same row or the same column as the pan start tile.
    bool inSameRow = y == panStartCoordinate.y;

    // Interpolate between the start and end coordinates.
    if (inSameRow) {
      for (int i = min(x, panStartCoordinate.x);
          i <= max(x, panStartCoordinate.x);
          i++) {
        _updateTile(i, y, targetTileState);
      }
    } else {
      for (int i = min(y, panStartCoordinate.y);
          i <= max(y, panStartCoordinate.y);
          i++) {
        _updateTile(x, i, targetTileState);
      }
    }

    currentAnswers.value = BoardLabels.fromBoardState(board, width, height);
  }

  void _updateTile(int x, int y, TileState targetTileState) {
    final tileState = board[y][x];
    final backupTileState =
        boardBackup[panStartCoordinate.y][panStartCoordinate.x];

    if (backupTileState.value == targetTileState) {
      if (tileState.value == targetTileState) {
        tileState.value = TileState.empty;
      }
    } else if (backupTileState.value == TileState.empty) {
      if (tileState.value == TileState.empty) {
        tileState.value = targetTileState;
      }
    } else {
      // we started with a tile that was neither empty nor the target tile state,
      // so just set the tile state indiscriminately
      tileState.value = targetTileState;
    }
  }

  /// Handles cases where a one-finger pan turns into a two-finger pan.
  bool isPanCancelled = false;
  bool checkIfPanCancelled(ScaleUpdateDetails details) {
    if (isPanCancelled) return true;
    if (details.pointerCount == 1 && details.scale == 1.0) return false;

    if (kDebugMode) print('Pan cancelled');
    isPanCancelled = true;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        board[y][x].value = boardBackup[y][x].value;
      }
    }
    currentAnswers.value = BoardLabels.fromBoardState(board, width, height);
    return true;
  }

  void autoselectCompleteRowsCols() {
    if (width <= 6 && height <= 6) {
      // Don't autoselect if the board is too small,
      // because we might accidentally solve the puzzle.
      return;
    }

    for (int x = 0; x < width; ++x) {
      if (answer.labelColumn(x) == '$height') {
        for (int y = 0; y < height; ++y) {
          board[y][x].value = TileState.selected;
        }
      }
    }
    for (int y = 0; y < height; ++y) {
      if (answer.labelRow(y) == '$width') {
        for (int x = 0; x < width; ++x) {
          board[y][x].value = TileState.selected;
        }
      }
    }
    currentAnswers.value = BoardLabels.fromBoardState(board, width, height);
  }

  void _onCurrentAnswersChanged() {
    if (!isSolved) return;
    widget.onSolved();
  }

  /// Returns the expected height of the first row
  /// (the one with the column labels).
  @visibleForTesting
  static double getColumnLabelsHeight(BoardLabels answer) {
    /// The number of lines in the longest column label.
    final lines = answer.columns.map((column) => column.length).reduce(max);

    return lines * Board.labelFontSize * colLabelLineHeight +
        Board.tileSpacing / 2;
  }

  @override
  void initState() {
    autoselectCompleteRowsCols();
    super.initState();

    currentAnswers.addListener(_onCurrentAnswersChanged);
  }

  @override
  Widget build(BuildContext context) {
    final columnLabelsHeight = getColumnLabelsHeight(answer);
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(Board.tileSpacing * 2),
        child: SizedBox(
          width: Board.tileSize * (width + 1),
          height: Board.tileSize * height + columnLabelsHeight,
          child: Listener(
            onPointerDown: (event) {
              secondaryInput = event.buttons == kSecondaryButton;
            },
            onPointerUp: (event) {
              secondaryInput = false;
            },
            child: InteractiveViewer(
              onInteractionStart: (details) {
                isPanCancelled = false;
                final (:x, :y) =
                    getCoordinateOfPosition(details.localFocalPoint);
                onPanStart(x, y);
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
                final (:x, :y) =
                    getCoordinateOfPosition(details.localFocalPoint);
                if (getTileRelation(x, y) == TileRelation.valid) {
                  onPanUpdate(x, y);
                }
              },
              onInteractionEnd: (details) {
                tapHoldTimer?.cancel();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BoardGrid(
                    width: width,
                    height: height,
                    answer: answer,
                    currentAnswers: currentAnswers,
                    board: board,
                    colLabelLineHeight: colLabelLineHeight,
                    columnLabelsHeight: columnLabelsHeight,
                  ),
                  if (widget.srcImage != null)
                    Opacity(
                      opacity: 0.2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: Board.tileSize,
                          left: Board.tileSize,
                        ),
                        child: Image.memory(
                          widget.srcImage!,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentAnswers.removeListener(_onCurrentAnswersChanged);
    super.dispose();
  }
}

@visibleForTesting
enum TileRelation {
  valid,
  outOfBounds,
  notInSameRowOrColumn,
}
