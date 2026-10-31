import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/board/tile_state.dart';

const _egNgb = '''
[3,3]
1X-
X1X
--1
''';

void main() {
  group('NGB', () {
    test('read valid', () {
      const ngb = _egNgb;
      final board = _parse(ngb);
      expect(board, <List<TileState>>[
        [.selected, .crossed, .empty],
        [.crossed, .selected, .crossed],
        [.empty, .empty, .selected],
      ]);
    });

    test('read with missing preamble', () {
      const ngb = '''
1X-
X1X
--1
''';
      expect(() => _parse(ngb), throwsFormatException);
    });

    test('read with missing line', () {
      const ngb = '''
[3,3]
1X-
X1X
''';
      expect(() => _parse(ngb), throwsRangeError);
    });

    test('write', () {
      final BoardState board = [
        [.new(.selected), .new(.crossed), .new(.empty)],
        [.new(.crossed), .new(.selected), .new(.crossed)],
        [.new(.empty), .new(.empty), .new(.selected)],
      ];
      final ngb = Ngb.writeNgb(board);
      expect(ngb, _egNgb);
    });
  });
}

/// The same as [Ngb.readNgb] but without `ValueNotifier`s.
List<List<TileState>> _parse(String ngb) {
  final board = Ngb.readNgb(ngb);
  final unwrapped = <List<TileState>>[];
  for (var i = 0; i < board.length; ++i) {
    unwrapped.add(board[i].map((notifier) => notifier.value).toList());
  }
  return unwrapped;
}
