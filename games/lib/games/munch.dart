import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'session.dart';

/// Pixel-art colour-sort puzzle (Pixel Flow / Food Hunt style).
///
/// Eaters of one colour wait in lines. Tap the front eater of a line to send
/// it to a slot; it then munches exposed pixels of its colour (pixels on the
/// edge or next to an eaten pixel). Lines are built by simulating a solution
/// with the same deterministic eating rule, so every level is solvable.
const _palette = {
  'R': Color(0xFFE53935),
  'O': Color(0xFFFB8C00),
  'Y': Color(0xFFFDD835),
  'G': Color(0xFF43A047),
  'B': Color(0xFF1E88E5),
  'P': Color(0xFF8E24AA),
  'M': Color(0xFFF06292),
  'N': Color(0xFF8D6E63),
  'K': Color(0xFF37474F),
  'W': Color(0xFFCFD8DC),
};

const _sprites = [
  // strawberry
  [
    '...GGG....',
    '..GGGGG...',
    '.RRRRRRR..',
    'RRYRRRYRR.',
    'RRRRRRRRR.',
    'RYRRRRRYR.',
    '.RRRYRRR..',
    '..RRRRR...',
    '...RRR....',
    '....R.....',
  ],
  // heart
  [
    '.RRR.RRR.',
    'RMMRRRRRR',
    'RMRRRRRRR',
    'RRRRRRRRR',
    '.RRRRRRR.',
    '..RRRRR..',
    '...RRR...',
    '....R....',
  ],
  // mushroom
  [
    '...RRRR...',
    '.RRWWRRRR.',
    'RRRWWRRWWR',
    'RWWRRRRWWR',
    'RRRRRRRRRR',
    '...WWWW...',
    '...WKWK...',
    '...WWWW...',
    '...WWWW...',
  ],
  // cat face
  [
    'O.......O.',
    'OO.....OO.',
    'OOOOOOOOO.',
    'OKKOOOKKO.',
    'OOOOOOOOO.',
    'OOOOMOOOO.',
    'OOOKKKOOO.',
    '.OOOOOOO..',
  ],
  // fish
  [
    '....BBB.....',
    '..BBBBBBB..Y',
    '.BKBBBBBBBYY',
    'BBBBBBBBBYYY',
    '.BBBBBBBBBYY',
    '..BBBBBBB..Y',
    '....BBB.....',
  ],
  // tree
  [
    '...GGGG...',
    '..GGGGGG..',
    '.GGGGGGGG.',
    'GGGGRGGGGG',
    'GGGGGGGRGG',
    '.GGGGGGGG.',
    '....NN....',
    '....NN....',
    '...NNNN...',
  ],
  // flower
  [
    '..MM.MM...',
    '.MMMMMMM..',
    '..MYYYM...',
    '.MMYYYMM..',
    '..MMMMM...',
    '....G.....',
    '..G.G.G...',
    '...GGG....',
    '....G.....',
  ],
  // watermelon
  [
    'GGGGGGGGGG',
    'WWWWWWWWWW',
    '.RRRRRRRR.',
    '.RRKRRKRR.',
    '..RRRRRR..',
    '...RKRR...',
    '....RR....',
  ],
  // house
  [
    '....RR....',
    '...RRRR...',
    '..RRRRRR..',
    '.RRRRRRRR.',
    'RRRRRRRRRR',
    '.OOOOOOOO.',
    '.OBBOONOO.',
    '.OBBOONOO.',
    '.OOOOONOO.',
  ],
  // rocket
  [
    '....RR....',
    '...RRRR...',
    '...WWWW...',
    '...WBBW...',
    '...WBBW...',
    '...WWWW...',
    '..RWWWWR..',
    '.RRWWWWRR.',
    '...OYYO...',
    '....OO....',
  ],
  // sun
  [
    'Y...Y...Y.',
    '.Y.OOO.Y..',
    '..OOOOO...',
    'YOOYOYOOY.',
    '..OOOOO...',
    '..OKOKO...',
    '..OOOOO...',
    '.Y.OOO.Y..',
    'Y...Y...Y.',
  ],
  // ghost
  [
    '...PPPP...',
    '..PPPPPP..',
    '.PPWPPWPP.',
    '.PPKPPKPP.',
    '.PPPPPPPP.',
    '.PPPMMPPP.',
    '.PPPPPPPP.',
    '.P.PP.PP.P',
  ],
];

class MunchEater {
  MunchEater(this.color, this.left);
  final String color;
  int left;
}

class MunchLevel {
  MunchLevel(this.w, this.h, this.cells, this.lanes, this.slots);
  final int w, h;
  final List<String?> cells;
  final List<List<MunchEater>> lanes;
  final int slots;
}

bool _exposed(List<String?> cells, int w, int h, int i) {
  final r = i ~/ w, c = i % w;
  if (r == 0 || c == 0 || r == h - 1 || c == w - 1) return true;
  return cells[i - 1] == null ||
      cells[i + 1] == null ||
      cells[i - w] == null ||
      cells[i + w] == null;
}

/// Bottom-most, then left-most exposed pixel of [color]. Used by both the
/// generator and the game, so the simulated solution replays exactly.
int? munchNextBite(List<String?> cells, int w, int h, String color) {
  for (var r = h - 1; r >= 0; r--) {
    for (var c = 0; c < w; c++) {
      final i = r * w + c;
      if (cells[i] == color && _exposed(cells, w, h, i)) return i;
    }
  }
  return null;
}

