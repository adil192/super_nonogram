import 'dart:math';

import 'package:flutter/material.dart';
import 'package:super_nonogram/components/board/tile.dart';
import 'package:super_nonogram/components/board/tile_state.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  static const width = 10;
  static const height = 10;

  static final List<List<ValueNotifier<TileState>>> board = List.generate(
    height,
    (_) => List.generate(
      width,
      (_) => ValueNotifier(TileState()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: 50.0 * width,
        height: 50.0 * height,
        child: GridView.builder(
          itemCount: width * height,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final int x = index % width;
            final int y = index ~/ width;
            return ValueListenableBuilder(
              valueListenable: board[y][x],
              builder: (context, tileState, child) {
                return Tile(
                  tileState: tileState,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
