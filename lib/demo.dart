import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress.dart';
import 'screens/guide_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';

/// Store-screenshot scenes, reachable only on web via `?demo=<scene>`.
/// Seeds realistic progress in memory; nothing is shown on Android builds.
class DemoScene extends StatelessWidget {
  const DemoScene({super.key, required this.scene});
  final String scene;

  static void seed(AppState app, [String scene = '']) {
    final p = app.progress;
    // The study-guide shot shows full cards, not the locked ones.
    if (scene == 'guide') p.premium = true;
    final qs = app.bank.questions;
    for (var i = 0; i < qs.length; i++) {
      if (i % 5 < 3) p.lastResult[qs[i].id] = true;
      if (i % 11 == 0) p.lastResult[qs[i].id] = false;
    }
    p.bookmarks.addAll(qs.take(7).map((q) => q.id));
    p.studyDays = 9;
    p.onboarded = true;
    p.streak = 6;
    p.lastStudyDay = DateTime.now().toIso8601String().substring(0, 10);
    p.todayCount = 14;
    p.examDate = DateTime.now()
        .add(const Duration(days: 23))
        .toIso8601String()
        .substring(0, 10);
    p.exams.add(ExamRecord(DateTime.now(), 41, 50, true));
    p.showHelperLang = app.helperLang != null;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
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
        final spec = app.config.hasSections
            ? app.sectionExam(app.bank.categories.first)
            : app.fullExam;
        return QuizScreen(
          title: spec.title,
          questions: spec.pick(),
          exam: true,
          initialPick: 1,
          spec: spec,
        );
      case 'result':
        final spec = app.config.hasSections
            ? app.allSectionsExam
            : app.fullExam;
        final exam = app.config.hasSections
            ? [
                for (final c in app.bank.categories)
                  ...app.bank
                      .inCategory(c.id)
                      .take(app.config.sectionQuestions!),
              ]
            : app.bank.questions.take(app.config.examQuestions).toList();
        return ResultScreen(
          title: spec.title,
          spec: spec,
          questions: exam,
          picked: {
            for (var i = 0; i < exam.length; i++)
              i: i % 7 == 3 ? (exam[i].answer + 1) % 4 : exam[i].answer,
          },
          exam: true,
        );
      case 'guide':
        return const GuideScreen();
      case 'paywall':
        return const PaywallScreen();
      case 'onboarding':
        return const OnboardingScreen();
      default:
        return const HomeScreen();
    }
  }
}
