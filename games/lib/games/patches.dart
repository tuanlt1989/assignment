import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'session.dart';

/// Shape badge a clue can show: SQUARE (w == h), WIDE (w > h), TALL (h > w).
enum PatchShape {
  square,
  wide,
  tall;

  static PatchShape of(int width, int height) => width == height
      ? square
      : width > height
      ? wide
      : tall;
}

/// Axis-aligned rectangle of cells: [top]/[left] corner plus size.
class PatchRect {
  const PatchRect(this.top, this.left, this.height, this.width);

  /// Rectangle spanned by two opposite corner cells (in any order).
  factory PatchRect.span(int r0, int c0, int r1, int c1) => PatchRect(
    min(r0, r1),
    min(c0, c1),
    (r0 - r1).abs() + 1,
    (c0 - c1).abs() + 1,
  );

  final int top;
  final int left;
  final int height;
  final int width;

  /// Last row / column inside the rectangle (inclusive).
  int get bottom => top + height - 1;
  int get right => left + width - 1;
  int get area => width * height;
  PatchShape get shape => PatchShape.of(width, height);

  bool contains(int r, int c) =>
      r >= top && r <= bottom && c >= left && c <= right;

  bool overlaps(PatchRect o) =>
      top <= o.bottom && o.top <= bottom && left <= o.right && o.left <= right;

  @override
  bool operator ==(Object other) =>
      other is PatchRect &&
      other.top == top &&
      other.left == left &&
      other.height == height &&
      other.width == width;

  @override
  int get hashCode => Object.hash(top, left, height, width);

  @override
  String toString() => 'PatchRect($top,$left ${width}x$height)';
}

/// One clue cell. [area] and/or [shape] may be hidden (null); a clue with
/// both hidden is an "any" clue: its patch just has to contain it.
class PatchClue {
  const PatchClue(this.row, this.col, {this.area, this.shape});
  final int row;
  final int col;
  final int? area;
  final PatchShape? shape;

  bool fits(PatchRect r) =>
      (area == null || area == r.area) && (shape == null || shape == r.shape);
}

/// Rectangle-division puzzle (Shikaku style): split the [size]×[size] grid
/// into rectangles, each holding exactly one clue and matching its area and
/// shape badge.
class PatchPuzzle {
  PatchPuzzle(this.size, this.clues, this.solution)
    : _clueAt = List<int>.filled(size * size, -1) {
    for (var k = 0; k < clues.length; k++) {
      _clueAt[clues[k].row * size + clues[k].col] = k;
    }
  }

  final int size;
  final List<PatchClue> clues;

  /// The intended solution: `solution[k]` is the patch holding `clues[k]`.
  final List<PatchRect> solution;

  final List<int> _clueAt;

  /// Index of the clue at (r, c), or null.
  int? clueAt(int r, int c) {
    final k = _clueAt[r * size + c];
    return k < 0 ? null : k;
  }

  /// Index of the clue a patch would correctly hold, or null if the patch
  /// holds 0 or 2+ clues or breaks its clue's area / shape.
  int? clueIn(PatchRect rect) {
    var found = -1;
    for (var r = rect.top; r <= rect.bottom; r++) {
      for (var c = rect.left; c <= rect.right; c++) {
        final k = _clueAt[r * size + c];
        if (k < 0) continue;
        if (found >= 0) return null;
        found = k;
      }
    }
    if (found < 0 || !clues[found].fits(rect)) return null;
    return found;
  }

  // ---------------------------------------------------------------- solver

  /// Number of solutions, counting up to [limit].
  int countSolutions({int limit = 2}) =>
      _solve(limit, 20000000)?.length ?? limit;

