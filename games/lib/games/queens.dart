import 'dart:math';

import 'package:flutter/material.dart';

import 'session.dart';

/// "Cats" logic puzzle (Queens / Meowdoku style): one cat per row, column
/// and colour region; cats never touch, not even diagonally.
class QueensPuzzle {
  QueensPuzzle(this.n, this.regions, this.solution);
  final int n;

  /// Region id per cell (r * n + c).
  final List<int> regions;

  /// Column of the cat in each row.
  final List<int> solution;

  static QueensPuzzle generate(int level, int seed) {
    final rnd = Random(seed);
    final n = (5 + level ~/ 7).clamp(5, 9);
    QueensPuzzle? best;
    for (var attempt = 0; attempt < 80; attempt++) {
      final sol = _placeCats(n, rnd);
      final p = QueensPuzzle(n, _growRegions(n, sol, rnd), sol);
      if (p._makeUnique(rnd)) return p;
      best = p;
    }
    return best!;
  }

  /// While another solution exists, move one of its "wrong" cat cells into a
  /// neighbouring region (keeping every region connected and keeping each
  /// region's true cat) until the intended solution is the only one.
  bool _makeUnique(Random rnd) {
    for (var step = 0; step < 300; step++) {
      final sols = solutions(limit: 2);
      final other = sols.where((s) => !_same(s, solution)).firstOrNull;
      if (other == null) return true;
      final wrong = [
        for (var r = 0; r < n; r++)
          if (other[r] != solution[r]) r * n + other[r],
      ]..shuffle(rnd);
      var moved = false;
      for (final cell in wrong) {
        if (_isCat(cell)) continue;
        final from = regions[cell];
        final targets =
            _neighbours(cell)
                .map((x) => regions[x])
                .where((reg) => reg != from)
                .toSet()
                .toList()
              ..shuffle(rnd);
        for (final to in targets) {
          regions[cell] = to;
          if (_connected(from)) {
            moved = true;
            break;
          }
          regions[cell] = from;
        }
        if (moved) break;
      }
      if (!moved) return false;
    }
    return solutions(limit: 2).length == 1;
  }

  static bool _same(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _isCat(int cell) => solution[cell ~/ n] == cell % n;

  List<int> _neighbours(int cell) {
    final r = cell ~/ n, c = cell % n;
    return [
      if (r > 0) cell - n,
      if (r < n - 1) cell + n,
      if (c > 0) cell - 1,
      if (c < n - 1) cell + 1,
    ];
  }

  bool _connected(int region) {
    final cells = [
      for (var i = 0; i < n * n; i++)
        if (regions[i] == region) i,
    ];
    if (cells.isEmpty) return false;
    final seen = {cells.first};
    final stack = [cells.first];
    while (stack.isNotEmpty) {
      for (final x in _neighbours(stack.removeLast())) {
        if (regions[x] == region && seen.add(x)) stack.add(x);
      }
    }
    return seen.length == cells.length;
  }

  static List<int> _placeCats(int n, Random rnd) {
    final cols = List<int>.filled(n, -1);
    final used = List<bool>.filled(n, false);
    bool place(int r) {
      if (r == n) return true;
      final order = List<int>.generate(n, (i) => i)..shuffle(rnd);
      for (final c in order) {
        if (used[c]) continue;
        if (r > 0 && (cols[r - 1] - c).abs() <= 1) continue;
        cols[r] = c;
        used[c] = true;
        if (place(r + 1)) return true;
        used[c] = false;
      }
      return false;
    }

    place(0);
    return cols;
  }

  /// Grows one region from each cat by random flood fill.
  static List<int> _growRegions(int n, List<int> sol, Random rnd) {
    final regions = List<int>.filled(n * n, -1);
    final frontier = <int>[];
    for (var r = 0; r < n; r++) {
      regions[r * n + sol[r]] = r;
      frontier.add(r * n + sol[r]);
    }
    while (frontier.isNotEmpty) {
      final i = rnd.nextInt(frontier.length);
      final cell = frontier[i];
      final r = cell ~/ n, c = cell % n;
      final options = <int>[];
      for (final (dr, dc) in const [(0, 1), (1, 0), (0, -1), (-1, 0)]) {
        final rr = r + dr, cc = c + dc;
        if (rr < 0 || rr >= n || cc < 0 || cc >= n) continue;
        if (regions[rr * n + cc] == -1) options.add(rr * n + cc);
      }
      if (options.isEmpty) {
        frontier.removeAt(i);
        continue;
      }
      final next = options[rnd.nextInt(options.length)];
      regions[next] = regions[cell];
      frontier.add(next);
    }
    return regions;
  }

  /// Up to [limit] solutions (as the cat column for each row).
  List<List<int>> solutions({int limit = 2}) {
    final found = <List<int>>[];
    final usedCol = List<bool>.filled(n, false);
    final usedReg = List<bool>.filled(n, false);
    final cols = List<int>.filled(n, -1);
    void solve(int r) {
      if (found.length >= limit) return;
      if (r == n) {
        found.add(List.of(cols));
        return;
      }
      for (var c = 0; c < n; c++) {
        final reg = regions[r * n + c];
        if (usedCol[c] || usedReg[reg]) continue;
        if (r > 0 && (cols[r - 1] - c).abs() <= 1) continue;
        usedCol[c] = usedReg[reg] = true;
        cols[r] = c;
        solve(r + 1);
        usedCol[c] = usedReg[reg] = false;
      }
    }

    solve(0);
    return found;
  }

  int countSolutions({int limit = 2}) => solutions(limit: limit).length;
}

class QueensGame extends StatefulWidget {
  const QueensGame({super.key, required this.session});
  final GameSession session;

