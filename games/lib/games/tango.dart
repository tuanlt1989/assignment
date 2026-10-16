import 'dart:math';

import 'package:flutter/material.dart';

import 'session.dart';

/// A "=" / "×" sign between two neighbouring cells [a] < [b] (b is a + 1 for
/// a horizontal pair, a + n for a vertical one). [equal] is true for "=".
typedef TangoSign = ({int a, int b, bool equal});

/// Rule violations in a (partly) filled grid, see [TangoPuzzle.check].
class TangoCheck {
  TangoCheck(this.ids, this.cells, this.signs);

  /// One id per distinct violation (a 3-in-a-row, an over-full line for one
  /// symbol, a broken sign) so a caller can tell when a new one appears.
  final Set<int> ids;

  /// Cells involved in any violation.
  final Set<int> cells;

  /// Indices into [TangoPuzzle.signs] of broken signs.
  final Set<int> signs;

  bool get isEmpty => ids.isEmpty;
}

/// "Sun & Moon" binary puzzle (LinkedIn Tango style): every row and column
/// holds n/2 suns and n/2 moons, never three equal symbols in a line, and
/// "=" / "×" signs say two neighbours are the same / different.
class TangoPuzzle {
  TangoPuzzle(this.n, this.solution, this.givens, this.signs);

  static const empty = 0, sun = 1, moon = 2;

  final int n;

  /// [sun] or [moon] per cell (r * n + c).
  final List<int> solution;

  /// Cells shown (and locked) at the start, sorted.
  final List<int> givens;

  final List<TangoSign> signs;

  late final Set<int> _givenSet = givens.toSet();
  bool isGiven(int cell) => _givenSet.contains(cell);

  /// The starting grid: givens filled, everything else [empty].
  List<int> get start => [
    for (var i = 0; i < n * n; i++) isGiven(i) ? solution[i] : empty,
  ];

  /// 0 easy: 6×6, ~15 givens + a few signs. 1 medium: 6×6, ~9 givens + more
  /// signs. 2 hard: 6×6 minimal clues, mostly signs. 3 expert: 8×8 minimal.
  static TangoPuzzle forDifficulty(int difficulty, int level, int seed) {
    final d = difficulty.clamp(0, 3);
    return generate(d == 3 ? 8 : 6, d, Random(seed * 4 + d));
  }

  static TangoPuzzle generate(int n, int difficulty, Random rnd) {
    final sol = _fullGrid(n, rnd);
    final edges = <TangoSign>[
      for (var r = 0; r < n; r++)
        for (var c = 0; c < n; c++) ...[
          if (c < n - 1)
            (
              a: r * n + c,
              b: r * n + c + 1,
              equal: sol[r * n + c] == sol[r * n + c + 1],
            ),
          if (r < n - 1)
            (
              a: r * n + c,
              b: (r + 1) * n + c,
              equal: sol[r * n + c] == sol[(r + 1) * n + c],
            ),
        ],
    ]..shuffle(rnd);
    final signCount = switch (difficulty) {
      0 => 3 + rnd.nextInt(3),
      1 => 7 + rnd.nextInt(3),
      _ => edges.length * 2 ~/ 5,
    };
    final signs = edges.take(signCount).toList();
    final givens = List<int>.generate(n * n, (i) => i)..shuffle(rnd);
    final givenTarget = switch (difficulty) {
      0 => 14 + rnd.nextInt(3),
      1 => 8 + rnd.nextInt(3),
      // Hard / expert keep a few givens (like the original) and lean on signs.
      _ => n == 6 ? 4 + rnd.nextInt(2) : 6 + rnd.nextInt(3),
    };
    bool solvable(List<int> g, List<TangoSign> s) =>
        TangoPuzzle(n, sol, g, s)._logicSolves();

    // Drop givens (random order) while the puzzle stays solvable by logic.
    for (final cell in List.of(givens)) {
      if (givens.length <= givenTarget) break;
      final without = List.of(givens)..remove(cell);
      if (solvable(without, signs)) givens.remove(cell);
    }
    // Hard / expert: then drop every sign that is not needed either.
    if (difficulty >= 2) {
      for (final s in List.of(signs)) {
        final without = List.of(signs)..remove(s);
        if (solvable(givens, without)) signs.remove(s);
      }
    }
    givens.sort();
    signs.sort((x, y) => x.a != y.a ? x.a - y.a : x.b - y.b);
    return TangoPuzzle(n, sol, givens, signs);
  }