  /// Up to [limit] solutions (patch per clue), or null when the search
  /// needs more than [budget] nodes.
  List<List<PatchRect>>? _solve(int limit, int budget) {
    final n = size;
    final k = clues.length;
    final w1 = n + 1;
    // Prefix sums of clue cells, to reject rectangles holding 2+ clues.
    final pre = List<int>.filled(w1 * w1, 0);
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        pre[(r + 1) * w1 + c + 1] =
            pre[r * w1 + c + 1] +
            pre[(r + 1) * w1 + c] -
            pre[r * w1 + c] +
            (_clueAt[r * n + c] >= 0 ? 1 : 0);
      }
    }
    int inside(int r0, int c0, int r1, int c1) =>
        pre[(r1 + 1) * w1 + c1 + 1] -
        pre[r0 * w1 + c1 + 1] -
        pre[(r1 + 1) * w1 + c0] +
        pre[r0 * w1 + c0];

    // Candidate patches per clue.
    final cTop = <int>[], cBot = <int>[], cLeft = <int>[], cRight = <int>[];
    final cMask = <int>[], cClue = <int>[];
    final candsOf = List<List<int>>.generate(k, (_) => <int>[]);
    for (var q = 0; q < k; q++) {
      final clue = clues[q];
      for (var r0 = clue.row; r0 >= 0; r0--) {
        if (inside(r0, clue.col, clue.row, clue.col) > 1) break;
        for (var r1 = clue.row; r1 < n; r1++) {
          if (inside(r0, clue.col, r1, clue.col) > 1) break;
          for (var c0 = clue.col; c0 >= 0; c0--) {
            if (inside(r0, c0, r1, clue.col) > 1) break;
            for (var c1 = clue.col; c1 < n; c1++) {
              if (inside(r0, c0, r1, c1) > 1) break;
              final h = r1 - r0 + 1, w = c1 - c0 + 1;
              if (clue.area != null && clue.area != h * w) continue;
              if (clue.shape != null && clue.shape != PatchShape.of(w, h)) {
                continue;
              }
              candsOf[q].add(cTop.length);
              cTop.add(r0);
              cBot.add(r1);
              cLeft.add(c0);
              cRight.add(c1);
              cMask.add(((1 << w) - 1) << c0);
              cClue.add(q);
            }
          }
        }
      }
    }

    final occ = List<int>.filled(n, 0);
    final placed = List<bool>.filled(k, false);
    final pick = List<int>.filled(k, -1);
    final found = <List<int>>[];
    final full = (1 << n) - 1;
    var nodes = 0;
    var aborted = false;

    bool free(int i) {
      final m = cMask[i];
      for (var r = cTop[i]; r <= cBot[i]; r++) {
        if (occ[r] & m != 0) return false;
      }
      return true;
    }

    void rec(int remaining) {
      if (found.length >= limit || aborted) return;
      if (++nodes > budget) {
        aborted = true;
        return;
      }
      if (remaining == 0) {
        for (var r = 0; r < n; r++) {
          if (occ[r] != full) return;
        }
        found.add(List.of(pick));
        return;
      }
      final valid = <int>[];
      final cnt = List<int>.filled(n * n, 0);
      var bestClue = -1, bestClueN = 1 << 30;
      for (var q = 0; q < k; q++) {
        if (placed[q]) continue;
        var m = 0;
        for (final i in candsOf[q]) {
          if (!free(i)) continue;
          valid.add(i);
          m++;
          for (var r = cTop[i]; r <= cBot[i]; r++) {
            for (var c = cLeft[i]; c <= cRight[i]; c++) {
              cnt[r * n + c]++;
            }
          }
        }
        if (m == 0) return;
        if (m < bestClueN) {
          bestClueN = m;
          bestClue = q;
        }
      }
      var bestCell = -1, bestCellN = bestClueN;
      for (var r = 0; r < n; r++) {
        final row = occ[r];
        if (row == full) continue;
        for (var c = 0; c < n; c++) {
          if (row >> c & 1 != 0) continue;
          final v = cnt[r * n + c];
          if (v == 0) return;
          if (v < bestCellN) {
            bestCellN = v;
            bestCell = r * n + c;
          }
        }
      }
      final br = bestCell ~/ n, bc = bestCell % n;
      for (final i in valid) {
        if (bestCell >= 0) {
          if (br < cTop[i] || br > cBot[i] || bc < cLeft[i] || bc > cRight[i]) {
            continue;
          }
        } else if (cClue[i] != bestClue) {
          continue;
        }
        final q = cClue[i];
        for (var r = cTop[i]; r <= cBot[i]; r++) {
          occ[r] |= cMask[i];
        }
        placed[q] = true;
        pick[q] = i;
        rec(remaining - 1);
        placed[q] = false;
        for (var r = cTop[i]; r <= cBot[i]; r++) {
          occ[r] &= ~cMask[i];
        }
        if (found.length >= limit || aborted) return;
      }
    }

    rec(k);
    if (aborted) return null;
    return [
      for (final s in found)
        [
          for (final i in s)
            PatchRect(
              cTop[i],
              cLeft[i],
              cBot[i] - cTop[i] + 1,
              cRight[i] - cLeft[i] + 1,
            ),
        ],
    ];
  }

  // ------------------------------------------------------------ generator

  static const _budget = 60000;

  /// Grid side for a difficulty (0 easy … 3 expert); some later levels of
  /// the easier tiers grow by one.
  static int sizeFor(int difficulty, int level) {
    final d = difficulty.clamp(0, 3);
    final base = 5 + d;
    if (d < 3 && level >= 12 && level % 3 == 0) return base + 1;
    return base;
  }

  static PatchPuzzle generate(int difficulty, int level, int seed) {
    final d = difficulty.clamp(0, 3);
    final rnd = Random(seed);
    final n = sizeFor(d, level);
    PatchPuzzle? fallback;
    for (var attempt = 0; attempt < 40; attempt++) {
      final rects = _partition(n, d, rnd);
      final cells = [
        for (final r in rects)
          (r.top + rnd.nextInt(r.height), r.left + rnd.nextInt(r.width)),
      ];
      final shownNum = List<bool>.filled(rects.length, true);
      final shownShape = List<bool>.filled(rects.length, true);
      PatchPuzzle build() => PatchPuzzle(n, [
        for (var q = 0; q < rects.length; q++)
          PatchClue(
            cells[q].$1,
            cells[q].$2,
            area: shownNum[q] ? rects[q].area : null,
            shape: shownShape[q] ? rects[q].shape : null,
          ),
      ], rects);

      // 1. With every number and shape shown, move clue cells until the
      //    layout is unique.
      var p = build();
      var unique = false;
      for (var step = 0; step < 16; step++) {
        final sols = p._solve(2, _budget);
        if (sols == null) break;
        if (sols.length == 1) {
          unique = true;
          break;
        }
        final alt = sols.firstWhere((s) => !_sameLayout(s, rects));
        final movable = [
          for (var q = 0; q < rects.length; q++)
            if (alt[q] != rects[q] && rects[q].area > 1) q,
        ];
        if (movable.isEmpty) break;
        final q = movable[rnd.nextInt(movable.length)];
        final r = rects[q];
        var cell = cells[q];
        while (cell == cells[q]) {
          cell = (r.top + rnd.nextInt(r.height), r.left + rnd.nextInt(r.width));
        }
        cells[q] = cell;
        p = build();
      }
      fallback ??= p;
      if (!unique) continue;

      // 2. Hide information according to difficulty...
      for (var q = 0; q < rects.length; q++) {
        final x = rnd.nextDouble();
        final y = rnd.nextDouble();
        switch (d) {
          case 0:
            shownShape[q] = y < 0.5;
          case 1:
            shownNum[q] = x >= 0.15;
            shownShape[q] = !shownNum[q] || y < 0.3;
          case 2:
            shownNum[q] = x >= 0.28;
            shownShape[q] = !shownNum[q] || y < 0.15;
          default:
            final any = x < 0.12;
            shownNum[q] = x >= 0.42;
            shownShape[q] = !any && (!shownNum[q] || y < 0.08);
        }
      }

      // 3. ...then add it back, aimed at whatever breaks uniqueness. Full
      //    information is unique, so some differing clue always has a hidden
      //    fact that rules the other solution out.
      for (var step = 0; step < rects.length * 2 + 2; step++) {
        p = build();
        final sols = p._solve(2, _budget);
        if (sols != null && sols.length == 1) return p;
        if (sols == null) {
          final hidden = [
            for (var q = 0; q < rects.length; q++)
              if (!shownNum[q] || !shownShape[q]) q,
          ];
          if (hidden.isEmpty) break;
          final q = hidden[rnd.nextInt(hidden.length)];
          if (!shownNum[q]) {
            shownNum[q] = true;
          } else {
            shownShape[q] = true;
          }
          continue;
        }
        final alt = sols.firstWhere((s) => !_sameLayout(s, rects));
        final fixes = <(int, bool)>[]; // (clue, revealNumber)
        for (var q = 0; q < rects.length; q++) {
          if (alt[q] == rects[q]) continue;
          if (!shownNum[q] && alt[q].area != rects[q].area) {
            fixes.add((q, true));
          }
          if (!shownShape[q] && alt[q].shape != rects[q].shape) {
            fixes.add((q, false));
          }
        }
        if (fixes.isEmpty) break;
        // Harder tiers prefer revealing shapes (keeps numbers scarce).
        final shapeFixes = fixes.where((f) => !f.$2).toList();
        final pool = d >= 2 && shapeFixes.isNotEmpty && rnd.nextDouble() < 0.6
            ? shapeFixes
            : fixes;
        final (q, number) = pool[rnd.nextInt(pool.length)];
        if (number) {
          shownNum[q] = true;
        } else {
          shownShape[q] = true;
        }
      }
      p = build();
      if (p._solve(2, _budget)?.length == 1) return p;
      // Fall back to all numbers + shapes (unique by step 1).
      shownNum.fillRange(0, shownNum.length, true);
      shownShape.fillRange(0, shownShape.length, true);
      return build();
    }
    return fallback!;
  }

  static bool _sameLayout(List<PatchRect> a, List<PatchRect> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Random tiling of the grid with rectangles of mixed sizes (few 1×1).
  static List<PatchRect> _partition(int n, int d, Random rnd) {
    final maxArea = const [6, 8, 9, 10][d];
    final maxSingles = n >= 7 ? 2 : 1;
    late List<PatchRect> rects;
    for (var tries = 0; tries < 60; tries++) {
      final used = List<bool>.filled(n * n, false);
      rects = <PatchRect>[];
      var singles = 0;
      for (var cell = 0; cell < n * n; cell++) {
        if (used[cell]) continue;
        final r = cell ~/ n, c = cell % n;
        var maxW = 0;
        while (c + maxW < n && !used[r * n + c + maxW]) {
          maxW++;
        }
        final options = <PatchRect>[];
        final weights = <double>[];
        var total = 0.0;
        for (var w = 1; w <= maxW; w++) {
          for (var h = 1; r + h <= n; h++) {
            var blocked = false;
            for (var x = c; x < c + w; x++) {
              if (used[(r + h - 1) * n + x]) blocked = true;
            }
            if (blocked) break;
            final a = w * h;
            if (a > maxArea) break;
            var wt = a == 1
                ? 0.03
                : a == 2
                ? 0.45
                : 1.0;
            if (w == h && a > 1) wt *= 1.4;
            if (min(w, h) == 1 && max(w, h) >= 4) wt *= 0.35;
            options.add(PatchRect(r, c, h, w));
            weights.add(wt);
            total += wt;
          }
        }
        var pickAt = rnd.nextDouble() * total;
        var chosen = options.last;
        for (var i = 0; i < options.length; i++) {
          pickAt -= weights[i];
          if (pickAt <= 0) {
            chosen = options[i];
            break;
          }
        }
        if (chosen.area == 1) singles++;
        rects.add(chosen);
        for (var y = chosen.top; y <= chosen.bottom; y++) {
          for (var x = chosen.left; x <= chosen.right; x++) {
            used[y * n + x] = true;
          }
        }
      }
      if (singles <= maxSingles) break;
    }
    return rects;
  }
}

