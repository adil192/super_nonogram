import 'package:flutter/material.dart';
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: tileState.selected ? colorScheme.primary : colorScheme.primary.withOpacity(0.3),
      ),
    );
  }
}