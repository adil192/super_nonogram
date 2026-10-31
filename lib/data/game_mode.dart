sealed class GameMode {
  const GameMode();

  String get descriptor;
}

class LevelGameMode extends GameMode {
  final int level;
  const LevelGameMode(this.level)
    : assert(level > 0, 'Level must be greater than 0');

  @override
  String get descriptor => 'level:$level';
}

class ClassicGameMode extends GameMode {
  const ClassicGameMode(this.seed);
  final int seed;

  @override
  String get descriptor => 'classic:$seed';
}

class ImageGameMode extends GameMode {
  const ImageGameMode(this.query)
    : assert(query != '', 'Query must be non-empty');
  final String query;

  @override
  String get descriptor => 'image:$query';
}
