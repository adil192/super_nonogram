import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/api/level_to_board.dart';

void main() {
  group('P values of randomized boards', () {
    test('pValueAtLevel(1) = 0.9', () {
      expect(LevelToBoard.pValueAtLevel(1), 0.9);
    });
    test('pValueAtLevel(infinity) = 0.4', () {
      expect(LevelToBoard.pValueAtLevel(1000000), closeTo(0.4, 0.01));
    });
    test('pValueAtLevel(2) = 0.87', () {
      expect(LevelToBoard.pValueAtLevel(2), closeTo(0.87, 0.01));
    });
    test('pValueAtLevel(3) = 0.80', () {
      expect(LevelToBoard.pValueAtLevel(3), closeTo(0.80, 0.01));
    });
    test('pValueAtLevel(10) = 0.57', () {
      expect(LevelToBoard.pValueAtLevel(10), closeTo(0.57, 0.01));
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
