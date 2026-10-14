import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Level, lives, hints and premium, persisted locally.
///
/// Monetization lever: failing a level costs a life (5 max, one refills every
/// [refill]). Hints are limited (one free hint per day). Premium = unlimited
/// lives and hints, forever.
class GameProgress extends ChangeNotifier {
  GameProgress(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  static const maxLives = 5;
  static const refill = Duration(minutes: 20);
  static const maxHints = 5;

  int level = 1;
  int _lives = maxLives;
  int _livesStampMs = 0;
  int _hints = 3;
  String _hintGiftDay = '';
  bool premium = false;
  int bestScore = 0;
  String dailyDoneDay = '';
  int finishedLevels = 0;
  int lastReviewAskMs = 0;

  static String _day(DateTime d) => d.toIso8601String().substring(0, 10);
  static String get today => _day(DateTime.now());

  void _load() {
    final raw = _prefs.getString('game');
    if (raw != null) {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      level = j['lv'] as int? ?? 1;
      _lives = j['li'] as int? ?? maxLives;
      _livesStampMs = j['ls'] as int? ?? 0;
      _hints = j['hi'] as int? ?? 3;
      _hintGiftDay = j['hg'] as String? ?? '';
      premium = j['pr'] as bool? ?? false;
      bestScore = j['bs'] as int? ?? 0;
      dailyDoneDay = j['dd'] as String? ?? '';
      finishedLevels = j['fl'] as int? ?? 0;
      lastReviewAskMs = j['ra'] as int? ?? 0;
    }
    if (_hintGiftDay != today) {
      _hintGiftDay = today;
      _hints = min(maxHints, _hints + 1);
    }
  }

  Future<void> _save() async {
    notifyListeners();
    await _prefs.setString(
      'game',
      jsonEncode({
        'lv': level,
        'li': _lives,
        'ls': _livesStampMs,
        'hi': _hints,
        'hg': _hintGiftDay,
        'pr': premium,
        'bs': bestScore,
        'dd': dailyDoneDay,
        'fl': finishedLevels,
        'ra': lastReviewAskMs,
      }),
    );
  }

  /// Lives after applying time-based refills.
  int get lives {
    if (premium) return maxLives;
    _applyRefill();
    return _lives;
  }

  void _applyRefill() {
    if (_lives >= maxLives) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final gained = (now - _livesStampMs) ~/ refill.inMilliseconds;
    if (gained > 0) {
      _lives = min(maxLives, _lives + gained);
      _livesStampMs += gained * refill.inMilliseconds;
      if (_lives >= maxLives) _livesStampMs = now;
    }
  }

  /// Time until the next life, or null when full.
  Duration? get nextLifeIn {
    if (premium || lives >= maxLives) return null;
    final next = _livesStampMs + refill.inMilliseconds;
    return Duration(
      milliseconds: max(0, next - DateTime.now().millisecondsSinceEpoch),
    );
  }

  void loseLife() {
    if (premium) return;
    _applyRefill();
    if (_lives >= maxLives) {
      _livesStampMs = DateTime.now().millisecondsSinceEpoch;
    }
    _lives = max(0, _lives - 1);
    _save();
  }

  int get hints => premium ? 99 : _hints;

  bool useHint() {
    if (premium) return true;
    if (_hints <= 0) return false;
    _hints--;
    _save();
    return true;
  }

  void winLevel({required bool daily}) {
    finishedLevels++;
    if (daily) {
      dailyDoneDay = today;
    } else {
      level++;
    }
    _save();
  }

  bool get dailyDone => dailyDoneDay == today;

  void submitScore(int score) {
    if (score > bestScore) {
      bestScore = score;
      _save();
    }
  }

  void setPremium(bool v) {
    if (premium == v) return;
    premium = v;
    _save();
  }

  void markReviewAsked() {
    lastReviewAskMs = DateTime.now().millisecondsSinceEpoch;
    _save();
  }
}
