import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/tile_state.dart';

void main() {
  group('BoardLabels:', () {
    const height = 5;
    const width = 5;

    test('empty board', () {
      final BoardState boardState = List.generate(
        height,
        (_) => List.generate(
          width,
          (_) => ValueNotifier(TileState.empty),
        ),
      );

      final labels = BoardLabels.fromBoardState(boardState, width, height);

      for (List<int> column in labels.columns) {
        expect(column, isEmpty);
      }
      for (List<int> row in labels.rows) {
        expect(row, isEmpty);
      }
    });

    test('full board', () {
      final BoardState boardState = List.generate(
        height,
        (_) => List.generate(
          width,
          (_) => ValueNotifier(TileState.selected),
        ),
      );

      final labels = BoardLabels.fromBoardState(boardState, width, height);

      for (List<int> column in labels.columns) {
        expect(column, hasLength(1));
        expect(column.first, equals(height));
      }
      for (List<int> row in labels.rows) {
        expect(row, hasLength(1));
        expect(row.first, equals(width));
      }
    });

    test('1 1 1', () {
      final BoardState boardState = List.generate(
        height,
        (_) => List.generate(
          width,
          (_) => ValueNotifier(TileState.empty),
        ),
      );

      for (int x = 0; x < width; ++x) {
        if (x.isOdd) continue;
        boardState[0][x].value = TileState.selected;
      }

      final labels = BoardLabels.fromBoardState(boardState, width, height);

      expect(labels.rows[0], equals([1, 1, 1]));
      expect(labels.labelRow(0), '1 1 1');
      for (int y = 1; y < height; ++y) {
        expect(labels.rows[y], isEmpty);
        expect(labels.labelRow(y), '');
      }

      for (int x = 0; x < width; ++x) {
        if (x.isEven) {
          expect(labels.columns[x], equals([1]));
          expect(labels.labelColumn(x), '1');
        } else {
          expect(labels.columns[x], isEmpty);
          expect(labels.labelColumn(x), '');
        }
      }
    });
  });
}
