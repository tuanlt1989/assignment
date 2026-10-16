import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/culprit.dart';
import 'package:puzzle_games/games/session.dart';

int _maskOf(Iterable<int> people) => people.fold(0, (m, i) => m | (1 << i));

int _popcount(int x) {
  var c = 0;
  for (; x != 0; x &= x - 1) {
    c++;
  }
  return c;
}

void main() {
  const sizes = [(3, 4), (4, 4), (4, 5), (4, 5)];

  group('generator', () {
    for (var d = 0; d < 4; d++) {
      test('difficulty $d puzzles are true, logical and unique', () {
        for (var seed = 1; seed <= 12; seed++) {
          final level = seed * 3;
          final p = CulpritPuzzle.forDifficulty(d, level, seed * 7919 + 5);
          final reason = 'd=$d seed=$seed';
          expect((p.cols, p.rows), sizes[d], reason: reason);
          expect(p.names.length, p.size);
          expect(p.clues.length, p.size);
          // Alphabetical initials in reading order.
          for (var i = 0; i < p.size; i++) {
            expect(p.names[i].codeUnitAt(0), 65 + i, reason: reason);
          }
          // 35–50 % criminals (rounded).
          final k = _popcount(p.criminals);
          expect(k, inInclusiveRange(p.size * 0.3, p.size * 0.55));
          // Every clue is true.
          for (var i = 0; i < p.size; i++) {
            expect(
              p.clues[i].holds(p.criminals),
              isTrue,
              reason: '$reason #$i',
            );
            expect(p.clueText(i, 'en'), isNot(contains('{')));
          }
          // The deduction closure from the start covers everybody.
          final path = p.solvePath();
          final all = path.expand((s) => s).toSet();
          expect(all.length, p.size, reason: reason);
          expect(_maskOf(all), p.allMask);
          // ...and the secret assignment is the only one consistent with
          // every clue and the start's revealed status.
          expect(p.countSolutions(), 1, reason: reason);
        }
      });
    }

    test('generation is deterministic', () {
      for (var d = 0; d < 4; d++) {
        final a = CulpritPuzzle.forDifficulty(d, 7, 4242);
        final b = CulpritPuzzle.forDifficulty(d, 7, 4242);
        expect(a.names, b.names);
        expect(a.criminals, b.criminals);
        expect(a.start, b.start);
        expect(
          [for (var i = 0; i < a.size; i++) a.clueText(i, 'en')],
          [for (var i = 0; i < b.size; i++) b.clueText(i, 'en')],
        );
        final c = CulpritPuzzle.forDifficulty(d, 8, 4242);
        expect(
          a.criminals != c.criminals || a.start != c.start,
          isTrue,
          reason: 'different level should give a different puzzle',
        );
      }
    });

    test('forced() is monotone along the solve path', () {
      final p = CulpritPuzzle.forDifficulty(3, 2, 99);
      final revealed = {p.start};
      while (revealed.length < p.size) {
        final f = p.forced(revealed);
        expect(f, isNotEmpty);
        expect(f.intersection(revealed), isEmpty);
        // Reveal just one at a time: progress must never stall.
        revealed.add(f.first);
      }
    });

    test('expert puzzles generate fast', () {
      final sw = Stopwatch()..start();
      for (var s = 0; s < 10; s++) {
        CulpritPuzzle.forDifficulty(3, s + 1, 1000 + s);
      }
      sw.stop();
      // ignore: avoid_print
      print('10 expert puzzles: ${sw.elapsedMilliseconds} ms');
      expect(sw.elapsedMilliseconds, lessThan(3000));
    });
  });

  test('every language has every template', () {
    for (final lang in CulpritText.languages) {
      expect(CulpritText.missingKeys(lang), isEmpty, reason: lang);
      final m = CulpritText.templates[lang]!;
      for (final e in m.entries) {
        final base = e.key.replaceAll(RegExp(r'_(0|1|f)$'), '');
        final en = CulpritText.templates['en']![base]!;
        // Same placeholders as English (singular forms may spell out k).
        for (final ph in ['{name}', '{name2}', '{r}', '{r2}', '{c}', '{c2}']) {
          expect(
            e.value.contains(ph),
            en.contains(ph),
            reason: '$lang ${e.key} $ph',
          );
        }
        if (!RegExp(r'_(0|1)$').hasMatch(e.key)) {
          expect(e.value.contains('{k}'), en.contains('{k}'), reason: e.key);
        }
      }
    }
    // Plural agreement for k == 1.
    final p = CulpritPuzzle.forDifficulty(0, 1, 1);
    expect(CulpritText.ui('xx', 'ui_innocent'), 'Innocent');
    expect(CulpritText.ui('vi', 'ui_criminal'), 'Tội phạm');
    expect(CulpritText.ui('ja', 'ui_criminal'), '犯人');
    for (var i = 0; i < p.size; i++) {
      for (final lang in CulpritText.languages) {
        expect(p.clueText(i, lang), isNot(contains('{')), reason: lang);
      }
    }
  });

  Future<GameSession> pumpGame(
    WidgetTester tester, {
    int difficulty = 2,
    int level = 3,
    int seed = 77,
    bool demo = false,
    VoidCallback? onWin,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final session = GameSession(
      difficulty: difficulty,
      level: level,
      seed: seed,
      demo: demo,
      onWin: onWin ?? () {},
      onFail: () => fail('Who Did It? never fails'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CulpritGame(session: session)),
      ),
    );
    return session;
  }

  for (var d = 0; d < 4; d++) {
    testWidgets('hints solve difficulty $d and win once', (tester) async {
      var won = 0;
      final session = await pumpGame(tester, difficulty: d, onWin: () => won++);
      final p = CulpritPuzzle.forDifficulty(d, 3, 77);
      for (var i = 0; i < p.size + 3; i++) {
        session.hint.value++;
        await tester.pump();
      }
      expect(won, 0);
      await tester.pump(const Duration(milliseconds: 500));
      expect(won, 1);
      session.hint.value++;
      await tester.pump(const Duration(seconds: 1));
      expect(won, 1);
      expect(session.mistakes.value, 0);
      expect(
        find.byIcon(Icons.gavel),
        findsAtLeastNWidgets(_popcount(p.criminals)),
      );
    });
  }

  testWidgets('unforced right answer says "Not enough evidence"; wrong '
      'answer is a mistake', (tester) async {
    // Find a seed where someone is not deducible at the start.
    late CulpritPuzzle p;
    var seed = 1, person = -1;
    for (; person < 0; seed++) {
      p = CulpritPuzzle.forDifficulty(1, 1, seed);
      final f = p.forced({p.start});
      for (var i = 0; i < p.size; i++) {
        if (i != p.start && !f.contains(i)) {
          person = i;
          break;
        }
      }
      if (person >= 0) break;
    }
    final session = await pumpGame(tester, difficulty: 1, level: 1, seed: seed);
    expect(find.text('Tap a person to accuse or clear them'), findsOneWidget);
    expect(find.text(p.clueText(p.start, 'en')), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('culprit-card-$person')));
    await tester.pump();
    final right = p.isCriminal(person) ? 'criminal' : 'innocent';
    final wrong = p.isCriminal(person) ? 'innocent' : 'criminal';
    await tester.tap(find.byKey(ValueKey('culprit-btn-$right')));
    await tester.pump();
    expect(find.text('Not enough evidence'), findsOneWidget);
    expect(session.mistakes.value, 0);

    await tester.tap(find.byKey(ValueKey('culprit-btn-$wrong')));
    await tester.pump();
    expect(session.mistakes.value, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Not enough evidence'), findsNothing);

    // A forced person with the right answer is revealed and shows its clue.
    final f = p.forced({p.start}).first;
    await tester.tap(find.byKey(ValueKey('culprit-card-$f')));
    await tester.pump();
    await tester.tap(
      find.byKey(
        ValueKey('culprit-btn-${p.isCriminal(f) ? 'criminal' : 'innocent'}'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(p.clueText(f, 'en')), findsOneWidget);
    expect(session.mistakes.value, 1);
  });

  testWidgets('demo mode pre-reveals about 40 %', (tester) async {
    await pumpGame(tester, difficulty: 3, level: 10, seed: 5, demo: true);
    final p = CulpritPuzzle.forDifficulty(3, 10, 5);
    final shown =
        find.byIcon(Icons.gavel).evaluate().length +
        find.byIcon(Icons.verified_user).evaluate().length;
    // Card icons plus the one in the clue panel.
    expect(shown - 1, (p.size * 0.4).round());
  });

  testWidgets('renders in every language without overflow', (tester) async {
    for (final lang in CulpritText.languages) {
      tester.view.physicalSize = const Size(1080, 2070);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final session = GameSession(
        difficulty: 3,
        level: 1,
        seed: 3,
        demo: true,
        onWin: () {},
        onFail: () {},
      );
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(lang),
          home: Scaffold(
            body: CulpritGame(session: session, lang: lang),
          ),
        ),
      );
      final p = CulpritPuzzle.forDifficulty(3, 1, 3);
      final hidden = [
        for (var i = 0; i < p.size; i++)
          if (!p.solvePath().first.contains(i)) i,
      ];
      await tester.tap(find.byKey(ValueKey('culprit-card-${hidden.last}')));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: lang);
    }
  });
}
