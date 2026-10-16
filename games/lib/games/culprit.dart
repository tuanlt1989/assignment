import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'session.dart';

/// "Who Did It?": a deduction puzzle in the style of Clues by Sam.
///
/// A grid of people, each secretly criminal or innocent. Every person carries
/// one true clue that becomes visible once they are revealed. The player may
/// only reveal a person whose status is logically forced by the clues already
/// on the table, so the puzzle is solved by pure deduction.

/// Population count for masks of up to 32 people.
int _pop(int x) {
  x = x - ((x >> 1) & 0x55555555);
  x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
  x = (x + (x >> 4)) & 0x0F0F0F0F;
  x = x + (x >> 8);
  x = x + (x >> 16);
  return x & 0x3F;
}

List<int> _bits(int mask) => [
  for (var i = 0; mask >> i != 0; i++)
    if ((mask >> i) & 1 == 1) i,
];

/// `lo <= count(a) - count(b) <= hi`, where count(m) is the number of
/// criminals among the people in bitmask m (bit i = person i).
class CulpritConstraint {
  CulpritConstraint(int a, int b, this.lo, this.hi) : a = a & ~b, b = b & ~a;

  CulpritConstraint.eq(int mask, int k) : this(mask, 0, k, k);
  CulpritConstraint.ge(int mask, int k) : this(mask, 0, k, 1 << 20);
  CulpritConstraint.le(int mask, int k) : this(mask, 0, -(1 << 20), k);

  /// count(a) - count(b) >= 1.
  CulpritConstraint.more(int a, int b) : this(a, b, 1, 1 << 20);

  /// count(a) == count(b).
  CulpritConstraint.same(int a, int b) : this(a, b, 0, 0);

  /// Common people of the two sides are cancelled out.
  final int a, b;
  final int lo, hi;

  bool holds(int criminals) {
    final v = _pop(criminals & a) - _pop(criminals & b);
    return v >= lo && v <= hi;
  }
}

/// One clue: a template key with its parameters, plus the counting
/// constraints that encode it.
class CulpritClue {
  const CulpritClue(
    this.key,
    this.constraints, {
    required this.mask,
    this.people = const [],
    this.k = 0,
    this.r = 0,
    this.r2 = 0,
    this.c = 0,
    this.c2 = 0,
  });

  /// Template key (see [CulpritText.templates]).
  final String key;
  final List<CulpritConstraint> constraints;

  /// Everyone the clue talks about (outlined in the UI).
  final int mask;

  /// Named people: {name}, {name2}.
  final List<int> people;
  final int k;

  /// 0-based rows / columns for {r}, {r2}, {c}, {c2}.
  final int r, r2, c, c2;

  bool holds(int criminals) => constraints.every((x) => x.holds(criminals));
}

class CulpritPuzzle {
  CulpritPuzzle._(
    this.difficulty,
    this.cols,
    this.rows,
    this.names,
    this.female,
    this.criminals,
    this.clues,
    this.start,
  );

  final int difficulty;
  final int cols, rows;
  final List<String> names;

  /// Grammatical gender of each name (a few Portuguese templates use it).
  final List<bool> female;

  /// Bitmask of the secret criminals (bit i = person i, reading order).
  final int criminals;

  /// Clue of every person (shown once that person is revealed).
  final List<CulpritClue> clues;

  /// The person revealed at the start.
  final int start;

  int get size => cols * rows;
  int get allMask => (1 << size) - 1;
  bool isCriminal(int i) => (criminals >> i) & 1 == 1;
  int row(int i) => i ~/ cols;
  int col(int i) => i % cols;

  /// "B3" style label.
  String label(int i) => '${String.fromCharCode(65 + col(i))}${row(i) + 1}';

  /// Grid by difficulty: 3×4 easy, 4×4 medium, 4×5 hard and expert.
  static CulpritPuzzle forDifficulty(int difficulty, int level, int seed) {
    final d = difficulty.clamp(0, 3);
    final (cols, rows) = const [(3, 4), (4, 4), (4, 5), (4, 5)][d];
    final mixed = (seed * 31 + level * 1009 + d * 7919 + 17) & 0x7fffffff;
    return generate(d, cols, rows, mixed);
  }

  static CulpritPuzzle generate(int difficulty, int cols, int rows, int seed) {
    final rnd = Random(seed);
    final n = cols * rows;
    final names = <String>[];
    final female = <bool>[];
    for (var i = 0; i < n; i++) {
      final options = _nameBank[i];
      final (name, f) = options[rnd.nextInt(options.length)];
      names.add(name);
      female.add(f);
    }
    // 35–50 % criminals.
    final nCrim = (n * (0.35 + rnd.nextDouble() * 0.15)).round();
    final order = List.generate(n, (i) => i)..shuffle(rnd);
    var crim = 0;
    for (final i in order.take(nCrim)) {
      crim |= 1 << i;
    }
    final start = rnd.nextInt(n);
    final gen = _Gen(cols, rows, crim, rnd, difficulty);
    final clues = [for (var p = 0; p < n; p++) gen.clue(p)];
    final puzzle = CulpritPuzzle._(
      difficulty,
      cols,
      rows,
      names,
      female,
      crim,
      clues,
      start,
    );
    puzzle._makeSolvable(gen, rnd);
    return puzzle;
  }

  /// Walks the deduction closure from the start. Whenever it gets stuck,
  /// the clue of someone revealed in the last step is replaced by a new true
  /// clue that unlocks progress. Those clues were not used for any earlier
  /// deduction, so everything revealed so far stays reachable.
  void _makeSolvable(_Gen gen, Random rnd) {
    var revealed = 1 << start;
    var last = [start];
    final full = allMask;
    final wanted = const [1, 1, 6, 10][difficulty];
    while (revealed != full) {
      final f = forcedMask(revealed);
      if (f != 0) {
        revealed |= f;
        last = _bits(f);
        continue;
      }
      CulpritClue? best;
      var bestPerson = -1;
      var bestScore = 1 << 30;
      var found = 0;
      for (var t = 0; t < 80 && found < wanted; t++) {
        final p = last[rnd.nextInt(last.length)];
        final cand = gen.clue(p);
        final old = clues[p];
        clues[p] = cand;
        final f = forcedMask(revealed);
        clues[p] = old;
        if (f == 0) continue;
        found++;
        var score = 0;
        if (difficulty >= 2) {
          // Prefer clues that only work together with earlier clues, and
          // that unlock few people at a time.
          final alone = _forcedWith(revealed, cand.constraints);
          final same = clues.where((c) => c.key == cand.key).length;
          score = _pop(f) + (alone != 0 ? 10 : 0) + 2 * same;
        }
        if (score < bestScore) {
          bestScore = score;
          best = cand;
          bestPerson = p;
        }
      }
      if (best == null) {
        // Safety net: name an unknown person next to someone just revealed.
        bestPerson = last[rnd.nextInt(last.length)];
        best = gen.direct(bestPerson, revealed);
      }
      clues[bestPerson] = best;
    }
  }

  /// Unrevealed people whose status is the same in every assignment that
  /// agrees with the revealed statuses and the revealed people's clues.
  Set<int> forced(Set<int> revealed) {
    var m = 0;
    for (final i in revealed) {
      m |= 1 << i;
    }
    return _bits(forcedMask(m)).toSet();
  }

