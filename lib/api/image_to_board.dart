import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:super_nonogram/board/board.dart';
import 'package:super_nonogram/board/tile_state.dart';

abstract class ImageToBoard {
  static Future<BoardState> importFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return await importFromBytes(response.bodyBytes);
    } else {
      throw Exception('Pixabay image download error: ${response.statusCode}');
    }
  }

  // todo: make this async
  static Future<BoardState> importFromBytes(Uint8List bytes, [int width = 20]) async {
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
    
    for (final pixel in image) {
      board[pixel.y][pixel.x].selected = pixel.luminance == 0;
    }

    return board;
  }
}
