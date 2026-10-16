// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/session.dart';
import 'package:puzzle_games/games/tango.dart';

void expectValid(TangoPuzzle p, String why) {
  final n = p.n, v = p.solution;
  expect(v.length, n * n, reason: why);
  expect(
    v.every((x) => x == TangoPuzzle.sun || x == TangoPuzzle.moon),
    isTrue,
    reason: why,
  );
  for (var line = 0; line < 2 * n; line++) {
    final cells = [
      for (var k = 0; k < n; k++) line < n ? line * n + k : k * n + line - n,
    ];
    final suns = cells.where((i) => v[i] == TangoPuzzle.sun).length;
    expect(suns, n ~/ 2, reason: '$why line $line balanced');
    for (var k = 0; k + 2 < n; k++) {
      final x = v[cells[k]];
      expect(
        x == v[cells[k + 1]] && x == v[cells[k + 2]],
        isFalse,
        reason: '$why line $line has 3 in a row',
      );
    }
  }
  for (final s in p.signs) {
    expect(s.b == s.a + 1 || s.b == s.a + n, isTrue, reason: why);
    if (s.b == s.a + 1) expect(s.a % n, lessThan(n - 1), reason: why);
    expect(v[s.a] == v[s.b], s.equal, reason: '$why sign $s');
  }
  expect(p.check(p.solution).isEmpty, isTrue, reason: why);
  final start = p.start;
  for (final g in p.givens) {
    expect(start[g], v[g], reason: why);
  }
}

