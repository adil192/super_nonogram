import 'package:stow_plain/stow_plain.dart';

final stows = Stows();

class Stows {
  final currentLevel = PlainStow('currentLevel', 1);

  final hyperlegibleFont = PlainStow('hyperlegibleFont', false);

  final useHapticFeedback = PlainStow('useHapticFeedback', true);

  final lastClassicGameModeSeed = PlainStow('lastClassicGameModeSeed', 1234);
}
