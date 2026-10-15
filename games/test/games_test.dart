import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/queens.dart';
import 'package:puzzle_games/i18n.dart';

void main() {
  test('every UI language has every string', () {
    for (final lang in T.languages) {
      expect(T.missingKeys(lang), isEmpty, reason: lang);
      expect(T.missingRules(lang), isEmpty, reason: lang);
    }
  });

  test('cat puzzles have a valid (and mostly unique) solution', () {
    var unique = 0;
    for (var level = 1; level <= 150; level++) {
      final p = QueensPuzzle.generate(level, level * 7919 + 17);
      final n = p.n;
      expect(p.solution.toSet().length, n);
      expect(
        {for (var r = 0; r < n; r++) p.regions[r * n + p.solution[r]]}.length,
        n,
      );
      for (var r = 1; r < n; r++) {
        expect((p.solution[r] - p.solution[r - 1]).abs(), greaterThan(1));
      }
      expect(p.regions.toSet().length, n);
      if (p.countSolutions() == 1) unique++;
    }
    expect(unique, 150);
  });

  test('queens difficulty sizes grow from 5x5 to 9x9', () {
    expect(QueensPuzzle.forDifficulty(0, 1, 1).n, 5);
    expect(QueensPuzzle.forDifficulty(1, 1, 1).n, 6);
    expect(QueensPuzzle.forDifficulty(2, 1, 1).n, 7);
    expect(QueensPuzzle.forDifficulty(3, 1, 1).n, 8);
    expect(QueensPuzzle.forDifficulty(3, 30, 1).n, 9);
  });
}