void main() {
  test('every difficulty: valid solution, exactly one solution', () {
    const names = ['easy', 'medium', 'hard', 'expert'];
    for (var d = 0; d < 4; d++) {
      var givens = 0, signs = 0;
      for (var level = 1; level <= 15; level++) {
        final seed = level * 7919 + 17;
        final p = TangoPuzzle.forDifficulty(d, level, seed);
        final why = '${names[d]} level $level';
        expectValid(p, why);
        expect(p.countSolutions(), 1, reason: why);
        givens += p.givens.length;
        signs += p.signs.length;
      }
      print(
        '${names[d]}: avg givens ${(givens / 15).toStringAsFixed(1)}, '
        'avg signs ${(signs / 15).toStringAsFixed(1)}',
      );
    }
  });

  test('sizes and clue amounts follow the difficulty', () {
    for (var seed = 1; seed <= 10; seed++) {
      expect(TangoPuzzle.forDifficulty(0, 1, seed).n, 6);
      expect(TangoPuzzle.forDifficulty(1, 1, seed).n, 6);
      expect(TangoPuzzle.forDifficulty(2, 1, seed).n, 6);
      expect(TangoPuzzle.forDifficulty(3, 1, seed).n, 8);
      final easy = TangoPuzzle.forDifficulty(0, 1, seed);
      final medium = TangoPuzzle.forDifficulty(1, 1, seed);
      final hard = TangoPuzzle.forDifficulty(2, 1, seed);
      expect(easy.givens.length, inInclusiveRange(14, 16));
      expect(medium.givens.length, inInclusiveRange(8, 10));
      expect(easy.givens.length, greaterThan(hard.givens.length));
      expect(medium.signs.length, greaterThan(easy.signs.length));
    }
  });

  test('generation is deterministic', () {
    for (var d = 0; d < 4; d++) {
      for (final seed in [1, 42, 99999]) {
        final a = TangoPuzzle.forDifficulty(d, 3, seed);
        final b = TangoPuzzle.forDifficulty(d, 3, seed);
        expect(b.solution, a.solution);
        expect(b.givens, a.givens);
        expect(b.signs, a.signs);
      }
    }
  });

  test('20 expert puzzles generate quickly', () {
    final sw = Stopwatch()..start();
    var worst = 0;
    for (var level = 1; level <= 20; level++) {
      final t0 = sw.elapsedMicroseconds;
      TangoPuzzle.forDifficulty(3, level, level * 104729 + 5);
      final t = sw.elapsedMicroseconds - t0;
      if (t > worst) worst = t;
    }
    final avg = sw.elapsedMicroseconds / 20 / 1000;
    print(
      'expert: avg ${avg.toStringAsFixed(1)} ms, '
      'worst ${(worst / 1000).toStringAsFixed(1)} ms',
    );
    expect(avg, lessThan(300));
    expect(worst / 1000, lessThan(300));
  });

  test('check() reports 3 in a row, over-full lines and broken signs', () {
    final p = TangoPuzzle.forDifficulty(1, 1, 7);
    final n = p.n;
    final v = List<int>.filled(n * n, TangoPuzzle.empty);
    expect(p.check(v).isEmpty, isTrue);
    v[0] = v[1] = v[2] = TangoPuzzle.sun;
    final c = p.check(v);
    expect(c.cells, containsAll([0, 1, 2]));
    expect(c.ids, isNotEmpty);
    v[0] = v[1] = v[2] = TangoPuzzle.empty;
    for (var r = 0; r < n; r += 2) {
      v[r * n] = TangoPuzzle.moon; // 3 moons spread down column 0 (fine)
    }
    expect(p.check(v).isEmpty, isTrue);
    v[n] = TangoPuzzle.moon; // 4th moon in column 0 of a 6×6
    expect(p.check(v).cells, contains(n));
    final s = p.signs.first;
    final w = List<int>.filled(n * n, TangoPuzzle.empty)
      ..[s.a] = TangoPuzzle.sun
      ..[s.b] = s.equal ? TangoPuzzle.moon : TangoPuzzle.sun;
    expect(p.check(w).signs, {0});
  });

  GameSession session0(int d, int level, int seed, VoidCallback onWin) =>
      GameSession(
        difficulty: d,
        level: level,
        seed: seed,
        onWin: onWin,
        onFail: () => fail('Tango never fails'),
      );

  Future<void> phone(WidgetTester tester, GameSession session) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TangoGame(session: session)),
      ),
    );
  }

  testWidgets('tap shows a sun; hints solve the board and win once', (
    tester,
  ) async {
    var won = 0;
    const seed = 3 * 7919 + 18;
    final session = session0(2, 3, seed, () => won++);
    await phone(tester, session);
    final p = TangoPuzzle.forDifficulty(2, 3, seed);
    expect(tester.takeException(), isNull);

    final cell = List.generate(
      p.n * p.n,
      (i) => i,
    ).firstWhere((i) => !p.isGiven(i));
    final suns = find.byIcon(Icons.wb_sunny).evaluate().length;
    await tester.tap(find.byKey(ValueKey('tango-cell-$cell')));
    await tester.pump();
    expect(find.byIcon(Icons.wb_sunny).evaluate().length, suns + 1);

    for (var i = 0; i < p.n * p.n + 2 && won == 0; i++) {
      session.hint.value++;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pump(const Duration(seconds: 1));
    expect(won, 1);
    session.hint.value++;
    await tester.pump(const Duration(seconds: 1));
    expect(won, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('breaking a sign counts one mistake; undo restores', (
    tester,
  ) async {
    // Find an easy puzzle with a sign between a given and an open cell.
    late TangoPuzzle p;
    late int seed, open, wrong;
    for (seed = 1; ; seed++) {
      p = TangoPuzzle.forDifficulty(0, 1, seed);
      final s = p.signs
          .where((s) => p.isGiven(s.a) != p.isGiven(s.b))
          .firstOrNull;
      if (s == null) continue;
      final given = p.isGiven(s.a) ? s.a : s.b;
      open = given == s.a ? s.b : s.a;
      final g = p.solution[given];
      final other = g == TangoPuzzle.sun ? TangoPuzzle.moon : TangoPuzzle.sun;
      wrong = s.equal ? other : g;
      break;
    }
    final session = session0(0, 1, seed, () {});
    await phone(tester, session);
    final target = find.byKey(ValueKey('tango-cell-$open'));
    if (wrong == TangoPuzzle.moon) {
      await tester.tap(target);
      await tester.pump();
    }
    final before = session.mistakes.value;
    final moons = find.byIcon(Icons.nightlight_round).evaluate().length;
    await tester.tap(target);
    await tester.pump();
    expect(session.mistakes.value, before + 1);

    await tester.tap(find.byIcon(Icons.undo));
    await tester.pump();
    expect(find.byIcon(Icons.nightlight_round).evaluate().length, moons);
    expect(session.mistakes.value, before + 1);
    // Tapping on a given cell does nothing.
    final given = p.givens.first;
    final suns = find.byIcon(Icons.wb_sunny).evaluate().length;
    await tester.tap(find.byKey(ValueKey('tango-cell-$given')));
    await tester.pump();
    expect(find.byIcon(Icons.wb_sunny).evaluate().length, suns);
  });

  testWidgets('demo mode renders a half-filled expert board', (tester) async {
    final session = GameSession(
      difficulty: 3,
      level: 10,
      seed: 99,
      demo: true,
      onWin: () {},
      onFail: () {},
    );
    await phone(tester, session);
    final filled =
        find.byIcon(Icons.wb_sunny).evaluate().length +
        find.byIcon(Icons.nightlight_round).evaluate().length;
    expect(filled, inInclusiveRange(28, 36));
    expect(tester.takeException(), isNull);
  });
}
