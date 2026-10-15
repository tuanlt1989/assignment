import 'dart:math';

import 'package:flutter/material.dart';

import 'session.dart';
import 'weave_words.dart';

/// Outcome of tracing a path of letters.
enum WeaveVerdict {
  /// Spells an unfound hidden word and the rest of the board still works.
  found,

  /// Spells an unfound hidden word, but taking these cells would leave the
  /// rest of the board unsolvable. Rejected without penalty.
  blocked,

  /// Not a hidden word (counts as a mistake).
  wrong,

  /// Fewer than 3 letters: ignored.
  tooShort,
}

/// "Word Weave": a letter grid completely split into hidden words. Every word
/// is a chain of orthogonally adjacent cells and every cell belongs to exactly
/// one word. The player only sees the letters and the word lengths.
class WeavePuzzle {
  WeavePuzzle(this.cols, this.rows, this.letters, this.words, this.paths);

  final int cols;
  final int rows;

  /// One uppercase letter per cell (index r * cols + c).
  final List<String> letters;

  /// The hidden words (all distinct).
  final List<String> words;

  /// Intended solution: cells of each word, in reading order.
  final List<List<int>> paths;

  int get size => cols * rows;

  /// Grid size (cols, rows) for a difficulty / level.
  static (int, int) gridSize(int difficulty, int level) => switch (difficulty) {
    0 => (4, 4),
    1 => (5, 5),
    2 => level.isOdd ? (5, 6) : (6, 6),
    _ => level.isOdd ? (6, 7) : (7, 7),
  };

  /// Builds a puzzle deterministically from (difficulty, level, seed, lang).
  static WeavePuzzle generate(
    int difficulty,
    int level,
    int seed, {
    String lang = 'en',
  }) {
    final d = difficulty.clamp(0, 3);
    final (cols, rows) = gridSize(d, level);
    final rnd = Random(seed);
    final dict = weaveWords(lang);
    final byLen = <int, List<String>>{};
    for (final w in dict) {
      (byLen[w.length] ??= []).add(w);
    }
    final base = const [
      {3: 2, 4: 4, 5: 4, 6: 2, 7: 1},
      {3: 2, 4: 4, 5: 4, 6: 3, 7: 1},
      {3: 1, 4: 3, 5: 4, 6: 4, 7: 2},
      {3: 1, 4: 2, 5: 4, 6: 4, 7: 3},
    ][d];
    // Fewer short words in languages with few of them.
    final weights = <int, double>{
      for (final e in base.entries)
        if ((byLen[e.key]?.length ?? 0) >= 12)
          e.key: e.value * min(1.0, byLen[e.key]!.length / 60.0),
    };
    final (minWords, maxWords) = const [(3, 4), (5, 7), (6, 9), (7, 11)][d];

    // Keep the unique puzzle whose words have the fewest look-alike paths
    // elsewhere on the board (those would be rejected as "blocked").
    WeavePuzzle? fallback, best;
    var bestScore = 1 << 30, uniques = 0;
    for (var attempt = 0; attempt < 60 && uniques < 8; attempt++) {
      final parts = _partition(cols, rows, rnd, weights, minWords, maxWords);
      if (parts == null) continue;
      for (var fill = 0; fill < 12; fill++) {
        final p = _fill(cols, rows, parts, byLen, rnd);
        if (p == null) continue;
        fallback ??= p;
        if (p.countSolutions(limit: 2, maxNodes: 4000) != 1) continue;
        uniques++;
        final score = p._lookAlikes();
        if (score < bestScore) {
          bestScore = score;
          best = p;
        }
        if (score == 0 || uniques >= 8) break;
      }
      if (bestScore == 0) break;
    }
    return best ?? fallback ?? _emergency(cols, rows, byLen, rnd);
  }

  /// Extra placements of hidden words beyond their intended path.
  int _lookAlikes() {
    final none = List<bool>.filled(size, false);
    var extra = 0;
    for (final w in words) {
      extra += placements(w, none).length - 1;
    }
    return extra;
  }

