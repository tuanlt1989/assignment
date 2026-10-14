import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import 'session.dart';

/// 8x8 block puzzle (Block Blast style). Drag pieces in, clear full rows and
/// columns. Endless; the shell shows game over / revive.
const _n = 8;

const _shapes = <List<(int, int)>>[
  [(0, 0)],
  [(0, 0), (0, 1)],
  [(0, 0), (1, 0)],
  [(0, 0), (0, 1), (0, 2)],
  [(0, 0), (1, 0), (2, 0)],
  [(0, 0), (0, 1), (0, 2), (0, 3)],
  [(0, 0), (1, 0), (2, 0), (3, 0)],
  [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)],
  [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)],
  [(0, 0), (0, 1), (1, 0), (1, 1)],
  [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2), (2, 0), (2, 1), (2, 2)],
  [(0, 0), (1, 0), (1, 1)],
  [(0, 1), (1, 0), (1, 1)],
  [(0, 0), (0, 1), (1, 0)],
  [(0, 0), (0, 1), (1, 1)],
  [(0, 0), (1, 0), (2, 0), (2, 1)],
  [(0, 1), (1, 1), (2, 1), (2, 0)],
  [(0, 0), (0, 1), (0, 2), (1, 1)],
  [(0, 1), (1, 0), (1, 1), (1, 2)],
  [(0, 0), (0, 1), (1, 1), (1, 2)],
  [(0, 1), (0, 2), (1, 0), (1, 1)],
  [(0, 0), (1, 0), (2, 0), (0, 1), (0, 2)],
];

const _colors = [
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFFFDD835),
  Color(0xFF43A047),
  Color(0xFF00ACC1),
  Color(0xFF1E88E5),
  Color(0xFF8E24AA),
];

class _Piece {
  _Piece(this.cells, this.color);
  final List<(int, int)> cells;
  final int color;
  int get rows => cells.map((e) => e.$1).reduce(max) + 1;
  int get cols => cells.map((e) => e.$2).reduce(max) + 1;
}

class BlocksGame extends StatefulWidget {
  const BlocksGame({super.key, required this.session});
  final GameSession session;

  @override
  State<BlocksGame> createState() => _BlocksGameState();
}

class _BlocksGameState extends State<BlocksGame> {
  late final Random _rnd = Random(widget.session.seed);
  final List<int?> _board = List.filled(_n * _n, null);
  late List<_Piece?> _tray = _deal();
  final _boardKey = GlobalKey();
  double _cell = 30;
  int _score = 0;
  int _combo = 0;
  (int, int, int)? _preview; // tray index, row, col
  Set<int> _flash = {};
  bool _over = false;

  @override
  void initState() {
    super.initState();
    widget.session.revive.addListener(_revive);
    if (widget.session.demo) _prefill();
  }

  /// Screenshot mode: a believable mid-game board without full lines.
  void _prefill() {
    for (var i = 0; i < _board.length; i++) {
      final r = i ~/ _n, c = i % _n;
      if (r >= 3 && c != (r * 3) % _n && _rnd.nextDouble() < 0.6) {
        _board[i] = _rnd.nextInt(_colors.length);
      }
    }
    _score = 1260;
  }

  @override
  void dispose() {
    widget.session.revive.removeListener(_revive);
    super.dispose();
  }

  _Piece _random() => _Piece(
    _shapes[_rnd.nextInt(_shapes.length)],
    _rnd.nextInt(_colors.length),
  );

  /// Deals three pieces, retrying a few times so at least one fits.
  List<_Piece?> _deal() {
    for (var i = 0; i < 25; i++) {
      final hand = [_random(), _random(), _random()];
      if (hand.any(_fitsAnywhere)) return hand;
    }
    return [_random(), _random(), _random()];
  }

  bool _fits(_Piece p, int r, int c) {
    for (final (dr, dc) in p.cells) {
      final rr = r + dr, cc = c + dc;
      if (rr < 0 || rr >= _n || cc < 0 || cc >= _n) return false;
      if (_board[rr * _n + cc] != null) return false;
    }
    return true;
  }

  bool _fitsAnywhere(_Piece p) {
    for (var r = 0; r < _n; r++) {
      for (var c = 0; c < _n; c++) {
        if (_fits(p, r, c)) return true;
      }
    }
    return false;
  }

