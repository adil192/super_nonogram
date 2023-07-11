import 'package:flutter/material.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.tileState,
  });

  final TileState tileState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Board.tileSize * 0.2),
        color: switch (tileState) {
          TileState.selected => colorScheme.primary,
          TileState.crossed => colorScheme.primary.withOpacity(0.1),
          TileState.empty => colorScheme.primary.withOpacity(0.3),
        },
      ),
      child: tileState == TileState.crossed ? Center(
        child: Icon(
          Icons.close,
          color: colorScheme.onBackground.withOpacity(0.7),
          size: Board.tileSize * 0.5,
        ),
      ) : null,
    );
  }
}
