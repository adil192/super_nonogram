import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

/// Utility class for reading and writing ngb (NonoGram Board) files,
/// which represent [BoardState]s.
abstract class Ngb {
  static BoardState readNgb(String ngbContents) {
    final lines = ngbContents.split('\n');

    final int width, height;
    if (jsonDecode(lines[0]) !case [int w, int h]) {
      width = w;
      height = h;
    } else {
      throw Exception('Invalid ngb file: Size not specified in first line');
    }

    final BoardState board = List.generate(
      height,
      (_) => List.generate(
        width,
        (_) => ValueNotifier(TileState.empty),
      ),
    );

    for (int y = 0; y < height; y++) {
      final line = lines[y + 1];
      for (int x = 0; x < width; x++) {
        final char = line[x];
        if (char == '1') {
          board[y][x].value = TileState.selected;
        } else {
          board[y][x].value = TileState.empty;
        }
      }
    }

    return board;
  }
  
  static String writeNgb(BoardState board) {
    final width = board[0].length;
    final height = board.length;

    final sb = StringBuffer();
    sb.writeln(jsonEncode([width, height]));
    for (int y = 0; y < height; y++) {
      final line = StringBuffer();
      for (int x = 0; x < width; x++) {
        final selected = board[y][x].value == TileState.selected;
        line.write(selected ? '1' : '-');
      }
      sb.writeln(line);
    }

    return sb.toString();
  }
}