  int forcedMask(int revealed) => _forcedWith(revealed, [
    for (final i in _bits(revealed)) ...clues[i].constraints,
  ]);

  int _forcedWith(int known, List<CulpritConstraint> cons) {
    final s = _Solver(size, criminals, known, cons);
    if (s.vars == 0) return 0;
    var cand = s.vars;
    var forced = 0;
    while (cand != 0) {
      final v = (cand & -cand).bitLength - 1;
      final sol = s.find(v, isCriminal(v) ? 0 : 1);
      if (sol < 0) {
        forced |= 1 << v;
        cand &= ~(1 << v);
      } else {
        cand &= ~((sol ^ criminals) & s.vars);
        cand &= ~(1 << v);
      }
    }
    return forced;
  }

  /// The order in which a logician reveals people: the start, then every
  /// person forced at each step.
  List<Set<int>> solvePath() {
    final path = <Set<int>>[
      {start},
    ];
    var revealed = 1 << start;
    while (true) {
      final f = forcedMask(revealed);
      if (f == 0) break;
      path.add(_bits(f).toSet());
      revealed |= f;
    }
    return path;
  }

  /// Assignments consistent with all clues and the start's revealed status
  /// (capped at [limit]).
  int countSolutions({int limit = 2}) {
    final known = 1 << start;
    final cons = [for (final c in clues) ...c.constraints];
    final s = _Solver(size, criminals, known, cons);
    final free = allMask & ~known & ~s.vars;
    final count = s.count(limit);
    if (count > 0 && free != 0) return limit;
    return count;
  }

  String clueText(int person, String lang) =>
      CulpritText.clue(clues[person], names, female, lang);
}

/// Bounded backtracking over the unknown people mentioned in constraints.
class _Solver {
  _Solver(int n, this.truth, int known, List<CulpritConstraint> cons) {
    final kv = truth & known;
    for (final c in cons) {
      final a = c.a & ~known, b = c.b & ~known;
      if (a | b == 0) continue;
      final base = _pop(kv & c.a) - _pop(kv & c.b);
      ua.add(a);
      ub.add(b);
      lo.add(c.lo - base);
      hi.add(c.hi - base);
      vars |= a | b;
    }
    varCons = List.generate(n, (_) => <int>[]);
    for (var ci = 0; ci < ua.length; ci++) {
      for (final v in _bits(ua[ci] | ub[ci])) {
        varCons[v].add(ci);
      }
    }
    order = _bits(vars)
      ..sort((x, y) => varCons[y].length.compareTo(varCons[x].length));
  }

  final int truth;
  final ua = <int>[], ub = <int>[], lo = <int>[], hi = <int>[];
  var vars = 0;
  late final List<List<int>> varCons;
  late final List<int> order;
  var _assigned = 0, _val = 0, _found = -1, _count = 0, _limit = 1;

  bool _ok(int v) {
    for (final ci in varCons[v]) {
      final a = ua[ci], b = ub[ci];
      final cur = _pop(_val & a) - _pop(_val & b);
      if (cur + _pop(a & ~_assigned) < lo[ci]) return false;
      if (cur - _pop(b & ~_assigned) > hi[ci]) return false;
    }
    return true;
  }

  bool _dfs(int idx) {
    if (idx == order.length) {
      _found = _val;
      return ++_count >= _limit;
    }
    final v = order[idx];
    final bit = 1 << v;
    if (_assigned & bit != 0) return _dfs(idx + 1);
    _assigned |= bit;
    // Try the opposite of the truth first: counterexamples come sooner.
    final first = (truth & bit) != 0 ? 0 : 1;
    for (final t in [first, 1 - first]) {
      _val = t == 1 ? _val | bit : _val & ~bit;
      if (_ok(v) && _dfs(idx + 1)) return true;
    }
    _assigned &= ~bit;
    _val &= ~bit;
    return false;
  }

  /// Any solution with person [v] set to [value], or -1.
  int find(int v, int value) {
    _assigned = 1 << v;
    _val = value << v;
    _found = -1;
    _count = 0;
    _limit = 1;
    if (!_ok(v)) return -1;
    _dfs(0);
    return _found;
  }

  int count(int limit) {
    _assigned = 0;
    _val = 0;
    _count = 0;
    _limit = limit;
    _dfs(0);
    return min(_count, limit);
  }
}

