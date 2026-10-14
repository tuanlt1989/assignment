import 'dart:convert';
import 'dart:io';

import 'package:exam_prep/app_state.dart';
import 'package:exam_prep/main.dart';
import 'package:exam_prep/models.dart';
import 'package:exam_prep/monetization.dart';
import 'package:exam_prep/progress.dart';
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
  });
}
