import 'package:flutter/material.dart';

import '../games/session.dart';
import '../main.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.daily, this.demoLevel});
  final bool daily;

  /// Fixed level for store screenshots (no lives are spent).
  final int? demoLevel;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _attempt = 0;
  GameSession? _session;
  int _score = 0;

  int _level(GameApp app) {
    if (widget.demoLevel != null) return widget.demoLevel!;
    if (widget.daily) {
      final d = DateTime.now();
      return 12 + (d.day + d.month) % 12;
    }
    return app.progress.level;
  }

  int _seed(GameApp app) {
    if (widget.daily) {
      final d = DateTime.now();
      return d.year * 10000 + d.month * 100 + d.day;
    }
    return _level(app) * 7919 + 17;
  }

  GameSession _newSession(GameApp app) {
    final blocks = app.config.game == 'blocks';
    return GameSession(
      level: _level(app),
      // Endless block games get a fresh seed every attempt.
      seed: blocks
          ? DateTime.now().microsecondsSinceEpoch & 0x7fffffff
          : _seed(app),
      onWin: () => _onWin(app),
      onFail: () => blocks ? _onGameOver(app) : _onFail(app),
      onScore: (s) => _score = s,
      demo: widget.demoLevel != null,
    );
  }

  void _restart() => setState(() {
    _attempt++;
    _session = null;
  });

  Future<void> _onWin(GameApp app) async {
    final t = app.t;
    if (widget.demoLevel == null) {
      app.progress.winLevel(daily: widget.daily);
      app.money.maybeAskReview();
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
        title: Text(t.t('winTitle')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: Text(t.t('home')),
          ),
          if (!widget.daily)
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlayScreen(daily: false),
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
    if (widget.demoLevel == null) app.progress.loseLife();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.sentiment_dissatisfied, size: 48),
        title: Text(t.t('failTitle')),
        content: app.progress.premium ? null : LivesChip(app: app),
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
              if (app.progress.lives > 0) {
                _restart();
              } else {
                Navigator.pop(context);
                showOutOfLives(context);
              }
            },
            child: Text(t.t('retry')),
          ),
        ],
      ),
    );
  }

  Future<void> _onGameOver(GameApp app) async {
    final t = app.t;
    app.progress.submitScore(_score);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Text(t.t('gameOver')),
        content: Text(
          '${t.t('score')}: $_score\n${t.t('best')}: ${app.progress.bestScore}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              _restart();
            },
            child: Text(t.t('newGame')),
          ),
          FilledButton.icon(
            icon: Icon(app.progress.premium ? Icons.replay : Icons.lock),
            onPressed: () {
              Navigator.pop(c);
              if (app.progress.premium) {
                _session?.revive.value++;
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                ).then((_) {
                  if (app.progress.premium) {
                    _session?.revive.value++;
                  } else {
                    _restart();
                  }
                });
              }
            },
            label: Text(t.t('revive')),
          ),
        ],
      ),
    );
  }

  /// Restarting a puzzle level costs a life, like failing it.
  void _restartTapped(GameApp app) {
    if (app.config.game == 'blocks' || widget.demoLevel != null) {
      _restart();
      return;
    }
    if (app.progress.lives <= 0) {
      showOutOfLives(context);
      return;
    }
    app.progress.loseLife();
    _restart();
  }

  void _useHint(GameApp app) {
    if (app.progress.useHint()) {
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
    final blocks = app.config.game == 'blocks';
    final session = _session ??= _newSession(app);
    return ListenableBuilder(
      listenable: app.progress,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            blocks
                ? app.title
                : widget.daily
                ? t.t('daily')
                : t.t('level', {'n': session.level}),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            if (!blocks)
              Badge(
                label: Text(
                  app.progress.premium ? '∞' : '${app.progress.hints}',
                ),
                offset: const Offset(-4, 4),
                child: IconButton(
                  tooltip: 'Hint',
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: () => _useHint(app),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _restartTapped(app),
            ),
          ],
        ),
        body: SafeArea(
          child: KeyedSubtree(
            key: ValueKey(_attempt),
            child: buildGame(app.config.game, session),
          ),
        ),
      ),
    );
  }
}