  /// A random valid full grid by backtracking.
  static List<int> _fullGrid(int n, Random rnd) {
    final g = List<int>.filled(n * n, empty);
    final half = n ~/ 2;
    final rowCount = List.generate(n, (_) => [0, 0, 0]);
    final colCount = List.generate(n, (_) => [0, 0, 0]);
    bool fill(int i) {
      if (i == n * n) return true;
      final r = i ~/ n, c = i % n;
      final order = rnd.nextBool() ? const [sun, moon] : const [moon, sun];
      for (final v in order) {
        if (rowCount[r][v] >= half || colCount[c][v] >= half) continue;
        if (c >= 2 && g[i - 1] == v && g[i - 2] == v) continue;
        if (r >= 2 && g[i - n] == v && g[i - 2 * n] == v) continue;
        g[i] = v;
        rowCount[r][v]++;
        colCount[c][v]++;
        if (fill(i + 1)) return true;
        rowCount[r][v]--;
        colCount[c][v]--;
        g[i] = empty;
      }
      return false;
    }

    fill(0);
    return g;
  }

  // ---- Line logic --------------------------------------------------------
  //
  // Lines 0..n-1 are rows, n..2n-1 are columns. A line pattern is a bit mask
  // (bit k set = sun at position k). Every sign lies inside one line, so
  // "all patterns of this line that fit what is known" captures every rule.

  static final _patternCache = <int, List<int>>{};

  /// Balanced patterns with no three equal symbols in a row.
  static List<int> _patterns(int n) => _patternCache.putIfAbsent(n, () {
    final out = <int>[];
    for (var m = 0; m < 1 << n; m++) {
      if (_popCount(m) != n ~/ 2) continue;
      var ok = true;
      for (var k = 0; k + 2 < n && ok; k++) {
        final t = (m >> k) & 7;
        if (t == 0 || t == 7) ok = false;
      }
      if (ok) out.add(m);
    }
    return out;
  });

  static int _popCount(int m) {
    var c = 0;
    for (; m != 0; m &= m - 1) {
      c++;
    }
    return c;
  }

  int _cellOf(int line, int k) => line < n ? line * n + k : k * n + line - n;

  /// Patterns per line that respect the signs inside that line.
  late final List<List<int>> _lineCandidates = () {
    final all = _patterns(n);
    final out = List.generate(2 * n, (_) => List.of(all));
    for (final s in signs) {
      final horizontal = s.b == s.a + 1;
      final line = horizontal ? s.a ~/ n : n + s.a % n;
      final k = horizontal ? s.a % n : s.a ~/ n;
      out[line].removeWhere(
        (m) => (((m >> k) & 1) == ((m >> (k + 1)) & 1)) != s.equal,
      );
    }
    return out;
  }();

  /// Applies line logic to a fixpoint. [cands] is narrowed in place.
  /// Returns false on a contradiction.
  bool _propagate(List<int> v, List<List<int>> cands) {
    final full = (1 << n) - 1;
    final queued = List<bool>.filled(2 * n, true);
    final queue = List<int>.generate(2 * n, (i) => i);
    while (queue.isNotEmpty) {
      final line = queue.removeLast();
      queued[line] = false;
      var known = 0, suns = 0;
      for (var k = 0; k < n; k++) {
        final x = v[_cellOf(line, k)];
        if (x != empty) known |= 1 << k;
        if (x == sun) suns |= 1 << k;
      }
      final list = cands[line];
      list.removeWhere((m) => (m & known) != suns);
      if (list.isEmpty) return false;
      var all = full, any = 0;
      for (final m in list) {
        all &= m;
        any |= m;
      }
      final forcedSun = all & ~known;
      final forcedMoon = ~any & full & ~known;
      if (forcedSun | forcedMoon == 0) continue;
      for (var k = 0; k < n; k++) {
        final bit = 1 << k;
        if ((forcedSun | forcedMoon) & bit == 0) continue;
        final cell = _cellOf(line, k);
        v[cell] = forcedSun & bit != 0 ? sun : moon;
        final cross = line < n ? n + cell % n : cell ~/ n;
        if (!queued[cross]) {
          queued[cross] = true;
          queue.add(cross);
        }
      }
    }
    return true;
  }

