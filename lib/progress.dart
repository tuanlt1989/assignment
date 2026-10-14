import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ExamRecord {
  ExamRecord(this.date, this.correct, this.total, this.passed);
  final DateTime date;
  final int correct;
  final int total;
  final bool passed;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  Map<String, dynamic> toJson() => {
    'd': date.millisecondsSinceEpoch,
    'c': correct,
    't': total,
    'p': passed,
  };

  factory ExamRecord.fromJson(Map<String, dynamic> j) => ExamRecord(
    DateTime.fromMillisecondsSinceEpoch(j['d'] as int),
    j['c'] as int,
    j['t'] as int,
    j['p'] as bool,
  );
}

/// Everything the user has done, persisted locally. No account, no server.
class Progress extends ChangeNotifier {
  Progress(this._prefs, this.defaultUiLang) {
    _load();
  }

  final SharedPreferences _prefs;
  final String defaultUiLang;

  /// Question id -> was the latest answer correct.
  final Map<String, bool> lastResult = {};
  final Map<String, int> attempts = {};
  final Set<String> bookmarks = {};
  final List<ExamRecord> exams = [];
  bool premium = false;
  late String uiLang;
  bool showHelperLang = false;
  int finishedSessions = 0;
  int lastReviewAskMs = 0;
  int studyDays = 0;
  String lastStudyDay = '';

  void _load() {
    final raw = _prefs.getString('state');
    uiLang = defaultUiLang;
    if (raw == null) return;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    lastResult.addAll(Map<String, bool>.from(j['last'] as Map? ?? {}));
    attempts.addAll(Map<String, int>.from(j['att'] as Map? ?? {}));
    bookmarks.addAll(List<String>.from(j['bm'] as List? ?? []));
    exams.addAll([
      for (final e in j['ex'] as List? ?? [])
        ExamRecord.fromJson(e as Map<String, dynamic>),
    ]);
    premium = j['pr'] as bool? ?? false;
    uiLang = j['ui'] as String? ?? defaultUiLang;
    showHelperLang = j['hl'] as bool? ?? false;
    finishedSessions = j['fs'] as int? ?? 0;
    lastReviewAskMs = j['ra'] as int? ?? 0;
    studyDays = j['sd'] as int? ?? 0;
    lastStudyDay = j['lsd'] as String? ?? '';
  }

  Future<void> _save() async {
    notifyListeners();
    await _prefs.setString(
      'state',
      jsonEncode({
        'last': lastResult,
        'att': attempts,
        'bm': bookmarks.toList(),
        'ex': exams.map((e) => e.toJson()).toList(),
        'pr': premium,
        'ui': uiLang,
        'hl': showHelperLang,
        'fs': finishedSessions,
        'ra': lastReviewAskMs,
        'sd': studyDays,
        'lsd': lastStudyDay,
      }),
    );
  }

  void recordAnswer(String id, bool correct) {
    lastResult[id] = correct;
    attempts[id] = (attempts[id] ?? 0) + 1;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (today != lastStudyDay) {
      lastStudyDay = today;
      studyDays++;
    }
    _save();
  }

  void toggleBookmark(String id) {
    if (!bookmarks.remove(id)) bookmarks.add(id);
    _save();
  }

  void addExam(ExamRecord r) {
    exams.insert(0, r);
    if (exams.length > 50) exams.removeLast();
    _save();
  }

  void finishSession() {
    finishedSessions++;
    _save();
  }

  void setPremium(bool v) {
    if (premium == v) return;
    premium = v;
    _save();
  }

  void setUiLang(String lang) {
    uiLang = lang;
    _save();
  }

  void setShowHelperLang(bool v) {
    showHelperLang = v;
    _save();
  }

  void markReviewAsked() {
    lastReviewAskMs = DateTime.now().millisecondsSinceEpoch;
    _save();
  }

  Future<void> reset() async {
    lastResult.clear();
    attempts.clear();
    bookmarks.clear();
    exams.clear();
    studyDays = 0;
    lastStudyDay = '';
    await _save();
  }

  Set<String> get mistakes => {
    for (final e in lastResult.entries)
      if (!e.value) e.key,
  };

  int masteredIn(Iterable<Question> qs) =>
      qs.where((q) => lastResult[q.id] == true).length;

  /// Share of the whole bank whose latest answer was correct.
  double readiness(Bank bank) => bank.questions.isEmpty
      ? 0
      : masteredIn(bank.questions) / bank.questions.length;
}
