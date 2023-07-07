import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/board/board_labels.dart';

void main() {
  group('Board label status:', () {
    test('empty answer, empty current', () {
      final status = BoardLabelStatus.fromGroups([], []);
      expect(status, BoardLabelStatus.correct);
    });
    test('empty answer, non-empty current', () {
      final status = BoardLabelStatus.fromGroups([], [1]);
      expect(status, BoardLabelStatus.incorrect);
    });
    test('non-empty answer, empty current', () {
      final status = BoardLabelStatus.fromGroups([1], []);
      expect(status, BoardLabelStatus.incomplete);
    });
    test('same length, correct', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 1], [1, 1, 1]);
      expect(status, BoardLabelStatus.correct);
    });
    test('same length, incorrect', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 1], [1, 1, 2]);
      expect(status, BoardLabelStatus.incorrect);
    });
    test('same length, incomplete', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 2], [1, 1, 1]);
      expect(status, BoardLabelStatus.incomplete);
    });
    test('longer than answer, incorrect', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 1], [1, 1, 1, 1]);
      expect(status, BoardLabelStatus.incorrect);
    });
    test('longer than answer, incorrect', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 2], [1, 1, 1, 1]);
      expect(status, BoardLabelStatus.incorrect);
    });
    test('longer than answer, incomplete', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 3], [1, 1, 1, 1]);
      expect(status, BoardLabelStatus.incomplete);
    });
    test('shorter than answer, incorrect', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 1], [1, 3]);
      expect(status, BoardLabelStatus.incorrect);
    });
    test('shorter than answer, incorrect', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 1], [1, 2]);
      expect(status, BoardLabelStatus.incorrect);
    });
    test('shorter than answer, incomplete', () {
      final status = BoardLabelStatus.fromGroups([1, 1, 1], [1, 1]);
      expect(status, BoardLabelStatus.incomplete);
    });
  });
}
