import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stow_plain/stow_plain.dart';

final stows = Stows();

@visibleForTesting
class Stows {
  final currentLevel = PlainStow('currentLevel', 1);
  final hyperlegibleFont = PlainStow('hyperlegibleFont', false);
}