  List<List<int>> _freshCandidates() => [
    for (final l in _lineCandidates) List.of(l),
  ];

  /// True when the givens and signs alone force the whole grid by line
  /// logic (no guessing). Implies a unique solution.
  bool _logicSolves() {
    final v = start;
    return _propagate(v, _freshCandidates()) && !v.contains(empty);
  }

  /// Number of solutions, counting at most [limit].
  int countSolutions({int limit = 2}) {
    var found = 0;
    void solve(List<int> v, List<List<int>> cands) {
      if (found >= limit) return;
      if (!_propagate(v, cands)) return;
      final i = v.indexOf(empty);
      if (i < 0) {
        found++;
        return;
      }
      for (final x in const [sun, moon]) {
        final vv = List.of(v)..[i] = x;
        solve(vv, [for (final l in cands) List.of(l)]);
        if (found >= limit) return;
      }
    }

    solve(start, _freshCandidates());
    return found;
  }

  /// A cell that line logic forces next, given a grid holding only correct
  /// symbols; falls back to the first empty cell. Null when full.
  int? nextHintCell(List<int> cells) {
    final v = List.of(cells);
    final cands = _freshCandidates();
    final full = (1 << n) - 1;
    for (var line = 0; line < 2 * n; line++) {
      var known = 0, suns = 0;
      for (var k = 0; k < n; k++) {
        final x = v[_cellOf(line, k)];
        if (x != empty) known |= 1 << k;
        if (x == sun) suns |= 1 << k;
      }
      final list = cands[line].where((m) => (m & known) == suns);
      if (list.isEmpty) continue;
      var all = full, any = 0;
      for (final m in list) {
        all &= m;
        any |= m;
      }
      final forced = (all | (~any & full)) & ~known;
      for (var k = 0; k < n; k++) {
        if (forced & (1 << k) != 0) return _cellOf(line, k);
      }
    }
    final i = v.indexOf(empty);
    return i < 0 ? null : i;
  }

  /// Every rule broken by the symbols placed so far in [v].
  TangoCheck check(List<int> v) {
    final ids = <int>{}, cells = <int>{}, bad = <int>{};
    final half = n ~/ 2;
    for (var line = 0; line < 2 * n; line++) {
      final idx = [for (var k = 0; k < n; k++) _cellOf(line, k)];
      for (var k = 0; k + 2 < n; k++) {
        final x = v[idx[k]];
        if (x != empty && v[idx[k + 1]] == x && v[idx[k + 2]] == x) {
          ids.add(line * n + k);
          cells.addAll(idx.sublist(k, k + 3));
        }
      }
      for (final sym in const [sun, moon]) {
        final of = idx.where((i) => v[i] == sym).toList();
        if (of.length > half) {
          ids.add(2 * n * n + line * 2 + sym - 1);
          cells.addAll(of);
        }
      }
    }
    for (var s = 0; s < signs.length; s++) {
      final x = v[signs[s].a], y = v[signs[s].b];
      if (x != empty && y != empty && (x == y) != signs[s].equal) {
        ids.add(2 * n * n + 4 * n + s);
        cells.addAll([signs[s].a, signs[s].b]);
        bad.add(s);
      }
    }
    return TangoCheck(ids, cells, bad);
  }
}

class TangoGame extends StatefulWidget {
  const TangoGame({super.key, required this.session});
  final GameSession session;

  @override
  State<TangoGame> createState() => _TangoGameState();
}

class _TangoGameState extends State<TangoGame> {
  late final TangoPuzzle _p = TangoPuzzle.forDifficulty(
    widget.session.difficulty,
    widget.session.level,
    widget.session.seed,
  );
  late final List<int> _cells = _p.start;
  late TangoCheck _check = _p.check(_cells);
  final _history = <(int, int)>[];
  int? _hinted;
  bool _won = false;

