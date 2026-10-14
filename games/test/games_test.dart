import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_games/games/arrow.dart';
import 'package:puzzle_games/games/bus.dart';
import 'package:puzzle_games/games/munch.dart';
import 'package:puzzle_games/games/queens.dart';
import 'package:puzzle_games/i18n.dart';

void main() {
  test('every UI language has every string', () {
    for (final lang in T.languages) {
      expect(T.missingKeys(lang), isEmpty, reason: lang);
    }
  });

  test('arrow levels are always solvable', () {
    for (var level = 1; level <= 60; level++) {
      final b = ArrowBoard.generate(level, level * 7919 + 17);
      expect(b.arrows.length, greaterThan(5));
      // Removing an arrow never blocks another, so greedy solving works.
      var guard = 0;
      while (b.arrows.isNotEmpty && guard++ < 1000) {
        final free = b.arrows.keys.firstWhere(b.canExit, orElse: () => -1);
        expect(free, isNot(-1), reason: 'stuck at level $level');
        b.arrows.remove(free);
      }
      expect(b.arrows, isEmpty);
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

  test('pixel munch levels replay to an empty board in lane order', () {
    for (var level = 1; level <= 40; level++) {
      final lv = munchLevel(level, level * 7919 + 17);
      final total = lv.lanes.fold<int>(0, (a, l) => a + l.length);
      for (var i = 0; i < total; i++) {
        final e = lv.lanes[i % 3][i ~/ 3];
        for (var k = 0; k < e.left; k++) {
          final bite = munchNextBite(lv.cells, lv.w, lv.h, e.color);
          expect(bite, isNotNull, reason: 'level $level eater $i');
          lv.cells[bite!] = null;
        }
      }
      expect(lv.cells.every((c) => c == null), isTrue, reason: 'level $level');
    }
  });

  test('bus levels are solvable in exit order with the 4-slot stop', () {
    for (var level = 1; level <= 60; level++) {
      final lv = busLevel(level, level * 7919 + 17);
      final queue = List.of(lv.queue);
      final stop = <BusCar>[];
      for (final car in lv.cars.reversed.toList()) {
        expect(
          busRoadClear(lv.size, lv.cars, car),
          isTrue,
          reason: 'level $level blocked',
        );
        lv.cars.remove(car);
        expect(stop.length, lessThan(4), reason: 'level $level stop full');
        stop.add(car);
        // Board as many passengers as possible.
        var moved = true;
        while (moved && queue.isNotEmpty) {
          moved = false;
          final i = stop.indexWhere((c) => c.color == queue.first);
          if (i >= 0) {
            stop[i].seats++;
            queue.removeAt(0);
            if (stop[i].seats >= stop[i].capacity) stop.removeAt(i);
            moved = true;
          }
        }
      }
      expect(queue, isEmpty, reason: 'level $level');
      expect(stop, isEmpty, reason: 'level $level');
    }
  });
}
