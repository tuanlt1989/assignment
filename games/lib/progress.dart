import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the player has done, persisted locally.
///
/// Free: Easy and Medium are unlimited, Hard gives [freePerDay] new puzzles a
/// day, Expert one; today's daily puzzle is always free; 3 hints + 1 per day.
/// Premium (one-time purchase): every difficulty unlimited, unlimited hints,
/// the daily archive and every theme.
class GameProgress extends ChangeNotifier {
  GameProgress(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  static const difficulties = 4;

  /// New puzzles a free player may start per day, per difficulty (null = no limit).
  static const freePerDay = <int?>[null, null, 3, 1];
  static const maxHints = 5;
  static const archiveDays = 60;

  bool premium = false;

  /// Next puzzle number per difficulty (1-based).
  List<int> next = List.filled(difficulties, 1);
  List<int> solved = List.filled(difficulties, 0);

  /// Best solve time per difficulty in ms (0 = none yet).
  List<int> bestMs = List.filled(difficulties, 0);

  /// Stars per puzzle: `d:level` for levels, `day:yyyy-mm-dd` for dailies.
  Map<String, int> stars = {};

  /// Days on which the daily puzzle was solved.
  Set<String> dailyDays = {};
  int bestStreak = 0;
  int perfectWins = 0;
  int noHintWins = 0;
  int totalPlayMs = 0;
  int themeIndex = 0;
  int lastReviewAskMs = 0;
  bool seenRules = false;

  int _hints = 3;
  String _hintGiftDay = '';
  String _quotaDay = '';
  Set<String> _startedToday = {};

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String get today => dayKey(DateTime.now());

  void _load() {
    final raw = _prefs.getString('game2');
    if (raw != null) {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      List<int> ints(String k) {
        final l = (j[k] as List?)?.cast<int>() ?? const [];
        return List.generate(difficulties, (i) => i < l.length ? l[i] : 0);
      }

      premium = j['pr'] as bool? ?? false;
      next = ints('nx').map((v) => max(1, v)).toList();
      solved = ints('sv');
      bestMs = ints('bt');
      stars = Map<String, int>.from(j['st'] as Map? ?? {});
      dailyDays = Set<String>.from(j['dd'] as List? ?? []);
      bestStreak = j['bs'] as int? ?? 0;
      perfectWins = j['pw'] as int? ?? 0;
      noHintWins = j['nh'] as int? ?? 0;
      totalPlayMs = j['tp'] as int? ?? 0;
      themeIndex = j['th'] as int? ?? 0;
      lastReviewAskMs = j['ra'] as int? ?? 0;
      seenRules = j['sr'] as bool? ?? false;
      _hints = j['hi'] as int? ?? 3;
      _hintGiftDay = j['hg'] as String? ?? '';
      _quotaDay = j['qd'] as String? ?? '';
      _startedToday = Set<String>.from(j['qs'] as List? ?? []);
    } else {
      // Purchases from the first game version carry over.
      final old = _prefs.getString('game');
      if (old != null) {
        premium = (jsonDecode(old) as Map)['pr'] as bool? ?? false;
      }
    }
    if (_hintGiftDay != today) {
      if (_hintGiftDay.isNotEmpty) _hints = min(maxHints, _hints + 1);
      _hintGiftDay = today;
    }
    if (_quotaDay != today) {
      _quotaDay = today;
      _startedToday = {};
    }
  }

  Future<void> _save() async {
    notifyListeners();
    await _prefs.setString(
      'game2',
      jsonEncode({
        'pr': premium,
        'nx': next,
        'sv': solved,
        'bt': bestMs,
        'st': stars,
        'dd': dailyDays.toList(),
        'bs': bestStreak,
        'pw': perfectWins,
        'nh': noHintWins,
        'tp': totalPlayMs,
        'th': themeIndex,
        'ra': lastReviewAskMs,
        'sr': seenRules,
        'hi': _hints,
        'hg': _hintGiftDay,
        'qd': _quotaDay,
        'qs': _startedToday.toList(),
      }),
    );
  }

  // ---------------------------------------------------------------- quota

  void _rollDay() {
    if (_quotaDay != today) {
      _quotaDay = today;
      _startedToday = {};
    }
  }

  /// New puzzles of [d] the free player can still start today (null = unlimited).
  int? leftToday(int d) {
    final limit = freePerDay[d];
    if (premium || limit == null) return null;
    _rollDay();
    final used = _startedToday.where((k) => k.startsWith('$d:')).length;
    return max(0, limit - used);
  }

  /// Whether puzzle [level] of difficulty [d] may be opened now. Re-opening a
  /// puzzle already started today never costs quota.
  bool canStart(int d, int level) {
    if (premium || freePerDay[d] == null) return true;
    _rollDay();
    return _startedToday.contains('$d:$level') || leftToday(d)! > 0;
  }

  void markStarted(int d, int level) {
    if (premium || freePerDay[d] == null) return;
    _rollDay();
    if (_startedToday.add('$d:$level')) _save();
  }

  // ---------------------------------------------------------------- hints

  int get hints => premium ? 99 : _hints;

  bool useHint() {
    if (premium) return true;
    if (_hints <= 0) return false;
    _hints--;
    _save();
    return true;
  }

  // ---------------------------------------------------------------- results

  /// 3 stars for a clean solve, minus one per mistake or hint (minimum 1).
  static int starsFor({required int mistakes, required int hintsUsed}) =>
      max(1, 3 - mistakes - hintsUsed);

  int starsOf(String key) => stars[key] ?? 0;
  int get starsTotal => stars.values.fold(0, (a, b) => a + b);
  int get solvedTotal => solved.fold(0, (a, b) => a + b);

  /// Records a solve. [day] is set for daily puzzles (today or an archive day).
  void recordWin({
    required int difficulty,
    required int level,
    String? day,
    required int ms,
    required int starCount,
    required int hintsUsed,
  }) {
    final key = day != null ? 'day:$day' : '$difficulty:$level';
    stars[key] = max(stars[key] ?? 0, starCount);
    solved[difficulty]++;
    if (bestMs[difficulty] == 0 || ms < bestMs[difficulty]) {
      bestMs[difficulty] = ms;
    }
    totalPlayMs += ms;
    if (starCount == 3) perfectWins++;
    if (hintsUsed == 0) noHintWins++;
    if (day != null) {
      dailyDays.add(day);
      bestStreak = max(bestStreak, currentStreak);
    } else if (level >= next[difficulty]) {
      next[difficulty] = level + 1;
    }
    _save();
  }

  bool get dailyDone => dailyDays.contains(today);

  /// Consecutive days with a solved daily, ending today (or yesterday, so an
  /// unplayed today doesn't break the streak until midnight).
  int get currentStreak {
    var d = DateTime.now();
    if (!dailyDays.contains(dayKey(d))) {
      d = d.subtract(const Duration(days: 1));
    }
    var n = 0;
    while (dailyDays.contains(dayKey(d))) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  // ---------------------------------------------------------------- misc

  void setTheme(int i) {
    themeIndex = i;
    _save();
  }

  void setPremium(bool v) {
    if (premium == v) return;
    premium = v;
    _save();
  }

  void markRulesSeen() {
    seenRules = true;
    _save();
  }

  void markReviewAsked() {
    lastReviewAskMs = DateTime.now().millisecondsSinceEpoch;
    _save();
  }

  /// Store-screenshot state (web demo only).
  void loadDemo() {
    premium = false;
    next = [43, 18, 7, 3];
    solved = [42, 17, 6, 2];
    bestMs = [48000, 95000, 171000, 302000];
    for (var i = 1; i <= 42; i++) {
      stars['0:$i'] = i % 5 == 0 ? 2 : 3;
    }
    for (var i = 1; i <= 17; i++) {
      stars['1:$i'] = i % 3 == 0 ? 2 : 3;
    }
    final now = DateTime.now();
    for (var i = 1; i <= 12; i++) {
      final day = dayKey(now.subtract(Duration(days: i)));
      dailyDays.add(day);
      stars['day:$day'] = 3;
    }
    bestStreak = 12;
    perfectWins = 51;
    noHintWins = 58;
    totalPlayMs = 3 * 3600 * 1000;
    seenRules = true;
    notifyListeners();
  }
}
