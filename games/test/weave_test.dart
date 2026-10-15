import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/session.dart';
import 'package:puzzle_games/games/weave.dart';
import 'package:puzzle_games/games/weave_words.dart';

void main() {
  test('word lists are clean', () {
    for (final lang in ['en', 'es', 'pt', 'de']) {
      final words = weaveWords(lang);
      expect(words.length, greaterThan(650), reason: lang);
      expect(words.toSet().length, words.length, reason: '$lang duplicates');
      for (final w in words) {
        expect(RegExp(r'^[A-Z]{3,7}$').hasMatch(w), isTrue, reason: w);
      }
      for (var len = 3; len <= 7; len++) {
        expect(
          words.where((w) => w.length == len).length,
          greaterThan(40),
          reason: '$lang length $len',
        );
      }
    }
    expect(weaveWords('xx'), same(weaveWords('en')));
  });

  test('generated puzzles are valid partitions into dictionary words', () {
    final sw = Stopwatch();
    var count = 0, unique = 0;
    for (final lang in ['en', 'es', 'pt', 'de']) {
      final dict = weaveWords(lang).toSet();
      for (var d = 0; d <= 3; d++) {
        var dTime = 0;
        for (var level = 1; level <= 20; level++) {
          final seed = level * 7919 + 17 + d;
          sw
            ..reset()
            ..start();
          final p = WeavePuzzle.generate(d, level, seed, lang: lang);
          sw.stop();
          dTime += sw.elapsedMicroseconds;
          count++;
          final why = '$lang d$d level $level';

          // Deterministic.
          final again = WeavePuzzle.generate(d, level, seed, lang: lang);
          expect(again.letters, p.letters, reason: why);
          expect(again.words, p.words, reason: why);

          // Covers every cell exactly once.
          final cover = List<int>.filled(p.size, 0);
          for (final path in p.paths) {
            for (final x in path) {
              cover[x]++;
            }
          }
          expect(cover.every((c) => c == 1), isTrue, reason: why);

          expect(p.words.toSet().length, p.words.length, reason: why);
          for (var i = 0; i < p.words.length; i++) {
            final w = p.words[i], path = p.paths[i];
            expect(dict.contains(w), isTrue, reason: '$why $w');
            expect(path.length, w.length, reason: why);
            expect(path.map((x) => p.letters[x]).join(), w, reason: why);
            for (var k = 1; k < path.length; k++) {
              expect(p.adjacent(path[k - 1], path[k]), isTrue, reason: why);
            }
          }
          final (cols, rows) = WeavePuzzle.gridSize(d, level);
          expect(p.cols * p.rows, cols * rows);

          expect(p.canComplete(const {}), isTrue, reason: why);
          // Solver result is itself a valid partition.
          final sol = p.solve()!;
          expect(sol.expand((x) => x).toSet().length, p.size, reason: why);
          if (p.countSolutions() == 1) unique++;
        }
        final avgMs = dTime / 20 / 1000;
        // ignore: avoid_print
        print('$lang difficulty $d: avg ${avgMs.toStringAsFixed(1)} ms');
        expect(avgMs, lessThan(300), reason: '$lang d$d too slow');
      }
    }
    // ignore: avoid_print
    print('unique: $unique / $count');
    expect(unique / count, greaterThan(0.9));
  });

  test('judge: our path is accepted, wrong words are mistakes', () {
    final p = WeavePuzzle.generate(1, 3, 3 * 7919 + 18);
    final (v, i, _) = p.judge(p.paths[0], const {});
    expect(v, WeaveVerdict.found);
    expect(p.words[i], p.words[0]);
    // Reverse tracing is accepted too.
    final (v2, _, path2) = p.judge(p.paths[0].reversed.toList(), const {});
    expect(v2, WeaveVerdict.found);
    expect(path2, p.paths[0]);
    expect(
      p.judge(p.paths[0].sublist(0, 2), const {}).$1,
      WeaveVerdict.tooShort,
    );
    // Already-found cells can't be reused.
    expect(p.judge(p.paths[0], {0: p.paths[0]}).$1, WeaveVerdict.wrong);
    // Fairness: a valid word on a path that breaks the board is "blocked".
    var checked = 0;
    for (var seed = 0; seed < 300 && checked < 20; seed++) {
      final q = WeavePuzzle.generate(2, seed, seed);
      for (var w = 0; w < q.words.length; w++) {
        final blocked = List<bool>.filled(q.size, false);
        for (final alt in q.placements(q.words[w], blocked)) {
          final canon = (List.of(alt)..sort()).join();
          if (canon == (List.of(q.paths[w])..sort()).join()) continue;
          final ok = q.canComplete({w: alt});
          expect(
            q.judge(alt, const {}).$1,
            ok ? WeaveVerdict.found : WeaveVerdict.blocked,
          );
          checked++;
        }
      }
    }
    expect(checked, greaterThan(0));
  });

  testWidgets('hints solve the puzzle and trigger onWin', (tester) async {
    var won = 0;
    final session = GameSession(
      level: 4,
      seed: 4 * 7919 + 18,
      difficulty: 1,
      onWin: () => won++,
      onFail: () {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeaveGame(session: session, lang: 'en'),
        ),
      ),
    );
    expect(find.byType(WeaveGame), findsOneWidget);
    for (var i = 0; i < 40 && won == 0; i++) {
      session.hint.value++;
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(seconds: 1));
    expect(won, 1);
    expect(session.mistakes.value, 0);
  });

  testWidgets('dragging a wrong word costs a mistake', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final session = GameSession(
      level: 2,
      seed: 2 * 7919 + 17,
      onWin: () {},
      onFail: () {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeaveGame(session: session, lang: 'en'),
        ),
      ),
    );
    final p = WeavePuzzle.generate(0, 2, 2 * 7919 + 17);
    // Drag along the first word's path: it locks in.
    final board = tester.getRect(find.byKey(const ValueKey('weave-board')));
    final tile = board.width / p.cols;
    Offset pos(int cell) =>
        board.topLeft +
        Offset((cell % p.cols + 0.5) * tile, (cell ~/ p.cols + 0.5) * tile);
    final path = p.paths[0];
    final g = await tester.startGesture(pos(path.first));
    for (final x in path.skip(1)) {
      await g.moveTo(pos(x));
      await tester.pump();
    }
    await g.up();
    await tester.pump(const Duration(milliseconds: 500));
    expect(session.mistakes.value, 0);

    // A 3-cell trace that is not a hidden word.
    final free = [
      for (var i = 0; i < p.size; i++)
        if (!path.contains(i)) i,
    ];
    List<int>? bad;
    for (final a in free) {
      for (final b in p.neighbours(a).where(free.contains)) {
        for (final c in p.neighbours(b).where(free.contains)) {
          if (c == a) continue;
          final s = [a, b, c].map((x) => p.letters[x]).join();
          if (!p.words.contains(s) &&
              !p.words.contains(s.split('').reversed.join())) {
            bad = [a, b, c];
          }
        }
      }
    }
    final g2 = await tester.startGesture(pos(bad!.first));
    for (final x in bad.skip(1)) {
      await g2.moveTo(pos(x));
      await tester.pump();
    }
    await g2.up();
    await tester.pump(const Duration(milliseconds: 600));
    expect(session.mistakes.value, 1);
  });
}
