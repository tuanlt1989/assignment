import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'session.dart';

/// "Putt Puzzle": top-down mini-golf puzzle. Drag back from the ball like a
/// slingshot, release to putt, sink the ball in as few strokes as possible.
///
/// Everything happens in a fixed logical course of [kPuttW] × [kPuttH] units.
/// The physics is a deterministic fixed-step simulation ([PuttSim.step]); the
/// very same step function drives the on-screen animation, the par solver,
/// the hints and the tests.
const double kPuttW = 100;
const double kPuttH = 160;
const double kBallR = 2.2;
const double kCupR = 3.4;
const double kPuttDt = 1 / 120;
const int kPuttMaxSteps = 1000;
const double kPuttMaxSpeed = 150;

/// Drag length (course units) that gives full power.
const double kPuttDragMax = 38;

const double _wallT = 1.3; // half thickness of line walls
const double _edgeT = 0.8; // half thickness of block / void outlines
const double _borderT = 2.0;
const double _captureSpeed = 50;
const double _stopSpeed = 2.5;
const double _slopeForce = 48;
const double _magnetR = 13;
const double _magnetF = 80;

enum PuttSurface { grass, sand, water, ice, slope }

/// A surface patch (rectangle or circle). Slopes push with ([fx], [fy]).
class PuttZone {
  const PuttZone(
    this.kind,
    this.rect, {
    this.circle = false,
    this.fx = 0,
    this.fy = 0,
  });
  final PuttSurface kind;
  final Rect rect;
  final bool circle;
  final double fx, fy;

  bool contains(double x, double y) {
    if (!circle) return rect.contains(Offset(x, y));
    final c = rect.center, r = rect.width / 2;
    final dx = x - c.dx, dy = y - c.dy;
    return dx * dx + dy * dy <= r * r;
  }

  PuttZone mirrored() => PuttZone(
    kind,
    Rect.fromLTRB(
      kPuttW - rect.right,
      rect.top,
      kPuttW - rect.left,
      rect.bottom,
    ),
    circle: circle,
    fx: -fx,
    fy: fy,
  );
}

/// A line wall (a capsule of half thickness [thick]).
class PuttWall {
  const PuttWall(this.a, this.b, {this.thick = _wallT, this.bumper = false});
  final Offset a, b;
  final double thick;
  final bool bumper;

  double get bounce => bumper ? 1.0 : 0.8;

  PuttWall mirrored() => PuttWall(
    Offset(kPuttW - a.dx, a.dy),
    Offset(kPuttW - b.dx, b.dy),
    thick: thick,
    bumper: bumper,
  );
}

/// One putt: direction in radians (0 = right, π/2 = down) and power 0..1.
class PuttShot {
  const PuttShot(this.angle, this.power);
  final double angle, power;

  @override
  String toString() =>
      'PuttShot(${(angle * 180 / pi).toStringAsFixed(1)}°, '
      '${power.toStringAsFixed(2)})';
}

enum PuttState { rolling, stopped, sunk, water }

/// Mutable ball state advanced by [PuttSim.step].
class PuttBall {
  PuttBall(this.x, this.y, this.vx, this.vy);
  double x, y, vx, vy;
  int steps = 0;
  PuttState state = PuttState.rolling;

  double get speed => sqrt(vx * vx + vy * vy);
}

/// Result of a solver search: shots and the ball position before each one.
class PuttPlan {
  PuttPlan(this.shots, this.starts, this.sunk);
  final List<PuttShot> shots;
  final List<Offset> starts;
  final bool sunk;
}

class PuttHole {
  PuttHole({
    required this.difficulty,
    required this.layout,
    required this.tee,
    required this.cup,
    required this.voids,
    required this.blocks,
    required this.walls,
    required this.zones,
    this.magnet,
  });

  final int difficulty;

  /// Template name (straight, L, U, zigzag, island, tiers, dogleg).
  final String layout;
  final Offset tee, cup;

  /// Out-of-course areas (drawn as hedge, edged by walls).
  final List<List<Offset>> voids;

  /// Solid obstacles.
  final List<List<Offset>> blocks;

  /// Line walls: course border, dividers, short walls, bumpers.
  final List<PuttWall> walls;
  final List<PuttZone> zones;
  final Offset? magnet;

  late final PuttSim sim = PuttSim(this);

  int par = 2;

  /// The solver's shots from the tee ([par] - 1 of them).
  List<PuttShot> solution = const [];

  /// Ball position before each solution shot (first = tee).
  List<Offset> solutionStarts = const [];

  static const layouts = [
    'straight',
    'L',
    'tiers',
    'dogleg',
    'zigzag',
    'U',
    'island',
  ];

  /// Deterministic hole for (difficulty, level, seed), with par computed by
  /// a beam search over discretised shots.
  static PuttHole generate(int difficulty, int level, int seed) {
    final rnd = Random(seed);
    final d = difficulty.clamp(0, 3);
    PuttHole? fallback;
    for (var attempt = 0; attempt < 10; attempt++) {
      final h = _build(d, level, rnd);
      if (h == null) continue;
      final plan = h.sim.search(h.tee.dx, h.tee.dy, maxDepth: 4, beam: 8);
      if (!plan.sunk) continue;
      h._setPlan(plan);
      // No trivial hole-in-one layouts on expert (nor on hard after 5).
      if ((d == 3 || (d == 2 && level > 5)) && plan.shots.length < 2) {
        fallback ??= h;
        continue;
      }
      return h;
    }
    if (fallback != null) return fallback;
    final h = _plain(d);
    h._setPlan(h.sim.search(h.tee.dx, h.tee.dy, maxDepth: 4, beam: 8));
    return h;
  }

  void _setPlan(PuttPlan plan) {
    solution = plan.shots;
    solutionStarts = plan.starts;
    par = max(2, plan.shots.length + 1);
  }

  static PuttHole _plain(int d) => PuttHole(
    difficulty: d,
    layout: 'straight',
    tee: const Offset(50, 145),
    cup: const Offset(50, 22),
    voids: const [],
    blocks: const [],
    walls: _border(),
    zones: const [],
  );

  static List<PuttWall> _border() => const [
    PuttWall(Offset(0, 0), Offset(kPuttW, 0), thick: _borderT),
    PuttWall(Offset(kPuttW, 0), Offset(kPuttW, kPuttH), thick: _borderT),
    PuttWall(Offset(kPuttW, kPuttH), Offset(0, kPuttH), thick: _borderT),
    PuttWall(Offset(0, kPuttH), Offset(0, 0), thick: _borderT),
  ];

  static List<Offset> _rect(double l, double t, double r, double b) => [
    Offset(l, t),
    Offset(r, t),
    Offset(r, b),
    Offset(l, b),
  ];

