import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/putt.dart';
import 'package:puzzle_games/games/session.dart';

void main() {
  test(
    'putt holes: par 2..5, stored solution sinks in par-1, deterministic',
    () {
      final watch = Stopwatch();
      var holes = 0;
      final pars = <int, Map<int, int>>{};
      final layouts = <String, int>{};
      for (var difficulty = 0; difficulty <= 3; difficulty++) {
        for (var level = 1; level <= 20; level++) {
          final seed = level * 7919 + 17 + difficulty;
          watch.start();
          final h = PuttHole.generate(difficulty, level, seed);
          watch.stop();
          holes++;
          final why = 'difficulty $difficulty level $level';
          expect(h.par, inInclusiveRange(2, 5), reason: why);
          expect(h.solution.length, h.par - 1, reason: why);
          expect(h.solutionStarts.length, h.solution.length, reason: why);
          pars
              .putIfAbsent(difficulty, () => {})
              .update(h.par, (v) => v + 1, ifAbsent: () => 1);
          layouts.update(h.layout, (v) => v + 1, ifAbsent: () => 1);

          // Same inputs → same hole.
          final again = PuttHole.generate(difficulty, level, seed);
          expect(again.par, h.par, reason: why);
          expect(again.tee, h.tee, reason: why);
          expect(again.cup, h.cup, reason: why);

          // Replay the stored solution through the simulation.
          var x = h.tee.dx, y = h.tee.dy;
          for (var i = 0; i < h.solution.length; i++) {
            expect(Offset(x, y), h.solutionStarts[i], reason: why);
            final b = h.sim.shoot(x, y, h.solution[i]);
            final last = i == h.solution.length - 1;
            expect(
              b.state,
              last ? PuttState.sunk : PuttState.stopped,
              reason: '$why shot $i',
            );
            // Determinism: the same shot again ends in the same place, and
            // step-by-step stepping (the animation path) agrees with shoot().
            final b2 = h.sim.shoot(x, y, h.solution[i]);
            expect(b2.x, b.x, reason: why);
            expect(b2.y, b.y, reason: why);
            expect(b2.steps, b.steps, reason: why);
            final b3 = h.sim.launch(x, y, h.solution[i]);
            while (b3.state == PuttState.rolling) {
              h.sim.step(b3);
            }
            expect(b3.x, b.x, reason: why);
            expect(b3.y, b.y, reason: why);
            x = b.x;
            y = b.y;
          }
          if (difficulty == 3) {
            expect(h.par, greaterThanOrEqualTo(3), reason: '$why trivial');
          }
        }
      }
      final avg = watch.elapsedMilliseconds / holes;
      // ignore: avoid_print
      print(
        'putt: avg generation ${avg.toStringAsFixed(1)} ms; pars $pars; '
        'layouts $layouts',
      );
      expect(avg, lessThan(400));
    },
  );

  testWidgets('PuttGame pumps, shoots and shows hints', (tester) async {
    for (final demo in [false, true]) {
      var won = 0, failed = 0;
      final session = GameSession(
        level: 5,
        seed: 5 * 7919 + 17 + 2,
        difficulty: 2,
        demo: demo,
        onWin: () => won++,
        onFail: () => failed++,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: PuttGame(key: ValueKey(demo), session: session),
            ),
          ),
        ),
      );
      await tester.pump();
      session.hint.value++;
      await tester.pump(const Duration(milliseconds: 100));
      await tester.dragFrom(
        tester.getCenter(find.byType(PuttGame)),
        const Offset(0, 60),
      );
      for (var i = 0; i < 300; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(seconds: 4));
      expect(find.textContaining('Par'), findsOneWidget);
      expect(won + failed, lessThanOrEqualTo(1));
      if (!demo) {
        // The drag was a stroke (it may have sunk or found water).
        expect(find.textContaining('Strokes 0'), findsNothing);
      }
    }
  });
}
