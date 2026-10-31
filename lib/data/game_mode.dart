sealed class GameMode {
  const GameMode();

  /// A unique id for this game mode,
  /// used to save and restore the game state across sessions.
  ///
  /// This must be a valid file name on all target platforms,
  /// i.e. contain no restricted characters.
  /// It should not contain a file extension.
  String get descriptor;
}

class LevelGameMode extends GameMode {
  final int level;
  const LevelGameMode(this.level)
    : assert(level > 0, 'Level must be greater than 0');

  @override
  String get descriptor => 'level_$level';
}

class ClassicGameMode extends GameMode {
  const ClassicGameMode(this.seed);
  final int seed;

  @override
  String get descriptor => 'classic_$seed';
}

class ImageGameMode extends GameMode {
  const ImageGameMode(this.query)
    : assert(query != '', 'Query must be non-empty');
  final String query;

  @override
  String get descriptor => 'image_$query';
}