  /// Builds a layout template plus random obstacles; null if the cup cannot
  /// be reached at all.
  static PuttHole? _build(int d, int level, Random rnd) {
    double r(double a, double b) => a + rnd.nextDouble() * (b - a);
    final pool = [
      'straight',
      'L',
      'tiers',
      'dogleg',
      if (level > 4 || d > 0) 'zigzag',
      if (level > 8 || d > 0) 'U',
      if (d > 0 || level > 12) 'island',
    ];
    final layout = pool[rnd.nextInt(pool.length)];
    final voids = <List<Offset>>[];
    final walls = <PuttWall>[];
    final zones = <PuttZone>[];
    // Areas obstacles must keep away from (template features).
    final reserved = <(Offset, double)>[];
    var tee = const Offset(50, 145);
    var cup = const Offset(50, 20);
    final gapW = switch (d) {
      0 => r(16, 22),
      1 => r(13, 17),
      _ => r(9.5, 11.5),
    };
    switch (layout) {
      case 'straight':
        final a = r(0, 16);
        if (a > 5) {
          voids.add(_rect(-5, -5, a, kPuttH + 5));
          voids.add(_rect(kPuttW - a, -5, kPuttW + 5, kPuttH + 5));
        }
        tee = Offset(50 + r(-12, 12), 146);
        cup = Offset(50 + r(-26 + a, 26 - a), r(16, 28));
      case 'L':
        final w = r(40, 52), top = r(48, 62);
        voids.add(_rect(w, top, kPuttW + 5, kPuttH + 5));
        tee = Offset(w / 2, 146);
        cup = Offset((w + kPuttW) / 2 + r(-10, 10), top / 2 + r(-5, 5));
      case 'U':
        final half = r(9, 15), top = r(45, 65);
        voids.add(_rect(50 - half, top, 50 + half, kPuttH + 5));
        tee = Offset(25 + r(-6, 6), 146);
        cup = Offset(75 + r(-6, 6), r(115, 142));
      case 'zigzag':
        final g = r(36, 46), y1 = r(96, 106), y2 = r(46, 56);
        voids.add(_rect(g, y1, kPuttW + 5, y1 + 9));
        voids.add(_rect(-5, y2, kPuttW - g, y2 + 9));
        tee = Offset(r(62, 80), 146);
        cup = Offset(r(18, 34), r(16, 26));
      case 'tiers':
        final y = r(68, 98);
        final gx = r(8, 92 - gapW);
        walls.add(PuttWall(Offset(0, y), Offset(gx, y)));
        walls.add(PuttWall(Offset(gx + gapW, y), Offset(kPuttW, y)));
        reserved.add((Offset(gx + gapW / 2, y), 9));
        if (d >= 2 && rnd.nextBool()) {
          final y2 = y > 83 ? y - 38 : y + 38;
          final gx2 = (gx + 50 + r(-10, 10)) % (92 - gapW) + 8;
          walls.add(PuttWall(Offset(0, y2), Offset(gx2, y2)));
          walls.add(PuttWall(Offset(gx2 + gapW, y2), Offset(kPuttW, y2)));
          reserved.add((Offset(gx2 + gapW / 2, y2), 9));
        }
        tee = Offset(r(20, 80), 146);
        cup = Offset(r(20, 80), r(16, 26));
      case 'dogleg':
        final a = r(45, 60), b = r(60, 80);
        voids.add([const Offset(-5, -5), Offset(a, -5), Offset(-5, b)]);
        final a2 = r(45, 60), b2 = r(60, 80);
        voids.add([
          const Offset(kPuttW + 5, kPuttH + 5),
          Offset(kPuttW - a2, kPuttH + 5),
          Offset(kPuttW + 5, kPuttH - b2),
        ]);
        tee = Offset(r(18, 28), 146);
        cup = Offset(r(72, 82), r(16, 24));
      case 'island':
        cup = Offset(50 + r(-14, 14), r(36, 48));
        final s = r(13, 16);
        final side = rnd.nextInt(4); // opening / bridge side
        if (d < 2) {
          final o = d == 0 ? 7.0 : 6.0; // half opening
          final c = cup;
          final corners = [
            Offset(c.dx - s, c.dy - s),
            Offset(c.dx + s, c.dy - s),
            Offset(c.dx + s, c.dy + s),
            Offset(c.dx - s, c.dy + s),
          ];
          for (var i = 0; i < 4; i++) {
            final p = corners[i], q = corners[(i + 1) % 4];
            if (i == side) {
              final m = Offset((p.dx + q.dx) / 2, (p.dy + q.dy) / 2);
              final dir = (q - p) / (q - p).distance;
              walls.add(PuttWall(p, m - dir * o));
              walls.add(PuttWall(m + dir * o, q));
            } else {
              walls.add(PuttWall(p, q));
            }
          }
        } else {
          final c = cup;
          const t = 7.0;
          final rects = [
            Rect.fromLTRB(c.dx - s - t, c.dy - s - t, c.dx + s + t, c.dy - s),
            Rect.fromLTRB(c.dx + s, c.dy - s - t, c.dx + s + t, c.dy + s + t),
            Rect.fromLTRB(c.dx - s - t, c.dy + s, c.dx + s + t, c.dy + s + t),
            Rect.fromLTRB(c.dx - s - t, c.dy - s - t, c.dx - s, c.dy + s + t),
          ];
          final bw = gapW / 2 + 1;
          for (var i = 0; i < 4; i++) {
            final rc = rects[i];
            if (i != side) {
              zones.add(PuttZone(PuttSurface.water, rc));
            } else if (i.isEven) {
              zones.add(
                PuttZone(
                  PuttSurface.water,
                  Rect.fromLTRB(rc.left, rc.top, c.dx - bw, rc.bottom),
                ),
              );
              zones.add(
                PuttZone(
                  PuttSurface.water,
                  Rect.fromLTRB(c.dx + bw, rc.top, rc.right, rc.bottom),
                ),
              );
            } else {
              zones.add(
                PuttZone(
                  PuttSurface.water,
                  Rect.fromLTRB(rc.left, rc.top, rc.right, c.dy - bw),
                ),
              );
              zones.add(
                PuttZone(
                  PuttSurface.water,
                  Rect.fromLTRB(rc.left, c.dy + bw, rc.right, rc.bottom),
                ),
              );
            }
          }
        }
        reserved.add((cup, s + 10));
        tee = Offset(50 + r(-25, 25), 146);
    }

    // Random obstacles, featured surfaces first.
    final kinds = <String>[
      if (d == 1) rnd.nextBool() ? 'sand' : 'bumper',
      if (d == 2) 'water',
      if (d == 3) 'slope',
      if (d == 3) 'ice',
    ];
    final count = (d + 1 + level ~/ 6).clamp(1, 6);
    final general = [
      'block',
      'diamond',
      'tri',
      'wall',
      if (d >= 1) ...['sand', 'bumper'],
      if (d >= 2) ...['water', 'block'],
      if (d >= 3) ...['ice', 'slope'],
    ];
    while (kinds.length < count) {
      kinds.add(general[rnd.nextInt(general.length)]);
    }
    final obs = <_Ob>[];
    final placed = <(Offset, double)>[...reserved];
    for (final kind in kinds) {
      final o = _obstacle(kind, rnd, voids, walls, placed, tee, cup);
      if (o != null) obs.add(o);
    }
    Offset? magnet;
    if (d == 3 && rnd.nextDouble() < 0.45) {
      for (var t = 0; t < 12; t++) {
        final a = rnd.nextDouble() * 2 * pi;
        final dist = r(12, 16);
        final m = cup + Offset(cos(a), sin(a)) * dist;
        if (m.dx < 8 || m.dx > kPuttW - 8 || m.dy < 8 || m.dy > kPuttH - 8) {
          continue;
        }
        if (_inAny(voids, m)) continue;
        magnet = m;
        break;
      }
    }

    // Mirror half of the holes so templates do not always bend one way.
    final flip = rnd.nextBool();
    Offset fx(Offset p) => flip ? Offset(kPuttW - p.dx, p.dy) : p;
    List<Offset> fp(List<Offset> poly) => [for (final p in poly) fx(p)];

    PuttHole make(List<_Ob> obs) => PuttHole(
      difficulty: d,
      layout: layout,
      tee: fx(tee),
      cup: fx(cup),
      voids: [for (final v in voids) fp(v)],
      blocks: [
        for (final o in obs)
          if (o.block != null) fp(o.block!),
      ],
      walls: [
        ..._border(),
        for (final w in walls) flip ? w.mirrored() : w,
        for (final o in obs)
          if (o.wall != null) flip ? o.wall!.mirrored() : o.wall!,
      ],
      zones: [
        for (final z in zones) flip ? z.mirrored() : z,
        for (final o in obs)
          if (o.zone != null) flip ? o.zone!.mirrored() : o.zone!,
      ],
      magnet: magnet == null ? null : fx(magnet),
    );

    // Drop obstacles (last first) until the cup is reachable from the tee.
    while (true) {
      final h = make(obs);
      if (h.sim.distanceAt(h.tee.dx, h.tee.dy) < _unreachable) return h;
      if (obs.isEmpty) return null;
      obs.removeLast();
    }
  }

