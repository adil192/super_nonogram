import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile.dart';

class BoardGridUnlabelledRenderObjectWidget extends LeafRenderObjectWidget {
  const BoardGridUnlabelledRenderObjectWidget({
    super.key,
    required this.width,
    required this.height,
    required this.board,
  });

  final int width;
  final int height;
  final BoardState board;

  @override
  BoardGridUnlabelledRenderObject createRenderObject(BuildContext context) {
    return BoardGridUnlabelledRenderObject(
      width: width,
      height: height,
      board: board,
      colorScheme: ColorScheme.of(context),
      onOffSwitchLabels: MediaQuery.onOffSwitchLabelsOf(context),
      highContrast: MediaQuery.highContrastOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    BoardGridUnlabelledRenderObject renderObject,
  ) {
    renderObject
      ..width = width
      ..height = height
      ..board = board
      ..colorScheme = ColorScheme.of(context)
      ..onOffSwitchLabels = MediaQuery.onOffSwitchLabelsOf(context)
      ..highContrast = MediaQuery.highContrastOf(context);
  }
}

class BoardGridUnlabelledRenderObject extends RenderBox {
  BoardGridUnlabelledRenderObject({
    required int width,
    required int height,
    required BoardState board,
    required ColorScheme colorScheme,
    required bool onOffSwitchLabels,
    required bool highContrast,
  }) : _width = width,
       _height = height,
       _board = board,
       _colorScheme = colorScheme,
       _onOffSwitchLabels = onOffSwitchLabels,
       _highContrast = highContrast {
    _listenToTiles();
  }

  int get width => _width;
  int _width;
  set width(int width) {
    if (_width == width) return;
    _width = width;
    markNeedsLayout();
  }

  int get height => _height;
  int _height;
  set height(int height) {
    if (_height == height) return;
    _height = height;
    markNeedsLayout();
  }

  BoardState get board => _board;
  BoardState _board;
  set board(BoardState board) {
    if (_board == board) return;
    _board = board;
    markNeedsPaint();
    _listenToTiles();
  }

  ColorScheme get colorScheme => _colorScheme;
  ColorScheme _colorScheme;
  set colorScheme(ColorScheme colorScheme) {
    if (_colorScheme == colorScheme) return;
    _colorScheme = colorScheme;
    markNeedsPaint();
  }

  bool get onOffSwitchLabels => _onOffSwitchLabels;
  bool _onOffSwitchLabels;
  set onOffSwitchLabels(bool onOffSwitchLabels) {
    if (_onOffSwitchLabels == onOffSwitchLabels) return;
    _onOffSwitchLabels = onOffSwitchLabels;
    markNeedsPaint();
  }

  bool get highContrast => _highContrast;
  bool _highContrast;
  set highContrast(bool highContrast) {
    if (_highContrast == highContrast) return;
    _highContrast = highContrast;
    markNeedsPaint();
  }

  late double _tileSize;
  Listenable? _tilesListener;

  void _listenToTiles() {
    _tilesListener?.removeListener(markNeedsPaint);
    _tilesListener = Listenable.merge([
      for (var row in board) ...[for (var tile in row) tile],
    ])..addListener(markNeedsPaint);
  }

  @override
  bool get sizedByParent => true;
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;
  @override
  void performLayout() {
    final size = computeDryLayout(constraints);
    final tileWidth = size.width / width;
    final tileHeight = size.height / height;
    assert(
      (tileWidth / tileHeight - 1).abs() < 0.01,
      'Tiles must be square in BoardGridUnlabelledRenderObject',
    );
    _tileSize = tileWidth;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final spacing = _tileSize * 0.1;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final tileState = board[y][x].value;
        final tileOffset = Offset(
          offset.dx + x * _tileSize + spacing,
          offset.dy + y * _tileSize + spacing,
        );
        final tileRect =
            tileOffset & Size(_tileSize - spacing, _tileSize - spacing);
        TilePainter.paintTile(
          tileState,
          canvas: context.canvas,
          tileRect: tileRect,
          colorScheme: colorScheme,
          onOffSwitchLabels: onOffSwitchLabels,
          highContrast: highContrast,
          inCenterOfBoard: _isInCenter(x, width) || _isInCenter(y, height),
        );
      }
    }
  }

  @override
  void dispose() {
    _tilesListener?.removeListener(markNeedsPaint);
    super.dispose();
  }

  bool _isInCenter(int index, int total) {
    final middle = total ~/ 2;
    if (total.isOdd) {
      return index == middle;
    } else {
      return index == middle || index == middle - 1;
    }
  }
}