  (int, int)? _cellAt(Offset globalTopLeft) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(
      globalTopLeft + Offset(_cell / 2, _cell / 2),
    );
    return (local.dy ~/ _cell, local.dx ~/ _cell);
  }

  void _place(int tray, int r, int c) {
    final p = _tray[tray]!;
    setState(() {
      for (final (dr, dc) in p.cells) {
        _board[(r + dr) * _n + (c + dc)] = p.color;
      }
      _score += p.cells.length;
      _tray[tray] = null;
      _preview = null;

      final clear = <int>{};
      var lines = 0;
      for (var i = 0; i < _n; i++) {
        final row = [for (var j = 0; j < _n; j++) i * _n + j];
        final col = [for (var j = 0; j < _n; j++) j * _n + i];
        if (row.every((x) => _board[x] != null)) {
          clear.addAll(row);
          lines++;
        }
        if (col.every((x) => _board[x] != null)) {
          clear.addAll(col);
          lines++;
        }
      }
      if (lines > 0) {
        _combo++;
        _score += 10 * lines * lines + 5 * (_combo - 1);
        _flash = clear;
        for (final x in clear) {
          _board[x] = null;
        }
      } else {
        _combo = 0;
      }
      if (_tray.every((t) => t == null)) _tray = _deal();
    });
    widget.session.onScore?.call(_score);
    if (_flash.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _flash = {});
      });
    }
    if (!_tray.any((t) => t != null && _fitsAnywhere(t)) && !_over) {
      _over = true;
      Future.delayed(const Duration(milliseconds: 500), widget.session.onFail);
    }
  }

  /// Continue after game over: clear the two fullest rows and deal again.
  void _revive() {
    setState(() {
      final rows = List.generate(_n, (r) => r)
        ..sort((a, b) => _filled(b).compareTo(_filled(a)));
      for (final r in rows.take(2)) {
        for (var c = 0; c < _n; c++) {
          _board[r * _n + c] = null;
        }
      }
      _tray = _deal();
      _over = false;
    });
  }

  int _filled(int r) =>
      [for (var c = 0; c < _n; c++) _board[r * _n + c]].nonNulls.length;

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    return LayoutBuilder(
      builder: (context, box) {
        final boardSize = min(box.maxWidth - 32, box.maxHeight * 0.62);
        _cell = boardSize / _n;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(t.t('score'), '$_score'),
                  _stat(t.t('best'), '${max(_score, app.progress.bestScore)}'),
                ],
              ),
            ),
            DragTarget<int>(
              onMove: (d) {
                final cell = _cellAt(d.offset);
                final p = _tray[d.data];
                if (cell == null || p == null) return;
                final next = _fits(p, cell.$1, cell.$2)
                    ? (d.data, cell.$1, cell.$2)
                    : null;
                if (next != _preview) setState(() => _preview = next);
              },
              onLeave: (_) => setState(() => _preview = null),
              onAcceptWithDetails: (d) {
                final cell = _cellAt(d.offset);
                final p = _tray[d.data];
                if (cell != null && p != null && _fits(p, cell.$1, cell.$2)) {
                  _place(d.data, cell.$1, cell.$2);
                } else {
                  setState(() => _preview = null);
                }
              },
              builder: (context, _, _) => Container(
                key: _boardKey,
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _n,
                  ),
                  itemCount: _n * _n,
                  itemBuilder: (context, i) => _boardCell(i),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: _cell * 3.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [for (var i = 0; i < 3; i++) _trayPiece(i)],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _stat(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      Text(
        value,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      ),
    ],
  );

  Widget _boardCell(int i) {
    final r = i ~/ _n, c = i % _n;
    Color? color = _board[i] == null ? null : _colors[_board[i]!];
    final pv = _preview;
    if (pv != null && color == null) {
      final p = _tray[pv.$1]!;
      if (p.cells.any((e) => pv.$2 + e.$1 == r && pv.$3 + e.$2 == c)) {
        color = _colors[p.color].withValues(alpha: 0.45);
      }
    }
    if (_flash.contains(i)) color = Colors.white;
    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _pieceWidget(_Piece p, double cell) => SizedBox(
    width: p.cols * cell,
    height: p.rows * cell,
    child: Stack(
      children: [
        for (final (r, c) in p.cells)
          Positioned(
            left: c * cell,
            top: r * cell,
            width: cell,
            height: cell,
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: _colors[p.color],
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _trayPiece(int i) {
    final p = _tray[i];
    if (p == null) return SizedBox(width: _cell * 3);
    final small = _cell * 0.55;
    final fits = _fitsAnywhere(p);
    return Draggable<int>(
      data: i,
      dragAnchorStrategy: (draggable, context, position) =>
          Offset(p.cols * _cell / 2, p.rows * _cell + 40),
      feedback: _pieceWidget(p, _cell),
      childWhenDragging: SizedBox(width: _cell * 3),
      child: Opacity(
        opacity: fits ? 1 : 0.35,
        child: SizedBox(
          width: _cell * 3,
          child: Center(child: _pieceWidget(p, small)),
        ),
      ),
    );
  }
}
