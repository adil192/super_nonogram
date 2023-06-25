import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

abstract class ImageToBoard {
  static const minSelectedRatio = 0.2;

  static Future<BoardState?> importFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return await importFromBytes(response.bodyBytes);
    } else {
      throw Exception('Pixabay image download error: ${response.statusCode}');
    }
  }

  // todo: make this async
  static Future<BoardState?> importFromBytes(Uint8List bytes, [int width = 20]) async {
    var cmd = img.Command()
      ..decodeImage(bytes)
      ..copyResize(width: width);
    await cmd.executeThread();

    final image = cmd.outputImage!;

    final BoardState board = List.generate(
      image.height,
      (_) => List.generate(
        width,
        (_) => TileState(),
      ),
    );
    
    int selectedTiles = 0;
    for (final pixel in image) {
      final selected = pixel.luminance == 0;
      if (selected) selectedTiles++;
      board[pixel.y][pixel.x].selected = selected;
    }

    final totalTiles = width * image.height;
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
