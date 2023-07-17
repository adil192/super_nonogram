class _AchievementIds {
  const _AchievementIds({
    required this.levels,
  });

  final _AchievementIdsLevels levels;
}

class _AchievementIdsLevels {
  const _AchievementIdsLevels({
    required this.level1,
    required this.level10,
    required this.level50,
    required this.level100,
    required this.level500,
    required this.level1000,
  });

  final String level1;
  final String level10;
  final String level50;
  final String level100;
  final String level500;
  final String level1000;

  final List<int> tiers = const [1, 10, 50, 100, 500, 1000];

  String operator [](int level) => switch(level) {
    1 => level1,
    10 => level10,
    50 => level50,
    100 => level100,
    500 => level500,
    1000 => level1000,
    _ => throw ArgumentError.value(level, 'level', 'must be 1, 10, 50, 100, 500, or 1000'),
  };
}

const androidAchievements = _AchievementIds(
  levels: _AchievementIdsLevels(
    level1: 'CgkIrKj9mcsZEAIQAQ',
    level10: 'CgkIrKj9mcsZEAIQAg',
    level50: 'CgkIrKj9mcsZEAIQAw',
    level100: 'CgkIrKj9mcsZEAIQBA',
    level500: 'CgkIrKj9mcsZEAIQBQ',
    level1000: 'CgkIrKj9mcsZEAIQBg',
  ),
);
const iosAchievements = _AchievementIds(
  levels: _AchievementIdsLevels(
    level1: 'grp.snLevel1',
    level10: 'grp.snLevel10',
    level50: 'grp.snLevel50',
    level100: 'grp.snLevel100',
    level500: 'grp.snLevel500',
    level1000: 'grp.snLevel1000',
  ),
);
