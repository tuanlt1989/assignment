import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/pips.dart';
import 'package:puzzle_games/games/session.dart';

void main() {
  test('domino puzzles are valid, tileable and unique', () {
    var total = 0, unique = 0;
    final watch = Stopwatch();
    final perDifficulty = <int, int>{};
    for (var difficulty = 0; difficulty <= 3; difficulty++) {
      final t0 = watch.elapsedMicroseconds;
      for (var level = 1; level <= 25; level++) {
        final seed = level * 7919 + 17 + difficulty;
        watch.start();
        final p = PipsPuzzle.generate(difficulty, level, seed);
        watch.stop();
        final why = 'difficulty $difficulty level $level';
        total++;

        // Same inputs, same puzzle.
        final again = PipsPuzzle.generate(difficulty, level, seed);
        expect(again.solution, p.solution, reason: why);
        expect(again.regions.length, p.regions.length, reason: why);

        // Dominoes tile the board and match the solution values.
        expect(p.cells.length, p.dominoes.length * 2, reason: why);
        expect(p.dominoes.length, inInclusiveRange(4, 12), reason: why);
        final covered = <int>{};
        for (var i = 0; i < p.dominoes.length; i++) {
          final (a, b) = p.placement[i];
          expect(p.isCell(a) && p.isCell(b), isTrue, reason: why);
          expect(p.neighbours(a), contains(b), reason: why);
          expect(covered.add(a) && covered.add(b), isTrue, reason: why);
          expect(p.solution[a], p.dominoes[i].a, reason: why);
          expect(p.solution[b], p.dominoes[i].b, reason: why);
        }
        expect(covered, p.cells.toSet(), reason: why);
        expect(
          {for (final d in p.dominoes) '${d.a}${d.b}'}.length,
          p.dominoes.length,
          reason: '$why: dominoes are distinct',
        );

        // The solution satisfies every condition.
        expect(p.isSolved(p.solution), isTrue, reason: why);
        for (final r in p.regions) {
          expect(r.holds([for (final g in r.cells) p.solution[g]]), isTrue);
          expect(r.rule, isNot(PipsRule.none));
        }

        final count = p.countSolutions();
        if (count == 1) {
          unique++;
        } else {
          // ignore: avoid_print
          print('not unique: $why ($count solutions)');
        }
      }
      perDifficulty[difficulty] = watch.elapsedMicroseconds - t0;
    }
    // ignore: avoid_print
    print(
      'generation avg ms per puzzle by difficulty: '
      '${perDifficulty.map((d, us) => MapEntry(d, (us / 25000).toStringAsFixed(1)))}',
    );
    expect(unique, greaterThanOrEqualTo((total * 0.98).ceil()));
    expect(watch.elapsedMilliseconds / total, lessThan(300));
  });

  testWidgets('hints solve the domino puzzle and win', (tester) async {
    var won = 0;
    final session = GameSession(
      difficulty: 1,
      level: 3,
      seed: 3 * 7919 + 18,
      onWin: () => won++,
      onFail: () {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PipsGame(session: session)),
      ),
    );
    final p = PipsPuzzle.generate(1, 3, 3 * 7919 + 18);
    // A tap on the tray and the board must not throw.
    await tester.tap(find.byType(GestureDetector).last);
    await tester.pump();
    for (var i = 0; i < p.dominoes.length; i++) {
      session.hint.value++;
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 1));
    expect(won, 1);
    expect(session.mistakes.value, 0);
  });

  testWidgets('tap a tray domino, tap a cell to place, tap to take back', (
    tester,
  ) async {
    final session = GameSession(
      level: 1,
      seed: 1234,
      onWin: () {},
      onFail: () {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PipsGame(session: session)),
      ),
    );
    final p = PipsPuzzle.generate(0, 1, 1234);
    final trayCount = find.byType(Draggable<int>).evaluate().length;
    expect(trayCount, p.dominoes.length);
    await tester.tap(find.byType(Draggable<int>).first);
    await tester.pump();
    final board = tester.getRect(find.byType(DragTarget<int>));
    final s = board.width / p.width;
    Offset at(int g) =>
        board.topLeft +
        Offset((g % p.width + 0.5) * s, (g ~/ p.width + 0.5) * s);
    final cell = p.placement[0].$1;
    await tester.tapAt(at(cell));
    await tester.pump();
    expect(find.byType(Draggable<int>).evaluate().length, trayCount - 1);
    await tester.tapAt(at(cell));
    await tester.pump();
    expect(find.byType(Draggable<int>).evaluate().length, trayCount);
    expect(session.mistakes.value, 0);
  });

  testWidgets('demo mode renders a half-filled board', (tester) async {
    final session = GameSession(
      difficulty: 3,
      level: 10,
      seed: 99,
      demo: true,
      onWin: () {},
      onFail: () {},
    );
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PipsGame(session: session)),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