  static const _sunColor = Color(0xFFFFA000);
  static const _moonColor = Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    widget.session.hint.addListener(_hint);
    if (widget.session.demo) {
      // Screenshot mode: about half the board already filled in correctly.
      final open = [
        for (var i = 0; i < _cells.length; i++)
          if (_cells[i] == TangoPuzzle.empty) i,
      ]..shuffle(Random(widget.session.seed));
      final want = _cells.length ~/ 2 - _p.givens.length;
      for (final i in open.take(max(0, min(want, open.length - 1)))) {
        _cells[i] = _p.solution[i];
      }
      _check = _p.check(_cells);
    }
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_hint);
    super.dispose();
  }

  void _hint() {
    if (_won) return;
    int? cell;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i] != TangoPuzzle.empty && _cells[i] != _p.solution[i]) {
        cell = i;
        break;
      }
    }
    cell ??= _p.nextHintCell(_cells);
    if (cell == null) return;
    final target = cell;
    _set(target, _p.solution[target], byPlayer: false);
    setState(() => _hinted = target);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted && _hinted == target) setState(() => _hinted = null);
    });
  }

  void _tap(int cell) {
    if (_won || _p.isGiven(cell)) return;
    _set(cell, (_cells[cell] + 1) % 3, byPlayer: true);
  }

  void _set(int cell, int value, {required bool byPlayer}) {
    final before = _check.ids;
    setState(() {
      _history.add((cell, _cells[cell]));
      _cells[cell] = value;
      _check = _p.check(_cells);
    });
    if (byPlayer && _check.ids.difference(before).isNotEmpty) {
      widget.session.addMistake();
    }
    _checkWin();
  }

  void _undo() {
    if (_won || _history.isEmpty) return;
    final (cell, prev) = _history.removeLast();
    setState(() {
      _cells[cell] = prev;
      _check = _p.check(_cells);
    });
    _checkWin();
  }

  void _checkWin() {
    if (_won) return;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i] != _p.solution[i]) return;
    }
    _won = true;
    Future.delayed(const Duration(milliseconds: 300), widget.session.onWin);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black87, width: 3),
                  ),
                  child: LayoutBuilder(
                    builder: (context, box) => _board(box.maxWidth),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          iconSize: 30,
          onPressed: _history.isEmpty || _won ? null : _undo,
          icon: const Icon(Icons.undo),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _board(double side) {
    final n = _p.n;
    final s = side / n;
    final badge = s * 0.36;
    return Stack(
      children: [
        for (var i = 0; i < n * n; i++)
          Positioned(
            left: (i % n) * s,
            top: (i ~/ n) * s,
            width: s,
            height: s,
            child: _cell(i, s),
          ),
        for (var k = 0; k < _p.signs.length; k++)
          () {
            final sign = _p.signs[k];
            final r = sign.a ~/ n, c = sign.a % n;
            final horizontal = sign.b == sign.a + 1;
            final x = horizontal ? (c + 1) * s : (c + 0.5) * s;
            final y = horizontal ? (r + 0.5) * s : (r + 1) * s;
            final broken = _check.signs.contains(k);
            return Positioned(
              left: x - badge / 2,
              top: y - badge / 2,
              width: badge,
              height: badge,
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: broken ? Colors.red.shade600 : Colors.white,
                    borderRadius: BorderRadius.circular(badge * 0.3),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Text(
                    sign.equal ? '=' : '×',
                    style: TextStyle(
                      fontSize: badge * 0.72,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: broken ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }

  Widget _cell(int i, double s) {
    final given = _p.isGiven(i);
    final bad = _check.cells.contains(i);
    final color = _hinted == i
        ? Colors.lightGreen.shade200
        : bad
        ? Colors.red.shade200
        : given
        ? Colors.grey.shade300
        : Colors.white;
    return GestureDetector(
      key: ValueKey('tango-cell-$i'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _tap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black26, width: 0.5),
        ),
        child: switch (_cells[i]) {
          TangoPuzzle.sun => Icon(
            Icons.wb_sunny,
            size: s * 0.6,
            color: _sunColor,
          ),
          TangoPuzzle.moon => Icon(
            Icons.nightlight_round,
            size: s * 0.56,
            color: _moonColor,
          ),
          _ => const SizedBox.expand(),
        },
      ),
    );
  }
}
