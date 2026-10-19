import 'dart:convert';
import 'dart:io';

import 'package:exam_prep/app_state.dart';
import 'package:exam_prep/i18n.dart';
import 'package:exam_prep/main.dart';
import 'package:exam_prep/models.dart';
import 'package:exam_prep/monetization.dart';
import 'package:exam_prep/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _apps() =>
    jsonDecode(File('assets/apps.json').readAsStringSync())
        as Map<String, dynamic>;

Bank _bank(String id) => Bank.fromJson(
  jsonDecode(File('assets/banks/$id.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  group('content', () {
    for (final entry in _apps().entries) {
      test('${entry.key}: bank has every language the app needs', () {
        final config = AppConfig.fromJson(entry.value as Map<String, dynamic>);
        final bank = _bank(config.bank);
        expect(bank.questions, isNotEmpty);
        for (final q in bank.questions) {
          for (final lang in config.locales) {
            expect(q.hasLang(lang), isTrue, reason: '${q.id} missing $lang');
            final t = q.text(lang);
            expect(q.answer, inInclusiveRange(0, t.options.length - 1));
            expect(t.explanation, isNotEmpty);
          }
        }
        expect(config.examQuestions, lessThanOrEqualTo(bank.questions.length));
      });
    }

    test('every UI language has every string', () {
      for (final app in _apps().values) {
        for (final lang in List<String>.from(app['locales'] as List)) {
          expect(S.missingKeys(lang), isEmpty, reason: lang);
        }
      }
    });

    test(
      'sectioned exams: 25 per section, Universal needs every section',
      () async {
        SharedPreferences.setMockInitialValues({});
        final config = AppConfig.fromJson(
          _apps()['epa608'] as Map<String, dynamic>,
        );
        expect(config.hasSections, isTrue);
        final bank = _bank(config.bank);
        final progress = Progress(await SharedPreferences.getInstance(), 'en');
        progress.premium = true;
        final app = AppState(
          config,
          bank,
          progress,
          Monetization(config, progress),
        );
        for (final c in bank.categories) {
          final qs = app.sectionExam(c).pick();
          expect(qs.length, config.sectionQuestions);
          expect(qs.every((q) => q.category == c.id), isTrue);
        }
        final all = app.allSectionsExam;
        final qs = all.pick();
        expect(qs.length, config.sectionQuestions! * bank.categories.length);
        // Everything right except the whole last section: overall 75% but a
        // failed section, so Universal is not passed.
        final last = bank.categories.last.id;
        final picked = {
          for (var i = 0; i < qs.length; i++)
            i: qs[i].category == last ? (qs[i].answer + 1) % 4 : qs[i].answer,
        };
        expect(all.passed(qs, picked), isFalse);
        expect(app.fullExam.passed(qs, picked), isTrue);
        expect(
          all.passed(qs, {for (var i = 0; i < qs.length; i++) i: qs[i].answer}),
          isTrue,
        );
      },
    );

    test('free tier covers every category but not everything', () {
      final bank = _bank('nail');
      final free = bank.freeIds(0.4);
      for (final c in bank.categories) {
        expect(bank.inCategory(c.id).any((q) => free.contains(q.id)), isTrue);
      }
      expect(free.length, lessThan(bank.questions.length));
    });
  });

  testWidgets('home renders and a practice question can be answered', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final config = AppConfig.fromJson(
      _apps()['nailvi'] as Map<String, dynamic>,
    );
    final bank = _bank(config.bank);
    final progress = Progress(
      await SharedPreferences.getInstance(),
      config.primary,
    );
    final app = AppState(
      config,
      bank,
      progress,
      Monetization(config, progress),
    );
    await tester.pumpWidget(ExamApp(app: app));
    await tester.pumpAndSettle();

    // First launch: onboarding (date -> goal -> plan), then the soft paywall.
    expect(find.text('Bạn thi ngày nào?'), findsOneWidget);
    await tester.tap(find.text('Chưa có lịch thi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 câu mỗi ngày'));
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Kế hoạch ôn thi của bạn'), findsOneWidget);
    // No notification plugin in widget tests: turn the reminder off.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bắt đầu học'));
    await tester.pumpAndSettle();
    expect(progress.onboarded, isTrue);
    expect(progress.dailyGoal, 30);
    expect(find.text('Đầy đủ'), findsOneWidget); // paywall comparison table
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Luyện Thi Nail Tiếng Việt'), findsWidgets);
    expect(find.text('Luyện nhanh 10 câu'), findsOneWidget);

    await tester.tap(find.text('Luyện nhanh 10 câu'));
    await tester.pumpAndSettle();
    expect(find.text('Câu 1/10'), findsOneWidget);

    // Tap the first option (letter A) and expect feedback.
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp('Chính xác!|Chưa đúng')), findsOneWidget);
    expect(progress.lastResult.length, 1);
    expect(progress.answeredToday, 1);
    expect(progress.currentStreak, 1);
  });
}
