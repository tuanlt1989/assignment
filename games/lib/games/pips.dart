import 'dart:math';

import 'package:flutter/material.dart';

import 'session.dart';

/// Condition carried by a coloured region of the board.
enum PipsRule { none, sum, equal, distinct, less, greater }

/// One domino: two halves with 0–6 pips each.
class PipsDomino {
  const PipsDomino(this.a, this.b);
  final int a;
  final int b;

  @override
  String toString() => '[$a|$b]';
}

/// A group of board cells (grid indices) with one condition on their pips.
class PipsRegion {
  PipsRegion(this.cells, this.rule, this.target);
  final List<int> cells;
  final PipsRule rule;
  final int target;

  /// Short badge text: "Σ8", "=", "≠", "<3", ">10".
  String get label => switch (rule) {
    PipsRule.none => '',
    PipsRule.sum => 'Σ$target',
    PipsRule.equal => '=',
    PipsRule.distinct => '≠',
    PipsRule.less => '<$target',
    PipsRule.greater => '>$target',
  };

  /// Whether the (complete) pip values of this region's cells satisfy it.
  bool holds(List<int> values) => _holds(rule, target, values);
}

bool _holds(PipsRule rule, int target, List<int> v) {
  final sum = v.fold<int>(0, (a, b) => a + b);
  return switch (rule) {
    PipsRule.none => true,
    PipsRule.sum => sum == target,
    PipsRule.less => sum < target,
    PipsRule.greater => sum > target,
    PipsRule.equal => v.every((x) => x == v.first),
    PipsRule.distinct => v.toSet().length == v.length,
  };
}

/// Domino logic puzzle: place every domino of the tray on two adjacent cells
/// so that every region's condition holds. The pip value of every cell is
/// uniquely determined.
class PipsPuzzle {
  PipsPuzzle._(
    this.width,
    this.height,
    this.cells,
    this.regions,
    this.dominoes,
    this.solution,
    this.placement,
  ) {
    for (final g in cells) {
      _inBoard[g] = true;
    }
    for (var r = 0; r < regions.length; r++) {
      for (final g in regions[r].cells) {
        regionOf[g] = r;
      }
    }
  }

  final int width;
  final int height;

  /// Board cells as grid indices (row * width + col), ascending.
  final List<int> cells;
  final List<PipsRegion> regions;
  final List<PipsDomino> dominoes;

  /// Pip value per grid index (-1 = not a board cell).
  final List<int> solution;

  /// For each domino: (cell holding half a, cell holding half b).
  final List<(int, int)> placement;

  late final List<int> regionOf = List<int>.filled(width * height, -1);
  late final List<bool> _inBoard = List<bool>.filled(width * height, false);

  bool isCell(int g) => g >= 0 && g < width * height && _inBoard[g];

  /// Board cells next to [g].
  List<int> neighbours(int g) {
    final r = g ~/ width, c = g % width;
    return [
      if (r > 0 && _inBoard[g - width]) g - width,
      if (r < height - 1 && _inBoard[g + width]) g + width,
      if (c > 0 && _inBoard[g - 1]) g - 1,
      if (c < width - 1 && _inBoard[g + 1]) g + 1,
    ];
  }

  /// Regions whose cells are all filled in [values] (per grid index, -1 =
  /// empty) but whose condition fails.
  List<int> brokenRegions(List<int> values) => [
    for (var r = 0; r < regions.length; r++)
      if (regions[r].cells.every((g) => values[g] >= 0) &&
          !regions[r].holds([for (final g in regions[r].cells) values[g]]))
        r,
  ];

  /// True when every cell is filled and every condition holds.
  bool isSolved(List<int> values) =>
      cells.every((g) => values[g] >= 0) && brokenRegions(values).isEmpty;

  /// Number of distinct pip-value assignments (up to [limit]) that place all
  /// dominoes and satisfy every condition.
  int countSolutions({int limit = 2}) => _solver(limit, 0).run().length;

  _Solver _solver(int limit, int budget) => _Solver(
    cells,
    width,
    regionOf,
    [for (final r in regions) (r.rule, r.target, r.cells.length)],
    dominoes,
    limit,
    budget,
  );

  static const _baseDominoes = [4, 6, 8, 10];
  static const _extraDominoes = [1, 1, 1, 2];

  static PipsPuzzle generate(int difficulty, int level, int seed) {
    final d = difficulty.clamp(0, 3);
    final rnd = Random(seed);
    final k =
        _baseDominoes[d] +
        min<int>(_extraDominoes[d], rnd.nextInt(2) + max(0, level - 1) ~/ 10);
    _Draft? last;
    for (var attempt = 0; attempt < 8; attempt++) {
      final draft = _Draft.random(d, k, rnd);
      if (draft.makeUnique(rnd)) {
        draft.reduce(rnd);
        return draft.build();
      }
      last = draft;
    }
    last!.pinAll();
    return last.build();
  }
}