  static bool _nearTemplate(
    Offset c,
    double clear,
    List<List<Offset>> voids,
    List<PuttWall> walls,
  ) {
    for (final w in walls) {
      if (_segDist(c, w.a, w.b) < clear + w.thick) return true;
    }
    for (final v in voids) {
      for (var i = 0; i < v.length; i++) {
        if (_segDist(c, v[i], v[(i + 1) % v.length]) < clear) return true;
      }
    }
    return false;
  }

  static double _segDist(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final l2 = ab.distanceSquared;
    final t = l2 == 0
        ? 0.0
        : (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / l2).clamp(
            0.0,
            1.0,
          );
    return (p - (a + ab * t)).distance;
  }

  static bool _inAny(List<List<Offset>> polys, Offset p) {
    for (final poly in polys) {
      if (_pointInPoly(poly, p.dx, p.dy)) return true;
    }
    return false;
  }

  static _Ob? _obstacle(
    String kind,
    Random rnd,
    List<List<Offset>> voids,
    List<PuttWall> walls,
    List<(Offset, double)> placed,
    Offset tee,
    Offset cup,
  ) {
    double r(double a, double b) => a + rnd.nextDouble() * (b - a);
    for (var t = 0; t < 30; t++) {
      final c = Offset(r(10, kPuttW - 10), r(30, 132));
      if (_inAny(voids, c)) continue;
      late final _Ob ob;
      late final double rad;
      var solid = true;
      var cupClear = 9.0;
      switch (kind) {
        case 'block':
          final w = r(5, 14) / 2, h = r(5, 14) / 2;
          ob = _Ob(block: _rect(c.dx - w, c.dy - h, c.dx + w, c.dy + h));
          rad = sqrt(w * w + h * h);
        case 'diamond':
          final s = r(5, 9);
          ob = _Ob(
            block: [
              Offset(c.dx, c.dy - s),
              Offset(c.dx + s, c.dy),
              Offset(c.dx, c.dy + s),
              Offset(c.dx - s, c.dy),
            ],
          );
          rad = s;
        case 'tri':
          final s = r(8, 14);
          final q = rnd.nextInt(4);
          final sx = q.isEven ? 1.0 : -1.0, sy = q < 2 ? 1.0 : -1.0;
          final o = c - Offset(sx * s / 3, sy * s / 3);
          ob = _Ob(block: [o, o + Offset(sx * s, 0), o + Offset(0, sy * s)]);
          rad = s * 0.75;
        case 'wall':
          final l = r(14, 26) / 2;
          final v = rnd.nextBool();
          final dv = v ? Offset(0, l) : Offset(l, 0);
          ob = _Ob(wall: PuttWall(c - dv, c + dv));
          rad = l + 1;
        case 'bumper':
          final l = r(10, 16) / 2 / sqrt2;
          final dv = rnd.nextBool() ? Offset(l, l) : Offset(l, -l);
          ob = _Ob(wall: PuttWall(c - dv, c + dv, bumper: true));
          rad = l * sqrt2 + 1;
        case 'sand':
          solid = false;
          cupClear = 5;
          if (rnd.nextBool()) {
            final rr = r(7, 12);
            ob = _Ob(
              zone: PuttZone(
                PuttSurface.sand,
                Rect.fromCircle(center: c, radius: rr),
                circle: true,
              ),
            );
            rad = rr;
          } else {
            final w = r(14, 26) / 2, h = r(10, 18) / 2;
            ob = _Ob(
              zone: PuttZone(
                PuttSurface.sand,
                Rect.fromLTRB(c.dx - w, c.dy - h, c.dx + w, c.dy + h),
              ),
            );
            rad = sqrt(w * w + h * h);
          }
        case 'water':
          solid = false;
          cupClear = 7;
          if (rnd.nextBool()) {
            final rr = r(6, 10);
            ob = _Ob(
              zone: PuttZone(
                PuttSurface.water,
                Rect.fromCircle(center: c, radius: rr),
                circle: true,
              ),
            );
            rad = rr;
          } else {
            final w = r(12, 24) / 2, h = r(8, 16) / 2;
            ob = _Ob(
              zone: PuttZone(
                PuttSurface.water,
                Rect.fromLTRB(c.dx - w, c.dy - h, c.dx + w, c.dy + h),
              ),
            );
            rad = sqrt(w * w + h * h);
          }
        case 'ice':
          solid = false;
          cupClear = 6;
          final w = r(22, 36) / 2, h = r(16, 28) / 2;
          ob = _Ob(
            zone: PuttZone(
              PuttSurface.ice,
              Rect.fromLTRB(c.dx - w, c.dy - h, c.dx + w, c.dy + h),
            ),
          );
          rad = sqrt(w * w + h * h) * 0.8;
        case 'slope':
          solid = false;
          cupClear = 6;
          final w = r(20, 34) / 2, h = r(14, 22) / 2;
          final dir = rnd.nextInt(4);
          const dirs = [(1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)];
          ob = _Ob(
            zone: PuttZone(
              PuttSurface.slope,
              Rect.fromLTRB(c.dx - w, c.dy - h, c.dx + w, c.dy + h),
              fx: dirs[dir].$1 * _slopeForce,
              fy: dirs[dir].$2 * _slopeForce,
            ),
          );
          rad = sqrt(w * w + h * h) * 0.8;
        default:
          return null;
      }
      if ((c - tee).distance < rad + (solid ? 10 : 8)) continue;
      if ((c - cup).distance < rad + cupClear) continue;
      // Zones must never cover the cup itself.
      if (ob.zone != null && ob.zone!.contains(cup.dx, cup.dy)) continue;
      if (ob.zone != null && ob.zone!.contains(tee.dx, tee.dy)) continue;
      if (placed.any((p) => (p.$1 - c).distance < p.$2 + rad + 2)) continue;
      // Solid obstacles keep clear of the template's walls and voids.
      if (solid && _nearTemplate(c, rad + 3, voids, walls)) continue;
      placed.add((c, rad));
      return ob;
    }
    return null;
  }
}

class _Ob {
  _Ob({this.block, this.wall, this.zone});
  final List<Offset>? block;
  final PuttWall? wall;
  final PuttZone? zone;
}

bool _pointInPoly(List<Offset> poly, double x, double y) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final a = poly[i], b = poly[j];
    if ((a.dy > y) != (b.dy > y) &&
        x < (b.dx - a.dx) * (y - a.dy) / (b.dy - a.dy) + a.dx) {
      inside = !inside;
    }
  }
  return inside;
}

const int _unreachable = 1 << 30;

