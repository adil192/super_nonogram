import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:super_nonogram/api/file_manager.dart';

// Method signature for _loadAsync decode callbacks.
typedef _SimpleDecoderCallback = Future<ui.Codec> Function(
    ui.ImmutableBuffer buffer);

/// A [FileImage] that uses `FileManager.readFile(file.path)`
/// instead of `file.readAsBytes()`,
/// for compatibility with the web.
///
/// This also works on non-web platforms, though a regular [FileImage]
/// would be more efficient.
/// Just remember the path should be a valid input to FileManager.readFile,
/// not the actual file path on disk.
class WebFileImage extends FileImage {
  WebFileImage(String path) : super(File(path));

  @override
  ImageStreamCompleter loadBuffer(
    FileImage key,
    // ignore: deprecated_member_use
    DecoderBufferCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: key.file.path,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  @override
  @protected
  ImageStreamCompleter loadImage(FileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: key.file.path,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    FileImage key, {
    required _SimpleDecoderCallback decode,
  }) async {
    assert(key == this);
    final bytes = await FileManager.readFile<Uint8List>(file.path);
    if (bytes == null || bytes.isEmpty) {
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }
}