/// Backtracking solver over domino placements. Collects distinct pip-value
/// assignments (two tilings with the same values count once).
class _Solver {
  _Solver(
    List<int> cells,
    int width,
    List<int> regionOfGrid,
    List<(PipsRule, int, int)> regs,
    List<PipsDomino> dom,
    this.limit,
    this.budget,
  ) : n = cells.length,
      m = dom.length {
    final local = {for (var i = 0; i < cells.length; i++) cells[i]: i};
    _adj = [
      for (final g in cells)
        [
          for (final x in [g - width, g + width])
            if (local.containsKey(x)) local[x]!,
          if (g % width > 0 && local.containsKey(g - 1)) local[g - 1]!,
          if (g % width < width - 1 && local.containsKey(g + 1)) local[g + 1]!,
        ],
    ];
    _reg = [for (final g in cells) regionOfGrid[g]];
    _rule = [for (final r in regs) r.$1.index];
    _target = [for (final r in regs) r.$2];
    _size = [for (final r in regs) r.$3];
    _sum = List.filled(regs.length, 0);
    _fill = List.filled(regs.length, 0);
    _cnt = List.filled(regs.length * 7, 0);
    _pri = [
      for (final r in _reg)
        r < 0
            ? 4
            : switch (regs[r].$1) {
                PipsRule.none => 4,
                PipsRule.less || PipsRule.greater => 2,
                PipsRule.distinct => 1,
                _ => 0,
              },
    ];
    _da = [for (final x in dom) x.a];
    _db = [for (final x in dom) x.b];
    _v = List.filled(n, -1);
    _used = List.filled(m, false);
    _avail = List.filled(7, 0);
    for (final x in dom) {
      _avail[x.a]++;
      _avail[x.b]++;
    }
  }

  final int n, m, limit, budget;
  late final List<List<int>> _adj;
  late final List<int> _reg, _rule, _target, _size, _sum, _fill, _cnt, _pri;
  late final List<int> _da, _db, _v, _avail;
  late final List<bool> _used;
  int nodes = 0;
  bool aborted = false;
  final _found = <List<int>>[];
  final _keys = <String>{};

  static final _sumRule = PipsRule.sum.index;
  static final _lessRule = PipsRule.less.index;
  static final _equalRule = PipsRule.equal.index;
  static final _distinctRule = PipsRule.distinct.index;
  static final _noRule = PipsRule.none.index;

  /// Distinct solutions as pip values per local cell (board cell order).
  List<List<int>> run() {
    _go();
    return _found;
  }

  /// Sets cell [c] to [v] (region bookkeeping only).
  void _put(int c, int v) {
    _v[c] = v;
    final r = _reg[c];
    if (r < 0) return;
    _sum[r] += v;
    _fill[r]++;
    _cnt[r * 7 + v]++;
  }

  void _take(int c, int v) {
    _v[c] = -1;
    final r = _reg[c];
    if (r < 0) return;
    _sum[r] -= v;
    _fill[r]--;
    _cnt[r * 7 + v]--;
  }

  /// Can region [r] (just given value [v]) still be satisfied with the pip
  /// halves left in the tray?
  bool _ok(int r, int v) {
    if (r < 0) return true;
    final rule = _rule[r];
    final left = _size[r] - _fill[r];
    if (rule == _equalRule) {
      return _cnt[r * 7 + v] == _fill[r] && _avail[v] >= left;
    }
    if (rule == _distinctRule) {
      if (_cnt[r * 7 + v] != 1) return false;
      var free = 0;
      for (var x = 0; x < 7; x++) {
        if (_avail[x] > 0 && _cnt[r * 7 + x] == 0) free++;
      }
      return free >= left;
    }
    if (rule == _noRule) return true;
    // Smallest / largest total the remaining cells can still reach.
    var lo = 0, hi = 0;
    var need = left;
    for (var x = 0; x < 7 && need > 0; x++) {
      final k = min(need, _avail[x]);
      lo += k * x;
      need -= k;
    }
    need = left;
    for (var x = 6; x >= 0 && need > 0; x--) {
      final k = min(need, _avail[x]);
      hi += k * x;
      need -= k;
    }
    final s = _sum[r], t = _target[r];
    if (rule == _sumRule) return s + lo <= t && s + hi >= t;
    if (rule == _lessRule) return s + lo < t;
    return s + hi > t; // greater
  }

  void _go() {
    if (aborted || _found.length >= limit) return;
    if (budget > 0 && ++nodes > budget) {
      aborted = true;
      return;
    }
    // Most constrained empty cell: fewest empty neighbours, then tightest rule.
    var best = -1, bestKey = 1 << 30;
    for (var c = 0; c < n; c++) {
      if (_v[c] >= 0) continue;
      var deg = 0;
      for (final x in _adj[c]) {
        if (_v[x] < 0) deg++;
      }
      if (deg == 0) return;
      final key = deg * 8 + _pri[c];
      if (key < bestKey) {
        bestKey = key;
        best = c;
      }
    }
    if (best < 0) {
      final key = String.fromCharCodes(_v);
      if (_keys.add(key)) _found.add(List.of(_v));
      return;
    }
    for (final x in _adj[best]) {
      if (_v[x] >= 0) continue;
      for (var d = 0; d < m; d++) {
        if (_used[d]) continue;
        final a = _da[d], b = _db[d];
        _try(best, a, x, b, d);
        if (a != b) _try(best, b, x, a, d);
        if (aborted || _found.length >= limit) return;
      }
    }
  }

  void _try(int c, int a, int x, int b, int d) {
    _used[d] = true;
    _avail[a]--;
    _avail[b]--;
    _put(c, a);
    _put(x, b);
    if (_ok(_reg[c], a) && _ok(_reg[x], b)) _go();
    _take(x, b);
    _take(c, a);
    _avail[a]++;
    _avail[b]++;
    _used[d] = false;
  }
}

class _Reg {
  _Reg(this.cells, this.rule, this.target);
  List<int> cells;
  PipsRule rule;
  int target;
}

/// Mutable puzzle under construction.
class _Draft {
  _Draft(this.d, this.w, this.h, this.cells, this.sol, this.dom, this.place);

