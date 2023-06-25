import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/api/image_to_board.dart';
import 'package:super_nonogram/board/board_labels.dart';

void main() {
  test('USB image to board', () async {
    final file = File('test/test_assets/usb.png');
    final bytes = await file.readAsBytes();

    final boardState = await ImageToBoard.importFromBytes(bytes, 8);
    expect(boardState, isNotNull);
    expect(boardState!.length, 8);
    expect(boardState[0].length, 8);

    const expectedColumnLabels = [
      [8],
      [1, 2],
      [1, 1, 2],
      [1, 2],
      [1, 2],
      [1, 1, 2],
      [1, 2],
      [8],
    ];
    const expectedRowLabels = [
      [8],
      [1, 1],
      [1, 1],
      [1, 1],
      [1, 1, 1, 1],
      [1, 1],
      [8],
      [8],
    ];

    final labels = BoardLabels.fromBoardState(boardState, 8, 8);
    for (int i = 0; i < 8; i++) {
      printOnFailure('Testing column/row $i');
      expect(labels.columns[i], expectedColumnLabels[i]);
      expect(labels.rows[i], expectedRowLabels[i]);
    }
  });
}
