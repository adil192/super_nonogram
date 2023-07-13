import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/tile.dart';
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
  });

  final BoardState answerBoard;
  final Uint8List? srcImage;
  final VoidCallback onSolved;
  final TileState currentTileAction;

  static const double tileSize = 100;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late final int width = widget.answerBoard[0].length;
  late final int height = widget.answerBoard.length;
  late final BoardLabels answer = BoardLabels.fromBoardState(widget.answerBoard, width, height);
  late ValueNotifier<BoardLabels> currentAnswers = ValueNotifier(BoardLabels.fromBoardState(board, width, height));
  bool get isSolved => currentAnswers.value == answer;

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
    final x = position.dx ~/ Board.tileSize - 1;
    final y = position.dy ~/ Board.tileSize - 1;
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

  void onPanStart() {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        boardBackup[y][x].value = board[y][x].value;
      }
    }
  }
  void onPanUpdate(int x, int y) {
    final tileState = board[y][x];
    final backupTileState = boardBackup[panStartCoordinate.y][panStartCoordinate.x];

    if (backupTileState.value == widget.currentTileAction) {
      if (tileState.value == widget.currentTileAction) {
        tileState.value = TileState.empty;
      }
    } else {
      tileState.value = widget.currentTileAction;
    }

    currentAnswers.value = BoardLabels.fromBoardState(board, width, height);
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

  @override
  void initState() {
    autoselectCompleteRowsCols();
    super.initState();

    currentAnswers.addListener(_onCurrentAnswersChanged);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: Board.tileSize * (width + 1),
        height: Board.tileSize * (height + 1),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              GridView.builder(
                itemCount: width * height + width + height + 1,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width + 1,
                  mainAxisSpacing: Board.tileSize * 0.1,
                  crossAxisSpacing: Board.tileSize * 0.1,
                ),
                padding: const EdgeInsets.all(Board.tileSize * 0.2),
                itemBuilder: (context, index) {
                  final int x = index % (width + 1) - 1;
                  final int y = index ~/ (width + 1) - 1;
                  late final colorScheme = Theme.of(context).colorScheme;
                  return switch ((x, y)) {
                    (-1, -1) => const SizedBox(),
                    (-1, _) => Align(
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder(
                        valueListenable: currentAnswers,
                        builder: (context, _, child) {
                          final status = BoardLabels.statusOfRow(y, answer, currentAnswers.value);
                          return AnimatedOpacity(
                            opacity: switch (status) {
                              BoardLabelStatus.correct => 0,
                              _ => 1,
                            },
                            duration: const Duration(milliseconds: 500),
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                fontSize: Board.tileSize * 0.2,
                                color: switch (status) {
                                  BoardLabelStatus.correct => colorScheme.primary,
                                  BoardLabelStatus.incorrect => colorScheme.error,
                                  BoardLabelStatus.incomplete => colorScheme.onBackground,
                                },
                              ),
                              child: child!,
                            ),
                          );
                        },
                        child: Text(
                          answer.labelRow(y),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    (_, -1) => Align(
                      alignment: Alignment.bottomCenter,
                      child: ValueListenableBuilder(
                        valueListenable: currentAnswers,
                        builder: (context, _, child) {
                          final status = BoardLabels.statusOfColumn(x, answer, currentAnswers.value);
                          return AnimatedOpacity(
                            opacity: switch (status) {
                              BoardLabelStatus.correct => 0,
                              _ => 1,
                            },
                            duration: const Duration(milliseconds: 500),
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                height: 1.2,
                                fontSize: Board.tileSize * 0.2,
                                color: switch (status) {
                                  BoardLabelStatus.correct => colorScheme.primary,
                                  BoardLabelStatus.incorrect => colorScheme.error,
                                  BoardLabelStatus.incomplete => colorScheme.onBackground,
                                },
                              ),
                              child: child!,
                            ),
                          );
                        },
                        child: Text(
                          answer.labelColumn(x),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    _ => ValueListenableBuilder(
                      valueListenable: board[y][x],
                      builder: (context, tileState, child) {
                        return Tile(
                          tileState: tileState,
                        );
                      },
                    ),
                  };
                },
              ),
              if (widget.srcImage != null) Opacity(
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
