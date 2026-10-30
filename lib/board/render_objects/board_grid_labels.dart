import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/board/board_labels.dart';

/// A widget that lays out the board grid along with its labels.
///
/// The labels are drawn internally, but the tiles are expected to be provided
/// as its [child].
class BoardGridLabelsRenderObjectWidget extends SingleChildRenderObjectWidget {
  const BoardGridLabelsRenderObjectWidget({
    super.key,
    required this.answer,
    required this.currentAnswers,
    required this.textDirection,
    required this.textStyle,
    super.child,
  });

  final BoardLabels answer;
  final BoardLabels currentAnswers;
  final TextDirection textDirection;
  final TextStyle textStyle;

  @override
  BoardGridLabelsRenderObject createRenderObject(BuildContext context) {
    return BoardGridLabelsRenderObject(
      answer: answer,
      currentAnswers: currentAnswers,
      textStyle: textStyle,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    BoardGridLabelsRenderObject renderObject,
  ) {
    renderObject
      ..answer = answer
      ..currentAnswers = currentAnswers
      ..textStyle = textStyle
      ..textDirection = textDirection;
  }
}

/// A render object that lays out the board grid along with its labels.
///
/// The labels are drawn internally, but the tiles are expected to be provided
/// as its [child].
class BoardGridLabelsRenderObject extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  BoardGridLabelsRenderObject({
    required BoardLabels answer,
    required BoardLabels currentAnswers,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) : _answer = answer,
       _currentAnswers = currentAnswers,
       _textStyle = textStyle {
    _generateTextPainters();
  }

  BoardLabels get answer => _answer;
  BoardLabels _answer;
  set answer(BoardLabels answer) {
    if (_answer == answer) return;
    final changedSize =
        _answer.columns.length != answer.columns.length ||
        _answer.rows.length != answer.rows.length;
    _answer = answer;
    if (changedSize) {
      _generateTextPainters();
    } else {
      _updateTextPainters();
    }
  }

  BoardLabels get currentAnswers => _currentAnswers;
  BoardLabels _currentAnswers;
  set currentAnswers(BoardLabels currentAnswers) {
    if (_currentAnswers == currentAnswers) return;
    _currentAnswers = currentAnswers;
    _updateTextPainters(); // Updates color based on correctness
  }

  TextStyle get textStyle => _textStyle;
  TextStyle _textStyle;
  set textStyle(TextStyle textStyle) {
    if (_textStyle == textStyle) return;
    final sizeChanged = _textStyle.fontSize != textStyle.fontSize;
    _textStyle = textStyle;
    _updateTextPainters();
    if (sizeChanged) markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection = TextDirection.ltr;
  set textDirection(TextDirection textDirection) {
    if (_textDirection == textDirection) return;
    _textDirection = textDirection;
    _updateTextPainters();
  }

  List<TextPainter> _columnLabelPainters = const [];
  List<TextPainter> _rowLabelPainters = const [];
  late double _colLabelHeight;
  late double _rowLabelWidth;
  late double _tileSize;
  late double _rowLabelSpacing;

  int get boardWidth => currentAnswers.columns.length;
  int get boardHeight => currentAnswers.rows.length;

  @override
  void dispose() {
    for (final painter in _columnLabelPainters) {
      painter.dispose();
    }
    for (final painter in _rowLabelPainters) {
      painter.dispose();
    }
    super.dispose();
  }

  void _generateTextPainters() {
    // Font sizes are already as big as possible to fit within the tile size.
    // We use [TextScaler.noScaling] to not scale further.
    _columnLabelPainters = List.generate(
      boardWidth,
      (_) => TextPainter(textAlign: .center, textScaler: .noScaling),
      growable: false,
    );
    _rowLabelPainters = List.generate(
      boardHeight,
      (_) => TextPainter(textAlign: .end, textScaler: .noScaling),
      growable: false,
    );
    _updateTextPainters();
  }

  /// Updates the text and style of all text painters.
  /// Internally calls [markNeedsLayout] if needed, otherwise [markNeedsPaint].
  void _updateTextPainters() {
    var changedText = false;

    for (var x = 0; x < boardWidth; x++) {
      final painter = _columnLabelPainters[x];
      final newLabel = answer.labelColumn(x);
      changedText |= (painter.text as TextSpan?)?.text != newLabel;
      _updateTextPainterExplicitly(
        painter,
        newLabel,
        BoardLabels.statusOfCol(x, answer, currentAnswers),
      );
    }
    for (var y = 0; y < boardHeight; y++) {
      final painter = _rowLabelPainters[y];
      final newLabel = answer.labelRow(y);
      changedText |= (painter.text as TextSpan?)?.text != newLabel;
      _updateTextPainterExplicitly(
        painter,
        newLabel,
        BoardLabels.statusOfRow(y, answer, currentAnswers),
      );
    }

    if (changedText) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
  }

  /// Updates a single text painter's style.
  /// Call [_updateTextPainters] instead of using this method directly.
  void _updateTextPainterExplicitly(
    TextPainter painter,
    String label,
    BoardLabelStatus status,
  ) {
    painter.text = TextSpan(
      text: label,
      style: textStyle.copyWith(
        height: 1.1,
        color: switch (status) {
          .correct => Colors.transparent,
          .incorrect => Colors.red,
          .incomplete => null,
        },
      ),
    );
    painter.textDirection = textDirection;
  }

  @override
  void performLayout() {
    _rowLabelSpacing = _textStyle.fontSize! * 0.2;

    // Find the max width of the row labels
    double maxRowLabelsWidth = 0;
    for (var y = 0; y < _rowLabelPainters.length; y++) {
      final painter = _rowLabelPainters[y];
      painter.layout(maxWidth: constraints.maxWidth * 0.5);
      maxRowLabelsWidth = max(maxRowLabelsWidth, painter.width);
    }
    maxRowLabelsWidth += _rowLabelSpacing;
    _rowLabelWidth = maxRowLabelsWidth;

    // Find the max height of the column labels
    double maxColumnLabelsHeight = 0;
    for (var x = 0; x < _columnLabelPainters.length; x++) {
      final painter = _columnLabelPainters[x];
      painter.layout(maxWidth: double.infinity); // prevent wrapping mid-number
      maxColumnLabelsHeight = max(maxColumnLabelsHeight, painter.height);
    }
    _colLabelHeight = maxColumnLabelsHeight;

    // Calculate tile size (must be square)
    final maxPossibleTileWidth =
        (constraints.maxWidth - maxRowLabelsWidth) / boardWidth;
    final maxPossibleTileHeight =
        (constraints.maxHeight - maxColumnLabelsHeight) / boardHeight;
    final tileSize = min(
      128.0, // Avoid excessively large tiles
      min(maxPossibleTileWidth, maxPossibleTileHeight),
    );
    _tileSize = tileSize;

    // Set the size of the render box
    size = constraints.constrain(
      Size(
        maxRowLabelsWidth + tileSize * boardWidth,
        maxColumnLabelsHeight + tileSize * boardHeight,
      ),
    );

    // Layout child
    if (child != null) {
      child!.layout(
        BoxConstraints.tight(
          Size(tileSize * boardWidth, tileSize * boardHeight),
        ),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var x = 0; x < _columnLabelPainters.length; x++) {
      final painter = _columnLabelPainters[x];
      painter.paint(
        context.canvas,
        Offset(
          offset.dx +
              _rowLabelWidth +
              x * _tileSize +
              (_tileSize - painter.width) / 2,
          offset.dy + (_colLabelHeight - painter.height),
        ),
      );
    }

    for (var y = 0; y < _rowLabelPainters.length; y++) {
      final painter = _rowLabelPainters[y];
      painter.paint(
        context.canvas,
        Offset(
          offset.dx + (_rowLabelWidth - _rowLabelSpacing - painter.width),
          offset.dy +
              _colLabelHeight +
              y * _tileSize +
              (_tileSize - painter.height) / 2,
        ),
      );
    }

    if (child != null) {
      context.paintChild(
        child!,
        Offset(offset.dx + _rowLabelWidth, offset.dy + _colLabelHeight),
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final topLeft = Offset(_rowLabelWidth, _colLabelHeight);
    if (position.dx < topLeft.dx || position.dy < topLeft.dy) {
      return false;
    }
    return result.addWithPaintOffset(
      offset: topLeft,
      position: position,
      hitTest: (childHitTestResult, transformed) {
        return child!.hitTest(childHitTestResult, position: transformed);
      },
    );
  }
}