MunchLevel munchLevel(int level, int seed) {
  final rnd = Random(seed);
  final sprite = _sprites[(level - 1) % _sprites.length];
  final scale = level > 24 ? 2 : 1;
  final h = sprite.length * scale;
  final w = sprite.map((s) => s.length).reduce(max) * scale;
  final cells = List<String?>.filled(w * h, null);
  for (var r = 0; r < h; r++) {
    final row = sprite[r ~/ scale];
    for (var c = 0; c < w; c++) {
      final ch = c ~/ scale < row.length ? row[c ~/ scale] : '.';
      if (ch != '.') cells[r * w + c] = ch;
    }
  }

  // Simulate a solution to build the eater sequence.
  final sim = List<String?>.of(cells);
  final seq = <MunchEater>[];
  final caps = [3, 4, 5, 6, 8];
  while (sim.any((x) => x != null)) {
    final colors = <String>{};
    for (var i = 0; i < sim.length; i++) {
      if (sim[i] != null && _exposed(sim, w, h, i)) colors.add(sim[i]!);
    }
    final color = colors.elementAt(rnd.nextInt(colors.length));
    final cap = caps[rnd.nextInt(min(caps.length, 2 + level ~/ 6))] * scale;
    var eaten = 0;
    while (eaten < cap) {
      final bite = munchNextBite(sim, w, h, color);
      if (bite == null) break;
      sim[bite] = null;
      eaten++;
    }
    seq.add(MunchEater(color, eaten));
  }
  final lanes = [<MunchEater>[], <MunchEater>[], <MunchEater>[]];
  for (var i = 0; i < seq.length; i++) {
    lanes[i % 3].add(seq[i]);
  }
  return MunchLevel(w, h, cells, lanes, level < 8 ? 5 : 4);
}

class MunchGame extends StatefulWidget {
  const MunchGame({super.key, required this.session});
  final GameSession session;

  @override
  State<MunchGame> createState() => _MunchGameState();
}

class _MunchGameState extends State<MunchGame> {
  late final MunchLevel _lv = munchLevel(
    widget.session.level,
    widget.session.seed,
  );
  late final List<MunchEater?> _slots = List.filled(_lv.slots, null);
  Timer? _timer;
  bool _over = false;
  int? _hintLane;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 110), (_) => _tick());
    widget.session.hint.addListener(_hint);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.session.hint.removeListener(_hint);
    super.dispose();
  }

  /// Highlights the lane whose front eater can eat right now.
  void _hint() {
    for (var i = 0; i < 3; i++) {
      final lane = _lv.lanes[i];
      if (lane.isNotEmpty &&
          munchNextBite(_lv.cells, _lv.w, _lv.h, lane.first.color) != null) {
        setState(() => _hintLane = i);
        return;
      }
    }
  }

  void _send(int lane) {
    if (_over || _lv.lanes[lane].isEmpty) return;
    final free = _slots.indexOf(null);
    if (free < 0) return;
    setState(() {
      _slots[free] = _lv.lanes[lane].removeAt(0);
      if (_hintLane == lane) _hintLane = null;
    });
  }

  void _tick() {
    if (_over) return;
    var changed = false;
    for (var s = 0; s < _slots.length; s++) {
      final e = _slots[s];
      if (e == null) continue;
      final bite = munchNextBite(_lv.cells, _lv.w, _lv.h, e.color);
      if (bite == null) continue;
      _lv.cells[bite] = null;
      e.left--;
      if (e.left <= 0) _slots[s] = null;
      changed = true;
    }
    if (changed) setState(() {});
    if (_lv.cells.every((x) => x == null)) {
      _over = true;
      widget.session.onWin();
      return;
    }
    if (!changed) {
      final full = !_slots.contains(null);
      final lanesEmpty = _lv.lanes.every((l) => l.isEmpty);
      if (full || lanesEmpty) {
        _over = true;
        widget.session.onFail();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: _lv.w / _lv.h,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _lv.w,
                  ),
                  itemCount: _lv.w * _lv.h,
                  itemBuilder: (context, i) {
                    final c = _lv.cells[i];
                    return Container(
                      margin: const EdgeInsets.all(0.8),
                      decoration: BoxDecoration(
                        color: c == null
                            ? Colors.black.withValues(alpha: 0.04)
                            : _palette[c],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final e in _slots)
                Container(
                  margin: const EdgeInsets.all(4),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: e == null ? null : _eater(e, 44),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _send(i),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _hintLane == i
                              ? Colors.amber.shade600
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (final (k, e) in _lv.lanes[i].take(4).indexed)
                            Padding(
                              padding: const EdgeInsets.all(3),
                              child: Opacity(
                                opacity: k == 0 ? 1 : 0.55,
                                child: _eater(e, k == 0 ? 50 : 38),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eater(MunchEater e, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _palette[e.color],
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    alignment: Alignment.center,
    child: Text(
      '${e.left}',
      style: TextStyle(
        color: e.color == 'Y' || e.color == 'W' ? Colors.black87 : Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: size * 0.38,
      ),
    ),
  );
}