/// Random true clues for a fixed secret assignment.
class _Gen {
  _Gen(this.cols, this.rows, this.crim, this.rnd, this.difficulty)
    : n = cols * rows {
    nb = List.generate(n, (i) {
      var m = 0;
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final r = row(i) + dr, c = col(i) + dc;
          if (r < 0 || r >= rows || c < 0 || c >= cols) continue;
          m |= 1 << (r * cols + c);
        }
      }
      return m;
    });
  }

  final int cols, rows, n, crim, difficulty;
  final Random rnd;
  late final List<int> nb;

  static const _weights = <Map<String, int>>[
    {
      'nb': 5,
      'nbInno': 2,
      'row': 4,
      'col': 4,
      'direct': 3,
      'pair': 2,
      'corners': 1,
      'dir': 2,
      'oneof': 1,
    },
    {
      'nb': 4,
      'nbInno': 2,
      'row': 3,
      'col': 3,
      'direct': 1,
      'pair': 3,
      'dir': 3,
      'corners': 1,
      'edge': 1,
      'oneof': 2,
      'common': 1,
      'rowCmp': 1,
      'colCmp': 1,
      'nbMajor': 1,
    },
    {
      'nb': 3,
      'nbInno': 2,
      'row': 2,
      'col': 2,
      'direct': 1,
      'pair': 3,
      'dir': 3,
      'corners': 1,
      'edge': 1,
      'oneof': 2,
      'common': 2,
      'rowCmp': 2,
      'colCmp': 2,
      'nbCmp': 2,
      'nbMajor': 2,
      'total': 1,
    },
    {
      'nb': 2,
      'nbInno': 1,
      'row': 1,
      'col': 1,
      'pair': 3,
      'dir': 3,
      'corners': 1,
      'edge': 1,
      'oneof': 1,
      'common': 3,
      'rowCmp': 3,
      'colCmp': 3,
      'nbCmp': 3,
      'nbMajor': 3,
      'total': 1,
    },
  ];

  int row(int i) => i ~/ cols;
  int col(int i) => i % cols;
  bool isCrim(int i) => (crim >> i) & 1 == 1;
  int cnt(int m) => _pop(m & crim);
  int dist(int a, int b) =>
      max((row(a) - row(b)).abs(), (col(a) - col(b)).abs());

  int rowMask(int r) {
    var m = 0;
    for (var c = 0; c < cols; c++) {
      m |= 1 << (r * cols + c);
    }
    return m;
  }

  int colMask(int c) {
    var m = 0;
    for (var r = 0; r < rows; r++) {
      m |= 1 << (r * cols + c);
    }
    return m;
  }

  /// A person close to [p] (itself, a neighbour, or two steps away).
  int near(int p, {bool self = true}) {
    final opts = <int>[];
    for (var i = 0; i < n; i++) {
      final d = dist(p, i);
      final w = d == 0 ? (self ? 3 : 0) : (d == 1 ? 3 : (d == 2 ? 1 : 0));
      for (var t = 0; t < w; t++) {
        opts.add(i);
      }
    }
    return opts[rnd.nextInt(opts.length)];
  }

  int? other(int s, int maxDist, [bool Function(int)? ok]) {
    final opts = [
      for (var i = 0; i < n; i++)
        if (i != s && dist(s, i) <= maxDist && (ok == null || ok(i))) i,
    ];
    return opts.isEmpty ? null : opts[rnd.nextInt(opts.length)];
  }

  CulpritClue clue(int p) {
    final w = _weights[difficulty];
    final total = w.values.fold(0, (a, b) => a + b);
    for (var t = 0; t < 60; t++) {
      var x = rnd.nextInt(total);
      var kind = w.keys.first;
      for (final e in w.entries) {
        if (x < e.value) {
          kind = e.key;
          break;
        }
        x -= e.value;
      }
      final c = _make(kind, p);
      if (c != null) return c;
    }
    return _nb(p, false);
  }

  CulpritClue _nb(int s, bool innocent) {
    final m = nb[s];
    final k = cnt(m);
    return CulpritClue(
      innocent ? 'nb_inno' : 'nb_crim',
      [CulpritConstraint.eq(m, k)],
      mask: m | 1 << s,
      people: [s],
      k: innocent ? _pop(m) - k : k,
    );
  }

  /// "{name} is innocent/criminal" about an unrevealed person near [p].
  CulpritClue direct(int p, int revealed) {
    var s = -1;
    for (var d = 1; s < 0; d++) {
      final opts = [
        for (var i = 0; i < n; i++)
          if (revealed >> i & 1 == 0 && dist(p, i) == d) i,
      ];
      if (opts.isNotEmpty) s = opts[rnd.nextInt(opts.length)];
    }
    return _direct(s);
  }

  CulpritClue _direct(int s) => CulpritClue(
    isCrim(s) ? 'direct_crim' : 'direct_inno',
    [CulpritConstraint.eq(1 << s, isCrim(s) ? 1 : 0)],
    mask: 1 << s,
    people: [s],
  );

  CulpritClue? _make(String kind, int p) {
    switch (kind) {
      case 'nb':
        return _nb(near(p), false);
      case 'nbInno':
        return _nb(near(p), true);
      case 'nbMajor':
        final s = near(p);
        final m = nb[s];
        final kc = cnt(m), size = _pop(m);
        if (kc * 2 == size) return null;
        return CulpritClue(
          kc * 2 > size ? 'nb_major_crim' : 'nb_major_inno',
          [
            kc * 2 > size
                ? CulpritConstraint.ge(m, size ~/ 2 + 1)
                : CulpritConstraint.le(m, (size - 1) ~/ 2),
          ],
          mask: m | 1 << s,
          people: [s],
        );
      case 'row':
        final r = rnd.nextInt(3) > 0 ? row(p) : rnd.nextInt(rows);
        final m = rowMask(r);
        return CulpritClue(
          'row_count',
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m,
          k: cnt(m),
          r: r,
        );
      case 'col':
        final c = rnd.nextInt(3) > 0 ? col(p) : rnd.nextInt(cols);
        final m = colMask(c);
        return CulpritClue(
          'col_count',
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m,
          k: cnt(m),
          c: c,
        );
      case 'total':
        final m = (1 << n) - 1;
        return CulpritClue(
          'total',
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m,
          k: cnt(m),
        );
      case 'dir':
        final s = near(p);
        final r = row(s), c = col(s);
        final dirs = <String, int>{};
        var up = 0, down = 0, left = 0, right = 0;
        for (var rr = 0; rr < rows; rr++) {
          if (rr < r) up |= 1 << (rr * cols + c);
          if (rr > r) down |= 1 << (rr * cols + c);
        }
        for (var cc = 0; cc < cols; cc++) {
          if (cc < c) left |= 1 << (r * cols + cc);
          if (cc > c) right |= 1 << (r * cols + cc);
        }
        for (final (k, m) in [
          ('above', up),
          ('below', down),
          ('left', left),
          ('right', right),
        ]) {
          if (_pop(m) >= 2) dirs[k] = m;
        }
        if (dirs.isEmpty) return null;
        final key = dirs.keys.elementAt(rnd.nextInt(dirs.length));
        final m = dirs[key]!;
        return CulpritClue(
          key,
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m | 1 << s,
          people: [s],
          k: cnt(m),
        );
      case 'rowCmp':
        final r1 = rnd.nextInt(3) > 0 ? row(p) : rnd.nextInt(rows);
        var r2 = rnd.nextInt(rows - 1);
        if (r2 >= r1) r2++;
        return _cmp('row', r1, r2, rowMask(r1), rowMask(r2));
      case 'colCmp':
        final c1 = rnd.nextInt(3) > 0 ? col(p) : rnd.nextInt(cols);
        var c2 = rnd.nextInt(cols - 1);
        if (c2 >= c1) c2++;
        return _cmp('col', c1, c2, colMask(c1), colMask(c2));
      case 'nbCmp':
        final s1 = near(p);
        final s2 = other(s1, 2);
        if (s2 == null) return null;
        final k1 = cnt(nb[s1]), k2 = cnt(nb[s2]);
        final (x, y) = k1 >= k2 ? (s1, s2) : (s2, s1);
        return CulpritClue(
          k1 == k2 ? 'nb_same' : 'nb_more',
          [
            k1 == k2
                ? CulpritConstraint.same(nb[x], nb[y])
                : CulpritConstraint.more(nb[x], nb[y]),
          ],
          mask: nb[x] | nb[y] | 1 << x | 1 << y,
          people: [x, y],
        );
      case 'pair':
        final s1 = near(p, self: false);
        final s2 = other(s1, 1, (i) => i != p);
        if (s2 == null) return null;
        final m = 1 << s1 | 1 << s2;
        final k = cnt(m);
        final pick = rnd.nextInt(3);
        final (key, con) = switch (k) {
          1 when pick == 0 => ('pair_any', CulpritConstraint.ge(m, 1)),
          1 => ('pair_one', CulpritConstraint.eq(m, 1)),
          0 when pick == 0 => (
            'pair_same',
            CulpritConstraint.same(1 << s1, 1 << s2),
          ),
          0 => ('pair_inno', CulpritConstraint.eq(m, 0)),
          _ when pick == 0 => (
            'pair_same',
            CulpritConstraint.same(1 << s1, 1 << s2),
          ),
          _ when pick == 1 => ('pair_any', CulpritConstraint.ge(m, 1)),
          _ => ('pair_crim', CulpritConstraint.eq(m, 2)),
        };
        return CulpritClue(key, [con], mask: m, people: [s1, s2]);
      case 'corners':
        final m = 1 | 1 << (cols - 1) | 1 << ((rows - 1) * cols) | 1 << (n - 1);
        return CulpritClue(
          'corners',
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m,
          k: cnt(m),
        );
      case 'edge':
        var m = 0;
        for (var i = 0; i < n; i++) {
          if (row(i) == 0 ||
              row(i) == rows - 1 ||
              col(i) == 0 ||
              col(i) == cols - 1) {
            m |= 1 << i;
          }
        }
        return CulpritClue(
          'edge',
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m,
          k: cnt(m),
        );
      case 'direct':
        return _direct(near(p, self: false));
      case 'common':
        final s1 = near(p);
        final s2 = other(s1, 2, (i) => _pop(nb[s1] & nb[i]) >= 2);
        if (s2 == null) return null;
        final m = nb[s1] & nb[s2];
        return CulpritClue(
          'common',
          [CulpritConstraint.eq(m, cnt(m))],
          mask: m | 1 << s1 | 1 << s2,
          people: [s1, s2],
          k: cnt(m),
        );
      case 'oneof':
        final s = near(p, self: false);
        if (!isCrim(s)) return null;
        final byRow = rnd.nextBool();
        final m = byRow ? rowMask(row(s)) : colMask(col(s));
        final k = cnt(m);
        final key = (byRow ? 'row' : 'col') + (k == 1 ? '_only' : '_oneof');
        return CulpritClue(
          key,
          [CulpritConstraint.eq(1 << s, 1), CulpritConstraint.eq(m, k)],
          mask: m,
          people: [s],
          k: k,
          r: row(s),
          c: col(s),
        );
    }
    return null;
  }

  CulpritClue _cmp(String what, int x1, int x2, int m1, int m2) {
    final k1 = cnt(m1), k2 = cnt(m2);
    final (a, b, ma, mb) = k1 >= k2 ? (x1, x2, m1, m2) : (x2, x1, m2, m1);
    return CulpritClue(
      '${what}_${k1 == k2 ? 'same' : 'more'}',
      [
        k1 == k2
            ? CulpritConstraint.same(ma, mb)
            : CulpritConstraint.more(ma, mb),
      ],
      mask: ma | mb,
      r: a,
      r2: b,
      c: a,
      c2: b,
    );
  }
}