/// Deterministic physics for one hole (pure Dart doubles, fixed time step).
class PuttSim {
  PuttSim(this.hole) {
    _buildSegments();
    _buildZones();
    _buildDistance();
  }

  final PuttHole hole;

  // Segment table: ax, ay, dx, dy, 1/len², reach, bounce, (pad).
  late final Float64List _seg;
  late final int _segCount;
  static const _cell = 8.0;
  static final int _gw = (kPuttW / _cell).ceil();
  static final int _gh = (kPuttH / _cell).ceil();
  late final Int32List _cellStart, _cellSegs;

  // Zone index per 1×1 unit cell (-1 = plain grass).
  late final Int8List _zoneGrid;
  late final List<PuttZone> _zones = hole.zones;

  // Geodesic distance (×2 per 2-unit cell) from the cup, for the solver.
  static const _dg = 2.0;
  static final int _dw = (kPuttW / _dg).ceil();
  static final int _dh = (kPuttH / _dg).ceil();
  late final Int32List _dist;

  void _buildSegments() {
    final list = <(Offset, Offset, double, double)>[];
    for (final w in hole.walls) {
      list.add((w.a, w.b, kBallR + w.thick, w.bounce));
    }
    for (final poly in [...hole.voids, ...hole.blocks]) {
      for (var i = 0; i < poly.length; i++) {
        list.add((poly[i], poly[(i + 1) % poly.length], kBallR + _edgeT, 0.8));
      }
    }
    _segCount = list.length;
    _seg = Float64List(_segCount * 8);
    for (var i = 0; i < _segCount; i++) {
      final (a, b, reach, e) = list[i];
      final dx = b.dx - a.dx, dy = b.dy - a.dy;
      final l2 = dx * dx + dy * dy;
      _seg
        ..[i * 8] = a.dx
        ..[i * 8 + 1] = a.dy
        ..[i * 8 + 2] = dx
        ..[i * 8 + 3] = dy
        ..[i * 8 + 4] = l2 > 0 ? 1 / l2 : 0
        ..[i * 8 + 5] = reach
        ..[i * 8 + 6] = e;
    }
    final starts = Int32List(_gw * _gh + 1);
    final segs = <int>[];
    const slack = _cell * 0.7072 + 2;
    for (var cy = 0; cy < _gh; cy++) {
      for (var cx = 0; cx < _gw; cx++) {
        starts[cy * _gw + cx] = segs.length;
        final px = (cx + 0.5) * _cell, py = (cy + 0.5) * _cell;
        for (var i = 0; i < _segCount; i++) {
          final reach = _seg[i * 8 + 5] + slack;
          if (_segDist2(i, px, py) <= reach * reach) segs.add(i);
        }
      }
    }
    starts[_gw * _gh] = segs.length;
    _cellStart = starts;
    _cellSegs = Int32List.fromList(segs);
  }

  double _segDist2(int i, double x, double y) {
    final o = i * 8;
    final ax = _seg[o], ay = _seg[o + 1], dx = _seg[o + 2], dy = _seg[o + 3];
    var t = ((x - ax) * dx + (y - ay) * dy) * _seg[o + 4];
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    final ex = x - (ax + t * dx), ey = y - (ay + t * dy);
    return ex * ex + ey * ey;
  }

  void _buildZones() {
    final w = kPuttW.toInt(), h = kPuttH.toInt();
    final g = Int8List(w * h)..fillRange(0, w * h, -1);
    for (var z = 0; z < _zones.length; z++) {
      final zone = _zones[z];
      final r = zone.rect;
      final x0 = max(0, r.left.floor()), x1 = min(w - 1, r.right.ceil());
      final y0 = max(0, r.top.floor()), y1 = min(h - 1, r.bottom.ceil());
      for (var y = y0; y <= y1; y++) {
        for (var x = x0; x <= x1; x++) {
          if (zone.contains(x + 0.5, y + 0.5)) g[y * w + x] = z;
        }
      }
    }
    _zoneGrid = g;
  }

  int _zoneAt(double x, double y) {
    var ix = x.floor(), iy = y.floor();
    if (ix < 0) ix = 0;
    if (ix > 99) ix = 99;
    if (iy < 0) iy = 0;
    if (iy > 159) iy = 159;
    return _zoneGrid[iy * 100 + ix];
  }

  PuttSurface surfaceAt(double x, double y) {
    final z = _zoneAt(x, y);
    return z < 0 ? PuttSurface.grass : _zones[z].kind;
  }

  bool _blockedAt(double x, double y) {
    for (final poly in [...hole.voids, ...hole.blocks]) {
      if (_pointInPoly(poly, x, y)) return true;
    }
    final c = _cellOf(x, y);
    for (var k = _cellStart[c]; k < _cellStart[c + 1]; k++) {
      final i = _cellSegs[k];
      final reach = _seg[i * 8 + 5];
      if (_segDist2(i, x, y) < reach * reach) return true;
    }
    return surfaceAt(x, y) == PuttSurface.water;
  }

  void _buildDistance() {
    final n = _dw * _dh;
    final free = Uint8List(n);
    final sand = Uint8List(n);
    for (var j = 0; j < _dh; j++) {
      for (var i = 0; i < _dw; i++) {
        final x = (i + 0.5) * _dg, y = (j + 0.5) * _dg;
        if (!_blockedAt(x, y)) free[j * _dw + i] = 1;
        if (surfaceAt(x, y) == PuttSurface.sand) sand[j * _dw + i] = 1;
      }
    }
    final dist = Int32List(n)..fillRange(0, n, _unreachable);
    final ci = (hole.cup.dx / _dg).floor().clamp(0, _dw - 1);
    final cj = (hole.cup.dy / _dg).floor().clamp(0, _dh - 1);
    // Dial's algorithm with small integer costs (2 straight, 3 diagonal).
    final buckets = <List<int>>[];
    void push(int cell, int d) {
      while (buckets.length <= d) {
        buckets.add(<int>[]);
      }
      buckets[d].add(cell);
    }

    dist[cj * _dw + ci] = 0;
    free[cj * _dw + ci] = 1;
    push(cj * _dw + ci, 0);
    for (var d = 0; d < buckets.length; d++) {
      for (var k = 0; k < buckets[d].length; k++) {
        final cell = buckets[d][k];
        if (dist[cell] != d) continue;
        final i = cell % _dw, j = cell ~/ _dw;
        for (var dj = -1; dj <= 1; dj++) {
          for (var di = -1; di <= 1; di++) {
            if (di == 0 && dj == 0) continue;
            final ii = i + di, jj = j + dj;
            if (ii < 0 || jj < 0 || ii >= _dw || jj >= _dh) continue;
            final nc = jj * _dw + ii;
            if (free[nc] == 0) continue;
            if (di != 0 && dj != 0) {
              if (free[j * _dw + ii] == 0 || free[jj * _dw + i] == 0) continue;
            }
            final nd = d + (di != 0 && dj != 0 ? 3 : 2) + sand[nc] * 3;
            if (nd < dist[nc]) {
              dist[nc] = nd;
              push(nc, nd);
            }
          }
        }
      }
    }
    _dist = dist;
  }

  /// Path distance (≈ course units) from (x, y) to the cup.
  int distanceAt(double x, double y) {
    final i = (x / _dg).floor().clamp(0, _dw - 1);
    final j = (y / _dg).floor().clamp(0, _dh - 1);
    return _dist[j * _dw + i];
  }

