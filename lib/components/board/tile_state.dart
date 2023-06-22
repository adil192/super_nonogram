import 'package:flutter/material.dart';

class TileState extends ChangeNotifier {
  bool selected = false;

  /// Removes the @protected annotation from [notifyListeners] so that it can
  /// be called from outside this class.
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
