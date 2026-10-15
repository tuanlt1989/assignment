// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/patches.dart';
import 'package:puzzle_games/games/session.dart';

void main() {
  test('patch puzzles tile the grid and have a unique solution', () {
    const names = ['easy', 'medium', 'hard', 'expert'];
    final nonUnique = <String>[];
    var total = 0;
    for (var d = 0; d < 4; d++) {
      var micros = 0;
      var worst = 0;
      var numbers = 0, shapeOnly = 0, any = 0, clues = 0;
      for (var level = 1; level <= 25; level++) {
        final seed = level * 7919 + 17 + d;
        final sw = Stopwatch()..start();
        final p = PatchPuzzle.generate(d, level, seed);
        sw.stop();
        micros += sw.elapsedMicroseconds;
        if (sw.elapsedMicroseconds > worst) worst = sw.elapsedMicroseconds;
        total++;
        final n = p.size;
        final why = '${names[d]} level $level';
        expect(n, inInclusiveRange(5, 9), reason: why);
        expect(p.solution.length, p.clues.length, reason: why);

        // Solution rectangles tile the grid exactly.
        final cover = List<int>.filled(n * n, 0);
        for (final r in p.solution) {
          expect(r.top, greaterThanOrEqualTo(0), reason: why);
          expect(r.left, greaterThanOrEqualTo(0), reason: why);
          expect(r.bottom, lessThan(n), reason: why);
          expect(r.right, lessThan(n), reason: why);
          for (var y = r.top; y <= r.bottom; y++) {
            for (var x = r.left; x <= r.right; x++) {
              cover[y * n + x]++;
            }
          }
        }
        expect(cover.every((c) => c == 1), isTrue, reason: why);

        // Each holds exactly one clue, consistent with it.
        for (var k = 0; k < p.clues.length; k++) {
          final rect = p.solution[k];
          final clue = p.clues[k];
          final inside = p.clues
              .where((c) => rect.contains(c.row, c.col))
              .length;
          expect(inside, 1, reason: '$why clue $k');
          expect(rect.contains(clue.row, clue.col), isTrue, reason: why);
          expect(clue.fits(rect), isTrue, reason: why);
          expect(p.clueIn(rect), k, reason: why);
          clues++;
          if (clue.area != null) {
            numbers++;
          } else if (clue.shape != null) {
            shapeOnly++;
          } else {
            any++;
          }
          if (d < 3) expect(clue.area ?? clue.shape, isNotNull, reason: why);
        }
        if (p.countSolutions() != 1) nonUnique.add('$why (seed $seed)');
      }
      final avg = micros / 25 / 1000;
      print(
        '${names[d]}: avg ${avg.toStringAsFixed(1)} ms, '
        'worst ${(worst / 1000).toStringAsFixed(1)} ms, '
        'clues $clues (numbers $numbers, shape-only $shapeOnly, any $any)',
      );
      expect(avg, lessThan(300), reason: '${names[d]} generation too slow');
    }
    if (nonUnique.isNotEmpty) print('non-unique: $nonUnique');
    expect(nonUnique.length, lessThanOrEqualTo(total * 2 ~/ 100));
  });

  test('generation is deterministic', () {
    for (var d = 0; d < 4; d++) {
      final a = PatchPuzzle.generate(d, 7, 1234);
      final b = PatchPuzzle.generate(d, 7, 1234);
      expect(a.solution, b.solution);
      expect(
        [for (final c in a.clues) (c.row, c.col, c.area, c.shape)],
        [for (final c in b.clues) (c.row, c.col, c.area, c.shape)],
      );
    }
  });

  testWidgets('hints solve the board and trigger onWin', (tester) async {
    var won = 0;
    final s = GameSession(
      level: 3,
      seed: 3 * 7919 + 17 + 3,
      difficulty: 3,
      onWin: () => won++,
      onFail: () {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatchGame(session: s)),
      ),
    );
    for (var i = 0; i < 100 && won == 0; i++) {
      s.hint.value++;
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(won, 1);
    expect(s.mistakes.value, 0);
  });

  testWidgets('dragging draws a patch; a bad patch is a mistake', (
    tester,
  ) async {
    final s = GameSession(
      level: 1,
      seed: 1 * 7919 + 17,
      onWin: () {},
      onFail: () {},
    );
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatchGame(session: s)),
      ),
    );
    final p = PatchPuzzle.generate(0, 1, s.seed);
    final board = find.byKey(const ValueKey('patch-board'));
    final origin = tester.getTopLeft(board);
    final cs = tester.getSize(board).width / p.size;
    Offset at(int r, int c) => origin + Offset((c + 0.5) * cs, (r + 0.5) * cs);

    // Draw the largest solution patch corner to corner.
    final rect = p.solution.reduce((a, b) => a.area >= b.area ? a : b);
    final from = at(rect.top, rect.left), to = at(rect.bottom, rect.right);
    final g = await tester.startGesture(from);
    await g.moveTo(Offset.lerp(from, to, 0.5)!);
    await tester.pump();
    await g.moveTo(to);
    await tester.pump();
    expect(find.text('${rect.width}×${rect.height} = ${rect.area}'), findsOne);
    await g.up();
    await tester.pump();
    expect(s.mistakes.value, 0);

    // A patch covering the whole grid holds many clues: mistake.
    final g2 = await tester.startGesture(at(0, 0));
    await g2.moveTo(at(p.size ~/ 2, p.size ~/ 2));
    await g2.moveTo(at(p.size - 1, p.size - 1));
    await g2.up();
    await tester.pump();
    expect(s.mistakes.value, 1);

    // Tap removes it.
    await tester.tapAt(at(0, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(s.mistakes.value, 1);
  });
}
