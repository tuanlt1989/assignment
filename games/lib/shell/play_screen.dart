import 'dart:async';

import 'package:flutter/material.dart';

import '../games/session.dart';
import '../main.dart';
import '../meta.dart';
import '../progress.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.difficulty,
    required this.level,
    this.daily,
    this.demo = false,
  });

  final int difficulty;
  final int level;

  /// Set for the daily puzzle (today or an archive day).
  final DailySpec? daily;

  /// Store-screenshot mode: nothing is recorded.
  final bool demo;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _attempt = 0;
  GameSession? _session;
  int _hintsUsed = 0;
  final _clock = Stopwatch();
  Timer? _tick;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _clock.start();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_done) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowRules());
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _maybeShowRules() {
    final app = GameApp.of(context);
    if (widget.demo || app.progress.seenRules) return;
    app.progress.markRulesSeen();
    showRules(context);
  }

  GameSession _newSession(GameApp app) => GameSession(
    difficulty: widget.difficulty,
    level: widget.level,
    seed: widget.daily?.seed ?? levelSeed(widget.difficulty, widget.level),
    onWin: () => _onWin(app),
    onFail: () => _onFail(app),
    demo: widget.demo,
  );

  void _restart() => setState(() {
    _attempt++;
    _session = null;
    _hintsUsed = 0;
    _clock
      ..reset()
      ..start();
  });

  Future<void> _onWin(GameApp app) async {
    if (_done) return;
    _done = true;
    _clock.stop();
    final t = app.t;
    final p = app.progress;
    final ms = _clock.elapsedMilliseconds;
    final stars = GameProgress.starsFor(
      mistakes: _session?.mistakes.value ?? 0,
      hintsUsed: _hintsUsed,
    );
    final prevBest = p.bestMs[widget.difficulty];
    final newBest = prevBest == 0 || ms < prevBest;
    if (!widget.demo) {
      p.recordWin(
        difficulty: widget.difficulty,
        level: widget.level,
        day: widget.daily?.key,
        ms: ms,
        starCount: stars,
        hintsUsed: _hintsUsed,
      );
      app.money.maybeAskReview();
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: Stars(n: stars, size: 44),
        title: Text(t.t(stars == 3 ? 'winPerfect' : 'winTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${t.t('time')}: ${fmtTime(ms)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (newBest && !widget.demo)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  t.t('newBest'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (widget.daily != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('🔥 ${t.t('streak', {'n': p.currentStreak})}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: Text(t.t('home')),
          ),
          if (widget.daily == null)
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                final nav = Navigator.of(context);
                final d = widget.difficulty;
                final n = p.next[d];
                if (!p.canStart(d, n)) {
                  nav.pop();
                  showQuotaDialog(nav.context, d);
                  return;
                }
                p.markStarted(d, n);
                nav.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PlayScreen(difficulty: d, level: n),
                  ),
                );
              },
              child: Text(t.t('next')),
            ),
        ],
      ),
    );
  }

  Future<void> _onFail(GameApp app) async {
    final t = app.t;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.sentiment_dissatisfied, size: 48),
        title: Text(t.t('failTitle')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: Text(t.t('home')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              _restart();
            },
            child: Text(t.t('retry')),
          ),
        ],
      ),
    );
  }

  void _useHint(GameApp app) {
    if (app.progress.useHint()) {
      _hintsUsed++;
      _session?.hint.value++;
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(app.t.t('hintNone')),
          action: SnackBarAction(
            label: app.t.t('unlimited'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    final session = _session ??= _newSession(app);
    final title = widget.daily != null
        ? t.t('daily')
        : '${t.diff(widget.difficulty)} · #${widget.level}';
    return ListenableBuilder(
      listenable: app.progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                widget.demo ? '1:24' : fmtTime(_clock.elapsedMilliseconds),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: t.t('howTo'),
              icon: const Icon(Icons.help_outline),
              onPressed: () => showRules(context),
            ),
            Badge(
              label: Text(app.progress.premium ? '∞' : '${app.progress.hints}'),
              offset: const Offset(-4, 4),
              child: IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                onPressed: () => _useHint(app),
              ),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _restart),
          ],
        ),
        body: SafeArea(
          child: KeyedSubtree(
            key: ValueKey(_attempt),
            child: buildGame(app.config.game, session, lang: app.lang),
          ),
        ),
      ),
    );
  }
}

void showRules(BuildContext context) {
  final app = GameApp.of(context);
  final t = app.t;
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      icon: GameBadge(
        color: Theme.of(context).colorScheme.primary,
        game: app.config.game,
        size: 56,
      ),
      title: Text(t.t('howTo')),
      content: Text(t.t('rules_${app.config.game}')),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(c),
          child: Text(t.t('gotIt')),
        ),
      ],
    ),
  );
}
