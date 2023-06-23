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

  String labelColumn(int x) => columns[x].join('');
  String labelRow(int y) => rows[y].join('');

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
}