  final int d, w, h;
  final List<int> cells;
  final List<int> sol;
  final List<PipsDomino> dom;
  final List<(int, int)> place;
  final regs = <_Reg>[];

  static const _maxRegion = [2, 3, 4, 5];
  static const _budget = 40000;

  /// Random connected board grown one domino at a time (so it is tileable),
  /// distinct dominoes from a double-six set, random regions + conditions.
  static _Draft random(int d, int k, Random rnd) {
    final bw = k >= 8 ? 6 : 5, bh = k >= 10 ? 7 : 6;
    final used = List<bool>.filled(bw * bh, false);
    final pairs = <(int, int)>[];
    List<int> around(int g) {
      final r = g ~/ bw, c = g % bw;
      return [
        if (r > 0) g - bw,
        if (r < bh - 1) g + bw,
        if (c > 0) g - 1,
        if (c < bw - 1) g + 1,
      ];
    }

    final start = (bh ~/ 2) * bw + bw ~/ 2 - 1;
    final first = rnd.nextBool() ? start + 1 : start + bw;
    pairs.add((start, first));
    used[start] = used[first] = true;
    var guard = 0;
    while (pairs.length < k && guard++ < 2000) {
      final options = <int>[];
      final weights = <int>[];
      for (var g = 0; g < bw * bh; g++) {
        if (used[g]) continue;
        final touching = around(g).where((x) => used[x]).length;
        if (touching == 0) continue;
        if (around(g).every((x) => used[x])) continue;
        options.add(g);
        weights.add(1 + touching * touching * 2);
      }
      if (options.isEmpty) break;
      var pick = rnd.nextInt(weights.fold(0, (a, b) => a + b));
      var i = 0;
      while (pick >= weights[i]) {
        pick -= weights[i];
        i++;
      }
      final g = options[i];
      final free = around(g).where((x) => !used[x]).toList();
      final g2 = free[rnd.nextInt(free.length)];
      used[g] = used[g2] = true;
      pairs.add((g, g2));
    }
    // Crop to the bounding box.
    var r0 = bh, r1 = 0, c0 = bw, c1 = 0;
    for (var g = 0; g < bw * bh; g++) {
      if (!used[g]) continue;
      r0 = min(r0, g ~/ bw);
      r1 = max(r1, g ~/ bw);
      c0 = min(c0, g % bw);
      c1 = max(c1, g % bw);
    }
    final w = c1 - c0 + 1, h = r1 - r0 + 1;
    int map(int g) => (g ~/ bw - r0) * w + (g % bw - c0);
    final all = <PipsDomino>[
      for (var a = 0; a <= 6; a++)
        for (var b = a; b <= 6; b++) PipsDomino(a, b),
    ]..shuffle(rnd);
    final dom = all.take(pairs.length).toList();
    final sol = List<int>.filled(w * h, -1);
    final place = <(int, int)>[];
    for (var i = 0; i < pairs.length; i++) {
      var (x, y) = (map(pairs[i].$1), map(pairs[i].$2));
      if (rnd.nextBool()) (x, y) = (y, x);
      sol[x] = dom[i].a;
      sol[y] = dom[i].b;
      place.add((x, y));
    }
    final cells = [
      for (var g = 0; g < w * h; g++)
        if (sol[g] >= 0) g,
    ];
    return _Draft(d, w, h, cells, sol, dom, place).._initRegions(rnd);
  }

  List<int> _nb(int g) {
    final r = g ~/ w, c = g % w;
    return [
      if (r > 0 && sol[g - w] >= 0) g - w,
      if (r < h - 1 && sol[g + w] >= 0) g + w,
      if (c > 0 && sol[g - 1] >= 0) g - 1,
      if (c < w - 1 && sol[g + 1] >= 0) g + 1,
    ];
  }

  List<int> _regionIndex() {
    final idx = List<int>.filled(w * h, -1);
    for (var r = 0; r < regs.length; r++) {
      for (final g in regs[r].cells) {
        idx[g] = r;
      }
    }
    return idx;
  }

  /// The other half of the domino covering [g] in the solution.
  late final List<int> _partner = () {
    final out = List<int>.filled(w * h, -1);
    for (final (a, b) in place) {
      out[a] = b;
      out[b] = a;
    }
    return out;
  }();

  /// Starts tight: every cell in a small region with an exact condition.
  void _initRegions(Random rnd) {
    final owner = List<int>.filled(w * h, -1);
    final order = List.of(cells)..shuffle(rnd);
    for (final g in order) {
      if (owner[g] != -1) continue;
      final size = const [1, 2, 2, 2, 3, 3][rnd.nextInt(6)];
      final sameValue = rnd.nextDouble() < 0.35;
      final region = [g];
      owner[g] = regs.length;
      while (region.length < size) {
        final grow = <int>[
          for (final x in region)
            for (final y in _nb(x))
              if (owner[y] == -1 &&
                  (sol[y] == sol[g] ||
                      (!sameValue && !region.contains(_partner[y]))))
                y,
        ];
        if (grow.isEmpty) break;
        final y = grow[rnd.nextInt(grow.length)];
        owner[y] = regs.length;
        region.add(y);
      }
      final values = [for (final x in region) sol[x]];
      regs.add(
        values.length > 1 && values.every((v) => v == values.first)
            ? _Reg(region, PipsRule.equal, 0)
            : _Reg(region, PipsRule.sum, values.fold(0, (a, b) => a + b)),
      );
    }
  }

