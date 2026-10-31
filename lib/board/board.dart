import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mutex/mutex.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/board/board_grid.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/board/tile_state.dart';
import 'package:super_nonogram/data/game_mode.dart';
import 'package:super_nonogram/util/sonic_controller.dart';

typedef BoardState = List<List<ValueNotifier<TileState>>>;
typedef Coordinate = ({int x, int y});

class Board extends StatefulWidget {
  const Board({
    super.key,
    required this.gameMode,
    required this.answerBoard,
    required this.srcImage,
    required this.onSolved,
    required this.currentTileAction,
  }) : assert(currentTileAction != TileState.empty);

  final GameMode gameMode;
  final BoardState answerBoard;
  final Uint8List? srcImage;
  final VoidCallback onSolved;
  final TileState currentTileAction;

  @override
  State<Board> createState() => BoardWidgetState();
}

@visibleForTesting
class BoardWidgetState extends State<Board> {
  @visibleForTesting
  static const double colLabelLineHeight = 1.2;

  late final int width = widget.answerBoard[0].length;
  late final int height = widget.answerBoard.length;
  late final BoardLabels answer = BoardLabels.fromBoardState(
    widget.answerBoard,
    width,
    height,
  );
  late ValueNotifier<BoardLabels> currentAnswers = ValueNotifier(
    BoardLabels.fromBoardState(board, width, height),
  );
  bool get isSolved => currentAnswers.value == answer;

  /// Whether to disable user input, e.g. when loading.
  bool _blockInputs = true;

  /// Whether secondary input is currently active
  /// (right-click or stylus button)
  bool secondaryInput = false;

  /// If the player holds down at the start of a pan for 1s,
  /// secondary input is activated.
  Timer? tapHoldTimer;

  late final BoardState board = List.generate(
    height,
    (_) => List.generate(width, (_) => ValueNotifier(TileState.empty)),
  );
  late final BoardState boardBackup = List.generate(
    height,
    (_) => List.generate(width, (_) => ValueNotifier(TileState.empty)),
  );

  Coordinate panStartCoordinate = (x: -1, y: -1);

  TileRelation getTileRelation(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return TileRelation.outOfBounds;
    }
    if (x != panStartCoordinate.x && y != panStartCoordinate.y) {
      return TileRelation.notInSameRowOrColumn;
    }
    return TileRelation.valid;
  }

  void onPanStart(Coordinate coordinate) {
    if (_blockInputs) {
      panStartCoordinate = (x: -1, y: -1);
      return;
    }

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        boardBackup[y][x].value = board[y][x].value;
      }
    }

    final (:x, :y) = coordinate;

    tapHoldTimer?.cancel();
    tapHoldTimer = Timer(const Duration(seconds: 1), () {
      SonicController.notifyLongPress();
      secondaryInput = true;
      board[y][x].value = TileState.crossed;
      onPanUpdate(coordinate);
    });

    panStartCoordinate = coordinate;
    // The start position could be out of bounds
    switch (getTileRelation(x, y)) {
      case TileRelation.valid:
        panStartCoordinate = (x: x, y: y);
        onPanUpdate(coordinate);
      case TileRelation.outOfBounds:
      case TileRelation.notInSameRowOrColumn:
        panStartCoordinate = (x: -1, y: -1);
    }
  }

  void onPanUpdate(Coordinate coordinate) {
    if (_blockInputs) return;

    final (:x, :y) = coordinate;

    if (x != panStartCoordinate.x || y != panStartCoordinate.y) {
      tapHoldTimer?.cancel();
    }

    if (getTileRelation(x, y) != TileRelation.valid) return;

    final TileState targetTileState = secondaryInput
        ? TileState.crossed
        : widget.currentTileAction;

    /// This tile is either in the same row or the same column as the pan start tile.
    bool inSameRow = y == panStartCoordinate.y;

    // Interpolate between the start and end coordinates.
    if (inSameRow) {
      for (
        int i = min(x, panStartCoordinate.x);
        i <= max(x, panStartCoordinate.x);
        i++
      ) {
        _updateTile(i, y, targetTileState);
      }
    } else {
      for (
        int i = min(y, panStartCoordinate.y);
        i <= max(y, panStartCoordinate.y);
        i++
      ) {
        _updateTile(x, i, targetTileState);
      }
    }

    currentAnswers.value = BoardLabels.fromBoardState(board, width, height);
  }

  void onPanEnd() {
    if (_blockInputs) return;
    tapHoldTimer?.cancel();
    _saveBoard();
  }

  void _updateTile(int x, int y, TileState targetTileState) {
    final tileState = board[y][x];
    final backupTileState =
        boardBackup[panStartCoordinate.y][panStartCoordinate.x];

    final bool tileChanged;
    if (backupTileState.value == targetTileState) {
      if (tileState.value == targetTileState) {
        tileState.value = TileState.empty;
        tileChanged = true;
      } else {
        tileChanged = false;
      }
    } else if (backupTileState.value == TileState.empty) {
      if (tileState.value == TileState.empty) {
        tileState.value = targetTileState;
        tileChanged = true;
      } else {
        tileChanged = false;
      }
    } else {
      // we started with a tile that was neither empty nor the target tile state,
      // so just set the tile state indiscriminately
      tileState.value = targetTileState;
      tileChanged = true;
    }

    if (tileChanged) {
      SonicController.notifyTileChange();
    }
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
    unawaited(_asyncInit());
    super.initState();

    currentAnswers.addListener(_onCurrentAnswersChanged);
  }

  Future<void> _asyncInit() async {
    _blockInputs = true;
    try {
      await _restoreBoard();
    } finally {
      _blockInputs = false;
    }
  }

  Future<void> _restoreBoard() async {
    final ngbPath = _getCurrentAnswersNgbPath();
    try {
      final ngb = await FileManager.readFile<String>(ngbPath);
      if (ngb != null) {
        final restored = Ngb.readNgb(ngb);
        for (int x = 0; x < width; x++) {
          for (int y = 0; y < height; y++) {
            try {
              board[y][x].value = restored[y][x].value;
            } on RangeError {
              // ignore malsized saves
            }
          }
        }
        currentAnswers.value = BoardLabels.fromBoardState(board, width, height);
      }
    } catch (_) {
      // ignore corrupted saves
    }
    autoselectCompleteRowsCols();
  }

  late final _saveMutex = Mutex();

  /// Saves the current board state to a file.
  /// See also [_restoreBoard].
  void _saveBoard() => _saveMutex.protect(() async {
    final ngbPath = _getCurrentAnswersNgbPath();
    final ngb = Ngb.writeNgb(board);
    await FileManager.writeFile(ngbPath, string: ngb);
  });

  /// The file that contains the current [board] state.
  String _getCurrentAnswersNgbPath() {
    final descriptor = widget.gameMode.descriptor;
    return '/currentAnswers/$descriptor.ngb';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Listener(
        onPointerDown: (event) {
          secondaryInput =
              event.buttons == kSecondaryButton ||
              event.kind == PointerDeviceKind.invertedStylus;
        },
        onPointerUp: (event) {
          secondaryInput = false;
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
              overlay: widget.srcImage == null
                  ? null
                  : Opacity(
                      opacity: 0.2,
                      child: Image.memory(widget.srcImage!, fit: BoxFit.fill),
                    ),
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    tapHoldTimer?.cancel();
    currentAnswers.removeListener(_onCurrentAnswersChanged);
    super.dispose();
  }
}

@visibleForTesting
enum TileRelation { valid, outOfBounds, notInSameRowOrColumn }