  /// Splits the grid into random snake-like paths (lengths from [weights]).
  static List<List<int>>? _partition(
    int cols,
    int rows,
    Random rnd,
    Map<int, double> weights,
    int minWords,
    int maxWords,
  ) {
    final n = cols * rows;
    final owner = List<int>.filled(n, -1);
    final paths = <List<int>>[];
    final lengths = weights.keys.toList()..sort();
    final minLen = lengths.first, maxLen = lengths.last;
    var nodes = 0;

    List<int> nb(int cell) => _neighboursOf(cell, cols, rows);

    bool componentsOk() {
      final seen = List<bool>.filled(n, false);
      for (var s = 0; s < n; s++) {
        if (owner[s] != -1 || seen[s]) continue;
        var count = 0;
        final stack = [s];
        seen[s] = true;
        while (stack.isNotEmpty) {
          final x = stack.removeLast();
          count++;
          for (final y in nb(x)) {
            if (owner[y] == -1 && !seen[y]) {
              seen[y] = true;
              stack.add(y);
            }
          }
        }
        if (count < minLen) return false;
      }
      return true;
    }

    List<int> order() {
      // Weighted shuffle of the allowed lengths.
      final pool = Map.of(weights);
      final out = <int>[];
      while (pool.isNotEmpty) {
        final total = pool.values.fold<double>(0, (a, b) => a + b);
        var x = rnd.nextDouble() * total;
        var pick = pool.keys.first;
        for (final e in pool.entries) {
          x -= e.value;
          if (x <= 0) {
            pick = e.key;
            break;
          }
        }
        out.add(pick);
        pool.remove(pick);
      }
      return out;
    }

    // A few random self-avoiding walks of length [len] from [start].
    List<List<int>> walks(int start, int len) {
      final found = <List<int>>[];
      final keys = <String>{};
      for (var t = 0; t < 4 && found.length < 2; t++) {
        final path = [start];
        var steps = 0;
        bool dfs() {
          if (path.length == len) return true;
          if (++steps > 200) return false;
          final opts =
              nb(
                  path.last,
                ).where((y) => owner[y] == -1 && !path.contains(y)).toList()
                ..shuffle(rnd);
          for (final y in opts) {
            path.add(y);
            if (dfs()) return true;
            path.removeLast();
          }
          return false;
        }

        if (dfs() && keys.add(path.join(','))) found.add(List.of(path));
      }
      return found;
    }

    bool rec(int free) {
      if (free == 0) return paths.length >= minWords;
      if (++nodes > 400) return false;
      final left = maxWords - paths.length;
      if (left <= 0 || free > left * maxLen) return false;
      // Start from the free cell with the fewest free neighbours (it is
      // the hardest to cover); ties go to reading order.
      var start = -1, best = 9;
      for (var i = 0; i < n; i++) {
        if (owner[i] != -1) continue;
        final deg = nb(i).where((y) => owner[y] == -1).length;
        if (deg < best) {
          best = deg;
          start = i;
          if (deg <= 1) break;
        }
      }
      for (final len in order()) {
        if (len > free) continue;
        final rest = free - len;
        if (rest > 0 && rest < minLen) continue;
        final need = minWords - paths.length - 1;
        if (need > 0 && rest < need * minLen) continue;
        for (final p in walks(start, len)) {
          for (final x in p) {
            owner[x] = paths.length;
          }
          paths.add(p);
          if (componentsOk() && rec(rest)) return true;
          paths.removeLast();
          for (final x in p) {
            owner[x] = -1;
          }
        }
      }
      return false;
    }

    return rec(n) ? paths : null;
  }