  /// A condition that pip values [s] satisfy and (if given) [alt] breaks.
  (PipsRule, int)? _pickCond(List<int> s, List<int>? alt, Random rnd) {
    final sum = s.fold<int>(0, (a, b) => a + b);
    final altSum = alt?.fold<int>(0, (a, b) => a + b);
    final allEqual = s.every((x) => x == s.first);
    final allDistinct = s.toSet().length == s.length;
    final options = <(PipsRule, int)>[];
    final weights = <int>[];
    void add((PipsRule, int) c, int weight) {
      if (alt != null && _holds(c.$1, c.$2, alt)) return;
      options.add(c);
      weights.add(weight);
    }

    final slack = const [1, 2, 3, 3][d];
    add((PipsRule.sum, sum), const [8, 6, 4, 3][d]);
    if (s.length >= 2 && allEqual) add((PipsRule.equal, 0), 14);
    if (s.length >= (d >= 2 ? 2 : 3) && allDistinct) {
      add((PipsRule.distinct, 0), const [2, 3, 4, 4][d]);
    }
    var hiCap = 6 * s.length; // "<t" with t above this would be vacuous.
    if (altSum != null) hiCap = min(hiCap, altSum);
    if (sum + 1 <= hiCap) {
      final t = sum + 1 + rnd.nextInt(min(slack, hiCap - sum));
      add((PipsRule.less, t), const [1, 2, 3, 4][d]);
    }
    final loCap = altSum ?? 0;
    if (sum - 1 >= loCap) {
      final t = sum - 1 - rnd.nextInt(min(slack, sum - loCap));
      add((PipsRule.greater, t), const [1, 2, 3, 4][d]);
    }
    if (options.isEmpty) return null;
    var pick = rnd.nextInt(weights.fold(0, (a, b) => a + b));
    for (var i = 0; i < options.length; i++) {
      if (pick < weights[i]) return options[i];
      pick -= weights[i];
    }
    return options.last;
  }

  _Solver _solver(int limit, int budget) => _Solver(
    cells,
    w,
    _regionIndex(),
    [for (final r in regs) (r.rule, r.target, r.cells.length)],
    dom,
    limit,
    budget,
  );

  /// Second solution (pip values per grid index) or null when unique.
  /// Returns `(aborted, alt)`.
  (bool, List<int>?) _alternative([_Solver? solver]) {
    final s = solver ?? _solver(2, _budget);
    final found = s.run();
    if (s.aborted) return (true, null);
    for (final f in found) {
      final grid = List<int>.filled(w * h, -1);
      for (var i = 0; i < cells.length; i++) {
        grid[cells[i]] = f[i];
      }
      for (final g in cells) {
        if (grid[g] != sol[g]) return (false, grid);
      }
    }
    return (false, null);
  }

  /// Add / tighten conditions until the solution is unique.
  bool makeUnique(Random rnd) {
    for (var step = 0; step < 60; step++) {
      final (aborted, alt) = _alternative();
      if (aborted) {
        _tightenRandom(rnd);
      } else if (alt == null) {
        return true;
      } else {
        _tightenAgainst(alt, rnd);
      }
    }
    return false;
  }

  static const _maxMerged = [3, 4, 5, 6];
  static const _blankCap = [0.15, 0.2, 0.3, 0.35];
  static const _trials = [16, 24, 36, 48];

  /// Solver nodes the whole reduction may spend (keeps generation fast).
  static const _reduceNodes = [20000, 30000, 45000, 60000];
  static const _trialNodes = 6000;

  /// Make the puzzle leaner while it stays unique: merge neighbouring
  /// regions, drop regions (blank cells), loosen exact sums to < / >.
  void reduce(Random rnd) {
    var trials = _trials[d];
    var nodesLeft = _reduceNodes[d];
    while (trials > 0) {
      final idx = _regionIndex();
      final blanks = cells.where((g) => idx[g] < 0).length;
      var ops = <(int, int, int)>[];
      for (var a = 0; a < regs.length; a++) {
        final ra = regs[a];
        final near = <int>{
          for (final g in ra.cells)
            for (final y in _nb(g))
              if (idx[y] > a) idx[y],
        };
        for (final b in near) {
          if (ra.cells.length + regs[b].cells.length <= _maxMerged[d]) {
            ops.add((0, a, b));
          }
        }
        if (blanks + ra.cells.length <= cells.length * _blankCap[d]) {
          ops.add((1, a, 0));
        }
        if (d >= 1 && ra.rule == PipsRule.sum) ops.add((2, a, 0));
      }
      ops.shuffle(rnd);
      // Absorbing single-cell regions first gives nicer boards (every other
      // round, so blanks and loose < / > conditions still show up).
      bool single((int, int, int) op) =>
          op.$1 == 0 &&
          (regs[op.$2].cells.length == 1 || regs[op.$3].cells.length == 1);
      if (rnd.nextBool()) {
        ops = [...ops.where(single), ...ops.where((op) => !single(op))];
      }
      var changed = false;
      for (final op in ops) {
        if (trials-- <= 0 || nodesLeft <= 0) return;
        final saved = [
          for (final r in regs) _Reg(List.of(r.cells), r.rule, r.target),
        ];
        if (_apply(op, rnd)) {
          final solver = _solver(2, min(_trialNodes, nodesLeft));
          final (aborted, alt) = _alternative(solver);
          nodesLeft -= solver.nodes;
          if (!aborted && alt == null) {
            changed = true;
            break;
          }
        }
        regs
          ..clear()
          ..addAll(saved);
      }
      if (!changed) return;
    }
  }

