import 'dart:math';

import 'package:flutter/widgets.dart';

import 'i18n.dart';
import 'models.dart';
import 'monetization.dart';
import 'progress.dart';
import 'reminders.dart';

class AppState {
  AppState(this.config, this.bank, this.progress, this.money)
    : freeIds = bank.freeIds(config.freeRatio);

  final AppConfig config;
  final Bank bank;
  final Progress progress;
  final Monetization money;
  final Set<String> freeIds;

  S get s => S(progress.uiLang);

  /// Questions are shown in the app's primary language; the other language
  /// is the helper ("show English").
  String get questionLang => config.primary;
  String? get helperLang => config.secondary;

  bool get premium => progress.premium;

  bool canSee(Question q) => premium || freeIds.contains(q.id);

  List<Question> visible(Iterable<Question> qs) => qs.where(canSee).toList();

  int get lockedCount => bank.questions.length - freeIds.length;

  /// Free users take shorter exams drawn from the free pool.
  int get examSize => min(config.examQuestions, visible(bank.questions).length);

  List<Question> pickExam() {
    final pool = visible(bank.questions)..shuffle(Random());
    // Keep the exam balanced across topics by taking from a shuffled pool;
    // the bank itself is already balanced per topic.
    return pool.take(config.examQuestions).toList();
  }

  List<Question> pickRandom(int n) {
    final pool = visible(bank.questions);
    // Prefer questions the user has not mastered yet.
    pool.shuffle(Random());
    pool.sort((a, b) => _weight(a).compareTo(_weight(b)));
    return pool.take(n).toList()..shuffle(Random());
  }

  int _weight(Question q) => switch (progress.lastResult[q.id]) {
    false => 0,
    null => 1,
    true => 2,
  };

  /// The topic with the lowest share of mastered (visible) questions that
  /// still has something left to learn.
  Category? get weakestCategory {
    Category? best;
    var bestRatio = 2.0;
    for (final c in bank.categories) {
      final qs = visible(bank.inCategory(c.id));
      if (qs.isEmpty || progress.masteredIn(qs) == qs.length) continue;
      final ratio = progress.masteredIn(qs) / qs.length;
      if (ratio < bestRatio) {
        bestRatio = ratio;
        best = c;
      }
    }
    return best;
  }

  /// Unmastered visible questions first (wrong, then unseen), shuffled.
  List<Question> studyQueue(Iterable<Question> qs, [int? limit]) {
    final pool = visible(qs)..shuffle(Random());
    pool.sort((a, b) => _weight(a).compareTo(_weight(b)));
    return limit == null ? pool : pool.take(limit).toList();
  }

  /// Re-schedules (or cancels) the daily reminder with the current settings.
  Future<void> syncReminder() async {
    final p = progress;
    if (!p.reminderOn) return Reminders.cancel();
    await Reminders.scheduleDaily(
      minutesOfDay: p.reminderMinutes,
      title: config.titleFor(p.uiLang),
      body: s.t('notifBody', {'n': p.dailyGoal}),
    );
  }

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.app;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.app, required super.child});
  final AppState app;

  @override
  bool updateShouldNotify(AppScope oldWidget) => app != oldWidget.app;
}
