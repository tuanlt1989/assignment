import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/config.dart';
import 'package:puzzle_games/main.dart';
import 'package:puzzle_games/meta.dart';
import 'package:puzzle_games/monetization.dart';
import 'package:puzzle_games/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GameProgress> _progress() async {
  SharedPreferences.setMockInitialValues({});
  return GameProgress(await SharedPreferences.getInstance());
}

void main() {
  test('free players get 3 hard and 1 expert puzzle a day', () async {
    final p = await _progress();
    expect(p.leftToday(0), isNull);
    expect(p.leftToday(2), 3);
    for (var n = 1; n <= 3; n++) {
      expect(p.canStart(2, n), isTrue);
      p.markStarted(2, n);
    }
    expect(p.canStart(2, 4), isFalse);
    // Re-opening a puzzle already started today is free.
    expect(p.canStart(2, 2), isTrue);
    p.markStarted(3, 1);
    expect(p.canStart(3, 2), isFalse);
    p.setPremium(true);
    expect(p.canStart(3, 2), isTrue);
    expect(p.leftToday(3), isNull);
  });

  test(
    'wins advance the level, keep best stars and count the streak',
    () async {
      final p = await _progress();
      p.recordWin(
        difficulty: 1,
        level: 1,
        ms: 9000,
        starCount: 2,
        hintsUsed: 1,
      );
      p.recordWin(
        difficulty: 1,
        level: 1,
        ms: 7000,
        starCount: 3,
        hintsUsed: 0,
      );
      expect(p.next[1], 2);
      expect(p.starsOf('1:1'), 3);
      expect(p.bestMs[1], 7000);
      expect(p.solvedTotal, 2);
      final now = DateTime.now();
      for (var i = 2; i >= 0; i--) {
        final spec = DailySpec(now.subtract(Duration(days: i)));
        p.recordWin(
          difficulty: spec.difficulty,
          level: spec.level,
          day: spec.key,
          ms: 1000,
          starCount: 3,
          hintsUsed: 0,
        );
      }
      expect(p.currentStreak, 3);
      expect(p.bestStreak, 3);
      expect(p.dailyDone, isTrue);
    },
  );

  test('stars: 3 clean, minus mistakes and hints, never below 1', () {
    expect(GameProgress.starsFor(mistakes: 0, hintsUsed: 0), 3);
    expect(GameProgress.starsFor(mistakes: 1, hintsUsed: 0), 2);
    expect(GameProgress.starsFor(mistakes: 2, hintsUsed: 3), 1);
  });

  test('themes unlock with stars or premium', () async {
    final p = await _progress();
    expect(themeUnlocked(p, 0), isTrue);
    expect(themeUnlocked(p, 1), isFalse);
    p.setPremium(true);
    expect(themeUnlocked(p, gameThemes.length - 1), isTrue);
  });

  testWidgets('home screen and a queens puzzle open', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final p = await _progress();
    final config = GameConfig.fromJson({
      'id': 'meowqueens',
      'game': 'queens',
      'title': {'en': 'Meow Queens'},
      'color': '#8E24AA',
      'premiumProductId': 'premium_lifetime',
      'privacyPolicyUrl': 'https://example.com',
      'supportEmail': 'a@b.c',
    });
    final app = GameApp(
      config,
      p..markRulesSeen(),
      Monetization(config, p),
      'en',
    );
    await tester.pumpWidget(PuzzleApp(app: app));
    await tester.pumpAndSettle();
    expect(find.text('Daily puzzle'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);
    await tester.tap(find.text('Easy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Easy · #1'), findsOneWidget);
  });
}
