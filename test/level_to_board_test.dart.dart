import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/api/level_to_board.dart';

void main() {
  group('P values of randomized boards', () {
    test('pValueAtLevel(1) = 0.5', () {
      expect(LevelToBoard.pValueAtLevel(1), 0.5);
    });
    test('pValueAtLevel(infinity) = 0.2', () {
      expect(LevelToBoard.pValueAtLevel(1000000), closeTo(0.2, 0.01));
    });
    test('pValueAtLevel(2) = 0.48', () {
      expect(LevelToBoard.pValueAtLevel(2), closeTo(0.48, 0.01));
    });
    test('pValueAtLevel(3) = 0.45', () {
      expect(LevelToBoard.pValueAtLevel(3), closeTo(0.45, 0.01));
    });
    test('pValueAtLevel(10) = 0.3', () {
      expect(LevelToBoard.pValueAtLevel(10), closeTo(0.3, 0.01));
    });
  });

  group('Size of randomized boards', () {
    test('sizeAtLevel(1-4) = 5', () {
      for (var i = 1; i <= 4; i++) {
        expect(LevelToBoard.sizeAtLevel(i), 5);
      }
    });
    test('sizeAtLevel(5-9) = 6', () {
      for (var i = 5; i <= 9; i++) {
        expect(LevelToBoard.sizeAtLevel(i), 6);
      }
    });
    test('sizeAtLevel(10-14) = 7', () {
      for (var i = 10; i <= 14; i++) {
        expect(LevelToBoard.sizeAtLevel(i), 7);
      }
    });
    test('sizeAtLevel(15-19) = 8', () {
      for (var i = 15; i <= 19; i++) {
        expect(LevelToBoard.sizeAtLevel(i), 8);
      }
    });
  });
}
