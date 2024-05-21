import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/board_labels.dart';
import 'package:super_nonogram/board/tile.dart';

class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.width,
    required this.height,
    required this.answer,
    required this.currentAnswers,
    required this.board,
    required this.colLabelLineHeight,
    required this.columnLabelsHeight,
  });

  final int width;
  final int height;
  final BoardLabels answer;
  final ValueNotifier<BoardLabels> currentAnswers;
  final BoardState board;

  final double colLabelLineHeight;
  final double columnLabelsHeight;

  @override
  Widget build(BuildContext context) {
    return AlignedGridView.count(
      itemCount: width * height + width + height + 1,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: width + 1,
      itemBuilder: (context, index) {
        final int x = index % (width + 1) - 1;
        final int y = index ~/ (width + 1) - 1;
        late final colorScheme = Theme.of(context).colorScheme;
        return switch ((x, y)) {
          (-1, -1) => const SizedBox(),
          (-1, _) => Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder(
                valueListenable: currentAnswers,
                builder: (context, _, child) {
                  final status =
                      BoardLabels.statusOfRow(y, answer, currentAnswers.value);
                  return AnimatedOpacity(
                    opacity: switch (status) {
                      BoardLabelStatus.correct => 0,
                      _ => 1,
                    },
                    duration: const Duration(milliseconds: 500),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: Board.tileSize * 0.2,
                        color: switch (status) {
                          BoardLabelStatus.correct => colorScheme.primary,
                          BoardLabelStatus.incorrect => colorScheme.error,
                          BoardLabelStatus.incomplete =>
                            colorScheme.onBackground,
                        },
                      ),
                      child: child!,
                    ),
                  );
                },
                child: Text(
                  answer.labelRow(y),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          (_, -1) => Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                valueListenable: currentAnswers,
                builder: (context, _, child) {
                  final status = BoardLabels.statusOfColumn(
                      x, answer, currentAnswers.value);
                  return AnimatedOpacity(
                    opacity: switch (status) {
                      BoardLabelStatus.correct => 0,
                      _ => 1,
                    },
                    duration: const Duration(milliseconds: 500),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        height: colLabelLineHeight,
                        fontSize: Board.tileSize * 0.2,
                        color: switch (status) {
                          BoardLabelStatus.correct => colorScheme.primary,
                          BoardLabelStatus.incorrect => colorScheme.error,
                          BoardLabelStatus.incomplete =>
                            colorScheme.onBackground,
                        },
                      ),
                      child: child!,
                    ),
                  );
                },
                child: SizedBox(
                  height: columnLabelsHeight,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: Board.tileSpacing / 2),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        answer.labelColumn(x),
                        textAlign: TextAlign.center,
                        overflow:
                            kDebugMode ? TextOverflow.clip : TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          _ => ValueListenableBuilder(
              valueListenable: board[y][x],
              builder: (context, tileState, child) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(Board.tileSpacing / 2),
                    child: Tile(
                      tileState: tileState,
                    ),
                  ),
                );
              },
            ),
        };
      },
    );
  }
}
