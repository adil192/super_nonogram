import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_nonogram/api/web_file_image.dart';

abstract class FileManager {
  static SharedPreferences? _prefs;
  static Directory? _documentsDir;
  static const String _documentsSubDir = '/nonogram';

  static Future<void> writeFile(String path,
      {String? string, Uint8List? bytes}) async {
    assert(path.startsWith('/'));
    if (string != null) {
      assert(path.endsWith('.ngb') || path.endsWith('.json'));
    } else if (bytes != null) {
      assert(path.endsWith('.png'));
    } else {
      assert(false,
          'FileManager.writeFile: At least one of string or bytes must be provided');
    }

    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      if (string != null) {
        await _prefs!.setString(path, string);
      } else if (bytes != null) {
        await _prefs!.setString(path, base64Encode(bytes));
      }
    } else {
      _documentsDir ??= await getApplicationSupportDirectory();
      final file = File('${_documentsDir!.path}$_documentsSubDir$path');
      await file.create(recursive: true);
      if (string != null) {
        await file.writeAsString(string);
      } else if (bytes != null) {
        await file.writeAsBytes(bytes);
      }
    }
  }

  static Future<T?> readFile<T>(String path) async {
    assert(path.startsWith('/'));
    if (T == String) {
      assert(path.endsWith('.ngb') || path.endsWith('.json'));
    } else if (T == Uint8List) {
      assert(path.endsWith('.png'));
    } else {
      assert(false,
          'FileManager.readFile: T ($T) must be either String or Uint8List');
    }

    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      final string = _prefs!.getString(path);
      if (string == null) return null;
      if (T == Uint8List) {
        return base64Decode(string) as T;
      } else {
        return string as T;
      }
    } else {
      _documentsDir ??= await getApplicationSupportDirectory();
      final file = File('${_documentsDir!.path}$_documentsSubDir$path');
      if (!file.existsSync()) return null;
      if (T == Uint8List) {
        return await file.readAsBytes() as T;
      } else {
        return await file.readAsString() as T;
      }
    }
  }

  static Future<bool> doesFileExist(String path) async {
    assert(path.startsWith('/'));
    assert(path.endsWith('.ngb'));

    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.containsKey(path);
    } else {
      _documentsDir ??= await getApplicationSupportDirectory();
      final file = File('${_documentsDir!.path}$_documentsSubDir$path');
      return file.existsSync();
    }
  }

  /// Returns a list of the saved puzzle prompts,
  /// sorted alphabetically.
  static Future<List<String>> listPuzzles() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!
          .getKeys()
          .where((key) => key.endsWith('.ngb'))
          .map((filePath) => filePath.substring(filePath.lastIndexOf('/') + 1))
          .map((fileName) => fileName.substring(0, fileName.lastIndexOf('.')))
          .toList()
        ..sort();
    } else {
      _documentsDir ??= await getApplicationSupportDirectory();
      final dir = Directory('${_documentsDir!.path}$_documentsSubDir');
      if (!dir.existsSync()) return [];

      return dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.ngb'))
          .map((file) => file.path.substring(file.path.lastIndexOf('/') + 1))
          .map((fileName) => fileName.substring(0, fileName.lastIndexOf('.')))
          .toList()
        ..sort();
    }
  }

  /// Returns an ImageProvider for the saved puzzle image.
  ///
  /// This doesn't check if the image exists.
  static FileImage getPuzzleImage(String baseFilename) {
    final path = '/$baseFilename.png';

    if (kIsWeb) return WebFileImage(path);

    if (_documentsDir == null) {
      if (kDebugMode) {
        print('Warning: FileManager.getPuzzleImage: _documentsDir is null');
      }
      return WebFileImage(path);
    }

    final file = File('${_documentsDir!.path}$_documentsSubDir$path');
    return FileImage(file);
  }
}