  int _cellOf(double x, double y) {
    var cx = (x / _cell).floor(), cy = (y / _cell).floor();
    if (cx < 0) cx = 0;
    if (cx >= _gw) cx = _gw - 1;
    if (cy < 0) cy = 0;
    if (cy >= _gh) cy = _gh - 1;
    return cy * _gw + cx;
  }

  PuttBall launch(double x, double y, PuttShot s) {
    final v = s.power.clamp(0.0, 1.0) * kPuttMaxSpeed;
    return PuttBall(x, y, cos(s.angle) * v, sin(s.angle) * v);
  }

  /// Simulates a whole shot until the ball stops, sinks or hits water.
  PuttBall shoot(double x, double y, PuttShot s) {
    final b = launch(x, y, s);
    while (b.state == PuttState.rolling) {
      step(b);
    }
    return b;
  }

  /// Advances the ball by one fixed time step [kPuttDt].
  void step(PuttBall b) {
    if (b.state != PuttState.rolling) return;
    var x = b.x, y = b.y, vx = b.vx, vy = b.vy;
    var c = 26.0, k = 0.5, ax = 0.0, ay = 0.0;
    final zi = _zoneAt(x, y);
    if (zi >= 0) {
      final z = _zones[zi];
      switch (z.kind) {
        case PuttSurface.water:
          b.state = PuttState.water;
          b.vx = b.vy = 0;
          return;
        case PuttSurface.sand:
          c = 120;
          k = 2.5;
        case PuttSurface.ice:
          c = 6;
          k = 0.12;
        case PuttSurface.slope:
          ax = z.fx;
          ay = z.fy;
        case PuttSurface.grass:
          break;
      }
    }
    final m = hole.magnet;
    if (m != null) {
      final dx = m.dx - x, dy = m.dy - y;
      final d2 = dx * dx + dy * dy;
      if (d2 < _magnetR * _magnetR) {
        final d = sqrt(d2);
        if (d < 1.2 && vx * vx + vy * vy < 400) {
          b
            ..x = m.dx
            ..y = m.dy
            ..vx = 0
            ..vy = 0
            ..state = PuttState.stopped;
          b.steps++;
          return;
        }
        if (d > 1e-9) {
          final a = _magnetF * (1 - d / _magnetR) / d;
          ax += dx * a;
          ay += dy * a;
        }
        k += 1.2;
      }
    }
    vx += ax * kPuttDt;
    vy += ay * kPuttDt;
    var sp = sqrt(vx * vx + vy * vy);
    if (sp > 0) {
      final ns = sp - (c + k * sp) * kPuttDt;
      if (ns <= 0) {
        vx = vy = 0;
        sp = 0;
      } else {
        final f = ns / sp;
        vx *= f;
        vy *= f;
        sp = ns;
      }
    }
    x += vx * kPuttDt;
    y += vy * kPuttDt;

    var hit = false;
    final cell = _cellOf(x, y);
    final end = _cellStart[cell + 1];
    final seg = _seg;
    for (var q = _cellStart[cell]; q < end; q++) {
      final o = _cellSegs[q] * 8;
      final sax = seg[o], say = seg[o + 1], sdx = seg[o + 2], sdy = seg[o + 3];
      var t = ((x - sax) * sdx + (y - say) * sdy) * seg[o + 4];
      if (t < 0) t = 0;
      if (t > 1) t = 1;
      final px = sax + t * sdx, py = say + t * sdy;
      final ex = x - px, ey = y - py;
      final d2 = ex * ex + ey * ey;
      final reach = seg[o + 5];
      if (d2 >= reach * reach || d2 < 1e-12) continue;
      final d = sqrt(d2);
      final nx = ex / d, ny = ey / d;
      x = px + nx * reach;
      y = py + ny * reach;
      final vn = vx * nx + vy * ny;
      if (vn < 0) {
        final e = 1 + seg[o + 6];
        vx -= e * vn * nx;
        vy -= e * vn * ny;
      }
      hit = true;
    }
    b
      ..x = x
      ..y = y
      ..vx = vx
      ..vy = vy;
    b.steps++;

    final cx = x - hole.cup.dx, cy = y - hole.cup.dy;
    if (cx * cx + cy * cy < kCupR * kCupR && sp < _captureSpeed) {
      b
        ..x = hole.cup.dx
        ..y = hole.cup.dy
        ..vx = 0
        ..vy = 0
        ..state = PuttState.sunk;
      return;
    }
    final v2 = vx * vx + vy * vy;
    if (v2 < _stopSpeed * _stopSpeed && (ax * ax + ay * ay <= c * c || hit)) {
      b
        ..vx = 0
        ..vy = 0
        ..state = PuttState.stopped;
    } else if (b.steps >= kPuttMaxSteps) {
      b
        ..vx = 0
        ..vy = 0
        ..state = PuttState.stopped;
    }
  }

  /// First wall hit along a ray (for the aiming guide): hit point and the
  /// reflected direction, or null within [maxLen].
  (Offset, Offset)? rayHit(
    double x,
    double y,
    double dx,
    double dy, {
    double maxLen = 220,
  }) {
    const stepLen = 0.5;
    for (var s = stepLen; s <= maxLen; s += stepLen) {
      final px = x + dx * s, py = y + dy * s;
      final cell = _cellOf(px, py);
      for (var q = _cellStart[cell]; q < _cellStart[cell + 1]; q++) {
        final i = _cellSegs[q];
        final o = i * 8;
        final reach = _seg[o + 5];
        if (_segDist2(i, px, py) < reach * reach) {
          var t =
              ((px - _seg[o]) * _seg[o + 2] +
                  (py - _seg[o + 1]) * _seg[o + 3]) *
              _seg[o + 4];
          t = t.clamp(0.0, 1.0);
          final cx = _seg[o] + t * _seg[o + 2],
              cy = _seg[o + 1] + t * _seg[o + 3];
          var nx = px - cx, ny = py - cy;
          final l = sqrt(nx * nx + ny * ny);
          if (l < 1e-9) return null;
          nx /= l;
          ny /= l;
          final vn = dx * nx + dy * ny;
          return (Offset(px, py), Offset(dx - 2 * vn * nx, dy - 2 * vn * ny));
        }
      }
    }
    return null;
  }

  static const powers = [0.12, 0.2, 0.29, 0.39, 0.5, 0.63, 0.8, 1.0];