/// Two name options per letter (name, female) so neighbours' initials stay
/// alphabetical in reading order.
const _nameBank = <List<(String, bool)>>[
  [('Alice', true), ('Amir', false)],
  [('Bruno', false), ('Bea', true)],
  [('Chloe', true), ('Carlos', false)],
  [('Dev', false), ('Dana', true)],
  [('Emma', true), ('Eli', false)],
  [('Felix', false), ('Fatima', true)],
  [('Gina', true), ('Gus', false)],
  [('Hugo', false), ('Hana', true)],
  [('Iris', true), ('Ivan', false)],
  [('Jonas', false), ('Jade', true)],
  [('Kira', true), ('Kenji', false)],
  [('Leo', false), ('Lina', true)],
  [('Mia', true), ('Marco', false)],
  [('Nico', false), ('Nora', true)],
  [('Omar', false), ('Olga', true)],
  [('Pia', true), ('Pablo', false)],
  [('Quinn', false), ('Qiara', true)],
  [('Rosa', true), ('Raj', false)],
  [('Sven', false), ('Sara', true)],
  [('Tara', true), ('Theo', false)],
  [('Uma', true), ('Umar', false)],
  [('Victor', false), ('Vera', true)],
  [('Wendy', true), ('Wes', false)],
  [('Xavi', false), ('Xena', true)],
  [('Yuki', true), ('Yusuf', false)],
  [('Zoe', true), ('Zane', false)],
];

/// Clue and UI sentences. `key_1` is the singular form used when k == 1
/// (required in [pluralLanguages] for every template containing {k}).
/// Optional: `key_0` (k == 0 phrasing) and `key_f` (feminine form for a
/// single named person). Missing optional forms fall back to `key`.
class CulpritText {
  static const languages = ['en', 'es', 'pt', 'vi', 'id', 'de', 'ja'];
  static const pluralLanguages = {'en', 'es', 'pt', 'de'};

