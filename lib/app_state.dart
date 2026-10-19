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

  /// The full mock exam (one test, one pass mark).
  ExamSpec get fullExam => ExamSpec(
    title: s.t('mockExam'),
    minutes: config.examMinutes,
    passPercent: config.passPercent,
    pick: pickExam,
  );

  /// One section of a sectioned exam (e.g. EPA 608 Core), from that topic.
  ExamSpec sectionExam(Category c) => ExamSpec(
    title: c.name(progress.uiLang),
    minutes: config.sectionMinutes!,
    passPercent: config.sectionPass!,
    pick: () => (visible(
      bank.inCategory(c.id),
    )..shuffle(Random())).take(config.sectionQuestions!).toList(),
  );

  /// Every section in a row; passing needs the pass mark in each section.
  ExamSpec get allSectionsExam => ExamSpec(
    title: s.t('universal'),
    minutes: config.sectionMinutes! * bank.categories.length,
    passPercent: config.sectionPass!,
    bySection: true,
    pick: () => [for (final c in bank.categories) ...sectionExam(c).pick()],
  );

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

/// A timed exam: how long, the pass mark and how to draw its questions.
class ExamSpec {
  const ExamSpec({
    required this.title,
    required this.minutes,
    required this.passPercent,
    required this.pick,
    this.bySection = false,
  });

  final String title;
  final int minutes;
  final int passPercent;

  /// Pass only if every topic in the exam reaches [passPercent] on its own.
  final bool bySection;
  final List<Question> Function() pick;

  /// Correct / total per topic for answers [picked] (question index → option).
  static Map<String, (int, int)> byTopic(
    List<Question> qs,
    Map<int, int> picked,
  ) {
    final out = <String, (int, int)>{};
    for (var i = 0; i < qs.length; i++) {
      final (c, t) = out[qs[i].category] ?? (0, 0);
      out[qs[i].category] = (c + (picked[i] == qs[i].answer ? 1 : 0), t + 1);
    }
    return out;
  }

  bool passed(List<Question> qs, Map<int, int> picked) {
    if (qs.isEmpty) return false;
    final topics = byTopic(qs, picked);
    if (bySection) {
      return topics.values.every((v) => v.$1 * 100 >= passPercent * v.$2);
    }
    final correct = topics.values.fold(0, (a, v) => a + v.$1);
    return correct * 100 >= passPercent * qs.length;
  }
}