  bool _apply((int, int, int) op, Random rnd) {
    final (kind, a, b) = op;
    if (kind == 1) {
      regs.removeAt(a);
      return true;
    }
    final reg = regs[a];
    if (kind == 0) {
      final merged = [...reg.cells, ...regs[b].cells];
      final values = [for (final g in merged) sol[g]];
      final sum = values.fold<int>(0, (x, y) => x + y);
      regs.removeAt(b);
      if (values.every((v) => v == values.first)) {
        regs[a] = _Reg(merged, PipsRule.equal, 0);
      } else if (d >= 2 &&
          values.toSet().length == values.length &&
          rnd.nextInt(3) == 0) {
        regs[a] = _Reg(merged, PipsRule.distinct, 0);
      } else {
        regs[a] = _Reg(merged, PipsRule.sum, sum);
      }
      return true;
    }
    // Loosen an exact sum.
    final values = [for (final g in reg.cells) sol[g]];
    final sum = values.fold<int>(0, (x, y) => x + y);
    final slack = rnd.nextInt(d);
    final options = <(PipsRule, int)>[
      if (sum + 1 + slack <= 6 * values.length)
        (PipsRule.less, sum + 1 + slack),
      if (sum - 1 - slack >= 0) (PipsRule.greater, sum - 1 - slack),
      if (d >= 2 &&
          values.length >= 2 &&
          values.toSet().length == values.length)
        (PipsRule.distinct, 0),
    ];
    if (options.isEmpty) return false;
    final pick = options[rnd.nextInt(options.length)];
    reg
      ..rule = pick.$1
      ..target = pick.$2;
    return true;
  }

  void _tightenAgainst(List<int> alt, Random rnd) {
    final diff = [
      for (final g in cells)
        if (alt[g] != sol[g]) g,
    ]..shuffle(rnd);
    final idx = _regionIndex();
    // Prefer giving a blank cell a condition, else tighten its region.
    final g = diff.firstWhere((x) => idx[x] < 0, orElse: () => diff.first);
    final r = idx[g];
    if (r < 0) {
      final region = [g];
      final size = 1 + rnd.nextInt(min(3, _maxRegion[d]));
      while (region.length < size) {
        final grow = [
          for (final x in region)
            for (final y in _nb(x))
              if (idx[y] < 0 && !region.contains(y)) y,
        ];
        if (grow.isEmpty) break;
        region.add(grow[rnd.nextInt(grow.length)]);
      }
      var cond = _pickCond(
        [for (final x in region) sol[x]],
        [for (final x in region) alt[x]],
        rnd,
      );
      if (cond == null) {
        region
          ..clear()
          ..add(g);
        cond = _pickCond([sol[g]], [alt[g]], rnd)!;
      }
      regs.add(_Reg(region, cond.$1, cond.$2));
      return;
    }
    final reg = regs[r];
    final cond = _pickCond(
      [for (final x in reg.cells) sol[x]],
      [for (final x in reg.cells) alt[x]],
      rnd,
    );
    if (cond != null) {
      reg
        ..rule = cond.$1
        ..target = cond.$2;
      return;
    }
    _split(r, g, rnd, alt);
  }

  /// Cut cell [g] out of region [r] into its own region.
  void _split(int r, int g, Random rnd, List<int>? alt) {
    final reg = regs.removeAt(r);
    final single = _pickCond([sol[g]], alt == null ? null : [alt[g]], rnd)!;
    regs.add(_Reg([g], single.$1, single.$2));
    final rest = reg.cells.where((x) => x != g).toSet();
    while (rest.isNotEmpty) {
      final comp = <int>[rest.first];
      rest.remove(rest.first);
      for (var i = 0; i < comp.length; i++) {
        for (final y in _nb(comp[i])) {
          if (rest.remove(y)) comp.add(y);
        }
      }
      final values = [for (final x in comp) sol[x]];
      final sum = values.fold<int>(0, (a, b) => a + b);
      var rule = reg.rule, target = reg.target;
      if (rule == PipsRule.sum) target = sum;
      if (rule == PipsRule.greater && sum <= target) rule = PipsRule.sum;
      if (rule == PipsRule.sum) target = sum;
      if ((rule == PipsRule.equal || rule == PipsRule.distinct) &&
          comp.length == 1) {
        continue; // A single cell can't be "equal"/"different": leave blank.
      }
      regs.add(_Reg(comp, rule, target));
    }
  }

  /// Search too big: make something stricter without a guiding alternative.
  void _tightenRandom(Random rnd) {
    final idx = _regionIndex();
    final blank = [
      for (final g in cells)
        if (idx[g] < 0) g,
    ];
    if (blank.isNotEmpty) {
      final g = blank[rnd.nextInt(blank.length)];
      regs.add(_Reg([g], PipsRule.sum, sol[g]));
      return;
    }
    final loose = [
      for (var r = 0; r < regs.length; r++)
        if (regs[r].rule != PipsRule.sum && regs[r].rule != PipsRule.equal) r,
    ];
    if (loose.isNotEmpty) {
      final reg = regs[loose[rnd.nextInt(loose.length)]];
      reg
        ..rule = PipsRule.sum
        ..target = reg.cells.fold<int>(0, (a, g) => a + sol[g]);
      return;
    }
    final big = [
      for (var r = 0; r < regs.length; r++)
        if (regs[r].cells.length > 1) r,
    ];
    if (big.isEmpty) return;
    final r = big[rnd.nextInt(big.length)];
    final cs = regs[r].cells;
    _split(r, cs[rnd.nextInt(cs.length)], rnd, null);
  }

  /// Fallback: every cell gets an exact value (always unique).
  void pinAll() {
    regs
      ..clear()
      ..addAll([
        for (final g in cells) _Reg([g], PipsRule.sum, sol[g]),
      ]);
  }