  /// Beam search over discretised shots ([angles] × [powers]). Returns the
  /// first (fewest-strokes) sinking plan found, or else the plan to the
  /// state closest to the cup with `sunk == false`.
  PuttPlan search(
    double sx,
    double sy, {
    required int maxDepth,
    required int beam,
    int angles = 72,
    List<double> powers = powers,
  }) {
    final xs = <double>[sx], ys = <double>[sy];
    final parent = <int>[-1];
    final shots = <PuttShot?>[null];
    int bucket(double x, double y) =>
        (y / 2.5).floor() * 1000 + (x / 2.5).floor();
    final seen = <int>{bucket(sx, sy)};
    var frontier = [0];
    var best = 0;
    var bestScore = distanceAt(sx, sy);

    PuttPlan plan(int node, bool sunk) {
      final s = <PuttShot>[], st = <Offset>[];
      for (var n = node; parent[n] >= 0; n = parent[n]) {
        s.add(shots[n]!);
        st.add(Offset(xs[parent[n]], ys[parent[n]]));
      }
      return PuttPlan(s.reversed.toList(), st.reversed.toList(), sunk);
    }

    for (var depth = 1; depth <= maxDepth; depth++) {
      final next = <int>[];
      final score = <int, int>{};
      for (final n in frontier) {
        for (var a = 0; a < angles; a++) {
          final ang = a * 2 * pi / angles;
          for (final p in powers) {
            final shot = PuttShot(ang, p);
            final b = shoot(xs[n], ys[n], shot);
            if (b.state == PuttState.water) continue;
            if (b.state == PuttState.sunk) {
              xs.add(b.x);
              ys.add(b.y);
              parent.add(n);
              shots.add(shot);
              return plan(xs.length - 1, true);
            }
            if (!seen.add(bucket(b.x, b.y))) continue;
            final dist = distanceAt(b.x, b.y);
            if (dist >= _unreachable) continue;
            xs.add(b.x);
            ys.add(b.y);
            parent.add(n);
            shots.add(shot);
            final id = xs.length - 1;
            next.add(id);
            score[id] = dist;
            if (dist < bestScore) {
              bestScore = dist;
              best = id;
            }
          }
        }
      }
      next.sort((p, q) {
        final c = score[p]!.compareTo(score[q]!);
        return c != 0 ? c : p.compareTo(q);
      });
      frontier = next.take(beam).toList();
      if (frontier.isEmpty) break;
    }
    return plan(best, false);
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PuttGame extends StatefulWidget {
  const PuttGame({super.key, required this.session});
  final GameSession session;

  @override
  State<PuttGame> createState() => _PuttGameState();
}

class _PuttGameState extends State<PuttGame>
    with SingleTickerProviderStateMixin {
  late final PuttHole _hole = PuttHole.generate(
    widget.session.difficulty,
    widget.session.level,
    widget.session.seed,
  );
  late final Ticker _ticker = createTicker(_tick);

  late Offset _ball = _hole.tee;
  Offset _shotFrom = Offset.zero;
  PuttBall? _rolling;
  int _stepsDone = 0;
  final List<Offset> _trail = [];

  int _strokes = 0;
  bool _over = false;
  double _ballScale = 1;
  Offset? _splash;

  // Aiming (course units).
  Offset? _dragStart;
  PuttShot? _aim;

  PuttShot? _hint;
  Timer? _hintTimer;
  bool _hintPending = false;

  @override
  void initState() {
    super.initState();
    widget.session.hint.addListener(_onHint);
    if (widget.session.demo && _hole.solution.isNotEmpty) {
      // Screenshot mode: ball mid-course after one stroke, aim drawn.
      final k = _hole.solution.length >= 2 ? 1 : 0;
      _ball = _hole.solutionStarts[k];
      _strokes = k;
      final s = _hole.solution[k];
      _aim = PuttShot(s.angle, s.power);
    }
  }

  @override
  void dispose() {
    widget.session.hint.removeListener(_onHint);
    _hintTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  // ---- hints ----

  void _onHint() {
    if (_over) return;
    if (_rolling != null || _splash != null) {
      _hintPending = true;
      return;
    }
    _showHint();
  }

  void _showHint() {
    PuttShot? shot;
    for (var k = 0; k < _hole.solutionStarts.length; k++) {
      if ((_hole.solutionStarts[k] - _ball).distanceSquared < 1e-12) {
        shot = _hole.solution[k];
        break;
      }
    }
    if (shot == null) {
      final plan = _hole.sim.search(
        _ball.dx,
        _ball.dy,
        maxDepth: 3,
        beam: 4,
        angles: 48,
        powers: const [0.12, 0.2, 0.29, 0.39, 0.5, 0.63, 0.8, 1.0],
      );
      if (plan.shots.isNotEmpty) shot = plan.shots.first;
    }
    if (shot == null) return;
    _hintTimer?.cancel();
    setState(() => _hint = shot);
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  // ---- shooting ----

  void _shoot(PuttShot s) {
    _strokes++;
    if (_strokes > _hole.par) widget.session.addMistake();
    _shotFrom = _ball;
    _rolling = _hole.sim.launch(_ball.dx, _ball.dy, s);
    _stepsDone = 0;
    _trail.clear();
    _hint = null;
    _hintTimer?.cancel();
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final b = _rolling;
    if (b == null) return;
    final due = (elapsed.inMicroseconds / 1e6 / kPuttDt).floor();
    var n = 0;
    while (_stepsDone < due && b.state == PuttState.rolling && n < 40) {
      _hole.sim.step(b);
      _stepsDone++;
      n++;
      if (_stepsDone % 4 == 0) {
        _trail.add(Offset(b.x, b.y));
        if (_trail.length > 14) _trail.removeAt(0);
      }
    }
    setState(() => _ball = Offset(b.x, b.y));
    if (b.state != PuttState.rolling) {
      _ticker.stop();
      _rolling = null;
      _settle(b.state);
    }
  }

  void _settle(PuttState state) {
    switch (state) {
      case PuttState.sunk:
        _over = true;
        _trail.clear();
        _sinkAnim();
        Future.delayed(const Duration(milliseconds: 650), () {
          widget.session.onWin();
        });
        return;
      case PuttState.water:
        setState(() {
          _splash = _ball;
          _trail.clear();
        });
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            _splash = null;
            _ball = _shotFrom;
            _strokes++; // penalty stroke
          });
          if (_strokes > _hole.par) widget.session.addMistake();
          _afterShot();
        });
        return;
      case PuttState.stopped:
      case PuttState.rolling:
        setState(_trail.clear);
        _afterShot();
    }
  }

  void _afterShot() {
    if (_over) return;
    if (_strokes >= _hole.par + 5) {
      _over = true;
      widget.session.onFail();
      return;
    }
    if (_hintPending) {
      _hintPending = false;
      _showHint();
    }
  }

