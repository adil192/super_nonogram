import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FileManager {
  static SharedPreferences? _prefs;
  static Directory? _documentsDir;
  static const String _documentsSubDir = '/nonogram';

  static Future<void> writeFile(String path, String contents) async {
    assert(path.startsWith('/'));
    assert(path.endsWith('.ngb'));

    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(path, contents);
    } else {
      _documentsDir ??= await getApplicationDocumentsDirectory();
      final file = File('${_documentsDir!.path}$_documentsSubDir$path');
      await file.create(recursive: true);
      await file.writeAsString(contents);
    }
  }

  static Future<String> readFile(String path) async {
    assert(path.startsWith('/'));
    assert(path.endsWith('.ngb'));

    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getString(path)!;
    } else {
      _documentsDir ??= await getApplicationDocumentsDirectory();
      final file = File('${_documentsDir!.path}$_documentsSubDir$path');
      return await file.readAsString();
    }
  }

  static Future<bool> doesFileExist(String path) async {
    assert(path.startsWith('/'));
    assert(path.endsWith('.ngb'));

    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.containsKey(path);
    } else {
      _documentsDir ??= await getApplicationDocumentsDirectory();
      final file = File('${_documentsDir!.path}$_documentsSubDir$path');
      return file.existsSync();
    }
  }
}