  PipsPuzzle build() => PipsPuzzle._(
    w,
    h,
    cells,
    [
      for (final r in regs)
        PipsRegion(List.unmodifiable(r.cells..sort()), r.rule, r.target),
    ],
    dom,
    sol,
    place,
  );
}

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------

class PipsGame extends StatefulWidget {
  const PipsGame({super.key, required this.session});
  final GameSession session;

  @override
  State<PipsGame> createState() => _PipsGameState();
}

class _PipsGameState extends State<PipsGame> {
  late final PipsPuzzle _p = PipsPuzzle.generate(
    widget.session.difficulty,
    widget.session.level,
    widget.session.seed,
  );

  /// Placed dominoes: (cell of half a, cell of half b), or null in the tray.
  late final List<(int, int)?> _pos = List.filled(_p.dominoes.length, null);

  /// Tray orientation: 0 a|b, 1 a over b, 2 b|a, 3 b over a.
  late final List<int> _turn = List.filled(_p.dominoes.length, 0);
  late final List<Color> _fill = _regionColors();
  final _boardKey = GlobalKey();
  int? _sel;
  Set<int> _flash = {};
  bool _over = false;
  bool _won = false;
  double _cell = 48;

  static const _palette = [
    (Color(0xFFF8BBD0), Color(0xFFC2185B)),
    (Color(0xFFBBDEFB), Color(0xFF1565C0)),
    (Color(0xFFC8E6C9), Color(0xFF2E7D32)),
    (Color(0xFFFFE0B2), Color(0xFFE65100)),
    (Color(0xFFE1BEE7), Color(0xFF6A1B9A)),
    (Color(0xFFB2DFDB), Color(0xFF00695C)),
    (Color(0xFFFFF59D), Color(0xFF9E7700)),
    (Color(0xFFC5CAE9), Color(0xFF283593)),
    (Color(0xFFDCEDC8), Color(0xFF558B2F)),
    (Color(0xFFD7CCC8), Color(0xFF5D4037)),
  ];
  late final List<int> _paletteOf = _assignPalette();