  Future<void> _sinkAnim() async {
    for (var i = 1; i <= 8; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => _ballScale = 1 - i / 8);
    }
  }

  // ---- gestures ----

  bool get _canAim => !_over && _rolling == null && _splash == null;

  void _panStart(Offset course) {
    if (!_canAim) return;
    _dragStart = course;
    setState(() => _aim = null);
  }

  void _panUpdate(Offset course) {
    final s = _dragStart;
    if (s == null || !_canAim) return;
    final pull = s - course; // slingshot: shoot opposite the drag
    final len = pull.distance;
    setState(() {
      _aim = len < 1
          ? null
          : PuttShot(atan2(pull.dy, pull.dx), min(1.0, len / kPuttDragMax));
    });
  }

  void _panEnd() {
    final a = _aim;
    _dragStart = null;
    setState(() => _aim = null);
    if (a == null || !_canAim || a.power < 0.05) return;
    _shoot(a);
  }

  static String _strokesWord() {
    var lang = PlatformDispatcher.instance.locale.languageCode;
    if (kIsWeb) lang = Uri.base.queryParameters['lang'] ?? lang;
    return switch (lang) {
      'es' => 'Golpes',
      'pt' => 'Tacadas',
      'vi' => 'Số gậy',
      'id' => 'Pukulan',
      'de' => 'Schläge',
      'ja' => '打数',
      _ => 'Strokes',
    };
  }

  @override
  Widget build(BuildContext context) {
    final over = _strokes > _hole.par;
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_golf, size: 24),
                const SizedBox(width: 6),
                Text(
                  '${_strokesWord()} $_strokes · Par ${_hole.par}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: over ? Colors.red.shade700 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Center(
              child: AspectRatio(
                aspectRatio: kPuttW / kPuttH,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final scale = box.maxWidth / kPuttW;
                    Offset toCourse(Offset p) => p / scale;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => _panStart(toCourse(d.localPosition)),
                      onPanUpdate: (d) => _panUpdate(toCourse(d.localPosition)),
                      onPanEnd: (_) => _panEnd(),
                      onPanCancel: _panEnd,
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size(box.maxWidth, box.maxHeight),
                          painter: _CoursePainter(_hole),
                          foregroundPainter: _BallPainter(
                            hole: _hole,
                            ball: _ball,
                            ballScale: _ballScale,
                            aim: _aim,
                            hint: _hint,
                            trail: List.of(_trail),
                            splash: _splash,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painting
// ---------------------------------------------------------------------------

const _hedge = Color(0xFF2F5D2B);
const _grassA = Color(0xFF7BC950);
const _grassB = Color(0xFF71BF47);
const _wallFill = Color(0xFF7A5545);
const _wallEdge = Color(0xFF5B3B2F);
const _wallTop = Color(0xFFA27D68);
const _sandC = Color(0xFFEAD7A2);
const _waterC = Color(0xFF3D9BE9);
const _iceC = Color(0xFFD3F3FA);
const _slopeC = Color(0xFF62B43F);
const _bumperC = Color(0xFFE53970);

class _CoursePainter extends CustomPainter {
  _CoursePainter(this.hole);
  final PuttHole hole;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / kPuttW;
    canvas.save();
    canvas.scale(s);
    final court = Rect.fromLTWH(0, 0, kPuttW, kPuttH);
    canvas.clipRRect(RRect.fromRectAndRadius(court, const Radius.circular(3)));

    // Grass with mowing stripes.
    canvas.drawRect(court, Paint()..color = _grassA);
    final stripe = Paint()..color = _grassB;
    for (var y = 0.0; y < kPuttH; y += 20) {
      canvas.drawRect(Rect.fromLTWH(0, y, kPuttW, 10), stripe);
    }

    for (final z in hole.zones) {
      _zone(canvas, z, s);
    }
    _magnet(canvas);

    // Tee mat.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: hole.tee, width: 9, height: 6),
        const Radius.circular(1.2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // Shadows first, then walls on top.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    const so = Offset(0.7, 1.1);
    for (final v in hole.voids) {
      canvas.drawPath(_path(v).shift(so), shadow..style = PaintingStyle.fill);
    }
    for (final b in hole.blocks) {
      canvas.drawPath(_path(b).shift(so), shadow..style = PaintingStyle.fill);
    }
    for (final w in hole.walls) {
      canvas.drawLine(
        w.a + so,
        w.b + so,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..strokeWidth = w.thick * 2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }

    for (final v in hole.voids) {
      final p = _path(v);
      canvas.drawPath(p, Paint()..color = _hedge);
      _hedgeDots(canvas, v);
      canvas.drawPath(
        p,
        Paint()
          ..color = _wallFill
          ..style = PaintingStyle.stroke
          ..strokeWidth = _edgeT * 2
          ..strokeJoin = StrokeJoin.round,
      );
    }
    for (final b in hole.blocks) {
      final p = _path(b);
      canvas.drawPath(p, Paint()..color = _wallFill);
      canvas.drawPath(
        p,
        Paint()
          ..color = _wallEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = _edgeT * 2
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        p.shift(const Offset(-0.3, -0.4)),
        Paint()
          ..color = _wallTop.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
    for (final w in hole.walls) {
      canvas.drawLine(
        w.a,
        w.b,
        Paint()
          ..color = w.bumper ? _bumperC : _wallFill
          ..strokeWidth = w.thick * 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        w.a,
        w.b,
        Paint()
          ..color = w.bumper
              ? Colors.white.withValues(alpha: 0.85)
              : _wallTop.withValues(alpha: 0.7)
          ..strokeWidth = w.bumper ? 0.6 : w.thick * 0.7
          ..strokeCap = StrokeCap.round,
      );
    }

    _cup(canvas);
    canvas.restore();
  }

  Path _path(List<Offset> poly) => Path()..addPolygon(poly, true);

  void _hedgeDots(Canvas canvas, List<Offset> poly) {
    final p = Paint()..color = Colors.black.withValues(alpha: 0.12);
    canvas.save();
    canvas.clipPath(_path(poly));
    for (var y = 2.0; y < kPuttH; y += 5) {
      for (var x = (y ~/ 5).isEven ? 2.0 : 4.5; x < kPuttW; x += 5) {
        canvas.drawCircle(Offset(x, y), 1.1, p);
      }
    }
    canvas.restore();
  }

  void _zone(Canvas canvas, PuttZone z, double s) {
    final shape = z.circle
        ? (Path()..addOval(z.rect))
        : (Path()..addRRect(
            RRect.fromRectAndRadius(z.rect, const Radius.circular(3)),
          ));
    switch (z.kind) {
      case PuttSurface.sand:
        canvas.drawPath(shape, Paint()..color = _sandC);
        canvas.save();
        canvas.clipPath(shape);
        final dot = Paint()..color = const Color(0xFFC9B07A);
        final r = z.rect;
        var i = 0;
        for (var y = r.top + 1; y < r.bottom; y += 2.6) {
          for (
            var x = r.left + ((i++).isEven ? 1 : 2.3);
            x < r.right;
            x += 2.6
          ) {
            canvas.drawCircle(Offset(x, y), 0.32, dot);
          }
        }
        canvas.restore();
        canvas.drawPath(
          shape,
          Paint()
            ..color = const Color(0xFFD9C185)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
      case PuttSurface.water:
        canvas.drawPath(shape, Paint()..color = _waterC);
        canvas.save();
        canvas.clipPath(shape);
        final wave = Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..strokeCap = StrokeCap.round;
        final r = z.rect;
        var row = 0;
        for (var y = r.top + 2.5; y < r.bottom; y += 4) {
          for (var x = r.left + (row.isEven ? 1.0 : 3.5); x < r.right; x += 6) {
            final p = Path()
              ..moveTo(x, y)
              ..quadraticBezierTo(x + 1, y - 0.9, x + 2, y)
              ..quadraticBezierTo(x + 3, y + 0.9, x + 4, y);
            canvas.drawPath(p, wave);
          }
          row++;
        }
        canvas.restore();
        canvas.drawPath(
          shape,
          Paint()
            ..color = const Color(0xFF1E6FB8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7,
        );
      case PuttSurface.ice:
        canvas.drawPath(shape, Paint()..color = _iceC);
        canvas.save();
        canvas.clipPath(shape);
        final streak = Paint()
          ..color = Colors.white
          ..strokeWidth = 0.6
          ..strokeCap = StrokeCap.round;
        final r = z.rect;
        for (var x = r.left - r.height; x < r.right; x += 7) {
          canvas.drawLine(
            Offset(x, r.bottom - 1),
            Offset(x + 4, r.bottom - 5),
            streak,
          );
          canvas.drawLine(
            Offset(x + 3, r.top + 6),
            Offset(x + 6, r.top + 3),
            streak,
          );
        }
        canvas.restore();
        canvas.drawPath(
          shape,
          Paint()
            ..color = const Color(0xFF8FD3E3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
      case PuttSurface.slope:
        canvas.drawPath(shape, Paint()..color = _slopeC);
        canvas.save();
        canvas.clipPath(shape);
        final arrow = Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final len = sqrt(z.fx * z.fx + z.fy * z.fy);
        final ux = z.fx / len, uy = z.fy / len;
        final r = z.rect;
        for (var y = r.top + 4; y < r.bottom - 1; y += 6) {
          for (var x = r.left + 4; x < r.right - 1; x += 6) {
            final c = Offset(x, y);
            final tip = c + Offset(ux, uy) * 1.6;
            final back = c - Offset(ux, uy) * 0.6;
            final side = Offset(-uy, ux) * 1.6;
            canvas.drawPath(
              Path()
                ..moveTo(back.dx + side.dx, back.dy + side.dy)
                ..lineTo(tip.dx, tip.dy)
                ..lineTo(back.dx - side.dx, back.dy - side.dy),
              arrow,
            );
          }
        }
        canvas.restore();
        canvas.drawPath(
          shape,
          Paint()
            ..color = const Color(0xFF4E9A2F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
      case PuttSurface.grass:
        break;
    }
  }

  void _magnet(Canvas canvas) {
    final m = hole.magnet;
    if (m == null) return;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    for (var r = 4.0; r <= _magnetR; r += 3) {
      ring.color = const Color(
        0xFFB0306A,
      ).withValues(alpha: 0.35 * (1 - r / 16));
      canvas.drawCircle(m, r, ring);
    }
    // Horseshoe magnet.
    final shoe = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: m + const Offset(0, 0.4), radius: 1.9),
      0,
      pi,
      false,
      shoe,
    );
    canvas.drawLine(
      m + const Offset(-1.9, 0.4),
      m + const Offset(-1.9, -1.6),
      shoe,
    );
    canvas.drawLine(
      m + const Offset(1.9, 0.4),
      m + const Offset(1.9, -1.6),
      shoe,
    );
    final tip = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1.3;
    canvas.drawLine(
      m + const Offset(-1.9, -1.6),
      m + const Offset(-1.9, -2.6),
      tip,
    );
    canvas.drawLine(
      m + const Offset(1.9, -1.6),
      m + const Offset(1.9, -2.6),
      tip,
    );
  }

  void _cup(Canvas canvas) {
    final c = hole.cup;
    canvas.drawCircle(c, kCupR + 0.5, Paint()..color = const Color(0xFF5EA83C));
    canvas.drawCircle(c, kCupR, Paint()..color = const Color(0xFF1B1B1B));
    canvas.drawCircle(
      c + const Offset(0.5, 0.6),
      kCupR - 0.9,
      Paint()..color = const Color(0xFF000000),
    );
    // Flag pole (leaning up-right) with its shadow on the grass.
    final top = c + const Offset(1.2, -15);
    canvas.drawLine(
      c,
      c + const Offset(8, -7),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      c,
      top,
      Paint()
        ..color = const Color(0xFFF5F5F5)
        ..strokeWidth = 0.7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..lineTo(top.dx + 7, top.dy + 2.2)
        ..lineTo(top.dx + 0.15, top.dy + 4.6)
        ..close(),
      Paint()..color = const Color(0xFFE53935),
    );
  }

  @override
  bool shouldRepaint(_CoursePainter old) => old.hole != hole;
}

class _BallPainter extends CustomPainter {
  _BallPainter({
    required this.hole,
    required this.ball,
    required this.ballScale,
    required this.aim,
    required this.hint,
    required this.trail,
    required this.splash,
  });

  final PuttHole hole;
  final Offset ball;
  final double ballScale;
  final PuttShot? aim, hint;
  final List<Offset> trail;
  final Offset? splash;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / kPuttW;
    canvas.save();
    canvas.scale(s);

    // Rolling trail.
    for (var i = 0; i < trail.length; i++) {
      canvas.drawCircle(
        trail[i],
        kBallR * 0.55 * (i + 1) / trail.length,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.25 * (i + 1) / trail.length,
          ),
      );
    }

    final h = hint;
    if (h != null) _ghost(canvas, h);
    final a = aim;
    if (a != null) _aim(canvas, a);

    final sp = splash;
    if (sp != null) {
      final ring = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      canvas.drawCircle(sp, 2.5, ring);
      canvas.drawCircle(
        sp,
        4.5,
        ring..color = Colors.white.withValues(alpha: 0.45),
      );
    } else if (ballScale > 0) {
      final r = kBallR * ballScale;
      canvas.drawCircle(
        ball + const Offset(0.5, 0.8),
        r,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
      );
      canvas.drawCircle(
        ball,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            colors: const [Colors.white, Color(0xFFDADADA)],
          ).createShader(Rect.fromCircle(center: ball, radius: r)),
      );
    }
    canvas.restore();
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint p) {
    final d = b - a;
    final len = d.distance;
    if (len < 1e-6) return;
    final u = d / len;
    for (var t = 0.0; t < len; t += 3) {
      canvas.drawLine(a + u * t, a + u * min(len, t + 1.7), p);
    }
  }

  void _aim(Canvas canvas, PuttShot a) {
    final u = Offset(cos(a.angle), sin(a.angle));
    final color = Color.lerp(
      const Color(0xFFFFFFFF),
      const Color(0xFFFF3D00),
      a.power,
    )!;
    final line = Paint()
      ..color = color
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round;
    final start = ball + u * (kBallR + 1);

    // Slingshot band back towards the finger.
    final back = ball - u * (a.power * kPuttDragMax);
    canvas.drawLine(
      ball,
      back,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..strokeWidth = 0.6,
    );
    canvas.drawCircle(
      back,
      1.2,
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );

    switch (hole.difficulty) {
      case 0: // to the first wall and a short stub after the bounce
        final hit = hole.sim.rayHit(ball.dx, ball.dy, u.dx, u.dy);
        if (hit == null) {
          _dashed(canvas, start, ball + u * 60, line);
        } else {
          _dashed(canvas, start, hit.$1, line);
          _dashed(
            canvas,
            hit.$1,
            hit.$1 + hit.$2 * 12,
            line..color = color.withValues(alpha: 0.5),
          );
        }
      case 1:
      case 2: // up to the first wall, no bounce
        final hit = hole.sim.rayHit(ball.dx, ball.dy, u.dx, u.dy, maxLen: 70);
        _dashed(canvas, start, hit?.$1 ?? ball + u * 70, line);
      default: // expert: just a short arrow
        final end = ball + u * (kBallR + 6 + 12 * a.power);
        _dashed(canvas, start, end, line);
        _arrowHead(canvas, end, u, line);
    }

    // Power meter: arc around the ball.
    final meter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: ball, radius: kBallR + 2.6);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi,
      false,
      meter..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * a.power,
      false,
      meter..color = color,
    );
  }

  void _arrowHead(Canvas canvas, Offset tip, Offset u, Paint p) {
    final side = Offset(-u.dy, u.dx) * 1.5;
    final back = tip - u * 2.2;
    canvas.drawLine(tip, back + side, p);
    canvas.drawLine(tip, back - side, p);
  }

  void _ghost(Canvas canvas, PuttShot h) {
    final u = Offset(cos(h.angle), sin(h.angle));
    const gold = Color(0xFFFFD54F);
    final p = Paint()
      ..color = gold.withValues(alpha: 0.9)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final tip = ball + u * (kBallR + 6 + 22 * h.power);
    canvas.drawLine(ball + u * (kBallR + 1), tip, p);
    _arrowHead(canvas, tip, u, p);
    // Where to pull the finger to (relative to the ball).
    final pull = ball - u * (h.power * kPuttDragMax);
    _dashed(
      canvas,
      ball - u * (kBallR + 1),
      pull,
      Paint()
        ..color = gold.withValues(alpha: 0.7)
        ..strokeWidth = 0.6,
    );
    canvas.drawCircle(
      pull,
      2.2,
      Paint()
        ..color = gold.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    canvas.drawCircle(pull, 0.8, Paint()..color = gold);
  }

  @override
  bool shouldRepaint(_BallPainter old) => true;
}
