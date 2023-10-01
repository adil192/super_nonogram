
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

abstract class ImageToBoard {
  static const minSelectedRatio = 0.2;

  /// The first row and column of the resized image are ignored
  /// since they're always empty.
  static Future<BoardState?> importFromBytes(Uint8List bytes, [int width = 14]) async {
    var cmd = img.Command()
      ..decodeImage(bytes)
      ..copyResize(width: width + 1, interpolation: img.Interpolation.cubic);
    await cmd.executeThread();

    final image = cmd.outputImage!;

    final BoardState board = List.generate(
      image.height - 1,
      (_) => List.generate(
        image.width - 1,
        (_) => ValueNotifier(TileState.empty),
      ),
    );

    int selectedTiles = 0;
    for (final pixel in image) {
      if (pixel.x == 0 || pixel.y == 0) continue; // ignore first row and column (always empty)
      final selected = pixel.aNormalized > 0.5;
      if (!selected) continue;
      board[pixel.y - 1][pixel.x - 1].value = TileState.selected;
      selectedTiles++;
    }

    final totalTiles = (image.width - 1) * (image.height - 1);
    if (selectedTiles < totalTiles * minSelectedRatio) {
      if (kDebugMode) print('ImageToBoard: too few tiles selected, try another image');
      return null;
    } else if (selectedTiles > totalTiles * (1 - minSelectedRatio)) {
      if (kDebugMode) print('ImageToBoard: too many tiles selected, try another image');
      return null;
    }

    return board;
  }
}
