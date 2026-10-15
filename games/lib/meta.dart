import 'package:flutter/material.dart';

import 'progress.dart';

/// Color themes, unlocked with stars (premium unlocks all).
class GameTheme {
  const GameTheme(this.key, this.seed, this.stars, {this.dark = false});
  final String key;

  /// Null = the game's own brand color.
  final Color? seed;
  final int stars;
  final bool dark;
}

const gameThemes = [
  GameTheme('themeClassic', null, 0),
  GameTheme('themeOcean', Color(0xFF0277BD), 15),
  GameTheme('themeForest', Color(0xFF2E7D32), 40),
  GameTheme('themeSunset', Color(0xFFEF6C00), 80),
  GameTheme('themeSakura', Color(0xFFD81B60), 130),
  GameTheme('themeLavender', Color(0xFF6A1B9A), 200),
  GameTheme('themeMidnight', Color(0xFF3949AB), 280, dark: true),
  GameTheme('themeGold', Color(0xFFB8860B), 400, dark: true),
];

bool themeUnlocked(GameProgress p, int i) =>
    p.premium || p.starsTotal >= gameThemes[i].stars;

/// Trophies, computed from progress (nothing extra to store).
class Achievement {
  const Achievement(this.key, this.icon, this.goal, this.value);

  /// i18n template, filled with {n} = [goal].
  final String key;
  final IconData icon;
  final int goal;
  final int Function(GameProgress p) value;

  int current(GameProgress p) => value(p).clamp(0, goal);
  bool done(GameProgress p) => value(p) >= goal;
}

final achievements = <Achievement>[
  Achievement('achFirst', Icons.flag, 1, (p) => p.solvedTotal),
  Achievement('achSolve', Icons.extension, 25, (p) => p.solvedTotal),
  Achievement('achSolve', Icons.workspace_premium, 100, (p) => p.solvedTotal),
  Achievement('achSolve', Icons.diamond, 500, (p) => p.solvedTotal),
  Achievement('achPerfect', Icons.star, 10, (p) => p.perfectWins),
  Achievement('achNoHint', Icons.psychology, 50, (p) => p.noHintWins),
  Achievement('achStreak', Icons.local_fire_department, 3, (p) => p.bestStreak),
  Achievement('achStreak', Icons.local_fire_department, 7, (p) => p.bestStreak),
  Achievement('achStreak', Icons.whatshot, 30, (p) => p.bestStreak),
  Achievement('achHard', Icons.trending_up, 10, (p) => p.solved[2]),
  Achievement('achExpert', Icons.military_tech, 10, (p) => p.solved[3]),
  Achievement('achStars', Icons.auto_awesome, 300, (p) => p.starsTotal),
];

/// The daily puzzle for a date: easier early in the week, hardest at the
/// weekend (like newspaper puzzles). Same for every player.
class DailySpec {
  DailySpec(this.date)
    : difficulty = const [0, 1, 1, 2, 2, 3, 3][date.weekday - 1],
      level = 5 + date.day,
      seed = date.year * 10000 + date.month * 100 + date.day;
  final DateTime date;
  final int difficulty;
  final int level;
  final int seed;
  String get key => GameProgress.dayKey(date);
}

/// Seed for a regular puzzle: fixed per (difficulty, number), so "Hard #12"
/// is the same puzzle for everyone and on every retry.
int levelSeed(int difficulty, int level) =>
    level * 7919 + 17 + difficulty * 104729;

String fmtTime(int ms) {
  final s = ms ~/ 1000;
  final m = s ~/ 60;
  return '$m:${(s % 60).toString().padLeft(2, '0')}';
}
