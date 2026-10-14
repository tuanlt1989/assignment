import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress.dart';
import 'screens/home_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';

/// Store-screenshot scenes, reachable only on web via `?demo=<scene>`.
/// Seeds realistic progress in memory; nothing is shown on Android builds.
class DemoScene extends StatelessWidget {
  const DemoScene({super.key, required this.scene});
  final String scene;

  static void seed(AppState app) {
    final p = app.progress;
    final qs = app.bank.questions;
    for (var i = 0; i < qs.length; i++) {
      if (i % 5 < 3) p.lastResult[qs[i].id] = true;
      if (i % 11 == 0) p.lastResult[qs[i].id] = false;
    }
    p.bookmarks.addAll(qs.take(7).map((q) => q.id));
    p.studyDays = 9;
    p.exams.add(ExamRecord(DateTime.now(), 41, 50, true));
    p.showHelperLang = app.helperLang != null;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final s = app.s;
    final cat = app.bank.categories[1];
    final qs = app.bank.inCategory(cat.id);
    switch (scene) {
      case 'practice':
        return QuizScreen(
          title: cat.name(app.progress.uiLang),
          questions: qs,
          initialPick: qs.first.answer,
        );
      case 'exam':
        return QuizScreen(
          title: s.t('mockExam'),
          questions: app.pickExam(),
          exam: true,
          initialPick: 1,
        );
      case 'result':
        final exam = app.bank.questions.take(app.config.examQuestions).toList();
        return ResultScreen(
          title: s.t('mockExam'),
          questions: exam,
          picked: {
            for (var i = 0; i < exam.length; i++)
              i: i % 7 == 3 ? (exam[i].answer + 1) % 4 : exam[i].answer,
          },
          exam: true,
        );
      case 'paywall':
        return const PaywallScreen();
      default:
        return const HomeScreen();
    }
  }
}