// ------------------------------------------------------------------- widget

class PatchGame extends StatefulWidget {
  const PatchGame({super.key, required this.session});
  final GameSession session;

  @override
  State<PatchGame> createState() => _PatchGameState();
}

class _PatchGameState extends State<PatchGame> {
  late final PatchPuzzle _p = PatchPuzzle.generate(
    widget.session.difficulty,
    widget.session.level,
    widget.session.seed,
  );
  final List<PatchRect> _patches = [];
  (int, int)? _dragFrom;
  (int, int)? _dragTo;
  double _cell = 1;
  bool _over = false;

  static const _palette = [
    Color(0xFFFFCDD2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFFFF9C4),
    Color(0xFFE1BEE7),
    Color(0xFFFFE0B2),
    Color(0xFFB2EBF2),
    Color(0xFFDCEDC8),
    Color(0xFFF8BBD0),
    Color(0xFFD1C4E9),
    Color(0xFFFFECB3),
    Color(0xFFB2DFDB),
  ];

  @override
  void initState() {
    super.initState();
    widget.session.hint.addListener(_hint);
    if (widget.session.demo) {
      // Screenshot mode: about 60% of the patches already drawn.
      final order = List<int>.generate(_p.solution.length, (i) => i)
        ..shuffle(Random(widget.session.seed));
      final count = (_p.solution.length * 0.6).round();
      for (final q in order.take(count)) {
        _patches.add(_p.solution[q]);
      }
    }
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_hint);
    super.dispose();
  }

  void _hint() {
    if (_over) return;
    for (final rect in _p.solution) {
      if (!_patches.contains(rect)) {
        _commit(rect, fromHint: true);
        return;
      }
    }
  }

  void _commit(PatchRect rect, {bool fromHint = false}) {
    if (_over) return;
    setState(() {
      _patches.removeWhere((p) => p.overlaps(rect));
      _patches.add(rect);
    });
    if (!fromHint && _p.clueIn(rect) == null) widget.session.addMistake();
    _checkWin();
  }

  void _checkWin() {
    if (_over) return;
    var covered = 0;
    for (final p in _patches) {
      if (_p.clueIn(p) == null) return;
      covered += p.area;
    }
    if (covered != _p.size * _p.size) return;
    _over = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) widget.session.onWin();
    });
  }

  (int, int) _cellAt(Offset pos) {
    final n = _p.size;
    return (
      (pos.dy / _cell).floor().clamp(0, n - 1),
      (pos.dx / _cell).floor().clamp(0, n - 1),
    );
  }

  PatchRect? _patchAt(int r, int c) {
    for (final p in _patches) {
      if (p.contains(r, c)) return p;
    }
    return null;
  }

  void _tapAt(int r, int c) {
    if (_over) return;
    final hit = _patchAt(r, c);
    if (hit != null) {
      setState(() => _patches.remove(hit));
    } else if (_p.clueAt(r, c) != null) {
      _commit(PatchRect(r, c, 1, 1));
    }
  }

  void _endDrag() {
    final from = _dragFrom, to = _dragTo;
    setState(() => _dragFrom = _dragTo = null);
    if (from == null || to == null || _over) return;
    if (from == to) {
      // A drag that never left its cell: only makes a 1×1 on a free clue.
      if (_patchAt(from.$1, from.$2) == null &&
          _p.clueAt(from.$1, from.$2) != null) {
        _commit(PatchRect(from.$1, from.$2, 1, 1));
      }
      return;
    }
    _commit(PatchRect.span(from.$1, from.$2, to.$1, to.$2));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = _p.size * _p.size;
    final covered = _patches.fold<int>(0, (a, p) => a + p.area);
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: covered / total,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$covered / $total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, box) {
                    _cell = box.maxWidth / _p.size;
                    return _board(scheme);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _board(ColorScheme scheme) {
    final n = _p.size;
    final preview = _dragFrom != null && _dragTo != null
        ? PatchRect.span(_dragFrom!.$1, _dragFrom!.$2, _dragTo!.$1, _dragTo!.$2)
        : null;
    final previewHidden = preview == null || preview.area == 1;
    return GestureDetector(
      key: const ValueKey('patch-board'),
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onTapUp: (d) {
        final (r, c) = _cellAt(d.localPosition);
        _tapAt(r, c);
      },
      onPanStart: (d) {
        if (_over) return;
        final cell = _cellAt(d.localPosition);
        setState(() => _dragFrom = _dragTo = cell);
      },
      onPanUpdate: (d) {
        if (_dragFrom == null) return;
        final cell = _cellAt(d.localPosition);
        if (cell != _dragTo) setState(() => _dragTo = cell);
      },
      onPanEnd: (_) => _endDrag(),
      onPanCancel: () => setState(() => _dragFrom = _dragTo = null),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outline, width: 2),
              ),
              child: CustomPaint(
                painter: _GridPainter(n, scheme.outlineVariant),
              ),
            ),
          ),
          for (final p in _patches) _patch(p, scheme),
          if (!previewHidden) _rectBox(preview, _previewDecoration(scheme)),
          for (var q = 0; q < _p.clues.length; q++) _clue(q, scheme),
          if (!previewHidden) _areaLabel(preview, scheme),
        ],
      ),
    );
  }

  Widget _rectBox(PatchRect rect, Decoration decoration, {Widget? child}) {
    final cs = _cell;
    final inset = max(1.5, cs * 0.05);
    return Positioned(
      left: rect.left * cs + inset,
      top: rect.top * cs + inset,
      width: rect.width * cs - inset * 2,
      height: rect.height * cs - inset * 2,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }

  Decoration _previewDecoration(ColorScheme scheme) => BoxDecoration(
    color: scheme.primary.withValues(alpha: 0.16),
    borderRadius: BorderRadius.circular(_cell * 0.18),
    border: Border.all(color: scheme.primary, width: 2.5),
  );

  Widget _patch(PatchRect rect, ColorScheme scheme) {
    final q = _p.clueIn(rect);
    final radius = BorderRadius.circular(_cell * 0.18);
    if (q == null) {
      return _rectBox(
        rect,
        BoxDecoration(
          color: Color.alphaBlend(
            scheme.error.withValues(alpha: 0.12),
            const Color(0xFFECEFF1),
          ),
          borderRadius: radius,
          border: Border.all(color: scheme.error, width: 3),
        ),
      );
    }
    final fill = _palette[q % _palette.length];
    final edge = HSLColor.fromColor(fill);
    return _rectBox(
      rect,
      BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: edge
              .withSaturation((edge.saturation * 0.8).clamp(0, 1))
              .withLightness(0.45)
              .toColor(),
          width: 2,
        ),
      ),
    );
  }

  Widget _clue(int q, ColorScheme scheme) {
    final clue = _p.clues[q];
    final cs = _cell;
    final onPatch = _patchAt(clue.row, clue.col) != null;
    final ink = onPatch ? Colors.black87 : scheme.onSurface;
    final chip = onPatch
        ? Colors.white.withValues(alpha: 0.7)
        : scheme.surface.withValues(alpha: 0.9);
    Widget body;
    if (clue.area != null) {
      body = Stack(
        children: [
          Center(
            child: Text(
              '${clue.area}',
              style: TextStyle(
                fontSize: cs * 0.42,
                fontWeight: FontWeight.w700,
                color: ink,
                height: 1,
              ),
            ),
          ),
          if (clue.shape != null)
            Positioned(
              right: cs * 0.06,
              top: cs * 0.06,
              child: _ShapeBadge(clue.shape!, cs * 0.18, ink),
            ),
        ],
      );
    } else if (clue.shape != null) {
      body = Center(child: _ShapeBadge(clue.shape!, cs * 0.36, ink));
    } else {
      body = Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: cs * 0.38,
            fontWeight: FontWeight.w700,
            color: ink.withValues(alpha: 0.55),
            height: 1,
          ),
        ),
      );
    }
    final pad = cs * 0.12;
    return Positioned(
      left: clue.col * cs + pad,
      top: clue.row * cs + pad,
      width: cs - pad * 2,
      height: cs - pad * 2,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: chip,
            borderRadius: BorderRadius.circular(cs * 0.2),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 2),
            ],
          ),
          child: body,
        ),
      ),
    );
  }

  Widget _areaLabel(PatchRect rect, ColorScheme scheme) {
    final cs = _cell;
    final n = _p.size;
    // Float the label above the preview (below it when at the top edge).
    final above = rect.top > 0;
    final cx = (rect.left + rect.width / 2) * cs;
    const w = 96.0, h = 34.0;
    final left = (cx - w / 2).clamp(-8.0, n * cs - w + 8);
    final top = above ? rect.top * cs - h - 4 : (rect.bottom + 1) * cs + 4;
    final ok = _p.clueIn(rect) != null;
    return Positioned(
      left: left,
      top: top.clamp(-h, n * cs),
      width: w,
      height: h,
      child: IgnorePointer(
        child: Material(
          elevation: 3,
          color: ok ? scheme.primary : scheme.inverseSurface,
          borderRadius: BorderRadius.circular(h / 2),
          child: Center(
            child: Text(
              '${rect.width}×${rect.height} = ${rect.area}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: ok ? scheme.onPrimary : scheme.onInverseSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square, wide bar or tall bar drawn as a small rounded block.
class _ShapeBadge extends StatelessWidget {
  const _ShapeBadge(this.shape, this.size, this.color);
  final PatchShape shape;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final (w, h) = switch (shape) {
      PatchShape.square => (size, size),
      PatchShape.wide => (size * 1.5, size * 0.75),
      PatchShape.tall => (size * 0.75, size * 1.5),
    };
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: max(1.5, size * 0.14)),
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.n, this.color);
  final int n;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final step = size.width / n;
    for (var i = 1; i < n; i++) {
      canvas.drawLine(
        Offset(i * step, 0),
        Offset(i * step, size.height),
        paint,
      );
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.n != n || old.color != color;
}
