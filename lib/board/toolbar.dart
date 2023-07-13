import 'package:flutter/material.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile.dart';
import 'package:super_nonogram/board/tile_state.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.currentTileAction,
    required this.setTileAction,
  });

  final TileState currentTileAction;
  final ValueSetter<TileState> setTileAction;

  static const _iconSize = Board.tileSize * 0.5;
  static const _unselectedIconSizeRatio = 0.6;
  static const _tileActions = [TileState.selected, TileState.crossed];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final tileAction in _tileActions)
          IconButton(
            onPressed: () => setTileAction(tileAction),
            icon: AnimatedScale(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeIn,
              scale: currentTileAction == tileAction ? 1 : _unselectedIconSizeRatio,
              child: SizedBox(
                width: _iconSize,
                height: _iconSize,
                child: Tile(
                  tileState: tileAction,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