  /// Puts a random distinct word on every path (random reading direction).
  static WeavePuzzle? _fill(
    int cols,
    int rows,
    List<List<int>> parts,
    Map<int, List<String>> byLen,
    Random rnd,
  ) {
    final letters = List<String>.filled(cols * rows, '');
    final words = <String>[];
    final paths = <List<int>>[];
    final used = <String>{};
    for (final part in parts) {
      final list = byLen[part.length];
      if (list == null || list.isEmpty) return null;
      String? word;
      for (var t = 0; t < 20; t++) {
        final w = list[rnd.nextInt(list.length)];
        final rev = w.split('').reversed.join();
        if (used.contains(w) || used.contains(rev)) continue;
        word = w;
        break;
      }
      if (word == null) return null;
      used.add(word);
      final path = rnd.nextBool() ? List.of(part) : part.reversed.toList();
      for (var i = 0; i < path.length; i++) {
        letters[path[i]] = word[i];
      }
      words.add(word);
      paths.add(path);
    }
    return WeavePuzzle(cols, rows, letters, words, paths);
  }

  /// Never expected: rows of words laid out boustrophedon.
  static WeavePuzzle _emergency(
    int cols,
    int rows,
    Map<int, List<String>> byLen,
    Random rnd,
  ) {
    final order = [
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cols; c++) r * cols + (r.isEven ? c : cols - 1 - c),
    ];
    final parts = <List<int>>[];
    var i = 0;
    while (i < order.length) {
      var len = min(4, order.length - i);
      if (order.length - i - len > 0 && order.length - i - len < 3) {
        len = order.length - i;
      }
      parts.add(order.sublist(i, i + len));
      i += len;
    }
    return _fill(cols, rows, parts, byLen, rnd)!;
  }

  static List<int> _neighboursOf(int cell, int cols, int rows) {
    final r = cell ~/ cols, c = cell % cols;
    return [
      if (r > 0) cell - cols,
      if (r < rows - 1) cell + cols,
      if (c > 0) cell - 1,
      if (c < cols - 1) cell + 1,
    ];
  }

  List<int> neighbours(int cell) => _neighboursOf(cell, cols, rows);

  bool adjacent(int a, int b) {
    final ra = a ~/ cols, ca = a % cols, rb = b ~/ cols, cb = b % cols;
    return (ra - rb).abs() + (ca - cb).abs() == 1;
  }

  /// Every way to spell [word] along adjacent cells that are not [blocked]
  /// (paths in reading order; one per distinct set of cells).
  List<List<int>> placements(String word, List<bool> blocked) {
    final out = <List<int>>[];
    final keys = <String>{};
    final path = <int>[];
    void dfs(int cell) {
      path.add(cell);
      if (path.length == word.length) {
        final key = (List.of(path)..sort()).join(',');
        if (keys.add(key)) out.add(List.of(path));
      } else {
        for (final y in neighbours(cell)) {
          if (!blocked[y] &&
              !path.contains(y) &&
              letters[y] == word[path.length]) {
            dfs(y);
          }
        }
      }
      path.removeLast();
    }

    for (var i = 0; i < size; i++) {
      if (!blocked[i] && letters[i] == word[0]) dfs(i);
    }
    return out;
  }

  /// Solutions (each a path per word) that keep the [found] words where they
  /// are. Stops after [limit] solutions or [maxNodes] search steps.
  List<List<List<int>>> solutions(
    Map<int, List<int>> found, {
    int limit = 1,
    int maxNodes = 200000,
  }) => _search(found, limit, maxNodes).$1;

  /// (solutions, whether the search ran to the end within [maxNodes]).
  (List<List<List<int>>>, bool) _search(
    Map<int, List<int>> found,
    int limit,
    int maxNodes,
  ) {
    final covered = List<bool>.filled(size, false);
    for (final p in found.values) {
      for (final x in p) {
        if (covered[x]) return (const [], true);
        covered[x] = true;
      }
    }
    final todo = [
      for (var i = 0; i < words.length; i++)
        if (!found.containsKey(i)) i,
    ];
    final options = <int, List<List<int>>>{};
    for (final i in todo) {
      options[i] = placements(words[i], covered);
      if (options[i]!.isEmpty) return (const [], true);
    }
    final chosen = <int, List<int>>{...found};
    final open = todo.toSet();
    final out = <List<List<int>>>[];
    var nodes = 0;

    bool fits(List<int> p) => p.every((x) => !covered[x]);

    void rec() {
      if (out.length >= limit || ++nodes > maxNodes) return;
      if (open.isEmpty) {
        if (covered.every((c) => c)) {
          out.add([for (var i = 0; i < words.length; i++) chosen[i]!]);
        }
        return;
      }
      // Branch on the most constrained word or cell.
      final perCell = List<int>.filled(size, 0);
      final valid = <int, List<List<int>>>{};
      int? bestWord;
      var bestCount = 1 << 30;
      for (final i in open) {
        final v = [
          for (final p in options[i]!)
            if (fits(p)) p,
        ];
        if (v.isEmpty) return;
        valid[i] = v;
        for (final p in v) {
          for (final x in p) {
            perCell[x]++;
          }
        }
        if (v.length < bestCount) {
          bestCount = v.length;
          bestWord = i;
        }
      }
      var bestCell = -1;
      for (var x = 0; x < size; x++) {
        if (covered[x]) continue;
        if (perCell[x] == 0) return;
        if (perCell[x] < bestCount) {
          bestCount = perCell[x];
          bestCell = x;
        }
      }
      final branches = <(int, List<int>)>[];
      if (bestCell >= 0) {
        for (final i in open) {
          for (final p in valid[i]!) {
            if (p.contains(bestCell)) branches.add((i, p));
          }
        }
      } else {
        for (final p in valid[bestWord]!) {
          branches.add((bestWord!, p));
        }
      }
      for (final (i, p) in branches) {
        for (final x in p) {
          covered[x] = true;
        }
        open.remove(i);
        chosen[i] = p;
        rec();
        chosen.remove(i);
        open.add(i);
        for (final x in p) {
          covered[x] = false;
        }
        if (out.length >= limit || nodes > maxNodes) return;
      }
    }

    rec();
    return (out, nodes <= maxNodes);
  }

  /// One full solution consistent with [found], or null.
  List<List<int>>? solve([Map<int, List<int>> found = const {}]) =>
      solutions(found).firstOrNull;

  /// Can the rest of the board still be split into the unfound words?
  bool canComplete(Map<int, List<int>> found) => solve(found) != null;

  /// Number of full solutions, capped at [limit]. Returns [limit] when the
  /// search is cut off by [maxNodes] (treated as "not unique").
  int countSolutions({int limit = 2, int maxNodes = 200000}) {
    final (s, complete) = _search(const {}, limit, maxNodes);
    return complete ? s.length : limit;
  }

  /// Judges a traced path against the unfound words (either direction).
  (WeaveVerdict, int, List<int>) judge(
    List<int> trace,
    Map<int, List<int>> found,
  ) {
    if (trace.length < 3) return (WeaveVerdict.tooShort, -1, const []);
    final taken = {for (final p in found.values) ...p};
    for (var i = 0; i < trace.length; i++) {
      if (taken.contains(trace[i]) ||
          (i > 0 && !adjacent(trace[i - 1], trace[i])) ||
          trace.indexOf(trace[i]) != i) {
        return (WeaveVerdict.wrong, -1, const []);
      }
    }
    var blocked = false;
    for (final path in [trace, trace.reversed.toList()]) {
      final s = path.map((x) => letters[x]).join();
      for (var i = 0; i < words.length; i++) {
        if (found.containsKey(i) || words[i] != s) continue;
        if (canComplete({...found, i: path})) {
          return (WeaveVerdict.found, i, path);
        }
        blocked = true;
      }
    }
    return blocked
        ? (WeaveVerdict.blocked, -1, const [])
        : (WeaveVerdict.wrong, -1, const []);
  }
}

