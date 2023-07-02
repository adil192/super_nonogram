import 'dart:math';

import 'package:flutter/material.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

abstract class LevelToBoard {
  /// Returns the probability of a given tile being selected at the given level.
  /// Values are between 0.5 and 0.2, with 0.5 being the easiest and 0.2 being the hardest.
  /// The [level] must be greater than 0.
  @visibleForTesting
  static double pValueAtLevel(int level) {
    assert(level > 0, 'Level must be greater than 0');
    return 0.5 - 0.3 * pow((1 - 1 / level), 4);
  }

  /// Returns the size of the square board at the given level,
  /// which is the number of tiles on one side of the board.
  /// The [level] must be greater than 0.
  /// 
  /// The size of the board is calculated as follows:
  /// - Levels 1-4: 5x5
  /// - Levels 5-9: 6x6
  /// - Levels 10-14: 7x7
  /// - etc
  @visibleForTesting
  static int sizeAtLevel(int level) {
    assert(level > 0, 'Level must be greater than 0');
    return 5 + level ~/ 5;
  }
}
