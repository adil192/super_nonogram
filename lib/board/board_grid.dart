import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/render_objects/board_grid_labels.dart';
import 'package:super_nonogram/board/render_objects/board_grid_unlabelled.dart';

/// Displays a labelled board grid with interactive tiles.
class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.width,
    required this.height,
    required this.answer,
    required this.currentAnswers,
    required this.board,
    this.overlay,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final int width;
  final int height;
  final BoardLabels answer;
  final ValueNotifier<BoardLabels> currentAnswers;
  final BoardState board;
  final Widget? overlay;
  final void Function(Coordinate) onPanStart;
  final void Function(Coordinate) onPanUpdate;
  final void Function() onPanEnd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: currentAnswers,
        builder: (context, currentAnswers, child) {
          final size = MediaQuery.sizeOf(context);
          final maxPossibleTileSize = min(
            size.width / width,
            // subtract 300 for header and footer
            max((size.height - 300), 300) / height,
          );
          final labelFontSize = min(24.0, maxPossibleTileSize * 0.7);

          return BoardGridLabelsRenderObjectWidget(
            answer: answer,
            currentAnswers: currentAnswers,
            textDirection: Directionality.of(context),
            textStyle: TextTheme.of(context).bodyLarge!.copyWith(
              fontSize: labelFontSize,
              letterSpacing: labelFontSize * -0.1,
            ),
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (overlay != null) IgnorePointer(child: overlay!),
            LayoutBuilder(
              builder: (context, constraints) {
                final gridSize = constraints.biggest;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (details) => onPanStart(
                    getCoordinateOfPosition(details.localFocalPoint, gridSize),
                  ),
                  onScaleUpdate: (details) => onPanUpdate(
                    getCoordinateOfPosition(details.localFocalPoint, gridSize),
                  ),
                  onScaleEnd: (_) => onPanEnd(),
                  child: BoardGridUnlabelledRenderObjectWidget(
                    width: width,
                    height: height,
                    board: board,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Coordinate getCoordinateOfPosition(Offset position, Size gridSize) {
    final tileSize = gridSize.width / answer.columns.length;
    final x = (position.dx / tileSize).floor();
    final y = (position.dy / tileSize).floor();
    return (x: x, y: y);
  }
}
