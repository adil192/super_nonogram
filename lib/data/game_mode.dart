sealed class GameMode {
  const GameMode();
}

class LevelGameMode extends GameMode {
  final int level;
  const LevelGameMode(this.level)
    : assert(level > 0, 'Level must be greater than 0');
}

class ClassicGameMode extends GameMode {
  const ClassicGameMode(this.seed);
  final int seed;
}

class ImageGameMode extends GameMode {
  const ImageGameMode(this.query)
    : assert(query != '', 'Query must be non-empty');
  final String query;
}
