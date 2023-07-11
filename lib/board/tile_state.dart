import 'package:flutter/material.dart';

class TileState extends ChangeNotifier {
  bool selected = false;
  bool crossed = false;

  /// Removes the @protected annotation from [notifyListeners] so that it can
  /// be called from outside this class.
  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  TileState clone() => TileState()
      ..selected = selected
      ..crossed = crossed;

  void copyFrom(TileState other) {
    selected = other.selected;
    crossed = other.crossed;
  }
}
