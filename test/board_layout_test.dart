import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/board_labels.dart';

void main() {
  group('getColumnLabelsHeight', () {
    const heightOfOneLine = Board.labelFontSize * BoardWidgetState.colLabelLineHeight;

    test('with one label group', () {
      const labels = BoardLabels.fromLists(
        columns: [[1]],
        rows: [[0]],
      );
      final height = BoardWidgetState.getColumnLabelsHeight(labels);
      expect(height, heightOfOneLine + Board.tileSpacing / 2);
    });

    test('with two label groups', () {
      const labels = BoardLabels.fromLists(
        columns: [[1, 1]],
        rows: [[0]],
      );
      final height = BoardWidgetState.getColumnLabelsHeight(labels);
      expect(height, heightOfOneLine * 2 + Board.tileSpacing / 2);
    });

    test('with 4 label groups', () {
      const labels = BoardLabels.fromLists(
        columns: [[3, 1, 1, 3]],
        rows: [[0]],
      );
      final height = BoardWidgetState.getColumnLabelsHeight(labels);
      // Addresses https://github.com/adil192/super_nonogram/issues/3
      expect(height, moreOrLessEquals(Board.tileSize, epsilon: Board.tileSize * 0.01),
          reason: 'Groups of 4 should take about 1 tile size');
    });

    test('with different label group lengths', () {
      const labels = BoardLabels.fromLists(
        columns: [[1, 1, 1], [1, 1]],
        rows: [[0]],
      );
      final height = BoardWidgetState.getColumnLabelsHeight(labels);
      expect(height, heightOfOneLine * 3 + Board.tileSpacing / 2); // longest group is of length 3
    });
  });
}