  @override
  State<QueensGame> createState() => _QueensGameState();
}

enum _Mark { none, x, cat }

class _QueensGameState extends State<QueensGame> {
  late final QueensPuzzle _p = QueensPuzzle.generate(
    widget.session.level,
    widget.session.seed,
  );
  late final List<_Mark> _marks = List.filled(_p.n * _p.n, _Mark.none);
  int _hearts = 3;
  int? _wrong;
  bool _over = false;

  static const _palette = [
    Color(0xFFFFCDD2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFFFF9C4),
    Color(0xFFE1BEE7),
    Color(0xFFFFE0B2),
    Color(0xFFB2EBF2),
    Color(0xFFD7CCC8),
    Color(0xFFF8BBD0),
  ];

  @override
  void initState() {
    super.initState();
    widget.session.hint.addListener(_hint);
    if (widget.session.demo) {
      // Screenshot mode: two cats already placed, plus a few marks.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hint();
        _hint();
      });
    }
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_hint);
    super.dispose();
  }

  void _hint() {
    for (var r = 0; r < _p.n; r++) {
      final cell = r * _p.n + _p.solution[r];
      if (_marks[cell] != _Mark.cat) {
        _placeCat(cell);
        return;
      }
    }
  }

  void _tap(int cell) {
    if (_over) return;
    switch (_marks[cell]) {
      case _Mark.none:
        setState(() => _marks[cell] = _Mark.x);
      case _Mark.x:
        _placeCat(cell);
      case _Mark.cat:
        return; // Cats are only ever placed when correct.
    }
  }

  void _placeCat(int cell) {
    final r = cell ~/ _p.n, c = cell % _p.n;
    if (_p.solution[r] != c) {
      setState(() {
        _hearts--;
        _wrong = cell;
        _marks[cell] = _Mark.x;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _wrong = null);
      });
      if (_hearts <= 0 && !_over) {
        _over = true;
        widget.session.onFail();
      }
      return;
    }
    setState(() {
      _marks[cell] = _Mark.cat;
      // Auto-X cells that can no longer hold a cat (row, column, region, touching).
      for (var i = 0; i < _marks.length; i++) {
        if (_marks[i] != _Mark.none) continue;
        final rr = i ~/ _p.n, cc = i % _p.n;
        if (rr == r ||
            cc == c ||
            _p.regions[i] == _p.regions[cell] ||
            ((rr - r).abs() <= 1 && (cc - c).abs() <= 1)) {
          _marks[i] = _Mark.x;
        }
      }
    });
    if (_marks.where((m) => m == _Mark.cat).length == _p.n && !_over) {
      _over = true;
      Future.delayed(const Duration(milliseconds: 300), widget.session.onWin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _p.n;
    return Column(
      children: [
        const SizedBox(height: 12),
        Hearts(left: _hearts),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87, width: 3),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: n,
                    ),
                    itemCount: n * n,
                    itemBuilder: (context, i) => _cell(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(int i) {
    final n = _p.n;
    final r = i ~/ n, c = i % n;
    final reg = _p.regions[i];
    bool edge(int rr, int cc) =>
        rr < 0 ||
        rr >= n ||
        cc < 0 ||
        cc >= n ||
        _p.regions[rr * n + cc] != reg;
    BorderSide side(bool thick) => BorderSide(
      color: thick ? Colors.black87 : Colors.black26,
      width: thick ? 2.5 : 0.5,
    );
    return GestureDetector(
      onTap: () => _tap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _wrong == i ? Colors.red.shade300 : _palette[reg % 9],
          border: Border(
            top: side(edge(r - 1, c)),
            bottom: side(edge(r + 1, c)),
            left: side(edge(r, c - 1)),
            right: side(edge(r, c + 1)),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, box) => switch (_marks[i]) {
            _Mark.cat => Icon(
              Icons.pets,
              size: box.maxWidth * 0.62,
              color: Colors.black87,
            ),
            _Mark.x => Icon(
              Icons.close,
              size: box.maxWidth * 0.36,
              color: Colors.black38,
            ),
            _Mark.none => const SizedBox.expand(),
          },
        ),
      ),
    );
  }
}