class WeaveGame extends StatefulWidget {
  const WeaveGame({super.key, required this.session, this.lang});
  final GameSession session;

  /// Word language ('en', 'es', 'pt', 'de'; others use English). Defaults to
  /// the device language.
  final String? lang;

  @override
  State<WeaveGame> createState() => _WeaveGameState();
}

class _WeaveGameState extends State<WeaveGame>
    with SingleTickerProviderStateMixin {
  late final WeavePuzzle _p;
  final _found = <int, List<int>>{};
  late List<List<int>> _plan;
  final _sel = <int>[];
  final _hinted = <int>{};
  List<int> _flash = const [];
  bool _flashBad = true;
  bool _dragMoved = false;
  bool _dragging = false;
  Offset? _downPos, _lastPos;
  bool _over = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  static const _palette = [
    Color(0xFFFFCDD2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFFFF59D),
    Color(0xFFE1BEE7),
    Color(0xFFFFE0B2),
    Color(0xFFB2EBF2),
    Color(0xFFF8BBD0),
    Color(0xFFDCEDC8),
    Color(0xFFD1C4E9),
    Color(0xFFFFCCBC),
    Color(0xFFB2DFDB),
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    final lang =
        widget.lang ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _p = WeavePuzzle.generate(s.difficulty, s.level, s.seed, lang: lang);
    _plan = _p.paths;
    if (s.demo) {
      // Screenshot mode: about half of the words already found.
      for (var i = 0; i < _p.words.length ~/ 2; i++) {
        _found[i] = _p.paths[i];
      }
    }
    s.hint.addListener(_hint);
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_hint);
    _shake.dispose();
    super.dispose();
  }

  Color _color(int word) => _palette[word % _palette.length];

  int? _owner(int cell) {
    for (final e in _found.entries) {
      if (e.value.contains(cell)) return e.key;
    }
    return null;
  }

  void _hint() {
    if (_over) return;
    final open = [
      for (var i = 0; i < _p.words.length; i++)
        if (!_found.containsKey(i)) i,
    ];
    if (open.isEmpty) return;
    final started = open.where(_hinted.contains).firstOrNull;
    if (started == null) {
      open.sort((a, b) => _p.words[a].length.compareTo(_p.words[b].length));
      setState(() => _hinted.add(open.first));
      return;
    }
    _lock(started, _plan[started]);
  }

  void _lock(int word, List<int> path) {
    setState(() {
      _found[word] = path;
      _hinted.remove(word);
      _sel.removeWhere(path.contains);
      _plan = _p.solve(_found) ?? _plan;
    });
    if (_found.length == _p.words.length && !_over) {
      _over = true;
      Future.delayed(const Duration(milliseconds: 450), widget.session.onWin);
    }
  }

  void _submit() {
    final trace = List.of(_sel);
    setState(_sel.clear);
    if (trace.length < 3 || _over) return;
    final (verdict, word, path) = _p.judge(trace, _found);
    switch (verdict) {
      case WeaveVerdict.found:
        _lock(word, path);
      case WeaveVerdict.blocked:
        _reject(trace, bad: false);
      case WeaveVerdict.wrong:
        _reject(trace, bad: true);
        widget.session.addMistake();
      case WeaveVerdict.tooShort:
        break;
    }
  }

  void _reject(List<int> trace, {required bool bad}) {
    setState(() {
      _flash = trace;
      _flashBad = bad;
    });
    _shake.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _flash = const []);
    });
  }

  bool _free(int cell) => _owner(cell) == null;

  void _tap(int cell) {
    if (_over || !_free(cell)) return;
    setState(() {
      if (_sel.isEmpty) {
        _sel.add(cell);
      } else if (_sel.last == cell) {
        _sel.removeLast();
      } else if (_sel.contains(cell)) {
        _sel.removeRange(_sel.indexOf(cell) + 1, _sel.length);
      } else if (_p.adjacent(_sel.last, cell)) {
        _sel.add(cell);
      } else {
        _sel
          ..clear()
          ..add(cell);
      }
    });
  }

  int? _cellAt(Offset pos, double tile, {required bool strict}) {
    final c = (pos.dx / tile).floor(), r = (pos.dy / tile).floor();
    if (c < 0 || c >= _p.cols || r < 0 || r >= _p.rows) return null;
    if (strict) {
      // Only the middle of a tile counts while dragging, so cutting a corner
      // doesn't grab a diagonal neighbour by accident.
      final centre = Offset((c + 0.5) * tile, (r + 0.5) * tile);
      if ((pos - centre).distance > tile * 0.42) return null;
    }
    return r * _p.cols + c;
  }

  void _panDown(Offset pos) => _downPos = pos;

  void _panStart(Offset pos, double tile) {
    final down = _downPos ?? pos;
    final cell = _cellAt(down, tile, strict: false);
    _dragMoved = false;
    _dragging = cell != null && _free(cell) && !_over;
    if (!_dragging) return;
    setState(() {
      if (_sel.isNotEmpty && _sel.last == cell) return;
      if (_sel.isNotEmpty &&
          !_sel.contains(cell) &&
          _p.adjacent(_sel.last, cell!)) {
        _sel.add(cell);
      } else {
        _sel
          ..clear()
          ..add(cell!);
      }
    });
    _lastPos = down;
    _panUpdate(pos, tile);
  }

  void _panUpdate(Offset pos, double tile) {
    if (!_dragging) return;
    // Walk the segment in small steps so a fast swipe doesn't skip tiles.
    final from = _lastPos ?? pos;
    final steps = max(1, ((pos - from).distance / (tile * 0.2)).ceil());
    for (var k = 1; k <= steps; k++) {
      _dragTo(Offset.lerp(from, pos, k / steps)!, tile);
    }
    _lastPos = pos;
  }

  void _dragTo(Offset pos, double tile) {
    final cell = _cellAt(pos, tile, strict: true);
    if (cell == null || _sel.isEmpty || cell == _sel.last) return;
    if (_sel.length >= 2 && cell == _sel[_sel.length - 2]) {
      setState(_sel.removeLast);
      _dragMoved = true;
    } else if (_free(cell) &&
        !_sel.contains(cell) &&
        _p.adjacent(_sel.last, cell)) {
      setState(() => _sel.add(cell));
      _dragMoved = true;
    }
  }

  void _panEnd() {
    if (_dragging && _dragMoved && _sel.length >= 2) _submit();
    _dragging = false;
    _downPos = _lastPos = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _slots(context),
        const SizedBox(height: 6),
        _selectionBar(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final tile = min(
                (box.maxWidth - 24) / _p.cols,
                (box.maxHeight - 16) / _p.rows,
              ).clamp(20.0, 88.0);
              return Center(
                child: AnimatedBuilder(
                  animation: _shake,
                  builder: (context, child) {
                    final t = _shake.value;
                    return Transform.translate(
                      offset: Offset(sin(t * pi * 5) * 10 * (1 - t), 0),
                      child: child,
                    );
                  },
                  child: _board(context, tile),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _slots(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final order = List.generate(_p.words.length, (i) => i)
      ..sort((a, b) {
        final d = _p.words[a].length.compareTo(_p.words[b].length);
        return d != 0 ? d : a.compareTo(b);
      });
    final box = _p.size <= 16
        ? 28.0
        : _p.size <= 25
        ? 24.0
        : 21.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final w in order)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var k = 0; k < _p.words[w].length; k++)
                  _slotBox(cs, w, k, box),
              ],
            ),
        ],
      ),
    );
  }

  Widget _slotBox(ColorScheme cs, int w, int k, double box) {
    final found = _found.containsKey(w);
    final hinted = !found && k == 0 && _hinted.contains(w);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: box,
      height: box + 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: found ? _color(w) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(5),
        border: Border(
          bottom: BorderSide(
            color: found ? Colors.black26 : cs.outline,
            width: 2,
          ),
        ),
      ),
      child: Text(
        found || hinted ? _p.words[w][k] : '',
        style: TextStyle(
          fontSize: box * 0.58,
          fontWeight: FontWeight.w700,
          color: found ? Colors.black87 : cs.tertiary,
        ),
      ),
    );
  }

  Widget _selectionBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = _sel.map((x) => _p.letters[x]).join();
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _sel.isEmpty ? null : () => setState(_sel.clear),
            icon: const Icon(Icons.backspace_outlined),
          ),
          const SizedBox(width: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: _sel.isEmpty
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                  : cs.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            onPressed: _sel.length >= 3 ? _submit : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  Widget _board(BuildContext context, double tile) {
    final cs = Theme.of(context).colorScheme;
    final hintCells = {
      for (final w in _hinted)
        if (!_found.containsKey(w)) _plan[w].first,
    };
    final flash = _flash.toSet();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        final cell = _cellAt(d.localPosition, tile, strict: false);
        if (cell != null) _tap(cell);
      },
      onPanDown: (d) => _panDown(d.localPosition),
      onPanStart: (d) => _panStart(d.localPosition, tile),
      onPanUpdate: (d) => _panUpdate(d.localPosition, tile),
      onPanEnd: (_) => _panEnd(),
      onPanCancel: () => _dragging = false,
      child: SizedBox(
        key: const ValueKey('weave-board'),
        width: tile * _p.cols,
        height: tile * _p.rows,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LinksPainter(
                  cols: _p.cols,
                  tile: tile,
                  links: [
                    for (final e in _found.entries)
                      (e.value, _darker(_color(e.key))),
                    (_sel, cs.primary),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < _p.size; i++)
              Positioned(
                left: (i % _p.cols) * tile,
                top: (i ~/ _p.cols) * tile,
                width: tile,
                height: tile,
                child: _tile(cs, i, tile, hintCells, flash),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    ColorScheme cs,
    int i,
    double tile,
    Set<int> hintCells,
    Set<int> flash,
  ) {
    final owner = _owner(i);
    final selected = _sel.contains(i);
    final Color bg, fg;
    if (flash.contains(i)) {
      bg = _flashBad ? cs.errorContainer : const Color(0xFFFFE082);
      fg = _flashBad ? cs.onErrorContainer : Colors.black87;
    } else if (selected) {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else if (owner != null) {
      bg = _color(owner);
      fg = Colors.black87;
    } else if (hintCells.contains(i)) {
      bg = cs.tertiaryContainer;
      fg = cs.onTertiaryContainer;
    } else {
      bg = cs.surfaceContainerHighest;
      fg = cs.onSurface;
    }
    return Padding(
      padding: EdgeInsets.all(tile * 0.08),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(tile * 0.26),
          border: hintCells.contains(i) && owner == null && !selected
              ? Border.all(color: cs.tertiary, width: 2.5)
              : null,
          boxShadow: selected || owner != null
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 2,
                    offset: const Offset(0, 1.5),
                  ),
                ],
        ),
        child: Text(
          _p.letters[i],
          style: TextStyle(
            fontSize: tile * 0.46,
            fontWeight: FontWeight.w700,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }

  static Color _darker(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Thick connectors between consecutive cells of each word / the trace,
/// drawn under the tiles so they show in the gaps.
class _LinksPainter extends CustomPainter {
  _LinksPainter({required this.cols, required this.tile, required this.links});
  final int cols;
  final double tile;
  final List<(List<int>, Color)> links;

  @override
  void paint(Canvas canvas, Size size) {
    Offset centre(int cell) =>
        Offset((cell % cols + 0.5) * tile, (cell ~/ cols + 0.5) * tile);
    for (final (path, color) in links) {
      if (path.length < 2) continue;
      final paint = Paint()
        ..color = color
        ..strokeWidth = tile * 0.24
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final p = Path()..moveTo(centre(path.first).dx, centre(path.first).dy);
      for (final x in path.skip(1)) {
        p.lineTo(centre(x).dx, centre(x).dy);
      }
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(_LinksPainter old) => true;
}
