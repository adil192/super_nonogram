class _AchievementIds {
  const _AchievementIds({
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
}

const androidAchievements = _AchievementIds(
  level1: 'CgkIrKj9mcsZEAIQAQ',
  level10: 'CgkIrKj9mcsZEAIQAg',
  level50: 'CgkIrKj9mcsZEAIQAw',
  level100: 'CgkIrKj9mcsZEAIQBA',
  level500: 'CgkIrKj9mcsZEAIQBQ',
  level1000: 'CgkIrKj9mcsZEAIQBg',
);
const iosAchievements = _AchievementIds(
  level1: 'grp.snLevel1',
  level10: 'grp.snLevel10',
  level50: 'grp.snLevel50',
  level100: 'grp.snLevel100',
  level500: 'grp.snLevel500',
  level1000: 'grp.snLevel1000',
);