  @override
  void initState() {
    super.initState();
    widget.session.hint.addListener(_hint);
    if (widget.session.demo) {
      // Screenshot mode: about half the dominoes already in place.
      for (var i = 0; i < _p.dominoes.length ~/ 2; i++) {
        _pos[i] = _p.placement[i];
      }
      _sel = _p.dominoes.length ~/ 2;
    }
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_hint);
    super.dispose();
  }

  List<int> _assignPalette() {
    final out = List<int>.filled(_p.regions.length, 0);
    final offset = widget.session.seed.abs() % _palette.length;
    for (var r = 0; r < _p.regions.length; r++) {
      final taken = <int>{};
      for (final g in _p.regions[r].cells) {
        for (final x in _p.neighbours(g)) {
          final o = _p.regionOf[x];
          if (o >= 0 && o < r) taken.add(out[o]);
        }
      }
      var c = (offset + r * 3) % _palette.length;
      for (var k = 0; k < _palette.length && taken.contains(c); k++) {
        c = (c + 1) % _palette.length;
      }
      out[r] = c;
    }
    return out;
  }

  List<Color> _regionColors() => [
    for (var r = 0; r < _p.regions.length; r++) _palette[_paletteOf[r]].$1,
  ];

  List<int> get _values {
    final v = List<int>.filled(_p.width * _p.height, -1);
    for (var i = 0; i < _pos.length; i++) {
      final p = _pos[i];
      if (p == null) continue;
      v[p.$1] = _p.dominoes[i].a;
      v[p.$2] = _p.dominoes[i].b;
    }
    return v;
  }

  int _occupant(int g) {
    for (var i = 0; i < _pos.length; i++) {
      final p = _pos[i];
      if (p != null && (p.$1 == g || p.$2 == g)) return i;
    }
    return -1;
  }

  void _hint() {
    if (_over) return;
    int? pick;
    for (var i = 0; i < _pos.length && pick == null; i++) {
      final (a, b) = _p.placement[i];
      if (_pos[i] == null && _occupant(a) < 0 && _occupant(b) < 0) pick = i;
    }
    for (var i = 0; i < _pos.length && pick == null; i++) {
      if (_pos[i] != _p.placement[i]) pick = i;
    }
    if (pick == null) return;
    final target = _p.placement[pick];
    setState(() {
      _pos[pick!] = null;
      for (final g in [target.$1, target.$2]) {
        final o = _occupant(g);
        if (o >= 0) _pos[o] = null;
      }
      _pos[pick] = target;
      if (_sel == pick) _sel = null;
    });
    _checkDone(fromHint: true);
  }

  void _tapTray(int i) {
    if (_over) return;
    setState(() {
      if (_sel == i) {
        _turn[i] = (_turn[i] + 1) % 4;
      } else {
        _sel = i;
      }
    });
  }

  void _tapBoard(int g) {
    if (_over || !_p.isCell(g)) return;
    final o = _occupant(g);
    if (o >= 0) {
      setState(() {
        _pos[o] = null;
        _sel = o;
      });
      return;
    }
    final s = _sel;
    if (s != null && _place(s, g)) {
      setState(() {
        _sel = null;
        for (var i = 0; i < _pos.length; i++) {
          if (_pos[i] == null) {
            _sel = i;
            break;
          }
        }
      });
      _checkDone();
    }
  }

  /// Puts domino [i] with its first (top/left) half on [g]; the second half
  /// goes right/down per its orientation, else to any other free side.
  bool _place(int i, int g) {
    final turn = _turn[i];
    final firstIsA = turn < 2;
    final w = _p.width;
    final r = g ~/ w, c = g % w;
    final dirs = turn.isEven
        ? const [(0, 1), (0, -1), (1, 0), (-1, 0)]
        : const [(1, 0), (-1, 0), (0, 1), (0, -1)];
    for (final (dr, dc) in dirs) {
      final rr = r + dr, cc = c + dc;
      if (rr < 0 || rr >= _p.height || cc < 0 || cc >= w) continue;
      final g2 = rr * w + cc;
      if (!_p.isCell(g2) || _occupant(g2) >= 0) continue;
      setState(() => _pos[i] = firstIsA ? (g, g2) : (g2, g));
      return true;
    }
    return false;
  }

  void _checkDone({bool fromHint = false}) {
    if (_over || _pos.any((p) => p == null)) return;
    final bad = _p.brokenRegions(_values);
    if (bad.isEmpty) {
      setState(() => _over = _won = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.session.onWin();
      });
      return;
    }
    if (!fromHint) widget.session.addMistake();
    setState(() => _flash = bad.toSet());
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _flash = {});
    });
  }

  void _drop(int i, Offset globalTopLeft) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _over) return;
    final local = box.globalToLocal(
      globalTopLeft + Offset(_cell / 2, _cell / 2),
    );
    final c = (local.dx / _cell).floor(), r = (local.dy / _cell).floor();
    if (r < 0 || r >= _p.height || c < 0 || c >= _p.width) return;
    final g = r * _p.width + c;
    if (!_p.isCell(g) || _occupant(g) >= 0) return;
    if (_place(i, g)) {
      setState(() {
        if (_sel == i) _sel = null;
      });
      _checkDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final s = min(
                72.0,
                min(
                  (box.maxWidth - 32) / _p.width,
                  (box.maxHeight - 24) / _p.height,
                ),
              ).clamp(20.0, 72.0);
              _cell = s;
              return Center(child: _board(context, s));
            },
          ),
        ),
        _tray(context),
      ],
    );
  }

  Widget _board(BuildContext context, double s) {
    final scheme = Theme.of(context).colorScheme;
    final values = _values;
    final broken = _p.brokenRegions(values).toSet();
    final bw = s * _p.width, bh = s * _p.height;
    return DragTarget<int>(
      onAcceptWithDetails: (det) => _drop(det.data, det.offset),
      builder: (context, cand, rej) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (det) {
          final c = (det.localPosition.dx / s).floor();
          final r = (det.localPosition.dy / s).floor();
          if (r < 0 || r >= _p.height || c < 0 || c >= _p.width) return;
          _tapBoard(r * _p.width + c);
        },
        child: SizedBox(
          key: _boardKey,
          width: bw,
          height: bh,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BoardPainter(
                    p: _p,
                    s: s,
                    fills: _fill,
                    blank: scheme.surfaceContainerHighest,
                    blankEdge: scheme.outlineVariant,
                    broken: broken,
                    flash: _flash,
                  ),
                ),
              ),
              for (var i = 0; i < _pos.length; i++)
                if (_pos[i] != null) _placed(i, s),
              for (var r = 0; r < _p.regions.length; r++)
                if (_p.regions[r].rule != PipsRule.none)
                  _badge(r, s, broken.contains(r) || _flash.contains(r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placed(int i, double s) {
    final (ga, gb) = _pos[i]!;
    final w = _p.width;
    final first = min(ga, gb), second = max(ga, gb);
    final vertical = second - first == w;
    final v1 = first == ga ? _p.dominoes[i].a : _p.dominoes[i].b;
    final v2 = first == ga ? _p.dominoes[i].b : _p.dominoes[i].a;
    final inset = s * 0.09;
    return Positioned(
      left: (first % w) * s + inset,
      top: (first ~/ w) * s + inset,
      child: _Face(
        v1: v1,
        v2: v2,
        vertical: vertical,
        half: s - inset * 2,
        gap: inset * 2,
        ring: _won ? Colors.green.shade600 : null,
      ),
    );
  }

  Widget _badge(int r, double s, bool bad) {
    final reg = _p.regions[r];
    final anchor = reg.cells.last; // bottom-most, right-most cell
    final row = anchor ~/ _p.width, col = anchor % _p.width;
    // Centred on the cell's corner and at most ~0.34 cells tall, so it never
    // hides a pip of a domino lying on the region.
    final h = min(s * 0.34, 26.0);
    final color = bad ? Colors.red.shade700 : _palette[_paletteOf[r]].$2;
    return Positioned(
      left: (col + 1) * s,
      top: (row + 1) * s - h / 2,
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: IgnorePointer(
          child: Container(
            height: h,
            constraints: BoxConstraints(minWidth: h),
            padding: EdgeInsets.symmetric(horizontal: h * 0.2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(h * 0.3),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              reg.label,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: h * 0.6,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tray(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        final half = (box.maxWidth / 12).clamp(24.0, 36.0);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _pos.length; i++)
                _pos[i] == null
                    ? _trayDomino(i, half, scheme)
                    : Container(
                        width: half * 2,
                        height: half,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(half * 0.2),
                          border: Border.all(
                            color: scheme.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                      ),
            ],
          ),
        );
      },
    );
  }

  Widget _trayDomino(int i, double half, ColorScheme scheme) {
    final d = _p.dominoes[i];
    final turn = _turn[i];
    final v1 = turn < 2 ? d.a : d.b, v2 = turn < 2 ? d.b : d.a;
    final vertical = turn.isOdd;
    final selected = _sel == i;
    Widget face(double h, {Color? ring}) =>
        _Face(v1: v1, v2: v2, vertical: vertical, half: h, ring: ring);
    return Draggable<int>(
      data: i,
      dragAnchorStrategy: (draggable, context, position) =>
          Offset(_cell / 2, _cell / 2),
      onDragStarted: () => setState(() => _sel = i),
      feedback: Opacity(opacity: 0.9, child: face(_cell * 0.92)),
      childWhenDragging: Opacity(opacity: 0.3, child: face(half)),
      child: GestureDetector(
        onTap: () => _tapTray(i),
        child: AnimatedScale(
          scale: selected ? 1.12 : 1,
          duration: const Duration(milliseconds: 150),
          child: face(half, ring: selected ? scheme.primary : null),
        ),
      ),
    );
  }
}

/// A domino drawn like the real thing: ivory tile, divider, black pips.
class _Face extends StatelessWidget {
  const _Face({
    required this.v1,
    required this.v2,
    required this.vertical,
    required this.half,
    this.gap = 0,
    this.ring,
  });
  final int v1, v2;
  final bool vertical;
  final double half;

  /// Extra length between the halves (board spacing between two cells).
  final double gap;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final long = half * 2 + gap;
    return Container(
      width: vertical ? half : long,
      height: vertical ? long : half,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF2),
        borderRadius: BorderRadius.circular(half * 0.2),
        border: Border.all(
          color: ring ?? const Color(0xFF37474F),
          width: ring != null ? 3 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: CustomPaint(painter: _PipPainter(v1, v2, vertical)),
    );
  }
}

class _PipPainter extends CustomPainter {
  _PipPainter(this.v1, this.v2, this.vertical);
  final int v1, v2;
  final bool vertical;

  static const _o = 0.27, _m = 0.5, _f = 0.73;
  static const _spots = <List<Offset>>[
    [],
    [Offset(_m, _m)],
    [Offset(_o, _o), Offset(_f, _f)],
    [Offset(_o, _o), Offset(_m, _m), Offset(_f, _f)],
    [Offset(_o, _o), Offset(_f, _o), Offset(_o, _f), Offset(_f, _f)],
    [
      Offset(_o, _o),
      Offset(_f, _o),
      Offset(_m, _m),
      Offset(_o, _f),
      Offset(_f, _f),
    ],
    [
      Offset(_o, _o),
      Offset(_o, _m),
      Offset(_o, _f),
      Offset(_f, _o),
      Offset(_f, _m),
      Offset(_f, _f),
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final side = vertical ? size.width : size.height;
    final pip = Paint()..color = const Color(0xFF263238);
    final line = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = max(1.0, side * 0.04);
    if (vertical) {
      final y = size.height / 2;
      canvas.drawLine(
        Offset(side * 0.15, y),
        Offset(size.width - side * 0.15, y),
        line,
      );
    } else {
      final x = size.width / 2;
      canvas.drawLine(
        Offset(x, side * 0.15),
        Offset(x, size.height - side * 0.15),
        line,
      );
    }
    void half(int v, Offset origin) {
      for (final p in _spots[v]) {
        // Sixes run along the long axis of the domino.
        final q = vertical ? p : Offset(p.dy, p.dx);
        canvas.drawCircle(origin + q * side, side * 0.09, pip);
      }
    }

    half(v1, Offset.zero);
    half(
      v2,
      vertical ? Offset(0, size.height - side) : Offset(size.width - side, 0),
    );
  }

  @override
  bool shouldRepaint(_PipPainter old) =>
      old.v1 != v1 || old.v2 != v2 || old.vertical != vertical;
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.p,
    required this.s,
    required this.fills,
    required this.blank,
    required this.blankEdge,
    required this.broken,
    required this.flash,
  });
  final PipsPuzzle p;
  final double s;
  final List<Color> fills;
  final Color blank, blankEdge;
  final Set<int> broken, flash;

  @override
  void paint(Canvas canvas, Size size) {
    final w = p.width;
    final gap = s * 0.05;
    final radius = Radius.circular(s * 0.16);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = blankEdge;
    for (final g in p.cells) {
      final r = g ~/ w, c = g % w;
      final reg = p.regionOf[g];
      bool same(int rr, int cc) =>
          reg >= 0 &&
          rr >= 0 &&
          rr < p.height &&
          cc >= 0 &&
          cc < w &&
          p.regionOf[rr * w + cc] == reg;
      final up = same(r - 1, c), down = same(r + 1, c);
      final left = same(r, c - 1), right = same(r, c + 1);
      // Sides joining the same region overlap a hair to hide seams.
      final rect = Rect.fromLTRB(
        c * s + (left ? -0.5 : gap),
        r * s + (up ? -0.5 : gap),
        (c + 1) * s - (right ? -0.5 : gap),
        (r + 1) * s - (down ? -0.5 : gap),
      );
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: up || left ? Radius.zero : radius,
        topRight: up || right ? Radius.zero : radius,
        bottomLeft: down || left ? Radius.zero : radius,
        bottomRight: down || right ? Radius.zero : radius,
      );
      var color = reg < 0 ? blank : fills[reg];
      if (flash.contains(reg)) {
        color = Color.lerp(color, Colors.red, 0.75)!;
      } else if (broken.contains(reg)) {
        color = Color.lerp(color, Colors.red, 0.4)!;
      }
      canvas.drawRRect(rrect, Paint()..color = color);
      if (reg < 0) canvas.drawRRect(rrect.deflate(0.5), edge);
    }
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}