  static const templates = <String, Map<String, String>>{
    'en': {
      'nb_crim': '{name} has exactly {k} criminal neighbours',
      'nb_crim_1': '{name} has exactly 1 criminal neighbour',
      'nb_crim_0': '{name} has no criminal neighbours',
      'nb_inno': '{name} has exactly {k} innocent neighbours',
      'nb_inno_1': '{name} has exactly 1 innocent neighbour',
      'nb_major_crim': '{name} has more criminal than innocent neighbours',
      'nb_major_inno': '{name} has more innocent than criminal neighbours',
      'row_count': 'There are exactly {k} criminals in row {r}',
      'row_count_1': 'There is exactly 1 criminal in row {r}',
      'row_count_0': 'There are no criminals in row {r}',
      'col_count': 'There are exactly {k} criminals in column {c}',
      'col_count_1': 'There is exactly 1 criminal in column {c}',
      'col_count_0': 'There are no criminals in column {c}',
      'total': 'There are {k} criminals in total',
      'total_1': 'There is only 1 criminal in total',
      'above': 'Exactly {k} of the people above {name} are criminals',
      'above_1': 'Exactly 1 of the people above {name} is a criminal',
      'above_0': 'None of the people above {name} are criminals',
      'below': 'Exactly {k} of the people below {name} are criminals',
      'below_1': 'Exactly 1 of the people below {name} is a criminal',
      'below_0': 'None of the people below {name} are criminals',
      'left': 'Exactly {k} of the people to the left of {name} are criminals',
      'left_1': 'Exactly 1 of the people to the left of {name} is a criminal',
      'right': 'Exactly {k} of the people to the right of {name} are criminals',
      'right_1': 'Exactly 1 of the people to the right of {name} is a criminal',
      'right_0': 'None of the people to the right of {name} are criminals',
      'row_more': 'There are more criminals in row {r} than in row {r2}',
      'col_more': 'There are more criminals in column {c} than in column {c2}',
      'row_same': 'Rows {r} and {r2} have the same number of criminals',
      'col_same': 'Columns {c} and {c2} have the same number of criminals',
      'nb_more': '{name} has more criminal neighbours than {name2}',
      'nb_same':
          '{name} and {name2} have the same number of criminal neighbours',
      'pair_one': 'Exactly one of {name} and {name2} is a criminal',
      'pair_any': 'At least one of {name} and {name2} is a criminal',
      'pair_inno': '{name} and {name2} are both innocent',
      'pair_crim': '{name} and {name2} are both criminals',
      'pair_same':
          '{name} and {name2} are either both criminals or both innocent',
      'corners': 'The 4 corners contain exactly {k} criminals',
      'corners_1': 'The 4 corners contain exactly 1 criminal',
      'edge': 'Exactly {k} criminals are on the edge',
      'edge_1': 'Exactly 1 criminal is on the edge',
      'direct_inno': '{name} is innocent',
      'direct_crim': '{name} is a criminal',
      'common':
          '{name} and {name2} have exactly {k} criminal neighbours in common',
      'common_1':
          '{name} and {name2} have exactly 1 criminal neighbour in common',
      'common_0': '{name} and {name2} have no criminal neighbours in common',
      'row_oneof': '{name} is one of {k} criminals in row {r}',
      'row_only': '{name} is the only criminal in row {r}',
      'col_oneof': '{name} is one of {k} criminals in column {c}',
      'col_only': '{name} is the only criminal in column {c}',
      'ui_innocent': 'Innocent',
      'ui_criminal': 'Criminal',
      'ui_not_enough': 'Not enough evidence',
      'ui_tap': 'Tap a person to accuse or clear them',
      'ui_ask': 'Is {name} innocent or a criminal?',
    },
    'es': {
      'nb_crim': '{name} tiene exactamente {k} vecinos criminales',
      'nb_crim_1': '{name} tiene exactamente 1 vecino criminal',
      'nb_inno': '{name} tiene exactamente {k} vecinos inocentes',
      'nb_inno_1': '{name} tiene exactamente 1 vecino inocente',
      'nb_major_crim': '{name} tiene más vecinos criminales que inocentes',
      'nb_major_inno': '{name} tiene más vecinos inocentes que criminales',
      'row_count': 'Hay exactamente {k} criminales en la fila {r}',
      'row_count_1': 'Hay exactamente 1 criminal en la fila {r}',
      'col_count': 'Hay exactamente {k} criminales en la columna {c}',
      'col_count_1': 'Hay exactamente 1 criminal en la columna {c}',
      'total': 'Hay {k} criminales en total',
      'total_1': 'Hay solo 1 criminal en total',
      'above':
          'Exactamente {k} de las personas encima de {name} son criminales',
      'above_1': 'Exactamente 1 de las personas encima de {name} es criminal',
      'below':
          'Exactamente {k} de las personas debajo de {name} son criminales',
      'below_1': 'Exactamente 1 de las personas debajo de {name} es criminal',
      'left':
          'Exactamente {k} de las personas a la izquierda de {name} son '
          'criminales',
      'left_1':
          'Exactamente 1 de las personas a la izquierda de {name} es criminal',
      'right':
          'Exactamente {k} de las personas a la derecha de {name} son '
          'criminales',
      'right_1':
          'Exactamente 1 de las personas a la derecha de {name} es criminal',
      'row_more': 'Hay más criminales en la fila {r} que en la fila {r2}',
      'col_more': 'Hay más criminales en la columna {c} que en la columna {c2}',
      'row_same': 'Las filas {r} y {r2} tienen el mismo número de criminales',
      'col_same':
          'Las columnas {c} y {c2} tienen el mismo número de criminales',
      'nb_more': '{name} tiene más vecinos criminales que {name2}',
      'nb_same':
          '{name} y {name2} tienen el mismo número de vecinos criminales',
      'pair_one': 'Exactamente uno de {name} y {name2} es criminal',
      'pair_any': 'Al menos uno de {name} y {name2} es criminal',
      'pair_inno': '{name} y {name2} son inocentes',
      'pair_crim': '{name} y {name2} son criminales',
      'pair_same': '{name} y {name2} son ambos criminales o ambos inocentes',
      'corners': 'Las 4 esquinas tienen exactamente {k} criminales',
      'corners_1': 'Las 4 esquinas tienen exactamente 1 criminal',
      'edge': 'Hay exactamente {k} criminales en el borde',
      'edge_1': 'Hay exactamente 1 criminal en el borde',
      'direct_inno': '{name} es inocente',
      'direct_crim': '{name} es criminal',
      'common':
          '{name} y {name2} tienen exactamente {k} vecinos criminales en común',
      'common_1':
          '{name} y {name2} tienen exactamente 1 vecino criminal en común',
      'row_oneof':
          '{name} es una de las {k} personas criminales de la fila {r}',
      'row_only': '{name} es la única persona criminal de la fila {r}',
      'col_oneof':
          '{name} es una de las {k} personas criminales de la columna {c}',
      'col_only': '{name} es la única persona criminal de la columna {c}',
      'ui_innocent': 'Inocente',
      'ui_criminal': 'Criminal',
      'ui_not_enough': 'No hay pruebas suficientes',
      'ui_tap': 'Toca a una persona para acusarla o declararla inocente',
      'ui_ask': '¿{name} es inocente o criminal?',
    },
    'pt': {
      'nb_crim': '{name} tem exatamente {k} vizinhos criminosos',
      'nb_crim_1': '{name} tem exatamente 1 vizinho criminoso',
      'nb_inno': '{name} tem exatamente {k} vizinhos inocentes',
      'nb_inno_1': '{name} tem exatamente 1 vizinho inocente',
      'nb_major_crim': '{name} tem mais vizinhos criminosos do que inocentes',
      'nb_major_inno': '{name} tem mais vizinhos inocentes do que criminosos',
      'row_count': 'Há exatamente {k} criminosos na linha {r}',
      'row_count_1': 'Há exatamente 1 criminoso na linha {r}',
      'col_count': 'Há exatamente {k} criminosos na coluna {c}',
      'col_count_1': 'Há exatamente 1 criminoso na coluna {c}',
      'total': 'Há {k} criminosos no total',
      'total_1': 'Há só 1 criminoso no total',
      'above': 'Exatamente {k} das pessoas acima de {name} são criminosas',
      'above_1': 'Exatamente 1 das pessoas acima de {name} é criminosa',
      'below': 'Exatamente {k} das pessoas abaixo de {name} são criminosas',
      'below_1': 'Exatamente 1 das pessoas abaixo de {name} é criminosa',
      'left': 'Exatamente {k} das pessoas à esquerda de {name} são criminosas',
      'left_1': 'Exatamente 1 das pessoas à esquerda de {name} é criminosa',
      'right': 'Exatamente {k} das pessoas à direita de {name} são criminosas',
      'right_1': 'Exatamente 1 das pessoas à direita de {name} é criminosa',
      'row_more': 'Há mais criminosos na linha {r} do que na linha {r2}',
      'col_more': 'Há mais criminosos na coluna {c} do que na coluna {c2}',
      'row_same': 'As linhas {r} e {r2} têm o mesmo número de criminosos',
      'col_same': 'As colunas {c} e {c2} têm o mesmo número de criminosos',
      'nb_more': '{name} tem mais vizinhos criminosos do que {name2}',
      'nb_same': '{name} e {name2} têm o mesmo número de vizinhos criminosos',
      'pair_one': 'Exatamente um entre {name} e {name2} é criminoso',
      'pair_any': 'Pelo menos um entre {name} e {name2} é criminoso',
      'pair_inno': '{name} e {name2} são ambos inocentes',
      'pair_crim': '{name} e {name2} são ambos criminosos',
      'pair_same': '{name} e {name2} são ambos criminosos ou ambos inocentes',
      'corners': 'Os 4 cantos têm exatamente {k} criminosos',
      'corners_1': 'Os 4 cantos têm exatamente 1 criminoso',
      'edge': 'Há exatamente {k} criminosos na borda',
      'edge_1': 'Há exatamente 1 criminoso na borda',
      'direct_inno': '{name} é inocente',
      'direct_crim': '{name} é criminoso',
      'direct_crim_f': '{name} é criminosa',
      'common':
          '{name} e {name2} têm exatamente {k} vizinhos criminosos em comum',
      'common_1':
          '{name} e {name2} têm exatamente 1 vizinho criminoso em comum',
      'row_oneof': '{name} é uma das {k} pessoas criminosas da linha {r}',
      'row_only': '{name} é a única pessoa criminosa da linha {r}',
      'col_oneof': '{name} é uma das {k} pessoas criminosas da coluna {c}',
      'col_only': '{name} é a única pessoa criminosa da coluna {c}',
      'ui_innocent': 'Inocente',
      'ui_criminal': 'Criminoso',
      'ui_not_enough': 'Provas insuficientes',
      'ui_tap': 'Toque numa pessoa para acusá-la ou inocentá-la',
      'ui_ask': '{name}: inocente ou criminoso?',
    },
    'vi': {
      'nb_crim': '{name} có đúng {k} hàng xóm là tội phạm',
      'nb_inno': '{name} có đúng {k} hàng xóm vô tội',
      'nb_major_crim': '{name} có nhiều hàng xóm tội phạm hơn hàng xóm vô tội',
      'nb_major_inno': '{name} có nhiều hàng xóm vô tội hơn hàng xóm tội phạm',
      'row_count': 'Hàng {r} có đúng {k} tội phạm',
      'col_count': 'Cột {c} có đúng {k} tội phạm',
      'total': 'Có tổng cộng {k} tội phạm',
      'above': 'Có đúng {k} người phía trên {name} là tội phạm',
      'below': 'Có đúng {k} người phía dưới {name} là tội phạm',
      'left': 'Có đúng {k} người bên trái {name} là tội phạm',
      'right': 'Có đúng {k} người bên phải {name} là tội phạm',
      'row_more': 'Hàng {r} có nhiều tội phạm hơn hàng {r2}',
      'col_more': 'Cột {c} có nhiều tội phạm hơn cột {c2}',
      'row_same': 'Hàng {r} và hàng {r2} có số tội phạm bằng nhau',
      'col_same': 'Cột {c} và cột {c2} có số tội phạm bằng nhau',
      'nb_more': '{name} có nhiều hàng xóm là tội phạm hơn {name2}',
      'nb_same': '{name} và {name2} có số hàng xóm là tội phạm bằng nhau',
      'pair_one': 'Đúng một trong hai người {name} và {name2} là tội phạm',
      'pair_any': 'Ít nhất một trong hai người {name} và {name2} là tội phạm',
      'pair_inno': '{name} và {name2} đều vô tội',
      'pair_crim': '{name} và {name2} đều là tội phạm',
      'pair_same': '{name} và {name2} hoặc cùng là tội phạm, hoặc cùng vô tội',
      'corners': '4 góc có đúng {k} tội phạm',
      'edge': 'Có đúng {k} tội phạm ở rìa',
      'direct_inno': '{name} vô tội',
      'direct_crim': '{name} là tội phạm',
      'common': '{name} và {name2} có đúng {k} hàng xóm chung là tội phạm',
      'row_oneof': '{name} là một trong {k} tội phạm ở hàng {r}',
      'row_only': '{name} là tội phạm duy nhất ở hàng {r}',
      'col_oneof': '{name} là một trong {k} tội phạm ở cột {c}',
      'col_only': '{name} là tội phạm duy nhất ở cột {c}',
      'ui_innocent': 'Vô tội',
      'ui_criminal': 'Tội phạm',
      'ui_not_enough': 'Chưa đủ bằng chứng',
      'ui_tap': 'Chạm vào một người để buộc tội hoặc minh oan',
      'ui_ask': '{name} vô tội hay là tội phạm?',
    },
    'id': {
      'nb_crim': '{name} punya tepat {k} tetangga penjahat',
      'nb_inno': '{name} punya tepat {k} tetangga yang tidak bersalah',
      'nb_major_crim':
          '{name} punya lebih banyak tetangga penjahat daripada yang tidak '
          'bersalah',
      'nb_major_inno':
          '{name} punya lebih banyak tetangga tidak bersalah daripada '
          'penjahat',
      'row_count': 'Ada tepat {k} penjahat di baris {r}',
      'col_count': 'Ada tepat {k} penjahat di kolom {c}',
      'total': 'Total ada {k} penjahat',
      'above': 'Tepat {k} orang di atas {name} adalah penjahat',
      'below': 'Tepat {k} orang di bawah {name} adalah penjahat',
      'left': 'Tepat {k} orang di sebelah kiri {name} adalah penjahat',
      'right': 'Tepat {k} orang di sebelah kanan {name} adalah penjahat',
      'row_more': 'Baris {r} punya lebih banyak penjahat daripada baris {r2}',
      'col_more': 'Kolom {c} punya lebih banyak penjahat daripada kolom {c2}',
      'row_same': 'Baris {r} dan baris {r2} punya jumlah penjahat yang sama',
      'col_same': 'Kolom {c} dan kolom {c2} punya jumlah penjahat yang sama',
      'nb_more': '{name} punya lebih banyak tetangga penjahat daripada {name2}',
      'nb_same': '{name} dan {name2} punya jumlah tetangga penjahat yang sama',
      'pair_one': 'Tepat satu dari {name} dan {name2} adalah penjahat',
      'pair_any': 'Setidaknya satu dari {name} dan {name2} adalah penjahat',
      'pair_inno': '{name} dan {name2} sama-sama tidak bersalah',
      'pair_crim': '{name} dan {name2} sama-sama penjahat',
      'pair_same':
          '{name} dan {name2} sama-sama penjahat atau sama-sama tidak '
          'bersalah',
      'corners': 'Keempat sudut berisi tepat {k} penjahat',
      'edge': 'Ada tepat {k} penjahat di tepi',
      'direct_inno': '{name} tidak bersalah',
      'direct_crim': '{name} adalah penjahat',
      'common':
          '{name} dan {name2} punya tepat {k} tetangga bersama yang penjahat',
      'row_oneof': '{name} adalah salah satu dari {k} penjahat di baris {r}',
      'row_only': '{name} adalah satu-satunya penjahat di baris {r}',
      'col_oneof': '{name} adalah salah satu dari {k} penjahat di kolom {c}',
      'col_only': '{name} adalah satu-satunya penjahat di kolom {c}',
      'ui_innocent': 'Tidak bersalah',
      'ui_criminal': 'Penjahat',
      'ui_not_enough': 'Bukti belum cukup',
      'ui_tap': 'Ketuk seseorang untuk menuduh atau membebaskannya',
      'ui_ask': 'Apakah {name} tidak bersalah atau penjahat?',
    },
    'de': {
      'nb_crim': '{name} hat genau {k} schuldige Nachbarn',
      'nb_crim_1': '{name} hat genau einen schuldigen Nachbarn',
      'nb_inno': '{name} hat genau {k} unschuldige Nachbarn',
      'nb_inno_1': '{name} hat genau einen unschuldigen Nachbarn',
      'nb_major_crim': '{name} hat mehr schuldige als unschuldige Nachbarn',
      'nb_major_inno': '{name} hat mehr unschuldige als schuldige Nachbarn',
      'row_count': 'In Reihe {r} gibt es genau {k} Schuldige',
      'row_count_1': 'In Reihe {r} gibt es genau eine schuldige Person',
      'col_count': 'In Spalte {c} gibt es genau {k} Schuldige',
      'col_count_1': 'In Spalte {c} gibt es genau eine schuldige Person',
      'total': 'Insgesamt gibt es {k} Schuldige',
      'total_1': 'Insgesamt gibt es nur eine schuldige Person',
      'above': 'Genau {k} der Personen über {name} sind schuldig',
      'above_1': 'Genau eine der Personen über {name} ist schuldig',
      'below': 'Genau {k} der Personen unter {name} sind schuldig',
      'below_1': 'Genau eine der Personen unter {name} ist schuldig',
      'left': 'Genau {k} der Personen links von {name} sind schuldig',
      'left_1': 'Genau eine der Personen links von {name} ist schuldig',
      'right': 'Genau {k} der Personen rechts von {name} sind schuldig',
      'right_1': 'Genau eine der Personen rechts von {name} ist schuldig',
      'row_more': 'In Reihe {r} gibt es mehr Schuldige als in Reihe {r2}',
      'col_more': 'In Spalte {c} gibt es mehr Schuldige als in Spalte {c2}',
      'row_same': 'Die Reihen {r} und {r2} haben gleich viele Schuldige',
      'col_same': 'Die Spalten {c} und {c2} haben gleich viele Schuldige',
      'nb_more': '{name} hat mehr schuldige Nachbarn als {name2}',
      'nb_same': '{name} und {name2} haben gleich viele schuldige Nachbarn',
      'pair_one': 'Von {name} und {name2} ist genau eine Person schuldig',
      'pair_any': 'Von {name} und {name2} ist mindestens eine Person schuldig',
      'pair_inno': '{name} und {name2} sind beide unschuldig',
      'pair_crim': '{name} und {name2} sind beide schuldig',
      'pair_same':
          '{name} und {name2} sind entweder beide schuldig oder beide '
          'unschuldig',
      'corners': 'In den 4 Ecken gibt es genau {k} Schuldige',
      'corners_1': 'In den 4 Ecken gibt es genau eine schuldige Person',
      'edge': 'Am Rand gibt es genau {k} Schuldige',
      'edge_1': 'Am Rand gibt es genau eine schuldige Person',
      'direct_inno': '{name} ist unschuldig',
      'direct_crim': '{name} ist schuldig',
      'common':
          '{name} und {name2} haben genau {k} gemeinsame schuldige '
          'Nachbarn',
      'common_1':
          '{name} und {name2} haben genau einen gemeinsamen schuldigen '
          'Nachbarn',
      'row_oneof': '{name} ist eine von {k} schuldigen Personen in Reihe {r}',
      'row_only': '{name} ist die einzige schuldige Person in Reihe {r}',
      'col_oneof': '{name} ist eine von {k} schuldigen Personen in Spalte {c}',
      'col_only': '{name} ist die einzige schuldige Person in Spalte {c}',
      'ui_innocent': 'Unschuldig',
      'ui_criminal': 'Schuldig',
      'ui_not_enough': 'Nicht genug Beweise',
      'ui_tap': 'Tippe auf eine Person, um sie anzuklagen oder zu entlasten',
      'ui_ask': 'Ist {name} unschuldig oder schuldig?',
    },
    'ja': {
      'nb_crim': '{name}の隣人のうち、犯人はちょうど{k}人',
      'nb_inno': '{name}の隣人のうち、無実の人はちょうど{k}人',
      'nb_major_crim': '{name}の隣人は、無実の人より犯人のほうが多い',
      'nb_major_inno': '{name}の隣人は、犯人より無実の人のほうが多い',
      'row_count': '{r}行目の犯人はちょうど{k}人',
      'col_count': '{c}列の犯人はちょうど{k}人',
      'total': '犯人は全部で{k}人',
      'above': '{name}より上にいる人のうち、犯人はちょうど{k}人',
      'below': '{name}より下にいる人のうち、犯人はちょうど{k}人',
      'left': '{name}より左にいる人のうち、犯人はちょうど{k}人',
      'right': '{name}より右にいる人のうち、犯人はちょうど{k}人',
      'row_more': '{r}行目の犯人は{r2}行目より多い',
      'col_more': '{c}列の犯人は{c2}列より多い',
      'row_same': '{r}行目と{r2}行目の犯人の数は同じ',
      'col_same': '{c}列と{c2}列の犯人の数は同じ',
      'nb_more': '{name}は{name2}より犯人の隣人が多い',
      'nb_same': '{name}と{name2}の隣人にいる犯人の数は同じ',
      'pair_one': '{name}と{name2}のうち、犯人はちょうど1人',
      'pair_any': '{name}と{name2}のうち、少なくとも1人は犯人',
      'pair_inno': '{name}と{name2}はどちらも無実',
      'pair_crim': '{name}と{name2}はどちらも犯人',
      'pair_same': '{name}と{name2}は、どちらも犯人かどちらも無実',
      'corners': '四隅にいる犯人はちょうど{k}人',
      'edge': '外周にいる犯人はちょうど{k}人',
      'direct_inno': '{name}は無実',
      'direct_crim': '{name}は犯人',
      'common': '{name}と{name2}の共通の隣人のうち、犯人はちょうど{k}人',
      'row_oneof': '{name}は{r}行目にいる{k}人の犯人のうちの1人',
      'row_only': '{name}は{r}行目で唯一の犯人',
      'col_oneof': '{name}は{c}列にいる{k}人の犯人のうちの1人',
      'col_only': '{name}は{c}列で唯一の犯人',
      'ui_innocent': '無実',
      'ui_criminal': '犯人',
      'ui_not_enough': '証拠が足りません',
      'ui_tap': '人をタップして、犯人か無実かを選ぼう',
      'ui_ask': '{name}は無実？それとも犯人？',
    },
  };

