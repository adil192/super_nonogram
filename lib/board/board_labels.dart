import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:super_nonogram/board/board.dart';

class BoardLabels {
  /// List of groups of selected tiles for each column.
  /// 
  /// Each group is represented by an integer,
  /// and unselected tiles are omitted.
  /// 
  /// Multiple [BoardState]s can have the same [BoardLabels],
  /// so the player can solve the puzzle in multiple ways.
  /// 
  /// For example:
  /// - A column with a selected tile, an unselected tile, and another selected tile would be represented as [1, 1].
  /// - A column with two selected tiles, an unselected tile, and another selected tile would be represented as [2, 1].
  /// - A column with an unselected tile, a selected tile, and another unselected tile would be represented as [1].
  final List<List<int>> columns;

  /// List of groups of selected tiles for each row.
  /// 
  /// See [columns] for more information.
  final List<List<int>> rows;

  String labelColumn(int x) => columns[x].join('\n');
  String labelRow(int y) => rows[y].join(' ');

  const BoardLabels._({
    required this.columns,
    required this.rows,
  });
  factory BoardLabels.fromBoardState(BoardState boardState, int width, int height) {
    final List<List<int>> columns = List.generate(width, (_) => [0]);
    final List<List<int>> rows = List.generate(height, (_) => [0]);

    for (int y = 0; y < height; ++y) {
      for (int x = 0; x < width; ++x) {
        final tileState = boardState[y][x];
        
        if (columns[x].last != 0 && !tileState.selected) {
          // Tile not selected so break column's previous group
          columns[x].add(0);
        } else if (tileState.selected) {
          // Add 1 to column's last group
          columns[x].last += 1;
        }

        if (rows[y].last != 0 && !tileState.selected) {
          // Tile not selected so break row's previous group
          rows[y].add(0);
        } else if (tileState.selected) {
          // Add 1 to row's last group
          rows[y].last += 1;
        }
      }
    }

    return BoardLabels._(
      columns: columns.map((column) => column.where((group) => group != 0).toList()).toList(),
      rows: rows.map((row) => row.where((group) => group != 0).toList()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! BoardLabels) return false;
    
    for (int r = 0; r < rows.length; ++r) {
      if (!listEquals(rows[r], other.rows[r])) {
        return false;
      }
    }
    for (int c = 0; c < columns.length; ++c) {
      if (!listEquals(columns[c], other.columns[c])) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(columns, rows);

  static BoardLabelStatus statusOfRow(int y, BoardLabels answer, BoardLabels currentAnswers) {
    final List<int> answerRow = answer.rows[y];
    final List<int> currentRow = currentAnswers.rows[y];
    return BoardLabelStatus.fromGroups(answerRow, currentRow);
  }
  static BoardLabelStatus statusOfColumn(int x, BoardLabels answer, BoardLabels currentAnswers) {
    final List<int> answerColumn = answer.columns[x];
    final List<int> currentColumn = currentAnswers.columns[x];
    return BoardLabelStatus.fromGroups(answerColumn, currentColumn);
  }
}

enum BoardLabelStatus {
  /// This row/column is definitely correct.
  correct,
  /// This row/column is definitely incorrect.
  incorrect,
  /// This row/column is neither definitely correct nor definitely incorrect.
  incomplete;

  @visibleForTesting
  static BoardLabelStatus fromGroups(List<int> answer, List<int> current) {
    if (answer.join(' ') == current.join(' ')) {
      return BoardLabelStatus.correct;
    }

    if (current.length == answer.length) {
      // Same number of groups,
      // so if a group of [current] is bigger than the corresponding group of [answer],
      // then it is definitely incorrect.
      for (int i = 0; i < current.length; ++i) {
        if (current[i] > answer[i]) {
          return BoardLabelStatus.incorrect;
        }
      }
    } else if (current.length > answer.length) {
      // More groups than answer, so check sum of groups
      final answerSum = answer.isEmpty
        ? 0
        : answer.reduce((sum, group) => sum + group + 1); // +1 for space between groups
      final currentSum = current.reduce((sum, group) => sum + group + 1);

      if (currentSum > answerSum) {
        return BoardLabelStatus.incorrect;
      }
    } else {
      // Less groups than answer, so compare each group of [current]
      // to the following groups of [answer].
      for (int i = 0; i < current.length; ++i) {
        // Check if group is bigger than the sum of [answer].
        if (current[i] > answer.skip(i).reduce((sum, group) => sum + group + 1)) {
          return BoardLabelStatus.incorrect;
        }
        // Check if group is bigger than the max of [answer].
        if (current[i] > answer.skip(i).reduce(max)) {
          return BoardLabelStatus.incorrect;
        }
      }
    }

    return BoardLabelStatus.incomplete;
  }
}
