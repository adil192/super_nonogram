import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

abstract class ClassicPuzzles {
  static BoardState generate({
    int width = 9,
    int height = 9,
    double pValue = 0.7,
    required int? seed,
  }) {
    final BoardState board = List.generate(
      height,
      (_) => List.generate(width, (_) => ValueNotifier(TileState.empty)),
    );

    final r = Random(seed);
    for (final row in board) {
      for (final tile in row) {
        if (r.nextDouble() < pValue) {
          tile.value = TileState.selected;
        }
      }
    }

    return board;
  }
}