  /// Template keys (excluding singular/feminine variants) missing in [lang],
  /// plus missing singular forms for languages with plural agreement.
  static List<String> missingKeys(String lang) {
    final en = templates['en']!;
    final m = templates[lang] ?? const {};
    return [
      for (final key in en.keys)
        if (!m.containsKey(key) &&
            !key.endsWith('_f') &&
            !key.endsWith('_0') &&
            (!key.endsWith('_1') || pluralLanguages.contains(lang)))
          key,
    ];
  }

  static String _pick(String lang, String key, {int? k, bool female = false}) {
    String? from(Map<String, String>? m) {
      if (m == null) return null;
      return (female ? m['${key}_f'] : null) ??
          (k == 1 ? m['${key}_1'] : null) ??
          (k == 0 ? m['${key}_0'] : null) ??
          m[key];
    }

    return from(templates[lang]) ?? from(templates['en']) ?? key;
  }

  static String ui(String lang, String key, {String name = ''}) =>
      _pick(lang, key).replaceAll('{name}', name);

  static String clue(
    CulpritClue c,
    List<String> names,
    List<bool> female,
    String lang,
  ) {
    final fem = c.people.length == 1 && female[c.people.first];
    final t = _pick(lang, c.key, k: c.k, female: fem);
    String letter(int x) => String.fromCharCode(65 + x);
    return t
        .replaceAll('{name}', c.people.isNotEmpty ? names[c.people[0]] : '')
        .replaceAll('{name2}', c.people.length > 1 ? names[c.people[1]] : '')
        .replaceAll('{k}', '${c.k}')
        .replaceAll('{r}', '${c.r + 1}')
        .replaceAll('{r2}', '${c.r2 + 1}')
        .replaceAll('{c}', letter(c.c))
        .replaceAll('{c2}', letter(c.c2));
  }
}

class CulpritGame extends StatefulWidget {
  const CulpritGame({super.key, required this.session, this.lang = 'en'});
  final GameSession session;
  final String lang;

  @override
  State<CulpritGame> createState() => _CulpritGameState();
}

class _CulpritGameState extends State<CulpritGame>
    with SingleTickerProviderStateMixin {
  late final CulpritPuzzle _p = CulpritPuzzle.forDifficulty(
    widget.session.difficulty,
    widget.session.level,
    widget.session.seed,
  );
  late int _revealed = 1 << _p.start;
  late int _focus = _p.start;
  int? _selected;
  int? _wrong;
  int? _hinted;
  bool _notEnough = false;
  bool _won = false;
  int _forcedFor = -1;
  int _forcedVal = 0;
  Timer? _msgTimer, _wrongTimer, _winTimer;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  static const _avatarColors = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF6C00),
    Color(0xFF8E24AA),
    Color(0xFF0288D1),
    Color(0xFF7CB342),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
    Color(0xFF00897B),
    Color(0xFFF4511E),
    Color(0xFF3949AB),
    Color(0xFFC0CA33),
  ];

  String _t(String key, {String name = ''}) =>
      CulpritText.ui(widget.lang, key, name: name);

  @override
  void initState() {
    super.initState();
    widget.session.hint.addListener(_hint);
    if (widget.session.demo) {
      // Screenshot mode: about 40 % already deduced, in a logical order.
      final target = (_p.size * 0.4).round();
      while (_pop(_revealed) < target) {
        final f = _forcedNow();
        if (f == 0) break;
        final i = (f & -f).bitLength - 1;
        _revealed |= 1 << i;
        _focus = i;
      }
    }
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_hint);
    _msgTimer?.cancel();
    _wrongTimer?.cancel();
    _winTimer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  bool _isRevealed(int i) => (_revealed >> i) & 1 == 1;

  int _forcedNow() {
    if (_forcedFor != _revealed) {
      _forcedFor = _revealed;
      _forcedVal = _p.forcedMask(_revealed);
    }
    return _forcedVal;
  }

  void _hint() {
    if (_won) return;
    final f = _forcedNow();
    if (f == 0) return;
    // Prefer the person the player is looking at, if it is deducible.
    final sel = _selected;
    final i = sel != null && (f >> sel) & 1 == 1 ? sel : (f & -f).bitLength - 1;
    _reveal(i, hinted: true);
  }

  void _tap(int i) {
    if (_won) return;
    setState(() {
      _hinted = null;
      if (_isRevealed(i)) {
        _focus = i;
        _selected = null;
      } else {
        _selected = _selected == i ? null : i;
      }
    });
  }

  void _answer(bool criminal) {
    final i = _selected;
    if (i == null || _won) return;
    if (criminal != _p.isCriminal(i)) {
      widget.session.addMistake();
      setState(() {
        _wrong = i;
        _notEnough = false;
      });
      _shake.forward(from: 0);
      _wrongTimer?.cancel();
      _wrongTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrong = null);
      });
      return;
    }
    if ((_forcedNow() >> i) & 1 == 0) {
      setState(() => _notEnough = true);
      _msgTimer?.cancel();
      _msgTimer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _notEnough = false);
      });
      return;
    }
    _reveal(i);
  }

  void _reveal(int i, {bool hinted = false}) {
    setState(() {
      _revealed |= 1 << i;
      _focus = i;
      _selected = null;
      _notEnough = false;
      _hinted = hinted ? i : null;
    });
    if (_revealed == _p.allMask && !_won) {
      _won = true;
      _winTimer = Timer(
        const Duration(milliseconds: 400),
        widget.session.onWin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _cluePanel(context),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(builder: (context, box) => _grid(box)),
              ),
              if (_notEnough)
                Positioned(
                  top: 4,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _t('ui_not_enough'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _actionBar(context),
      ],
    );
  }

  Widget _avatar(int i, double d) => Container(
    width: d,
    height: d,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _avatarColors[i % _avatarColors.length],
      shape: BoxShape.circle,
    ),
    child: Text(
      _p.names[i][0],
      style: TextStyle(
        color: Colors.white,
        fontSize: d * 0.5,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _cluePanel(BuildContext context) {
    final i = _focus;
    final crim = _p.isCriminal(i);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
      ),
      child: Row(
        children: [
          _avatar(i, 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${_p.names[i]} · ${_p.label(i)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      crim ? Icons.gavel : Icons.verified_user,
                      size: 15,
                      color: crim ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _p.clueText(i, widget.lang),
                  key: const ValueKey('culprit-clue'),
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(BoxConstraints box) {
    const lab = 18.0;
    final cols = _p.cols, rows = _p.rows;
    var cw = (box.maxWidth - 24 - lab) / cols;
    var ch = (box.maxHeight - 8 - lab) / rows;
    ch = min(ch, cw * 1.3);
    cw = min(cw, ch * 1.15);
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
    return Center(
      child: SizedBox(
        width: lab + cw * cols,
        height: lab + ch * rows,
        child: Column(
          children: [
            SizedBox(
              height: lab,
              child: Row(
                children: [
                  const SizedBox(width: lab),
                  for (var c = 0; c < cols; c++)
                    SizedBox(
                      width: cw,
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + c),
                          style: labelStyle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            for (var r = 0; r < rows; r++)
              Row(
                children: [
                  SizedBox(
                    width: lab,
                    child: Center(child: Text('${r + 1}', style: labelStyle)),
                  ),
                  for (var c = 0; c < cols; c++)
                    SizedBox(
                      width: cw,
                      height: ch,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: _card(r * cols + c, cw - 6, ch - 6),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _card(int i, double w, double h) {
    final revealed = _isRevealed(i);
    final crim = _p.isCriminal(i);
    final referenced = (_p.clues[_focus].mask >> i) & 1 == 1;
    final selected = _selected == i || (revealed && _focus == i);
    final wrong = _wrong == i;
    final Color bg;
    var border = Colors.blueGrey.shade200;
    var bw = 1.0;
    if (wrong) {
      bg = Colors.red.shade300;
    } else if (!revealed) {
      bg = const Color(0xFFF1F3F6);
    } else if (crim) {
      bg = Colors.red.shade100;
      border = Colors.red.shade300;
    } else {
      bg = Colors.green.shade100;
      border = Colors.green.shade400;
    }
    if (referenced) {
      border = const Color(0xFFFFA000);
      bw = 2.5;
    }
    if (selected) {
      border = Colors.blue.shade700;
      bw = 3;
    }
    final d = min(w, h) * 0.46;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: bw),
        boxShadow: [
          if (_hinted == i)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.9),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(opacity: revealed ? 0.85 : 1, child: _avatar(i, d)),
                    const SizedBox(height: 3),
                    Text(
                      _p.names[i],
                      style: TextStyle(
                        fontSize: (w * 0.17).clamp(11.0, 15.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (revealed)
            Positioned(
              top: 3,
              right: 3,
              child: Icon(
                crim ? Icons.gavel : Icons.verified_user,
                size: 16,
                color: crim ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
        ],
      ),
    );
    return GestureDetector(
      key: ValueKey('culprit-card-$i'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _tap(i),
      child: wrong
          ? AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final t = _shake.value;
                return Transform.translate(
                  offset: Offset(sin(t * pi * 6) * 6 * (1 - t), 0),
                  child: child,
                );
              },
              child: card,
            )
          : card,
    );
  }

  Widget _actionBar(BuildContext context) {
    final i = _selected;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: i == null
            ? Center(
                child: Text(
                  _won ? '' : _t('ui_tap'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _t('ui_ask', name: _p.names[i]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('culprit-btn-innocent'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                          ),
                          onPressed: () => _answer(false),
                          icon: const Icon(Icons.verified_user),
                          label: FittedBox(child: Text(_t('ui_innocent'))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('culprit-btn-criminal'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 46),
                          ),
                          onPressed: () => _answer(true),
                          icon: const Icon(Icons.gavel),
                          label: FittedBox(child: Text(_t('ui_criminal'))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
